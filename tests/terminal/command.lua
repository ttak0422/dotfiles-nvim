local root, temp = vim.env.TERMINAL_TEST_ROOT, vim.env.TERMINAL_TEST_TMP
for _, name in ipairs({ 'NFNL', 'TOGGLETERM', 'TOGGLER', 'PTERM_PLUGIN' }) do
  vim.opt.runtimepath:append(assert(vim.env['TERMINAL_TEST_' .. name], name))
end
vim.o.shell = '/bin/sh' -- Toggleterm's bridge launcher, never the child shell.
vim.o.shellcmdflag = '-c'
vim.o.shellquote, vim.o.shellxquote = '', ''
vim.o.columns, vim.o.lines = 100, 40
vim.cmd.cd(vim.env.TERMINAL_TEST_CWD)

local function source(name)
  local path = 'v2/fnl/' .. name .. '.fnl'
  local compiled = '-- [nfnl] ' .. path .. '\n' .. require('nfnl.fennel')['compile-string'](
    table.concat(vim.fn.readfile(root .. '/' .. path), '\n'), { filename = path })
  local output = root .. '/v2/lua/autogen/' .. name .. '.lua'
  assert(compiled == table.concat(vim.fn.readfile(output), '\n'), 'Fennel/Lua parity: ' .. name)
  return function() return dofile(output) end
end
local configure, startup = source('toggle-plugins'), source('terminal-command')
dofile(root .. '/v2/lua/autogen/toggleterm.lua')
local pterm = require('pterm')
pterm.config.socket_dir = vim.env.PTERM_SOCKET_DIR
_G.args = { pterm = vim.env.TERMINAL_TEST_PTERM }

-- Model bundler's module hook, including its reentrant require during postConfig.
local loads = 0
package.preload.toggler = function()
  local toggler = dofile(vim.env.TERMINAL_TEST_TOGGLER .. '/lua/toggler/init.lua')
  package.loaded.toggler = toggler
  loads = loads + 1
  configure()
  return toggler
end
startup()
assert(vim.tbl_contains(vim.fn.getcompletion('Terminal fixture-com', 'cmdline'), 'fixture-command'))
assert(loads == 0, 'completion must not load toggler or start a process')

