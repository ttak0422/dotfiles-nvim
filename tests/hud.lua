-- Real hud.nvim floats and Gitsigns, without loading the user's editor config.
local api = vim.api
for _, key in ipairs({ 'HUD_TEST_PLUGIN', 'HUD_TEST_GITSIGNS', 'HUD_TEST_THEME' }) do
  vim.opt.rtp:append(assert(vim.env[key], key))
end
local hud = require('hud')
local root = vim.fn.tempname()
local warnings = {}
vim.notify = function(message)
  warnings[#warnings + 1] = message
end
local function settle()
  vim.cmd('redraw')
  vim.wait(30)
end
local function floats()
  local result = {}
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    if vim.b[buf].hud_source_win then
      result[vim.b[buf].hud_source_win] = { win = win, buf = buf }
    end
  end
  return result
end
local function rows(source)
  local float = assert(floats()[source or api.nvim_get_current_win()], 'missing HUD')
  return api.nvim_buf_get_lines(float.buf, 0, -1, false), float
end
local function contains(text, value)
  assert(text:find(value, 1, true), text .. ' missing ' .. value)
end
local function event(name, pattern)
  api.nvim_exec_autocmds(name, pattern and { pattern = pattern } or {})
  settle()
end
local function git(...)
  local command = { 'git', '-C', root }
  vim.list_extend(command, { ... })
  local result = vim.system(command, { text = true }):wait()
  assert(result.code == 0, result.stderr)
  return vim.trim(result.stdout)
end
local function check()
  -- Headless Neovim has no UI to resize its screen grid; use its native 80 columns.
  vim.o.laststatus, vim.o.showtabline = 0, 0
  vim.o.winborder = 'single'
  vim.o.winminwidth, vim.o.winminheight = 1, 1
  vim.o.winwidth, vim.o.winheight = 1, 1
  vim.wo.wrap, vim.wo.signcolumn, vim.wo.foldcolumn = false, 'yes', '1'
  vim.cmd('colorscheme sorairo')
  vim.fn.mkdir(root .. '/src/main/java/org/example', 'p')
  git('init', '-b', 'hud-test')
  local content = {}
  for index = 1, 80 do
    content[index] = 'source line ' .. index
  end
  local name = root .. '/src/main/java/org/example/Example.java'
  vim.fn.writefile(content, name)
  git('add', '.')
  git('-c', 'user.name=HUD Test', '-c', 'user.email=hud@example.invalid', 'commit', '-m', 'fixture')
  print('HUD: Git fixture initialized')
  vim.cmd.edit(vim.fn.fnameescape(name))
  vim.bo.filetype = 'java'
  api.nvim_win_set_cursor(0, { 15, 2 })
  local source, buf = api.nvim_get_current_win(), api.nvim_get_current_buf()
  dofile('v2/lua/hud-config.lua')
  dofile('v2/lua/autogen/gitsigns.lua')
  print('HUD: providers loaded')
  assert(vim.wait(5000, function()
    return (vim.b[buf].gitsigns_status_dict or {}).head == 'hud-test'
  end, 10))
  settle()
  local initial, float = rows()
  local border = api.nvim_win_get_config(float.win).border
  assert(border == nil or border == 'none' or #border == 0, 'unexpected border')
  assert(#initial == 4, 'active rows')
  contains(initial[1], 'Example.java o/example')
  assert(not initial[1]:find('src/main/java', 1, true), 'Maven prefix retained')
  contains(initial[2], '15,3')
  contains(initial[2], '(hud-test)')
  assert(vim.trim(initial[3]) == '' and vim.trim(initial[4]) == '', 'empty rows compacted')
  assert(vim.wo[float.win].winhighlight:find('Normal:WinBar', 1, true))
  assert(vim.wo.winbar == '' and vim.o.laststatus == 0 and not package.loaded.incline)

  local ns = api.nvim_create_namespace('hud-integration-test')
  vim.diagnostic.set(ns, buf, {
    { lnum = 2, col = 0, message = 'error', severity = 1 },
    { lnum = 3, col = 0, message = 'warn', severity = 2 },
    { lnum = 4, col = 0, message = 'info', severity = 3 },
  })
  api.nvim_buf_set_lines(buf, 3, 4, false, { 'modified source' })
  event('BufModifiedSet')
  assert(
    vim.wait(5000, function()
      return (vim.b[buf].gitsigns_status_dict or {}).changed == 1
    end, 10),
    'real git diff update'
  )
  settle()
  local updated = rows()
  contains(updated[1], ' ')
  contains(updated[2], '(hud-test*)')
  contains(updated[3], ' 1')
  contains(updated[3], ' 1')
  contains(updated[4], ' 1')
  git('checkout', '-b', 'hud-next')
  require('gitsigns').refresh()
  assert(
    vim.wait(5000, function()
      return (vim.b[buf].gitsigns_status_dict or {}).head == 'hud-next'
    end, 10),
    'real branch update'
  )
  settle()
  contains(rows()[2], '(hud-next*)')
  git('checkout', 'hud-test')
  require('gitsigns').refresh()
  assert(vim.wait(5000, function()
    return (vim.b[buf].gitsigns_status_dict or {}).head == 'hud-test'
  end, 10))
  settle()

  vim.cmd('vsplit')
  local second = api.nvim_get_current_win()
  api.nvim_win_set_cursor(second, { 18, 5 })
  event('CursorMoved')
  assert(#rows(second) == 4 and #rows(source) == 2, 'split focus')
  contains(rows(second)[2], '18,6')
  contains(rows(source)[2], '15,3')
  contains(rows(source)[2], '(hud-test*)')
  assert(vim.wo[select(2, rows(source)).win].winhighlight:find('Normal:WinBarNC', 1, true))
  api.nvim_set_current_win(source)
  settle()
  assert(#rows(source) == 4 and #rows(second) == 2, 'focus transition')

  local reads, walks, writes = 0, 0, 0
  local count, fsroot, setlines = vim.diagnostic.count, vim.fs.root, api.nvim_buf_set_lines
  vim.diagnostic.count = function(...)
    reads = reads + 1
    return count(...)
  end
  vim.fs.root = function(...)
    walks = walks + 1
    return fsroot(...)
  end
  api.nvim_buf_set_lines = function(...)
    writes = writes + 1
    return setlines(...)
  end
  local started = vim.uv.hrtime()
  local oldfloat = select(2, rows(source))
  for index = 1, 90 do
    api.nvim_win_set_cursor(source, { 15 + index % 3, 2 })
    event('CursorMoved')
  end
  local elapsed = (vim.uv.hrtime() - started) / 1e6
  vim.diagnostic.count, vim.fs.root, api.nvim_buf_set_lines = count, fsroot, setlines
  assert(reads == 0 and walks == 0, 'cursor moves bypassed caches')
  assert(writes <= 90, 'redundant writes to inactive HUD')
  local move_writes = writes
  local _, stable = rows(source)
  assert(stable.win == oldfloat.win and stable.buf == oldfloat.buf, 'HUD resources recreated on cursor movement')
  writes = 0
  api.nvim_buf_set_lines = function(...)
    writes = writes + 1
    return setlines(...)
  end
  event('CursorMoved')
  api.nvim_buf_set_lines = setlines
  assert(writes == 0, 'unchanged output rewritten')
  print(
    ('HUD: 90 cursor events, %d diagnostic reads, %d root walks, %d writes; %.0fms including 30ms/event settling'):format(
      reads,
      walks,
      move_writes,
      elapsed
    )
  )

  vim.cmd('only')
  local long = root .. '/src/main/java/org/example/very/long/path/日本語/Example.java'
  api.nvim_buf_set_name(buf, long)
  event('BufFilePost')
  contains(rows()[1], 'o/e/v/l/p/日')
  vim.cmd('vsplit')
  api.nvim_win_set_cursor(0, { 15, 0 })
  event('CursorMoved')
  contains(rows()[1], 'o/e/v/l/p/日')
  api.nvim_win_set_width(0, 18)
  event('WinResized')
  local narrow, nfloat = rows()
  contains(narrow[1], 'Example.java')
  assert(not narrow[1]:find('o/e/', 1, true), 'path did not yield')
  assert(not narrow[2]:find('hud-test', 1, true), 'branch did not yield')
  for _, row in ipairs(narrow) do
    assert(vim.fn.strdisplaywidth(row) <= 16, 'overflow past gutters')
  end
  local info = vim.fn.getwininfo(api.nvim_get_current_win())[1]
  local cfg = api.nvim_win_get_config(nfloat.win)
  assert(cfg.col + cfg.width == info.width, 'not right aligned')
  api.nvim_win_set_width(0, 4)
  event('WinResized')
  for _, row in ipairs(rows()) do
    assert(vim.fn.strdisplaywidth(row) <= 2, 'tiny width overflow')
  end
  vim.cmd('only')
  event('WinResized')
  contains(rows()[1], 'o/e/v/l/p/日')

  vim.diagnostic.reset(ns, buf)
  vim.b[buf].gitsigns_status_dict = nil
  event('User', 'GitSignsUpdate')
  local empty = rows()
  assert(#empty == 4 and vim.trim(empty[3]) == '' and vim.trim(empty[4]) == '')
  assert(not empty[2]:find('hud-test', 1, true), 'stale git')
  vim.bo.modified = false
  event('BufModifiedSet')
  assert(not rows()[1]:find('', 1, true), 'stale modified indicator')
  vim.cmd('enew!')
  api.nvim_buf_set_lines(0, 0, -1, false, content)
  vim.bo.modified = false
  api.nvim_win_set_cursor(0, { 15, 0 })
  event('CursorMoved')
  contains(rows()[1], '[No Name]')
  for _, buftype in ipairs({ 'nofile', 'prompt', 'help', 'quickfix' }) do
    vim.bo.buftype = buftype
    event('OptionSet')
    assert(not floats()[api.nvim_get_current_win()], 'special buffer HUD: ' .. buftype)
  end
  vim.bo.buftype = ''
  for _, ft in ipairs({ 'gitcommit', 'Trouble', 'skk-terminal-input' }) do
    vim.bo.filetype = ft
    event('FileType')
    assert(not floats()[api.nvim_get_current_win()], 'special filetype HUD: ' .. ft)
  end
  vim.bo.filetype = ''
  vim.wo.previewwindow = true
  event('OptionSet')
  assert(not floats()[api.nvim_get_current_win()])
  vim.wo.previewwindow = false
  event('OptionSet')
  assert(#rows() == 4)

  vim.o.background = 'light'
  vim.cmd('colorscheme sorairo')
  settle()
  for _, item in ipairs({ { 'Added', 10 }, { 'Changed', 12 }, { 'Removed', 9 } }) do
    local hl = api.nvim_get_hl(0, { name = 'HudGit' .. item[1] })
    assert(hl.fg == tonumber(vim.g['terminal_color_' .. item[2]]:sub(2), 16) and hl.bold, 'theme refresh')
  end
  api.nvim_win_set_cursor(0, { 1, 0 })
  event('CursorMoved')
  assert(not floats()[api.nvim_get_current_win()], 'cursor overlap')
  api.nvim_win_set_cursor(0, { 15, 0 })
  event('CursorMoved')
  assert(#rows() == 4)
  vim.cmd('split')
  api.nvim_win_set_height(0, 3)
  event('WinResized')
  assert(not floats()[api.nvim_get_current_win()], 'short pane overflow')
  assert(#warnings == 0, vim.inspect(warnings))
  print(
    'HUD integration: layout, real git/diagnostic updates, focus, caching, widths, rename, special buffers and theme passed'
  )
end
local ok, err = xpcall(check, debug.traceback)
hud.disable()
vim.fn.delete(root, 'rf')
if not ok then
  io.stderr:write(err .. '\n')
  vim.cmd('cquit 1')
end
vim.cmd('qa!')
