-- UI primitives: notify, error modal, picker, prompt-chain.
--
-- vim.notify is used for success/info so it integrates with whatever
-- notifier the user has set (fidget, snacks.notifier, or the default).
-- Errors still get a modal because the user is more likely to miss a
-- transient toast for a failed action.

local store = require 'plugins.lang.dadbod.store'

local M = {}

function M.info(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = 'DB' })
end

function M.warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = 'DB' })
end

function M.error_modal(lines)
  local width = 30
  for _, l in ipairs(lines) do width = math.max(width, #l) end
  width = math.min(width + 4, math.floor(vim.o.columns * 0.6))
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'
  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    width = width,
    height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' DB error ',
    title_pos = 'center',
  })
  vim.wo[win].winhighlight = 'Normal:DiagnosticError,FloatBorder:DiagnosticError'
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end, 4000)
end

function M.list_modal()
  if #store.state.connections == 0 then
    M.warn('No connections. Run :DBAdd to create one.')
    return
  end
  local lines = {
    'active: ' .. (store.state.active or 'none') .. '   scope: ' .. store.state.scope,
    '',
  }
  for _, c in ipairs(store.state.connections) do
    local marker = c.name == store.state.active and '*' or ' '
    local detail
    if c.driver == 'sqlite3' or c.driver == 'sqlite' then
      detail = (c.driver or '?') .. ' ' .. (c.database or '')
    else
      detail = string.format('%s %s@%s:%s/%s',
        c.driver or '?', c.user or '', c.host or '', c.port or '', c.database or '')
    end
    table.insert(lines, string.format('%s %-20s %s', marker, c.name, detail))
  end
  local width = 30
  for _, l in ipairs(lines) do width = math.max(width, #l) end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width + 4,
    height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Connections ',
    title_pos = 'center',
  })
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end

-- Chain of vim.ui.input prompts. `steps` entries: {key, prompt, default,
-- optional?, hidden?}. Calls `done(table)` after the last step.
function M.prompt_chain(steps, done, acc)
  acc = acc or {}
  if #steps == 0 then done(acc) return end
  local step = steps[1]
  local rest = { unpack(steps, 2) }
  if step.hidden then
    local value = vim.fn.inputsecret(step.prompt, step.default or '')
    if value == nil then return end
    if value ~= '' or step.optional then acc[step.key] = value end
    M.prompt_chain(rest, done, acc)
    return
  end
  vim.ui.input({ prompt = step.prompt, default = step.default or '' }, function(value)
    if value == nil then return end
    if value ~= '' or step.optional then acc[step.key] = value end
    M.prompt_chain(rest, done, acc)
  end)
end

function M.pick_connection(prompt, cb)
  if #store.state.connections == 0 then
    M.warn('No connections. Run :DBAdd first.')
    return
  end
  local items = {}
  for _, c in ipairs(store.state.connections) do
    table.insert(items, c.name .. '  (' .. (c.driver or '?') .. ')')
  end
  vim.ui.select(items, { prompt = prompt }, function(_, idx)
    if not idx then return end
    cb(store.state.connections[idx], idx)
  end)
end

return M
