-- Standalone pre-discovery signs. Does NOT load neotest. Scans the
-- buffer with a regex per language and places a sign per test
-- declaration. neotest will overwrite (or stack at higher priority) the
-- sign with passed/failed/running once tests run.

local M = {}

local SIGN_NAME = 'neotest_ready'
local SIGN_GROUP_PREFIX = 'neotest_ready_buf_'

local function define_sign_once()
  if vim.fn.sign_getdefined(SIGN_NAME)[1] then return end
  vim.api.nvim_set_hl(0, 'NeotestReady', { fg = '#5c6370' })
  vim.fn.sign_define(SIGN_NAME, {
    text = '',
    texthl = 'NeotestReady',
    numhl = 'NeotestReady',
  })
end

-- (filetype) -> function(line) -> bool
local matchers = {
  rust = function(line)
    return line:match('^%s*#%[%s*test%s*%]')
        or line:match('^%s*#%[%s*tokio::test')
        or line:match('^%s*#%[%s*async_std::test')
        or line:match('^%s*#%[%s*rstest')
  end,
  cpp = function(line)
    return line:match('^%s*TEST[_FP]*%s*%(')
  end,
  c = function(line)
    return line:match('^%s*TEST[_FP]*%s*%(')
  end,
}

local function scan(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if vim.bo[bufnr].buftype ~= '' then return end
  local matcher = matchers[vim.bo[bufnr].filetype]
  if not matcher then return end

  define_sign_once()
  local group = SIGN_GROUP_PREFIX .. bufnr
  pcall(vim.fn.sign_unplace, group, { buffer = bufnr })

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    if matcher(line) then
      local target = i
      -- For rust the attribute line precedes `fn`; place on the next
      -- non-blank line for clearer visual alignment.
      if vim.bo[bufnr].filetype == 'rust' then
        for j = i + 1, math.min(i + 4, #lines) do
          if lines[j]:match('^%s*fn%s') or lines[j]:match('^%s*async%s+fn%s') then
            target = j; break
          end
        end
      end
      pcall(vim.fn.sign_place, 0, group, SIGN_NAME, bufnr,
        { lnum = target, priority = 5 })
    end
  end
end

function M.scan_buffer(bufnr)
  scan(bufnr)
end

function M.scan_all_buffers()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then scan(b) end
  end
end

function M.setup()
  define_sign_once()

  vim.api.nvim_create_user_command('NeotestPreScan', function()
    M.scan_all_buffers()
    vim.notify('neotest pre-signs scanned', vim.log.levels.INFO)
  end, { desc = 'Re-scan all buffers for test markers' })

  local grp = vim.api.nvim_create_augroup('NeotestPreSigns', { clear = true })

  -- Fire on every event where a test buffer might appear or change.
  vim.api.nvim_create_autocmd(
    { 'BufReadPost', 'BufWritePost', 'BufEnter', 'BufWinEnter', 'FileType' },
    {
      group = grp,
      callback = function(ev)
        local bufnr = ev.buf
        -- Quick filetype gate; matchers table covers what we support.
        vim.defer_fn(function() scan(bufnr) end, 20)
      end,
    }
  )

  -- Catch buffers opened before this setup ran (file passed on the
  -- command line: BufReadPost fires before lazy evaluates the spec).
  vim.api.nvim_create_autocmd({ 'VimEnter', 'User' }, {
    group = grp,
    pattern = { '*', 'LazyDone', 'VeryLazy' },
    callback = function()
      M.scan_all_buffers()
    end,
  })

  -- Immediate sweep in case setup() itself runs after VimEnter (e.g.
  -- :Lazy reload neotest mid-session).
  vim.schedule(function() M.scan_all_buffers() end)
end

return M
