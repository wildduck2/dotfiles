local M = {}

local function codelldb_path()
  local mason = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/adapter/codelldb'
  if vim.fn.executable(mason) == 1 then
    return mason
  end
  return vim.fn.exepath('codelldb')
end

local function pick_exe(default_dir)
  return function()
    return vim.fn.input('Executable: ', (default_dir or vim.fn.getcwd()) .. '/', 'file')
  end
end

local function rust_cargo_target()
  local co = coroutine.running()
  vim.system(
    { 'cargo', 'metadata', '--no-deps', '--format-version', '1' },
    { text = true },
    function(out)
      vim.schedule(function()
        local ok, meta = pcall(vim.json.decode, out.stdout or '')
        if not ok or not meta or not meta.packages then
          coroutine.resume(
            co,
            vim.fn.input('Binary: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          )
          return
        end
        local target_dir = meta.target_directory or (vim.fn.getcwd() .. '/target')
        local bins = {}
        for _, pkg in ipairs(meta.packages) do
          for _, t in ipairs(pkg.targets or {}) do
            for _, kind in ipairs(t.kind or {}) do
              if kind == 'bin' or kind == 'example' then
                local sub = kind == 'example' and '/examples/' or '/'
                table.insert(bins, target_dir .. '/debug' .. sub .. t.name)
              end
            end
          end
        end
        if #bins == 0 then
          coroutine.resume(co, vim.fn.input('Binary: ', target_dir .. '/debug/', 'file'))
        elseif #bins == 1 then
          coroutine.resume(co, bins[1])
        else
          vim.ui.select(bins, { prompt = 'Pick rust binary' }, function(choice)
            coroutine.resume(co, choice or bins[1])
          end)
        end
      end)
    end
  )
  return coroutine.yield()
end

function M.setup()
  local dap = require('dap')

  dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
      command = codelldb_path(),
      args = { '--port', '${port}' },
    },
  }

  dap.configurations.rust = {
    {
      name = 'Launch (cargo target)',
      type = 'codelldb',
      request = 'launch',
      program = rust_cargo_target,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
      sourceLanguages = { 'rust' },
    },
    {
      name = 'Launch (pick binary)',
      type = 'codelldb',
      request = 'launch',
      program = pick_exe(vim.fn.getcwd() .. '/target/debug'),
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = function()
        return vim.split(vim.fn.input('Args: '), ' +')
      end,
    },
    {
      name = 'Attach to process',
      type = 'codelldb',
      request = 'attach',
      pid = require('dap.utils').pick_process,
      args = {},
    },
  }

  dap.configurations.cpp = {
    {
      name = 'Launch (pick binary)',
      type = 'codelldb',
      request = 'launch',
      program = pick_exe(),
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = function()
        return vim.split(vim.fn.input('Args: '), ' +')
      end,
    },
    {
      name = 'Attach to process',
      type = 'codelldb',
      request = 'attach',
      pid = require('dap.utils').pick_process,
      args = {},
    },
  }

  dap.configurations.c = dap.configurations.cpp
end

return M
