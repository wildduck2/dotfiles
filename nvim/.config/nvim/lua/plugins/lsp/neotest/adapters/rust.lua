-- Minimal neotest adapter for cargo test (Rust).
--
-- Discovery: tree-sitter query matches `#[test]`, `#[tokio::test]`,
-- `#[async_std::test]`, and `#[rstest]` attributes followed by a
-- function_item. mod_item declarations create namespaces.
--
-- Run: `cargo test <module_path>::<name> -- --exact --nocapture
-- --test-threads=1` parsed from stable cargo human output. The JSON
-- (`-Z unstable-options --format=json`) path is skipped because it
-- requires nightly.
--
-- DAP strategy: `cargo test --no-run --message-format=json` is parsed
-- for the matching `compiler-artifact` line, then codelldb launches the
-- test binary with `--exact --nocapture <test_path>`.

local lib = require('neotest.lib')

local M = { name = 'cargo-test' }

local function cargo_workspace_root(dir)
  return lib.files.match_root_pattern('Cargo.toml')(dir)
end

function M.root(dir)
  return cargo_workspace_root(dir)
end

function M.filter_dir(name)
  return name ~= 'target' and name ~= 'node_modules' and name ~= '.git'
end

function M.is_test_file(file_path)
  if not file_path:match('%.rs$') then return false end
  local fd = io.open(file_path, 'r')
  if not fd then return false end
  local content = fd:read('*a'); fd:close()
  if not content then return false end
  return content:find('#%[test%]') ~= nil
      or content:find('#%[tokio::test%]') ~= nil
      or content:find('#%[async_std::test%]') ~= nil
      or content:find('#%[rstest%]') ~= nil
end

