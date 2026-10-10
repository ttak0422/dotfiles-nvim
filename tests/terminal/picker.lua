local root, temp = vim.env.TERMINAL_TEST_ROOT, vim.env.TERMINAL_TEST_TMP
for _, name in ipairs({ 'NFNL', 'TELESCOPE', 'PLENARY', 'LIVE_GREP_ARGS', 'PTERM_PLUGIN' }) do
  vim.opt.runtimepath:append(assert(vim.env['TERMINAL_TEST_' .. name], name))
end
vim.o.columns, vim.o.lines = 120, 40
vim.cmd.cd(vim.env.TERMINAL_TEST_CWD)
local notices = {}
vim.notify = function(message) notices[#notices + 1] = message end

local telescope = require('telescope')
telescope.setup({ defaults = { sorting_strategy = 'ascending' } })
dofile(vim.env.TERMINAL_TEST_TELESCOPE .. '/plugin/telescope.lua')
local original_grep = telescope.extensions.pterm.grep
local path = 'v2/fnl/pterm-picker.fnl'
local compiled = '-- [nfnl] ' .. path .. '\n' .. require('nfnl.fennel')['compile-string'](
  table.concat(vim.fn.readfile(root .. '/' .. path), '\n'), { filename = path })
assert(compiled == table.concat(vim.fn.readfile(root .. '/v2/lua/autogen/pterm-picker.lua'), '\n'),
  'Fennel/Lua parity')
dofile(root .. '/v2/lua/autogen/pterm-picker.lua')
dofile(root .. '/v2/lua/autogen/pterm.lua')
assert(telescope.extensions.pterm.grep == original_grep, 'grep picker must remain unchanged')
assert(vim.fn.exists(':Pterm') == 2, 'existing Pterm usercommand must remain')
assert(vim.fn.exists(':Terminal') == 0, 'do not add a Terminal usercommand')
local pterm = require('pterm')
pterm.config.auto_redraw = false
local actions, state = require('telescope.actions'), require('telescope.actions.state')
local calls, open = {}, pterm.open
pterm.open = function(name, argv)
  calls[#calls + 1] = { name = name, argv = argv }
  return open(name, argv)
end

local function wait(predicate, message)
  assert(vim.wait(5000, predicate, 10), message .. '\n' .. vim.inspect(notices))
end
local function reports()
  local result = {}
  for _, file in ipairs(vim.fn.glob(temp .. '/child-*.json', false, true)) do
    result[#result + 1] = vim.json.decode(table.concat(vim.fn.readfile(file), '\n'))
  end
  return result
end
local function record(count, argv)
  wait(function() return #reports() == count end, 'expected child count ' .. count)
  for _, report in ipairs(reports()) do
    if vim.deep_equal(report.argv, argv) then
      assert(vim.uv.fs_realpath(report.cwd) == vim.uv.fs_realpath(vim.env.TERMINAL_TEST_CWD))
      return report
    end
  end
  error('argv changed: ' .. vim.inspect(reports()))
end
local function quote(value)
  return '"' .. value:gsub('"', '\\"') .. '"'
end
local function picker(prompt, has_selection, alias, preview)
  vim.cmd.stopinsert()
  vim.cmd('Telescope pterm' .. (alias and ' sessions' or '') .. (preview and '' or ' previewer=false'))
  local buf = vim.api.nvim_get_current_buf()
  local current = state.get_current_picker(buf)
  local completed
  current:register_completion_callback(function(p) completed = p:_get_prompt() end)
  current:set_prompt(prompt)
  wait(function()
    return completed == prompt and (current:get_selection() ~= nil) == has_selection
  end, 'picker did not finish filtering: ' .. prompt)
  return current, buf
end
local function enter(buf)
  -- Invoke the real insert-mode <CR> mapping installed in the prompt buffer.
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, 'i')) do
    if map.lhs == '<CR>' then
      assert(map.callback, 'Telescope Enter callback missing')
      map.callback()
      return
    end
  end
  error('Telescope Enter mapping missing')
end
local function choose(current, name)
  for _ = 1, current.manager:num_results() do
    if current:get_selection().value == name then return end
    actions.move_selection_next(current.prompt_bufnr)
  end
  error('selection not found: ' .. name)
end
local function current_session(name)
  local buf = vim.api.nvim_get_current_buf()
  assert(vim.api.nvim_buf_get_name(buf) == 'pterm://' .. name)
  return { buf = buf, job = vim.b[buf].terminal_job_id }
end
local function close_with_code(session, name, code)
  vim.fn.chansend(session.job, 'exit ' .. code .. '\n')
  wait(function() return not vim.api.nvim_buf_is_valid(session.buf) end, 'pterm exit cleanup')
  assert(vim.tbl_contains(notices, "Session '" .. name .. "' exited (" .. code .. ')'))
end

-- Empty prompt with no results does nothing; surrounding/trailing spaces are ignored.
local _, buf = picker('', false)
enter(buf)
assert(#calls == 0 and #reports() == 0)
_, buf = picker('    ', false)
enter(buf)
assert(#calls == 0)
_, buf = picker('   shell   ', false)
enter(buf)
local shell_report, shell = record(1, {}), current_session('shell')

-- Real prompt parsing and pterm execvp preserve quoted spaces/quotes and shell symbols.
local argv = { 'one', 'two words', "O'Reilly", '"quoted"', 'back\\slash', '',
  '$(touch SHOULD_NOT_EXIST)', '`touch ALSO_NOT`', ';', '|', '>', '$HOME', '%', '#', '--flag' }
local words = { 'review', quote(vim.env.TERMINAL_TEST_CHILD) }
for _, arg in ipairs(argv) do words[#words + 1] = quote(arg) end
_, buf = picker(table.concat(words, '  ') .. '   ', false, true)
enter(buf)
local review_report, review = record(2, argv), current_session('review')
assert(vim.fn.filereadable('SHOULD_NOT_EXIST') == 0 and vim.fn.filereadable('ALSO_NOT') == 0)

-- Existing selection takes priority, even when the prompt is also a complete name.
_, buf = picker('"alternate review fixture-command" fixture-command legacy', false)
enter(buf)
local legacy_report, legacy = record(3, { 'legacy' }), current_session('alternate review fixture-command')
local current
current, buf = picker('review', true, false, true)
choose(current, 'alternate review fixture-command')
wait(function()
  local preview = current.previewer.state
  return preview and preview.bufnr and preview.pterm_preview_job == nil
    and not table.concat(vim.api.nvim_buf_get_lines(preview.bufnr, 0, -1, false), '\n'):find('Loading preview', 1, true)
end, 'real preview did not finish')
enter(buf)
assert(current_session('alternate review fixture-command').buf == legacy.buf and calls[#calls].argv == nil)
_, buf = picker('alternate review fixture-command', true)
enter(buf)
assert(current_session('alternate review fixture-command').buf == legacy.buf and #reports() == 3)
_, buf = picker('rev', true)
choose(state.get_current_picker(buf), 'review')
enter(buf)
assert(current_session('review').buf == review.buf and calls[#calls].argv == nil)

-- No results plus an existing first name is a collision, never command injection.
_, buf = picker('review fixture-command replacement', false)
enter(buf)
assert(notices[#notices]:find('already exists', 1, true))
assert(vim.api.nvim_buf_is_valid(buf) and #reports() == 3)
assert(vim.uv.kill(review_report.pid, 0) and vim.uv.kill(legacy_report.pid, 0))
actions.close(buf)
_, buf = picker('unused nonexistent-terminal-fixture', false)
enter(buf)
assert(notices[#notices]:find('Executable not found', 1, true))
assert(vim.api.nvim_buf_is_valid(buf) and #reports() == 3)
actions.close(buf)

-- An exact name created after the finder snapshot reconnects, including spaces.
_, buf = picker('late  name', false)
local result = vim.system({ vim.env.TERMINAL_TEST_PTERM, 'new', 'late  name', '--',
  vim.env.TERMINAL_TEST_CHILD, 'late' }):wait()
assert(result.code == 0, result.stderr)
record(4, { 'late' })
enter(buf)
local late = current_session('late  name')
assert(vim.deep_equal(calls[#calls].argv, { 'late  name' }) and #reports() == 4)

-- Multiple separators produce arguments, not a session name containing the command.
_, buf = picker("multi    fixture-command   first   second   'single quoted'  ", false)
enter(buf)
record(5, { 'first', 'second', 'single quoted' })
local multi = current_session('multi')
assert(vim.tbl_contains(pterm.list(), 'multi'))

-- Empty prompt with results keeps the upstream selection behavior.
current, buf = picker('', true)
choose(current, 'shell')
enter(buf)
assert(current_session('shell').buf == shell.buf and calls[#calls].argv == nil)
assert(#reports() == 5 and vim.uv.kill(shell_report.pid, 0))

-- Detach and reconnect the same daemon; no second command/child is launched.
pterm.detach('review')
wait(function() return not vim.api.nvim_buf_is_valid(review.buf) end, 'detach cleanup')
_, buf = picker('review', true)
choose(state.get_current_picker(buf), 'review')
enter(buf)
review = current_session('review')
assert(#reports() == 5 and vim.uv.kill(review_report.pid, 0))

-- Preserve pterm plugin exit semantics: remove the buffer, notify status, no shell fallback.
close_with_code(review, 'review', 7)
close_with_code(shell, 'shell', 0)
close_with_code(legacy, 'alternate review fixture-command', 0)
close_with_code(late, 'late  name', 0)
close_with_code(multi, 'multi', 0)
wait(function() return #pterm.list() == 0 end, 'test sessions did not exit')
assert(#reports() == 5)
print('PASS: Telescope prompt/filter/selection/Enter, shell, argv, cwd, collisions, reconnect, exits 0/7, Fennel parity')
