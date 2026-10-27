local root = assert(vim.env.TERMINAL_INPUT_ROOT)
local scenario = vim.env.TERMINAL_INPUT_SCENARIO or 'background'
local api = vim.api
vim.opt.runtimepath:append(assert(vim.env.TERMINAL_INPUT_NFNL))
vim.opt.runtimepath:append(assert(vim.env.TERMINAL_INPUT_NEOZOOM))
vim.o.columns, vim.o.lines = 120, 40
-- Headless Nvim has no UI; supply only the dimensions consumed by real NeoZoom.
api.nvim_list_uis = function() return { { width = 120, height = 40 } } end
-- Exercise helper windows without loading denops, SKK dictionaries, or user config.
api.nvim_feedkeys = function() end
local path = 'v2/fnl/term-open-plugins.fnl'
local compiled = '-- [nfnl] ' .. path .. '\n' .. require('nfnl.fennel')['compile-string'](
  table.concat(vim.fn.readfile(root .. '/' .. path), '\n'), { filename = path })
assert(compiled == table.concat(vim.fn.readfile(root .. '/v2/lua/autogen/term-open-plugins.lua'), '\n'), 'Fennel/Lua parity')
dofile(root .. '/v2/lua/autogen/term-open-plugins.lua')
dofile(root .. '/v2/lua/autogen/neozoom.lua')
local zoom = require('neo-zoom')
local term = api.nvim_get_current_buf()
local termwin = api.nvim_get_current_win()
local channel = api.nvim_open_term(term, {})
vim.b[term].terminal_job_id = channel
vim.wo[termwin].winbar = 'terminal-owner-bar'
local function settle() vim.wait(20, function() return false end, 5) end
local terminal_cursor
local function open_input()
  local callback
  for _, map in ipairs(api.nvim_get_keymap('t')) do
    if map.desc == 'SKK input helper' then callback = map.callback end
  end
  terminal_cursor = api.nvim_win_get_cursor(api.nvim_get_current_win())
  assert(callback, 'real terminal helper mapping missing')()
  settle()
  local win, buf = api.nvim_get_current_win(), api.nvim_get_current_buf()
  assert(vim.bo[buf].filetype == 'skk-terminal-input')
  api.nvim_buf_set_lines(buf, 0, -1, false, { 'draft to preserve', 'second line' })
  api.nvim_win_set_cursor(win, { 2, 3 })
  return win, buf
end
local function cancel(buf)
  for _, map in ipairs(api.nvim_buf_get_keymap(buf, 'n')) do
    if map.lhs == '<C-C>' or map.lhs == '<C-c>' then map.callback(); return end
  end
  error('real helper cancel mapping missing')
end
local function accept(buf)
  for _, map in ipairs(api.nvim_buf_get_keymap(buf, 'n')) do
    if map.lhs == '<C-S>' or map.lhs == '<C-s>' then map.callback(); return end
  end
  error('real helper accept mapping missing')
end
local function draft(buf)
  assert(api.nvim_buf_is_valid(buf), 'draft buffer was deleted')
  assert(api.nvim_buf_get_lines(buf, 0, -1, false)[1] == 'draft to preserve', 'draft changed')
  assert(vim.deep_equal(api.nvim_buf_get_lines(buf, 0, -1, false), { 'draft to preserve', 'second line' }), 'multiline draft changed')
end
local function restored(helper, buf, owner)
  settle()
  draft(buf)
  assert(api.nvim_win_is_valid(helper), 'helper was closed')
  local cfg = api.nvim_win_get_config(helper)
  assert(cfg.win == owner, 'helper not reparented to restored owner')
  assert(cfg.hide == false, 'restored input remains hidden')
  assert(cfg.zindex == (api.nvim_win_get_config(owner).zindex or 0) + 1, 'wrong restored layer')
  assert(vim.deep_equal(api.nvim_win_get_cursor(helper), { 2, 3 }), 'helper cursor moved')
  assert(api.nvim_get_current_win() == owner, 'sync stole focus from owner')
end
local function report(stage, helper, owner, zw)
  local function config(win)
    return api.nvim_win_is_valid(win) and api.nvim_win_get_config(win) or 'closed'
  end
  print(vim.json.encode({ scenario = scenario, stage = stage, current = api.nvim_get_current_win(),
    helper = config(helper), owner = config(owner), zoom = zw and config(zw) or nil }))
