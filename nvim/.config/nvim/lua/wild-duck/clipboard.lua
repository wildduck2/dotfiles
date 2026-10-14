-- Over ssh or inside tmux, "+ copies to the native clipboard and through OSC 52 too, so it
-- reaches the machine you type on even in a tmux session started locally (no SSH_TTY there).
if vim.env.SSH_TTY or vim.env.TMUX then
  local mac = vim.fn.executable('pbcopy') == 1
  local native_copy = mac and { 'pbcopy' } or { 'xsel', '--clipboard', '--input' }
  local native_paste = mac and { 'pbpaste' } or { 'xsel', '--clipboard', '--output' }
  local has_native = vim.fn.executable(native_copy[1]) == 1 and (mac or vim.env.DISPLAY or vim.env.WAYLAND_DISPLAY)

  -- tmux 3.6 silently drops plain OSC 52 from a pane it is redrawing; passthrough always gets out
  local function osc52(lines)
    local seq = string.format('\027]52;c;%s\a', vim.base64.encode(table.concat(lines, '\n')))
    if vim.env.TMUX then
      seq = '\027Ptmux;' .. seq:gsub('\027', '\027\027') .. '\027\\'
    end
    vim.api.nvim_chan_send(2, seq)
  end

  local function copy(lines)
    osc52(lines)
    if has_native then vim.system(native_copy, { stdin = lines }) end
  end
  local function paste()
    if has_native then
      local out = vim.system(native_paste, { text = true }):wait().stdout or ''
      return { vim.split(out, '\n', { plain = true }), 'v' }
    end
    return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
  end
  vim.g.clipboard = {
    name = 'OSC 52 + native',
    copy = { ['+'] = copy, ['*'] = copy },
    paste = { ['+'] = paste, ['*'] = paste },
  }
end
