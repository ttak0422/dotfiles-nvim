-- Exercise the evaluated v3 configuration with real hud.nvim floats and Git roots.
local api = vim.api
vim.opt.rtp:append(assert(vim.env.HUD_TEST_PLUGIN, 'HUD_TEST_PLUGIN'))
local hud = require('hud')
local base = vim.fn.tempname()
local repository = base .. '/repository'
-- Test runners can themselves live below a .git marker. Limit discovery to our fixtures.
local find_root = vim.fs.root
vim.fs.root = function(...)
  local found = find_root(...)
  return found and vim.startswith(found, base .. '/') and found or nil
end
local warnings = {}
vim.notify = function(message)
  warnings[#warnings + 1] = message
end
local function settle()
  vim.cmd('redraw')
  vim.wait(30)
end
local function event(name)
  api.nvim_exec_autocmds(name, {})
  settle()
end
local function rows(win)
  win = win or api.nvim_get_current_win()
  for _, candidate in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(candidate)
    if vim.b[buf].hud_source_win == win then
      return api.nvim_buf_get_lines(buf, 0, -1, false), api.nvim_win_get_config(candidate)
    end
  end
end
local function header(location, filename, win)
  local lines, config = rows(win)
  assert(lines, 'missing HUD')
  assert(vim.trim(lines[1]) == location, 'location: ' .. vim.inspect(lines))
  assert(vim.trim(lines[2]) == filename, 'filename: ' .. vim.inspect(lines))
  assert(config.height == #lines, 'stale HUD height')
  for _, line in ipairs(lines) do
    assert(line:sub(1, 1) == ' ', 'missing left padding')
    assert(vim.fn.strdisplaywidth(line) == config.width, 'unaligned HUD rows')
  end
end
local function git(directory, ...)
  local command = { 'git', '-C', directory }
  vim.list_extend(command, { ... })
  local result = vim.system(command, { text = true }):wait()
  assert(result.code == 0, result.stderr)
end
local content = {}
for index = 1, 50 do
  content[index] = 'source line ' .. index
end
local function fixture(name)
  vim.fn.mkdir(vim.fn.fnamemodify(name, ':h'), 'p')
  vim.fn.writefile(content, name)
end
local function edit(name, filetype)
  vim.cmd.edit(vim.fn.fnameescape(name))
  vim.bo.filetype = filetype or ''
  api.nvim_win_set_cursor(0, { 20, 0 })
  event('CursorMoved')
end
local function check()
  vim.o.laststatus, vim.o.showtabline = 0, 0
  vim.o.winminwidth, vim.o.winminheight = 1, 1
  vim.o.winwidth, vim.o.winheight = 1, 1
  vim.wo.wrap = false
  local name = repository .. '/src/main/java/org/example/Example.java'
  fixture(name)
  git(repository, 'init', '-b', 'hud-test')
  git(repository, 'add', '.')
  git(repository, '-c', 'user.name=HUD Test', '-c', 'user.email=hud@example.invalid', 'commit', '-m', 'fixture')
  edit(name, 'java')
  dofile(assert(vim.env.HUD_TEST_CONFIG, 'HUD_TEST_CONFIG'))
  settle()
  header('repository o/example', 'Example.java')
  assert(#rows() == 3, 'location, filename and ruler must occupy separate rows')

  local buf, source = api.nvim_get_current_buf(), api.nvim_get_current_win()
  vim.b[buf].gitsigns_status_dict = { head = 'hud-test', changed = 2 }
  event('User')
  api.nvim_buf_set_lines(buf, 0, 1, false, { 'changed' })
  event('BufModifiedSet')
  header('repository o/example', ' Example.java')
  assert(vim.trim(rows()[3]) == ' 2  hud-test', 'Git status must follow the filename')
  vim.bo.modified = false
  event('BufModifiedSet')
  vim.cmd('vsplit')
  local other = api.nvim_get_current_win()
  event('WinEnter')
  for _, win in ipairs({ source, other }) do
    header('repository o/example', 'Example.java', win)
  end
  assert(#rows(source) == 3 and #rows(other) == 4, 'active/inactive row count')
  assert(vim.trim(rows(source)[3]) == ' hud-test', 'inactive branch row')

  local walks, fsroot = 0, vim.fs.root
  vim.fs.root = function(...)
    walks = walks + 1
    return fsroot(...)
  end
  for line = 20, 25 do
    api.nvim_win_set_cursor(other, { line, 0 })
    event('CursorMoved')
  end
  vim.fs.root = fsroot
  assert(walks == 0, 'cursor movement must not walk the filesystem')

  api.nvim_win_set_width(other, 18)
  event('WinResized')
  header('repository', 'Example.java')
  vim.cmd('only')
  event('WinResized')
  header('repository o/example', 'Example.java')

  local renamed = repository .. '/lib/Renamed.java'
  vim.fn.mkdir(repository .. '/lib', 'p')
  api.nvim_buf_set_name(buf, renamed)
  event('BufFilePost')
  header('repository lib', 'Renamed.java')
  for _, ft in ipairs({ 'java', 'kotlin', 'scala' }) do
    local file = repository .. '/src/test/' .. ft .. '/org/example/Example.' .. ft
    fixture(file)
    edit(file, ft)
    header('repository o/example', 'Example.' .. ft)
  end

  -- Root files and unnamed buffers keep a location row, so filenames stay second.
  fixture(repository .. '/README.md')
  edit(repository .. '/README.md')
  header('repository .', 'README.md')
  local nested = repository .. '/nested'
  fixture(nested .. '/lib/Nested.lua')
  git(nested, 'init')
  edit(nested .. '/lib/Nested.lua')
  header('nested lib', 'Nested.lua')
  local worktree = base .. '/linked-tree'
  git(repository, 'worktree', 'add', '--detach', worktree)
  edit(worktree .. '/src/main/java/org/example/Example.java', 'java')
  header('linked-tree o/example', 'Example.java')

  -- Neither the cwd's repository nor a similarly named sibling may leak into the label.
  local plain = base .. '/repository-other'
  fixture(plain .. '/notes/Notes.txt')
  vim.cmd.cd(vim.fn.fnameescape(plain))
  edit(plain .. '/notes/Notes.txt')
  header('notes', 'Notes.txt')
  local directory = 'directory-that-does-not-fit'
  fixture(plain .. '/' .. directory .. '/Clipped.txt')
  edit(plain .. '/' .. directory .. '/Clipped.txt')
  header(directory, 'Clipped.txt')
  vim.cmd('vsplit')
  api.nvim_win_set_width(0, 18)
  event('WinResized')
  local clipped = vim.trim(rows()[1])
  assert(clipped ~= '' and vim.startswith(directory, clipped), 'non-Git path must clip, not disappear')
  assert(vim.trim(rows()[2]) == 'Clipped.txt', 'filename must stay second in a narrow non-Git window')
  vim.cmd('only')
  event('WinResized')
  edit(plain .. '/notes/Notes.txt')
  vim.cmd.cd(vim.fn.fnameescape(plain .. '/notes'))
  settle()
  header('.', 'Notes.txt')
  vim.cmd.cd(vim.fn.fnameescape(repository))
  settle()
  header(vim.fn.pathshorten(plain .. '/notes'), 'Notes.txt')
  vim.cmd('enew')
  api.nvim_buf_set_lines(0, 0, -1, false, content)
  vim.bo.modified = false
  api.nvim_win_set_cursor(0, { 20, 0 })
  event('CursorMoved')
  header('.', '[No Name]')

  -- URI-like names do not acquire a filesystem repository label.
  api.nvim_buf_set_name(0, 'term://' .. repository .. '//123:shell')
  event('BufFilePost')
  assert(not vim.trim(rows()[1]):match('^repository '), 'terminal URI inherited repository')
  for _, buftype in ipairs({ 'nofile', 'prompt', 'help', 'quickfix' }) do
    vim.bo.buftype = buftype
    event('OptionSet')
    assert(not rows(), 'special buffer HUD: ' .. buftype)
  end
  vim.bo.buftype = ''
  for _, ft in ipairs({ 'gitcommit', 'Trouble', 'skk-terminal-input' }) do
    vim.bo.filetype = ft
    event('FileType')
    assert(not rows(), 'special filetype HUD: ' .. ft)
  end
  vim.bo.filetype = ''
  vim.wo.previewwindow = true
  event('OptionSet')
  assert(not rows(), 'preview HUD')
  assert(#warnings == 0, vim.inspect(warnings))
  print('HUD v3: repository/path and filename rows, non-Git, roots, nested repositories, worktrees, caching and filters passed')
end
local ok, err = xpcall(check, debug.traceback)
hud.disable()
vim.cmd.cd(vim.fn.fnameescape(vim.env.HOME))
vim.fn.delete(base, 'rf')
if not ok then
  io.stderr:write(err .. '\n')
  vim.cmd('cquit 1')
end
vim.cmd('qa!')