end
if scenario == 'background' or scenario == 'same-buffer-other-owner' then
  vim.cmd.vsplit()
  local other = api.nvim_get_current_win()
  if scenario == 'background' then api.nvim_set_current_buf(api.nvim_create_buf(false, true)) end
  api.nvim_set_current_win(termwin)
  local helper, buf = open_input()
  api.nvim_set_current_win(other)
  zoom.neo_zoom({})
  local zw = api.nvim_get_current_win()
  settle()
  report('zoom-other-window', helper, termwin, zw)
  assert(api.nvim_win_get_config(helper).win == termwin, 'helper owner changed')
  assert(api.nvim_win_get_config(helper).zindex < api.nvim_win_get_config(zw).zindex,
    'background terminal SKK helper draws above unrelated zoom')
  assert(api.nvim_win_get_config(helper).hide, 'background helper must be hidden')
  draft(buf)
  assert(api.nvim_get_current_win() == zw, 'background sync stole focus')
  api.nvim_set_current_win(helper)
  settle()
  assert(api.nvim_get_current_win() == zw, 'focus left on hidden background input')
  zoom.neo_zoom({})
  settle()
  assert(not api.nvim_win_get_config(helper).hide, 'unzoom must restore background helper')
  assert(api.nvim_buf_get_lines(buf, 0, -1, false)[1] == 'draft to preserve', 'zoom destroyed draft')
  cancel(buf)
  assert(api.nvim_get_current_win() == termwin, 'cancel must restore terminal focus')
  assert(vim.deep_equal(api.nvim_win_get_cursor(termwin), terminal_cursor), 'terminal cursor not restored')
  assert(vim.wo[termwin].winbar == 'terminal-owner-bar', 'local winbar not restored')
elseif scenario == 'zoom-owner' or scenario == 'owner-close' or scenario == 'owner-q' or scenario == 'helper-toggle-close' then
  zoom.neo_zoom({})
  local zw = api.nvim_get_current_win()
  vim.wo[zw].winbar = 'zoom-owner-bar'
  assert(vim.bo[term].buftype == 'terminal')
  local helper, buf = open_input()
  report('input-inside-terminal-zoom', helper, zw, zw)
  assert(api.nvim_win_get_config(helper).win == zw, 'helper must anchor to zoom, not original split')
  assert(api.nvim_win_get_config(helper).zindex > api.nvim_win_get_config(zw).zindex,
    'terminal zoom covers its own SKK helper')
  if scenario ~= 'zoom-owner' then
    if scenario == 'helper-toggle-close' then
      zoom.neo_zoom({})
      settle()
      draft(buf)
      assert(api.nvim_get_current_win() == zw and api.nvim_win_is_valid(zw), 'first toggle should only focus zoom')
    else api.nvim_set_current_win(zw) end
    if scenario == 'owner-q' then vim.cmd.quit() else zoom.neo_zoom({}) end
    restored(helper, buf, termwin)
    report('zoom-owner-closed', helper, zw)
    cancel(buf)
    assert(vim.wo[termwin].winbar == 'terminal-owner-bar')
  else
    cancel(buf)
    assert(api.nvim_get_current_win() == zw, 'cancel must return to terminal zoom')
    assert(vim.deep_equal(api.nvim_win_get_cursor(zw), terminal_cursor), 'zoom terminal cursor not restored')
    assert(vim.wo[zw].winbar == 'zoom-owner-bar', 'cancel changed zoom owner winbar')
  end
