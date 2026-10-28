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
local function right_margin(source)
  local lines, float = rows(source)
  local info = vim.fn.getwininfo(source)[1]
  local config = api.nvim_win_get_config(float.win)
  assert(config.col + config.width == info.wincol - 1 + info.width - 1, 'HUD must leave one clear right cell')
  assert(config.row == info.winrow - 1 + (info.winbar or 0), 'top placement changed')
  assert(config.width <= info.width - info.textoff - 1, 'HUD overflow past gutters or margin')
  assert(config.height == #lines, 'margin introduced an empty row')
  for _, line in ipairs(lines) do
    assert(line:sub(1, 1) == ' ', 'every rendered HUD row must start with a padding cell')
    assert(vim.fn.strdisplaywidth(line) == config.width, 'row alignment must use display cells')
  end
  local ns = api.nvim_get_namespaces()['hud.nvim']
  for _, mark in ipairs(api.nvim_buf_get_extmarks(float.buf, ns, 0, -1, { details = true })) do
    local line, col, details = lines[mark[2] + 1], mark[3], mark[4]
    assert(col >= 1 and details.end_col <= #line, 'highlight must stay after padding and inside the row')
  end
  return info, config
end
local function highlighted(source, group, text)
  local lines, float = rows(source)
  local ns = api.nvim_get_namespaces()['hud.nvim']
  for _, mark in ipairs(api.nvim_buf_get_extmarks(float.buf, ns, 0, -1, { details = true })) do
    local details = mark[4]
    if details.hl_group == group and lines[mark[2] + 1]:sub(mark[3] + 1, details.end_col) == text then
      return
    end
  end
  error('missing highlight: ' .. group .. ' on ' .. text)
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
  right_margin(source)
  local border = api.nvim_win_get_config(float.win).border
  assert(border == nil or border == 'none' or #border == 0, 'unexpected border')
  assert(#initial == 3 and api.nvim_win_get_config(float.win).height == 3, 'empty rows did not compact')
  assert(initial[1] == ' Example.java o/example', 'longest row must gain exactly one left cell')
  highlighted(source, 'Title', 'Example.java')
  highlighted(source, 'WinBar', ' o/example')
  highlighted(source, 'WinBar', ('%4d,%-3d'):format(15, 3))
  contains(initial[1], 'Example.java o/example')
  assert(not initial[1]:find('src/main/java', 1, true), 'Maven prefix retained')
  contains(initial[3], '15,3')
  assert(vim.trim(initial[2]) == ' hud-test', 'clean branch without dirty marker')
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
  assert(updated[1] == '  Example.java o/example', 'modified filename row must keep one shared leading cell')
  contains(updated[1], ' ')
  assert(vim.trim(updated[2]) == ' 1  hud-test', 'dirty branch keeps diff counts without asterisk')
  contains(updated[3], '15,3')
  contains(updated[4], ' 1')
  contains(updated[4], ' 1')
  highlighted(source, 'Title', 'Example.java')
  highlighted(source, 'HudGitChanged', '  1')
  highlighted(source, 'DiagnosticError', '  1')
  highlighted(source, 'DiagnosticWarn', '  1')
  git('checkout', '-b', 'hud-next')
  require('gitsigns').refresh()
  assert(
    vim.wait(5000, function()
      return (vim.b[buf].gitsigns_status_dict or {}).head == 'hud-next'
    end, 10),
    'real branch update'
  )
  settle()
  assert(vim.trim(rows()[2]) == ' 1  hud-next', 'branch update without dirty marker')
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
  contains(rows(second)[3], '18,6')
  assert(vim.trim(rows(source)[2]) == ' hud-test', 'inactive must show only branch')
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
  right_margin(api.nvim_get_current_win())
  vim.cmd('vsplit')
  api.nvim_win_set_cursor(0, { 15, 0 })
  event('CursorMoved')
  contains(rows()[1], 'o/e/v/l/p/日')
  api.nvim_win_set_width(0, 18)
  event('WinResized')
  local narrow = rows()
  contains(narrow[1], 'Example.java')
  assert(not narrow[1]:find('o/e/', 1, true), 'path did not yield')
  assert(not narrow[2]:find('hud-test', 1, true), 'branch did not yield')
  local info = right_margin(api.nvim_get_current_win())
  api.nvim_win_set_width(0, info.textoff + 2)
  event('WinResized')
  local _, tiny = right_margin(api.nvim_get_current_win())
  assert(tiny.width == 1, 'one usable cell must remain available for padding')
  for _, line in ipairs(rows()) do
    assert(line == ' ', 'one-cell HUD must reserve the whole row for padding')
  end
  api.nvim_win_set_width(0, info.textoff + 1)
  event('WinResized')
  assert(not floats()[api.nvim_get_current_win()], 'HUD must hide when only the right margin fits')
  vim.cmd('only')
  event('WinResized')
  contains(rows()[1], 'o/e/v/l/p/日')
  right_margin(api.nvim_get_current_win())

  -- Stop the real watcher before deterministic row-state arrival/removal checks.
  require('gitsigns').detach()
  local original = api.nvim_get_current_win()
  vim.cmd('vsplit')
  local other = api.nvim_get_current_win()
  for _, state in ipairs({
    { diff = true, expected = { ' 2  hud-test', 'ruler' } },
    { added = 3, expected = { ' 3  hud-test', 'ruler' } },
    { removed = 4, expected = { ' 4  hud-test', 'ruler' } },
    { added = 3, diff = true, removed = 4, expected = { ' 3  2  4  hud-test', 'ruler' } },
    { diagnostics = true, expected = { ' hud-test', 'ruler', ' 1' } },
    { expected = { ' hud-test', 'ruler' } },
    { diagnostics = true, severity = 3, diff = true, expected = { ' 2  hud-test', 'ruler' } },
    { diagnostics = true, diff = true, expected = { ' 2  hud-test', 'ruler', ' 1' } },
    { head = 'feature/日本語', expected = { ' feature/日本語', 'ruler' } },
    { head = 'release(v2)', expected = { ' release(v2)', 'ruler' } },
    { head = 'HEAD', expected = { ' HEAD', 'ruler' } },
    { head = 'a1b2c3d', expected = { ' a1b2c3d', 'ruler' } },
    { head = '', diff = true, expected = { ' 2', 'ruler' } },
    { head = '', diagnostics = true, expected = { 'ruler', ' 1' } },
    { head = '', expected = { 'ruler' } },
    { diff = true, expected = { ' 2  hud-test', 'ruler' } },
    { expected = { ' hud-test', 'ruler' } },
  }) do
    vim.diagnostic.set(
      ns,
      buf,
      state.diagnostics and { { lnum = 2, col = 0, message = 'fixture', severity = state.severity or 1 } } or {}
    )
    vim.b[buf].gitsigns_status_dict = {
      head = state.head or 'hud-test',
      added = state.added,
      changed = state.diff and 2 or 0,
      removed = state.removed,
    }
    event('User', 'GitSignsUpdate')
    for _, win in ipairs({ original, other }) do
      api.nvim_set_current_win(win)
      settle()
      local rendered, hud_float = rows(win)
      assert(#rendered == 1 + #state.expected, 'compacted row count')
      assert(api.nvim_win_get_config(hud_float.win).height == #rendered, 'stale HUD height')
      for index, expected in ipairs(state.expected) do
        if expected == 'ruler' then
          local cursor = api.nvim_win_get_cursor(win)
          expected = ('%d,%d'):format(cursor[1], cursor[2] + 1)
        end
        assert(vim.trim(rendered[index + 1]) == expected, 'active row order or spacing: ' .. rendered[index + 1])
      end
      right_margin(win)
      local inactive = win == original and other or original
      local inactive_rows, inactive_float = rows(inactive)
      local height = state.head == '' and 1 or 2
      assert(#inactive_rows == height and api.nvim_win_get_config(inactive_float.win).height == height, 'inactive rows')
      if height == 2 then
        assert(
          vim.trim(inactive_rows[2]) == ' ' .. (state.head or 'hud-test'),
          'inactive branch only'
        )
      end
      right_margin(inactive)
    end
  end
  assert(vim.fn.char2nr('') == 0xEC6F, 'exact requested branch icon')
  vim.b[buf].gitsigns_status_dict = { head = '日本語/feature' }
  event('User', 'GitSignsUpdate')
  for _, win in ipairs({ original, other }) do
    api.nvim_set_current_win(win)
    local width = api.nvim_win_get_width(win)
    local info = vim.fn.getwininfo(win)[1]
    api.nvim_win_set_width(win, info.textoff + 2 + vim.fn.strdisplaywidth(' 日本'))
    event('WinResized')
    assert(vim.trim(rows(win)[2]) == ' 日本', 'branch icon, one space and multibyte clipping')
    right_margin(win)
    api.nvim_win_set_width(win, width)
    event('WinResized')
  end
  api.nvim_set_current_win(original)
  vim.cmd('only')
  local filename = '日本語é' .. string.rep('長', 50) .. '.java'
  api.nvim_buf_set_name(buf, root .. '/' .. filename)
  event('BufFilePost')
  for _, case in ipairs({
    { 0, '' },
    { 1, '' },
    { 2, '日' },
    { 3, '日' },
    { 4, '日本' },
    { 6, '日本語' },
    { 7, '日本語é' },
    { 8, '日本語é' },
    { 9, '日本語é長' },
  }) do
    vim.cmd('vsplit')
    local win = api.nvim_get_current_win()
    local info = vim.fn.getwininfo(win)[1]
    api.nvim_win_set_width(win, info.textoff + 2 + case[1])
    event('WinResized')
    local lines = rows(win)
    right_margin(win)
    assert(vim.trim(lines[1]) == case[2], 'Japanese/combining filename clipping: ' .. vim.inspect(lines[1]))
    if case[2] ~= '' then
      highlighted(win, 'Title', case[2])
    end
    vim.cmd('only')
  end
  vim.diagnostic.reset(ns, buf)
  vim.b[buf].gitsigns_status_dict = nil
  event('User', 'GitSignsUpdate')
  local empty = rows()
  assert(#empty == 2, 'empty trailing rows retained')
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
  assert(#rows() == 2)

  vim.o.background = 'light'
  vim.cmd('colorscheme sorairo')
  settle()
  for _, item in ipairs({ { 'Added', 10 }, { 'Changed', 12 }, { 'Removed', 9 } }) do
    local hl = api.nvim_get_hl(0, { name = 'HudGit' .. item[1] })
    assert(hl.fg == tonumber(vim.g['terminal_color_' .. item[2]]:sub(2), 16) and hl.bold, 'theme refresh')
  end
  local visible_buf = api.nvim_get_current_buf()
  vim.diagnostic.set(ns, visible_buf, { { lnum = 2, col = 0, message = 'visible', severity = 1 } })
  vim.b[visible_buf].gitsigns_status_dict = { head = 'visible', changed = 1 }
  event('User', 'GitSignsUpdate')
  local source = api.nvim_get_current_win()
  vim.cmd('vsplit')
  local other = api.nvim_get_current_win()
  api.nvim_set_current_win(source)
  local width = api.nvim_win_get_width(source)
  local function visible(active, inactive)
    local content, float = rows(active)
    assert(#content == 4 and #rows(inactive) == 2, 'visible active/inactive rows')
    assert(vim.trim(rows(inactive)[2]) == ' visible', 'inactive branch in Visual/focus transitions')
    contains(content[2], ' 1')
    contains(content[4], ' 1')
    assert(vim.wo[float.win].winhighlight:match('^Normal:([^,]+)') == 'WinBar')
    assert(vim.wo[select(2, rows(inactive)).win].winhighlight:match('^Normal:([^,]+)') == 'WinBarNC')
    for _, win in ipairs({ active, inactive }) do
      local _, config = right_margin(win)
      assert(config.border == nil or config.border == 'none' or #config.border == 0, 'border appeared')
    end
  end
  local edge = right_margin(source)
  local text = '日本語' .. string.rep('x', edge.width - edge.textoff - vim.fn.strdisplaywidth('日本語'))
  api.nvim_buf_set_lines(visible_buf, 0, 1, false, { text })
  api.nvim_win_set_cursor(source, { 1, #text - 1 })
  event('BufModifiedSet')
  event('CursorMoved')
  local cursor = vim.fn.screenpos(source, 1, #text)
  local _, hud_edge = right_margin(source)
  assert(cursor.col == edge.wincol + edge.width - 1, 'multibyte cursor fixture must reach the right edge')
  assert(hud_edge.col + hud_edge.width == cursor.col - 1, 'HUD covers the rightmost cursor cell')
  for line = 1, 6 do
    api.nvim_win_set_cursor(source, { line, 0 })
    vim.fn.winrestview({ topline = 1, lnum = line, col = 0 })
    event('CursorMoved')
    assert(vim.fn.winline() == line, 'cursor fixture did not cross HUD rows')
    visible(source, other)
  end
  for _, mode in ipairs({ 'v', 'V', '\22' }) do
    api.nvim_win_set_cursor(source, { 1, 0 })
    vim.cmd('normal! ' .. mode)
    assert(api.nvim_get_mode().mode == mode, 'Visual mode fixture')
    event('ModeChanged')
    visible(source, other)
    for line = 2, 5 do
      api.nvim_win_set_cursor(source, { line, 0 })
      event('CursorMoved')
      assert(api.nvim_get_mode().mode == mode, 'Visual selection ended')
      visible(source, other)
    end
    api.nvim_win_set_width(source, 18)
    event('WinResized')
    visible(source, other)
    api.nvim_set_current_win(other)
    settle()
    visible(other, source)
    api.nvim_set_current_win(source)
    settle()
    visible(source, other)
    vim.cmd('normal! \27')
    event('ModeChanged')
    api.nvim_win_set_width(source, width)
    event('WinResized')
    visible(source, other)
  end
  vim.cmd('only')
  api.nvim_win_set_cursor(0, { 15, 0 })
  event('CursorMoved')
  assert(#rows() == 4)
  vim.cmd('split')
  api.nvim_win_set_height(0, 3)
  event('WinResized')
  assert(not floats()[api.nvim_get_current_win()], 'short pane overflow')
  vim.diagnostic.reset(ns, visible_buf)
  vim.b[visible_buf].gitsigns_status_dict = nil
  event('User', 'GitSignsUpdate')
  local compact, compact_float = rows()
  assert(#compact == 2 and api.nvim_win_get_config(compact_float.win).height == 2, 'compacted short pane stayed hidden')
  assert(#warnings == 0, vim.inspect(warnings))
  print(
    'HUD integration: left padding/highlights, row compaction, git/diagnostics, caching, widths, theme, cursor overlap and Visual modes passed'
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
