-- AUTO_SAVE_PLUGIN_DIR=<pinned plugin> NFNL_PLUGIN_DIR=<pinned nfnl>
-- nvim --headless -u NONE -i NONE -l tests/auto-save.lua
vim.opt.rtp:append(assert(vim.env.AUTO_SAVE_PLUGIN_DIR))
vim.opt.rtp:append(assert(vim.env.NFNL_PLUGIN_DIR))
local path = 'v2/fnl/auto-save.fnl'
local compiled = '-- [nfnl] ' .. path .. '\n'
  .. require('nfnl.fennel')['compile-string'](table.concat(vim.fn.readfile(path), '\n'), { filename = path })
assert(compiled == table.concat(vim.fn.readfile('v2/lua/autogen/auto-save.lua'), '\n'))

-- Observe the real plugin's requested delay and run its queued callback deterministically.
local timers = {}
vim.defer_fn = function(callback, delay)
  timers[#timers + 1] = { callback = callback, delay = delay }
end
local writes = 0
vim.api.nvim_create_autocmd('BufWritePost', { callback = function() writes = writes + 1 end })
dofile('v2/lua/autogen/auto-save.lua')
vim.cmd('runtime plugin/auto-save.lua')
local file = vim.fn.tempname() .. '.md'
vim.cmd.edit(file)
vim.bo.filetype = 'markdown'
vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'first edit' })
vim.api.nvim_exec_autocmds('TextChanged', {})
assert(#timers == 1 and timers[1].delay == 500, 'configured 500 ms delay was ignored: ' .. vim.inspect(timers))
vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'latest edit' })
vim.api.nvim_exec_autocmds('TextChanged', {})
vim.api.nvim_exec_autocmds('InsertLeave', {})
assert(#timers == 1 and writes == 0 and vim.bo.modified, 'edit burst did not coalesce')
timers[1].callback()
assert(writes == 1 and not vim.bo.modified)
assert(vim.deep_equal(vim.fn.readfile(file), { 'latest edit' }), 'latest text was not saved')

-- Other filetypes and unmodifiable buffers retain their existing condition checks.
for _, case in ipairs({ { filetype = 'lua', modifiable = true }, { filetype = 'markdown', modifiable = false } }) do
  vim.bo.modifiable = true
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'unsaved' })
  vim.bo.filetype, vim.bo.modifiable = case.filetype, case.modifiable
  local before = #timers
  vim.api.nvim_exec_autocmds('TextChanged', {})
  assert(#timers == before + 1)
  timers[#timers].callback()
  assert(writes == 1 and vim.bo.modified, 'non-target buffer was saved')
end
vim.bo.modifiable, vim.bo.filetype = true, 'markdown'
vim.cmd('ASToggle')
local before = #timers
vim.api.nvim_exec_autocmds('TextChanged', {})
assert(#timers == before, 'ASToggle did not stop scheduling')
vim.fn.delete(file)
print('PASS configured delay, burst coalescing, latest text, filetype/modifiable conditions, ASToggle, generated Lua parity')
