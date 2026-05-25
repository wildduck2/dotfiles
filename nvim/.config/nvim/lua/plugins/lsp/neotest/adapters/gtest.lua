-- Minimal neotest adapter for GoogleTest (C/C++).
--
-- Discovery: tree-sitter query against `TEST`, `TEST_F`, `TEST_P` macros.
-- Run: <binary> --gtest_filter=<suite>.<name> --gtest_output=xml:<tmp>
-- Parse: gtest XML report -> per-test status + failure message.
--
-- Binary discovery order:
--   1. opts.binary (function or string) returned by adapter({ binary = ... })
--   2. ${cwd}/build/<basename without _test/.test suffix>
--   3. ${cwd}/build/<basename>
--   4. Prompt the user via vim.fn.input on first run, cached per cwd.
--
-- Build step is NOT performed automatically -- user keeps binary up to
-- date via their own cmake/make/ninja loop. Add a `pre_run` shell hook
-- in `opts` if you want automated builds.

local lib = require('neotest.lib')
local async = require('neotest.async')

local M = { name = 'gtest' }

local binary_cache = {}

local function default_binary_paths(file)
  local cwd = vim.fn.getcwd()
  local base = vim.fn.fnamemodify(file, ':t:r')
  local trimmed = base:gsub('_test$', ''):gsub('%.test$', '')
  return {
    cwd .. '/build/' .. trimmed,
    cwd .. '/build/' .. base,
    cwd .. '/build/test_' .. trimmed,
    cwd .. '/build/tests/' .. trimmed,
    cwd .. '/build/tests/' .. base,
  }
end

local function resolve_binary(opts, file)
  if opts.binary then
    local b = type(opts.binary) == 'function' and opts.binary(file) or opts.binary
    if b and vim.fn.executable(b) == 1 then return b end
  end
  for _, p in ipairs(default_binary_paths(file)) do
    if vim.fn.executable(p) == 1 then return p end
  end
  local cwd = vim.fn.getcwd()
  if binary_cache[cwd] and vim.fn.executable(binary_cache[cwd]) == 1 then
    return binary_cache[cwd]
  end
  local prompt = vim.fn.input('gtest binary for ' .. file .. ': ', cwd .. '/build/', 'file')
  if prompt ~= '' and vim.fn.executable(prompt) == 1 then
    binary_cache[cwd] = prompt
    return prompt
  end
  return nil
end

function M.root(dir)
  -- Treat the closest cmake / make / git root as the project root.
  return lib.files.match_root_pattern('CMakeLists.txt', 'Makefile', 'compile_commands.json', '.git')(dir)
end

function M.filter_dir(name)
  return name ~= 'build' and name ~= 'node_modules' and name ~= '.git'
end

function M.is_test_file(file_path)
  local ext = file_path:match('%.([^./]+)$')
  if ext ~= 'c' and ext ~= 'cc' and ext ~= 'cpp' and ext ~= 'cxx' then
    return false
  end
  local base = vim.fn.fnamemodify(file_path, ':t:r'):lower()
  if base:match('_test$') or base:match('%.test$') or base:match('^test_') then
    return true
  end
  -- Fallback: scan for #include <gtest/gtest.h>
  local fd = io.open(file_path, 'r')
  if not fd then return false end
  local content = fd:read('*a')
  fd:close()
  return content and content:find('gtest/gtest%.h', 1, true) ~= nil
end

function M.discover_positions(file_path)
  local query = [[
    ((call_expression
       function: (identifier) @macro
       arguments: (argument_list
         . (identifier) @namespace.name
         . (identifier) @test.name))
     (#any-of? @macro "TEST" "TEST_F" "TEST_P")) @test.definition
  ]]
  return lib.treesitter.parse_positions(file_path, query, {
    require_namespaces = true,
    nested_tests = false,
  })
end

local function parse_gtest_xml(path)
  local fd = io.open(path, 'r')
  if not fd then return {} end
  local xml = fd:read('*a'); fd:close()
  local results = {}
  -- Each <testcase ...> entry. Failures are nested <failure message="..."/>
  for case in xml:gmatch('<testcase[^>]*/?>.-</testcase>') do
    local suite = case:match('classname="([^"]+)"')
    local name  = case:match('name="([^"]+)"')
    if suite and name then
      local id = suite .. '.' .. name
      local status = 'passed'
      local message = nil
      if case:find('<failure') then
        status = 'failed'
        message = case:match('<failure[^>]*message="([^"]+)"')
        if message then
          message = message:gsub('&quot;', '"'):gsub('&amp;', '&'):gsub('&lt;', '<'):gsub('&gt;', '>')
        end
      elseif case:find('<skipped') then
        status = 'skipped'
      end
      results[id] = { status = status, message = message }
    end
  end
  -- Also catch self-closing <testcase ... /> with no body.
  for case in xml:gmatch('<testcase[^/>]*/>') do
    local suite = case:match('classname="([^"]+)"')
    local name  = case:match('name="([^"]+)"')
    if suite and name then
      results[suite .. '.' .. name] = results[suite .. '.' .. name] or { status = 'passed' }
    end
  end
  return results
end

function M.build_spec(args)
  local tree = args.tree
  if not tree then return end
  local pos = tree:data()
  local file = pos.path
  local opts = M._opts or {}

  local bin = resolve_binary(opts, file)
  if not bin then
    return { command = { 'false' }, context = { error = 'No gtest binary found' } }
  end

  -- Build filter from the position. File-level = run everything in this
  -- binary; namespace = SUITE.*; test = SUITE.NAME.
  local filter
  if pos.type == 'test' then
    -- Position name is just the test name; need parent (namespace) for suite.
    local parent = tree:parent() and tree:parent():data()
    local suite = parent and parent.name
    filter = suite and (suite .. '.' .. pos.name) or pos.name
  elseif pos.type == 'namespace' then
    filter = pos.name .. '.*'
  end

  local xml = vim.fn.tempname() .. '.xml'
  local cmd = { bin, '--gtest_output=xml:' .. xml, '--gtest_color=no' }
  if filter then table.insert(cmd, '--gtest_filter=' .. filter) end

  -- DAP strategy: hand back a config dap can launch via codelldb.
  local strategy
  if args.strategy == 'dap' then
    strategy = {
      type = 'codelldb',
      request = 'launch',
      name = 'gtest debug',
      program = bin,
      cwd = vim.fn.getcwd(),
      args = { '--gtest_color=no', filter and ('--gtest_filter=' .. filter) or nil },
      stopOnEntry = false,
    }
  end

  return {
    command = cmd,
    context = { results_path = xml, file = file },
    strategy = strategy,
  }
end

function M.results(spec, result, tree)
  local results = {}
  if spec.context.error then
    for _, node in tree:iter() do
      if node:data().type == 'test' then
        results[node:data().id] = { status = 'failed', short = spec.context.error }
      end
    end
    return results
  end
  local cases = parse_gtest_xml(spec.context.results_path)
  for _, node in tree:iter() do
    local d = node:data()
    if d.type == 'test' then
      local parent = node:parent() and node:parent():data()
      local suite = parent and parent.name
      local key = (suite or '') .. '.' .. d.name
      local case = cases[key]
      if case then
        results[d.id] = {
          status = case.status,
          short = case.message,
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