function M.discover_positions(file_path)
  local query = [[
    ;; Module declarations become namespaces
    (mod_item name: (identifier) @namespace.name) @namespace.definition

    ;; Test functions: #[test], #[tokio::test], #[async_std::test], #[rstest]
    ((attribute_item
       (attribute
         [(identifier) @attr (scoped_identifier path: (identifier) name: (identifier) @attr)]))
     . (function_item name: (identifier) @test.name) @test.definition
     (#any-of? @attr "test" "rstest"))
  ]]
  return lib.treesitter.parse_positions(file_path, query, {
    require_namespaces = false,
    nested_tests = true,
  })
end

-- Convert a neotest position to the cargo test filter string.
-- Position name is just the leaf; the module path is reconstructed from
-- the tree namespaces.
local function position_to_filter(tree)
  local pos = tree:data()
  if pos.type == 'file' then return nil end
  local parts = {}
  local node = tree
  while node do
    local d = node:data()
    if d.type == 'test' or d.type == 'namespace' then
      table.insert(parts, 1, d.name)
    end
    node = node:parent()
  end
  return table.concat(parts, '::')
end

-- Synchronous binary resolution. nvim-nio rejects raw coroutine.yield in
-- neotest's task context, so we block briefly on cargo here.
local function pick_test_binary(file_path)
  local out = vim.fn.system({ 'cargo', 'test', '--no-run', '--message-format=json' })
  if vim.v.shell_error ~= 0 or not out or out == '' then
    return nil, 'cargo test --no-run failed: ' .. (out or '')
  end
  local picked
  for line in out:gmatch('[^\n]+') do
    local ok, msg = pcall(vim.json.decode, line)
    if ok and msg and msg.reason == 'compiler-artifact'
        and msg.executable and msg.profile and msg.profile.test then
      if msg.target and msg.target.src_path == file_path then
        return msg.executable
      end
      picked = picked or msg.executable
    end
  end
  return picked, picked and nil or 'no test binary found'
end

function M.build_spec(args)
  local tree = args.tree
  if not tree then return end
  local pos = tree:data()
  local filter = position_to_filter(tree)

  if args.strategy == 'dap' then
    local binary, err = pick_test_binary(pos.path)
    if not binary then
      vim.notify('rust DAP: ' .. (err or 'no binary'), vim.log.levels.ERROR)
      return
    end

    local dap_args = { '--exact', '--nocapture' }
    if filter and pos.type == 'test' then table.insert(dap_args, 1, filter) end

    return {
      command = { 'true' },  -- placeholder; dap takes over
      context = { mode = 'dap' },
      strategy = {
        type = 'codelldb',
        request = 'launch',
        name = 'cargo test debug',
        program = binary,
        cwd = vim.fn.getcwd(),
        args = dap_args,
        stopOnEntry = false,
        sourceLanguages = { 'rust' },
      },
    }
  end

  local cmd = { 'cargo', 'test', '--color', 'never' }
  if filter then
    table.insert(cmd, filter)
  end
  table.insert(cmd, '--')
  table.insert(cmd, '--nocapture')
  if pos.type == 'test' then
    table.insert(cmd, '--exact')
  end
  table.insert(cmd, '--test-threads=1')

  return {
    command = cmd,
    context = { file = pos.path },
  }
end

local function strip_ansi(s)
  return (s:gsub('\27%[[%d;?]*[A-Za-z]', '')
           :gsub('\r', ''))
end

local function parse_human_output(text)
  text = strip_ansi(text or '')
  local results = {}

  -- Status lines: "test path::name ... ok|FAILED|ignored".
  -- Tolerate leading whitespace (some cargo wrappers indent) and any
  -- trailing word (test result might be `ok`, `FAILED`, `ignored`).
  for line in text:gmatch('[^\n]+') do
    local name, status = line:match('^%s*test%s+(%S+)%s+%.%.%.%s+(%a+)')
    if name and status then
      local s = 'unknown'
      local low = status:lower()
      if low == 'ok' then s = 'passed'
      elseif low == 'failed' then s = 'failed'
      elseif low == 'ignored' then s = 'skipped'
      end
      results[name] = { status = s }
    end
  end

  -- Failure bodies between `---- path::name stdout ----` markers.
  -- Body ends at the next `---- ... ----` line or a `failures:` summary.
  local idx = 1
  while true do
    local s_start, s_end, header = text:find('%-%-%-%-%s+(%S+)%s+stdout%s+%-%-%-%-', idx)
    if not s_start then break end
    local next_start = text:find('%-%-%-%-%s+%S+%s+stdout%s+%-%-%-%-', s_end + 1)
    local stop = next_start or text:find('\nfailures:', s_end + 1) or #text
    local body = text:sub(s_end + 1, stop):gsub('^%s+', ''):gsub('%s+$', '')
    if results[header] then
      results[header].message = body
      results[header].line = tonumber(body:match('panicked at[^:]+:(%d+):'))
    end
    idx = s_end + 1
  end

  return results
end

function M.results(spec, result, tree)
  local results = {}
  if spec.context and spec.context.mode == 'dap' then
    -- DAP mode does not produce parseable output; mark every test as
    -- unknown so neotest does not surface false failures.
    for _, node in tree:iter_nodes() do
      if node:data().type == 'test' then
        results[node:data().id] = { status = 'unknown' }
      end
    end
    return results
  end

  local output_path = result.output
  local content = ''
  if output_path then
    local fd = io.open(output_path, 'r')
    if fd then content = fd:read('*a'); fd:close() end
  end
  local parsed = parse_human_output(content)

  local nothing_parsed = next(parsed) == nil
  local cargo_failed = result.code ~= 0
  local has_test_header = content:match('running%s+%d+%s+tests?') ~= nil
  local compile_error = nothing_parsed and cargo_failed and not has_test_header

  for _, node in tree:iter_nodes() do
    local d = node:data()
    if d.type == 'test' then
      local key = position_to_filter(node)
      local p = key and parsed[key]
      if p then
        local entry = { status = p.status, short = p.message }
        if p.status == 'failed' and p.message then
          entry.errors = {
            { message = p.message, line = (p.line and p.line - 1) or (d.range and d.range[1] or 0) },
          }
        end
        results[d.id] = entry
      elseif compile_error then
        results[d.id] = {
          status = 'failed',
          short = 'compile error — see :NeotestOutputPanel',
          errors = {
            { message = 'cargo compile error — open <leader>TO',
              line = d.range and d.range[1] or 0 },
          },
        }
      elseif cargo_failed then
        -- cargo exited non-zero AND we know tests ran (has_test_header)
        -- AND our parser missed this specific test line — trust the exit
        -- code: this test failed. Dump the relevant failure section.
        local panic = content:match('panicked at[^\n]+\n[^\n]+')
        results[d.id] = {
          status = 'failed',
          short = panic or 'cargo test failed',
          errors = {
            { message = panic or 'see <leader>TO for full output',
              line = d.range and d.range[1] or 0 },
          },
        }
      else
        -- cargo exited 0 and parser missed → trust the exit code: passed.
        results[d.id] = { status = 'passed' }
      end
    end
  end
  return results
end

setmetatable(M, {
  __call = function(_, opts)
    M._opts = opts or {}
    return M
  end,
})

return M
