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

local function pick_test_binary(file_path, cb)
  vim.system({ 'cargo', 'test', '--no-run', '--message-format=json' },
    { text = true }, function(out)
      vim.schedule(function()
        if out.code ~= 0 or not out.stdout then
          cb(nil, 'cargo test --no-run failed: ' .. (out.stderr or ''))
          return
        end
        local picked
        for line in out.stdout:gmatch('[^\n]+') do
          local ok, msg = pcall(vim.json.decode, line)
          if ok and msg and msg.reason == 'compiler-artifact'
              and msg.executable and msg.profile and msg.profile.test then
            -- Prefer artifacts whose target src_path matches our file.
            if msg.target and msg.target.src_path == file_path then
              picked = msg.executable
              break
            end
            picked = picked or msg.executable
          end
        end
        if picked then cb(picked) else cb(nil, 'no test binary found') end
      end)
    end)
end

function M.build_spec(args)
  local tree = args.tree
  if not tree then return end
  local pos = tree:data()
  local filter = position_to_filter(tree)

  if args.strategy == 'dap' then
    -- DAP needs a binary path; this requires async resolution. Use the
    -- coroutine pattern dap.lua uses for its program callback.
    local co = coroutine.running()
    if not co then
      vim.notify('neotest-rust DAP strategy must run inside a coroutine', vim.log.levels.ERROR)
      return
    end
    pick_test_binary(pos.path, function(bin, err)
      if not bin then
        vim.notify('rust DAP: ' .. (err or 'no binary'), vim.log.levels.ERROR)
        coroutine.resume(co, nil)
      else
        coroutine.resume(co, bin)
      end
    end)
    local binary = coroutine.yield()
    if not binary then return end

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

local function parse_human_output(text)
  -- Lines look like:
  --   test some::path::name ... ok
  --   test some::path::name ... FAILED
  --   test some::path::name ... ignored
  -- Failure bodies follow `failures:` section:
  --   ---- some::path::name stdout ----
  --   <panic body>
  local results = {}
  for line in text:gmatch('[^\n]+') do
    local name, status = line:match('^test%s+(%S+)%s+%.%.%.%s+(%w+)')
    if name and status then
      local s = 'unknown'
      local low = status:lower()
      if low == 'ok' then s = 'passed'
      elseif low == 'failed' then s = 'failed'
      elseif low == 'ignored' then s = 'skipped' end
      results[name] = { status = s }
    end
  end
  -- Collect failure bodies
  local body = text:match('failures:%s*(.+)')
  if body then
    for header, msg in body:gmatch('%-%-%-%-%s+(%S+)%s+stdout%s+%-%-%-%-%s*(.-)\n%s*\n') do
      if results[header] then results[header].message = msg end
    end
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

  for _, node in tree:iter_nodes() do
    local d = node:data()
    if d.type == 'test' then
      local key = position_to_filter(node)
      local p = key and parsed[key]
      if p then
        results[d.id] = {
          status = p.status,
          short = p.message,
        }
      else
        results[d.id] = { status = 'skipped' }
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