local function wait(predicate, message)
  assert(vim.wait(5000, predicate, 10), message .. '\n'
    .. table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'))
end
local function reports()
  local result = {}
  for _, path in ipairs(vim.fn.glob(temp .. '/child-*.json', false, true)) do
    result[#result + 1] = vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))
  end
  return result
end
local function record(n, argv)
  wait(function() return #reports() == n end, 'expected child count ' .. n)
  for _, report in ipairs(reports()) do
    if vim.deep_equal(report.argv, argv) then
      assert(vim.uv.fs_realpath(report.cwd) == vim.uv.fs_realpath(vim.env.TERMINAL_TEST_CWD),
        'cwd was not preserved: ' .. report.cwd)
      return report
    end
  end
  error('argv changed: ' .. vim.inspect(reports()))
end
local function term()
  local buf = vim.api.nvim_get_current_buf()
  for _, t in pairs(require('toggleterm.terminal').get_all()) do
    if t.bufnr == buf then return t end
  end
  error('current terminal missing')
end
local function rejects(command, message)
  local ok, err = pcall(vim.cmd, command)
  assert(not ok and err:find(message, 1, true), tostring(err))
end
local function exarg(value)
  return (value:gsub('\\', '\\\\'):gsub(' ', '\\ '))
end
local function session(idx)
  return 'vim_tab' .. vim.api.nvim_get_current_tabpage() .. '_idx' .. idx
end
local exit_codes = {}
vim.api.nvim_create_autocmd('TermClose', {
  callback = function(event) exit_codes[event.buf] = vim.v.event.status end,
})
local function exit(t, code)
  vim.fn.chansend(t.job_id, 'exit ' .. code .. '\n')
  wait(function() return exit_codes[t.bufnr] ~= nil end, 'child did not exit')
  assert(exit_codes[t.bufnr] == code, 'exit code changed: ' .. exit_codes[t.bufnr])
  assert(t:is_open() and vim.api.nvim_buf_is_valid(t.bufnr), 'exit must retain the terminal buffer')
end

-- No arguments uses SHELL. Reopening and Ctrl-number toggling keep the child alive.
vim.cmd.Terminal()
assert(loads == 1)
local shell_report, shell = record(1, {}), term()
vim.cmd.Terminal()
assert(term() == shell)
local toggler = require('toggler')
toggler.toggle('term0')
assert(not shell:is_open())
toggler.toggle('term0')
assert(term() == shell and #reports() == 1)
rejects('Terminal fixture-command ignored', 'Terminal already exists')
assert(vim.uv.kill(shell_report.pid, 0))

-- Preserve Ex fargs through the lazy trampoline, shell quoting, pterm, and execvp.
-- Re-register the startup command as in a fresh editor before first module load.
vim.api.nvim_del_user_command('Terminal')
package.loaded.toggler = nil
startup()
local argv = { 'one', 'two words', "O'Reilly", '"quoted"', 'back\\slash',
  '$(touch SHOULD_NOT_EXIST)', '`touch ALSO_NOT`', ';', '|', '>', '$HOME', '%', '#', '--flag' }
local command = { '1Terminal', exarg(vim.env.TERMINAL_TEST_CHILD) }
for _, arg in ipairs(argv) do command[#command + 1] = exarg(arg) end
vim.cmd(table.concat(command, ' '))
local command_report, direct = record(2, argv), term()
assert(vim.fn.filereadable('SHOULD_NOT_EXIST') == 0 and vim.fn.filereadable('ALSO_NOT') == 0)
startup() -- Must not replace an already-loaded command with a recursive trampoline.
vim.cmd('1Terminal')
assert(term() == direct and #reports() == 2)
assert(vim.tbl_contains(vim.fn.getcompletion('Terminal fixture-com', 'cmdline'), 'fixture-command'))
vim.fn.writefile({ '' }, 'argument-file')
assert(vim.tbl_contains(vim.fn.getcompletion('Terminal fixture-command argument-f', 'cmdline'), 'argument-file'))
rejects('1Terminal fixture-command changed', 'Terminal already exists')
rejects('2Terminal nonexistent-terminal-test-executable', 'Terminal executable not found')
rejects('10Terminal fixture-command', 'Terminal slot must be between 0 and 9')
assert(#reports() == 2 and vim.uv.kill(command_report.pid, 0))

-- An existing daemon without a local Toggleterm object must also be protected.
local external = session(3)
local created = vim.system({ args.pterm, 'new', external, '--', vim.env.TERMINAL_TEST_CHILD, 'external' }):wait()
assert(created.code == 0, created.stderr)
local external_report = record(3, { 'external' })
rejects('3Terminal fixture-command replacement', 'Terminal already exists')
assert(vim.uv.kill(external_report.pid, 0))
vim.cmd('3Terminal')
local attached = term()
assert(#reports() == 3)
exit(attached, 0)

vim.cmd('1Terminal')
exit(direct, 7)
vim.cmd('1Terminal')
assert(vim.api.nvim_get_current_buf() == direct.bufnr and #reports() == 3,
  'reopening a completed buffer must not start a shell')
rejects('1Terminal fixture-command replacement', 'Terminal already exists')

-- Same numeric slot in a different tab is a new session.
direct:close()
vim.cmd.tabnew()
vim.cmd('1Terminal fixture-command other-tab')
record(4, { 'other-tab' })
exit(term(), 0)
vim.cmd.tabfirst()
shell:open()
exit(shell, 0)
print('PASS: lazy completion, Fennel parity, argv, cwd, shell default, slots, reuse, missing executable, exit 0/7')