elseif scenario == 'split-input-moved-to-zoom' then
  local helper, buf = open_input()
  api.nvim_set_current_win(termwin)
  zoom.neo_zoom({})
  local zw = api.nvim_get_current_win()
  settle()
  report('terminal-moved-to-zoom-with-existing-input', helper, termwin, zw)
  assert(api.nvim_win_get_buf(zw) == term, 'zoom must show terminal')
  restored(helper, buf, zw)
  assert(vim.wo[termwin].winbar == 'terminal-owner-bar', 'migration lost original winbar')
  zoom.neo_zoom({})
  restored(helper, buf, termwin)
  local sent, send = {}, api.nvim_chan_send
  api.nvim_chan_send = function(chan, text)
    sent[#sent + 1] = { chan, text }
    return send(chan, text)
  end
  accept(buf)
  assert(#sent == 1 and sent[1][1] == channel and sent[1][2] == 'draft to preserve\nsecond line\r', 'wrong terminal send')
  assert(not api.nvim_buf_is_valid(buf), 'successful accept must wipe draft')
  assert(api.nvim_get_current_win() == termwin, 'accept focus=' .. api.nvim_get_current_win())
  assert(vim.deep_equal(api.nvim_win_get_cursor(termwin), terminal_cursor), 'accept did not restore terminal cursor')
  assert(vim.wo[termwin].winbar == 'terminal-owner-bar', 'accept winbar=' .. vim.inspect(vim.wo[termwin].winbar))
elseif scenario == 'orphan-recovery' or scenario == 'terminal-wiped' then
  vim.cmd.vsplit()
  local survivor = api.nvim_get_current_win()
  api.nvim_set_current_buf(api.nvim_create_buf(false, true))
  api.nvim_set_current_win(termwin)
  local helper, buf = open_input()
  api.nvim_set_current_win(survivor)
  api.nvim_win_close(termwin, true)
  settle()
  draft(buf)
  assert(api.nvim_win_get_config(helper).hide, 'orphan must be hidden')
  assert(api.nvim_win_get_config(helper).relative == 'editor', 'orphan retains invalid owner ID')
  assert(api.nvim_get_current_win() == survivor, 'orphan cleanup stole focus')
  if scenario == 'terminal-wiped' then
    api.nvim_buf_delete(term, { force = true })
    settle()
    local sent = false
    api.nvim_chan_send = function() sent = true end
    accept(buf)
    assert(not sent, 'send attempted after terminal wipe')
    draft(buf)
  else
    api.nvim_set_current_buf(term)
    local same_helper, same_buf = open_input()
    assert(same_helper == helper and same_buf == buf)
    assert(api.nvim_win_get_config(helper).win == survivor)
    assert(not api.nvim_win_get_config(helper).hide)
    cancel(buf)
    assert(api.nvim_get_current_win() == survivor)
  end
elseif scenario == 'focus-visibility' then
  local helper, buf = open_input()
  api.nvim_set_current_win(termwin)
  assert(api.nvim_win_is_valid(helper), 'focus leave closed helper')
  assert(api.nvim_win_get_config(helper).hide == false, 'unexpected focus-driven hiding')
  api.nvim_win_set_config(helper, { hide = true })
  assert(api.nvim_buf_is_valid(buf), 'hiding must preserve scratch buffer')
  assert(api.nvim_buf_get_lines(buf, 0, -1, false)[1] == 'draft to preserve')
  api.nvim_win_set_config(helper, { hide = false })
  api.nvim_set_current_win(helper)
  report('hide-show-preserved-draft-and-window', helper, termwin)
  cancel(buf)
  assert(not api.nvim_buf_is_valid(buf), 'cancel must wipe scratch buffer')
  assert(api.nvim_get_current_win() == termwin, 'cancel must restore owner focus')
elseif scenario == 'repeat-zoom' then
  local helper, buf = open_input()
  api.nvim_set_current_win(termwin)
  for _ = 1, 3 do
    zoom.neo_zoom({})
    local zw = api.nvim_get_current_win()
    restored(helper, buf, zw)
    zoom.neo_zoom({})
    restored(helper, buf, termwin)
  end
  cancel(buf)
  assert(vim.wo[termwin].winbar == 'terminal-owner-bar')
elseif scenario == 'send-failure' then
  local helper, buf = open_input()
  api.nvim_chan_send = function() error('fixture channel closed') end
  accept(buf)
  draft(buf)
  assert(api.nvim_get_current_win() == helper, 'send failure changed focus')
  cancel(buf)
  assert(api.nvim_get_current_win() == termwin and vim.wo[termwin].winbar == 'terminal-owner-bar')
elseif scenario == 'external-helper-close' then
  local helper = open_input()
  api.nvim_win_close(helper, true)
  settle()
  assert(vim.wo[termwin].winbar == 'terminal-owner-bar', 'external close left owner winbar blank')
  api.nvim_set_current_win(termwin)
  local new_helper, buf = open_input()
  assert(new_helper ~= helper, 'closed window was reused')
  cancel(buf)
elseif scenario == 'reuse-other-terminal' then
  local helper, buf = open_input()
  api.nvim_set_current_win(termwin)
  vim.cmd.vsplit()
  local second = api.nvim_create_buf(false, true)
  api.nvim_set_current_buf(second)
  local second_channel = api.nvim_open_term(second, {})
  vim.b[second].terminal_job_id = second_channel
  local same_helper, same_buf = open_input()
  assert(same_helper == helper and same_buf == buf, 'current singleton behavior changed')
  report('second-terminal-reuses-first-helper', helper, termwin)
  assert(api.nvim_win_get_config(helper).win == termwin, 'current helper unexpectedly reowned')
else
  error('unknown scenario ' .. scenario)
end
print('PASS ' .. scenario)
