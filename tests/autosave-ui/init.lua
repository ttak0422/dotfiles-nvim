-- Loaded in an embedded UI child, never in the user's Neovim.
local root = assert(vim.env.AUTOSAVE_UI_ROOT)
for _, name in ipairs({ 'TINY', 'AUTO_SAVE', 'NFNL' }) do
  vim.opt.rtp:append(assert(vim.env['AUTOSAVE_UI_' .. name]))
end
vim.o.cmdheight, vim.o.showmode = 0, false
vim.o.shortmess = vim.o.shortmess .. 'sWcS'
local ui = require('vim._core.ui2')
ui.enable()
_G.trace = {}
_G.snapshot = function(event, extra)
  local win = vim.api.nvim_get_current_win()
  trace[#trace + 1] = {
    event = event, extra = extra, time = vim.uv.hrtime() / 1e6,
    win = win, ft = vim.bo.filetype, mode = vim.api.nvim_get_mode().mode,
    cursor = vim.api.nvim_win_get_cursor(win), cmd = vim.fn.getcmdline(),
    expand = ui.cmd.expand, level = ui.cmd.level,
  }
end
for _, name in ipairs({ 'msg_show', 'show_msg' }) do
  local original = ui.msg[name]
  ui.msg[name] = function(...)
    snapshot(name, { ... })
    return original(...)
  end
end
for _, name in ipairs({ 'nvim_set_current_win', 'nvim_open_win', 'nvim_echo', 'nvim__redraw' }) do
  local original = vim.api[name]
  vim.api[name] = function(...)
    snapshot(name, { ... })
    return original(...)
  end
end
local notify = vim.notify
vim.notify = function(...)
  snapshot('notify', { ... })
  return notify(...)
end
vim.api.nvim_create_autocmd({
  'WinEnter', 'WinLeave', 'ModeChanged', 'CmdlineEnter', 'CmdlineLeave',
  'InsertLeave', 'TextChanged', 'BufWritePost',
}, { callback = function(event) snapshot(event.event, { buf = event.buf, match = event.match }) end })
for _, name in ipairs({ 'tiny-cmdline', 'auto-save' }) do
  local path = 'v2/fnl/' .. name .. '.fnl'
  local compiled = '-- [nfnl] ' .. path .. '\n' .. require('nfnl.fennel')['compile-string'](
    table.concat(vim.fn.readfile(root .. '/' .. path), '\n'), { filename = path })
  assert(compiled == table.concat(vim.fn.readfile(root .. '/v2/lua/autogen/' .. name .. '.lua'), '\n'))
  dofile(root .. '/v2/lua/autogen/' .. name .. '.lua')
end
vim.cmd('runtime plugin/auto-save.lua')
vim.cmd.edit(vim.env.AUTOSAVE_UI_FILE)
vim.bo.filetype = 'markdown'
vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'synthetic document' })
vim.cmd('silent write')
_G.document = vim.api.nvim_get_current_buf()
trace = {}
snapshot('ready')
