-- NFNL_PLUGIN_DIR=<pinned nfnl> nvim --headless -u NONE -i NONE -l tests/gitcommit.lua
local api = vim.api
local root = vim.fn.tempname()
local source = vim.fn.getcwd()
local original_system = vim.system
local function check()
  vim.opt.rtp:append(assert(vim.env.NFNL_PLUGIN_DIR, 'NFNL_PLUGIN_DIR'))
  local path = 'v2/fnl/after/ftplugin/gitcommit.fnl'
  local compiled = '-- [nfnl] ' .. path .. '\n' .. require('nfnl.fennel')['compile-string'](
    table.concat(vim.fn.readfile(path), '\n'), { filename = path })
  assert(compiled == table.concat(vim.fn.readfile('v2/lua/autogen/after/ftplugin/gitcommit.lua'), '\n'))
  vim.fn.mkdir(root .. '/runtime/after/ftplugin', 'p')
  vim.fn.writefile(vim.split(compiled, '\n', { plain = true }), root .. '/runtime/after/ftplugin/gitcommit.lua')
  local init = root .. '/init.lua'
  vim.fn.writefile({
    'vim.opt.rtp:append(' .. vim.inspect(root .. '/runtime/after') .. ')',
    'vim.cmd("filetype plugin on")',
    'vim.api.nvim_create_autocmd("VimEnter", { callback = function()',
    '  vim.fn.writefile({vim.json.encode({ lines = vim.api.nvim_buf_get_lines(0, 0, -1, false),',
    '    disk = vim.fn.readfile(vim.api.nvim_buf_get_name(0)), ft = vim.bo.filetype,',
    '    modified = vim.bo.modified })}, assert(vim.env.GITCOMMIT_RESULT))',
    '  vim.cmd("cquit 1")', -- Inspect without saving or creating a commit.
    'end })',
  }, init)
  local env = vim.fn.environ()
  for key in pairs(env) do
    if key:match('^GIT_') then env[key] = nil end
  end
  env.GIT_CONFIG_NOSYSTEM = '1'
  env.GIT_CONFIG_GLOBAL = '/dev/null'
  env.GIT_AUTHOR_NAME, env.GIT_COMMITTER_NAME = 'Fixture', 'Fixture'
  env.GIT_AUTHOR_EMAIL, env.GIT_COMMITTER_EMAIL = 'fixture@example.invalid', 'fixture@example.invalid'
  local function run(cwd, args, extra)
    local argv = { 'git', '-C', cwd }
    vim.list_extend(argv, args)
    return original_system(argv, { text = true, clear_env = true, env = vim.tbl_extend('force', env, extra or {}) }):wait(5000)
  end
  local function git(cwd, ...)
    local out = run(cwd, { ... })
    assert(out.code == 0, out.stderr)
    return vim.trim(out.stdout)
  end
  local repo = root .. '/repo with spaces'
  vim.fn.mkdir(repo, 'p')
  git(repo, 'init', '-b', 'feature/TEST-123_foobar')
  git(repo, '-c', 'commit.gpgsign=false', 'commit', '--allow-empty', '-m', 'existing subject')
  local template = root .. '/template'
  vim.fn.writefile({ '', '', '# comment-only template', '# keep this' }, template)
  git(repo, 'config', 'commit.template', template)
  local editor = vim.fn.shellescape(vim.v.progpath) .. ' --headless -u ' .. vim.fn.shellescape(init) .. ' -i NONE'
  local count = 0
  local function commit_case(label, cwd, expected, args)
    count = count + 1
    local result = root .. '/result-' .. count
    local out = run(cwd, args or { 'commit', '--allow-empty' }, { GIT_EDITOR = editor, GITCOMMIT_RESULT = result })
    assert(out.code ~= 0, label .. ': inspection must abort commit')
    assert(vim.fn.filereadable(result) == 1, label .. ': editor did not run: ' .. out.stderr)
    local snapshot = vim.json.decode(vim.fn.readfile(result)[1])
    assert(snapshot.ft == 'gitcommit', label .. ': wrong filetype')
    assert(snapshot.lines[1] == expected, label .. ': ' .. vim.inspect(snapshot.lines))
    if expected:match('^[A-Z][A-Z0-9]*%-%d+ $') then
      assert(snapshot.modified and snapshot.disk[1] == '', label .. ': buffer must not auto-save')
      assert(vim.deep_equal(vim.list_slice(snapshot.lines, 2), vim.list_slice(snapshot.disk, 2)), label .. ': template changed')
    else
      assert(vim.deep_equal(snapshot.lines, snapshot.disk) and not snapshot.modified, label .. ': existing message changed')
    end
  end
  commit_case('new commit with comment template', repo, 'TEST-123 ')
  commit_case('amend keeps existing message', repo, 'existing subject', { 'commit', '--amend', '--allow-empty' })
  commit_case('existing prefix', repo, 'TEST-123 already entered', { 'commit', '--allow-empty', '-m', 'TEST-123 already entered', '--edit' })
  commit_case('other entered message', repo, 'a different subject', { 'commit', '--allow-empty', '-m', 'a different subject', '--edit' })
  git(repo, 'switch', '-c', 'feature/A1-007_two-parts_2')
  commit_case('other valid project key and slug', repo, 'A1-007 ')
  for _, branch in ipairs({ 'main', 'fix/TEST-123_foobar', 'feature/test-123_lowercase', 'feature/TEST-123',
      'feature/TEST-123_', 'feature/TEST-123_foo/bar', 'feature/TEST-123_foo.bar', 'feature/TEST-x_foobar' }) do
    git(repo, 'switch', '-c', branch)
    commit_case('ignored branch ' .. branch, repo, '')
  end
  git(repo, 'switch', 'feature/TEST-123_foobar')
  git(repo, 'checkout', '--detach')
  commit_case('detached HEAD', repo, '')
  git(repo, 'switch', 'feature/TEST-123_foobar')

  -- The same FileType loader as the new-editor cases, now in a persistent parent.
  vim.opt.rtp:append(root .. '/runtime/after')
  vim.cmd('filetype plugin on')
  vim.cmd.cd(vim.fn.fnameescape(source)) -- Deliberately unrelated to the fixture.
  local worktree = root .. '/other worktree'
  git(repo, 'worktree', 'add', '-b', 'feature/WORK-42_foobar', worktree)
  local gitdir = git(worktree, 'rev-parse', '--absolute-git-dir')
  local file = gitdir .. '/COMMIT_EDITMSG'
  local previous = {}
  for _, key in ipairs({ 'GIT_DIR', 'GIT_WORK_TREE', 'GIT_COMMON_DIR', 'GIT_NAMESPACE', 'GIT_CONFIG_GLOBAL', 'GIT_CONFIG_NOSYSTEM' }) do
    previous[key] = vim.env[key]
  end
  vim.env.GIT_DIR, vim.env.GIT_COMMON_DIR = repo .. '/.git', repo .. '/.git'
  vim.env.GIT_WORK_TREE, vim.env.GIT_NAMESPACE = repo, 'unrelated'
  vim.env.GIT_CONFIG_GLOBAL, vim.env.GIT_CONFIG_NOSYSTEM = '/dev/null', '1'
  local function open(lines, expected, name)
    vim.cmd('enew!')
    vim.fn.writefile(lines, name or file)
    vim.cmd.edit(vim.fn.fnameescape(name or file))
    assert(vim.bo.filetype == 'gitcommit')
    assert(api.nvim_get_current_line() == expected, vim.inspect(api.nvim_buf_get_lines(0, 0, -1, false)))
    assert(vim.deep_equal(vim.fn.readfile(name or file), lines), 'ftplugin auto-saved')
  end
  open({ '', '# preserved' }, 'WORK-42 ')
  local buf = api.nvim_get_current_buf()
  api.nvim_buf_set_lines(buf, 0, 1, false, { '' })
  vim.bo.modified = false
  api.nvim_exec_autocmds('FileType', { pattern = 'gitcommit' })
  api.nvim_exec_autocmds('BufWinEnter', { buffer = buf })
  assert(api.nvim_get_current_line() == '', 'must not insert twice in the same buffer')
  open({ '' }, 'WORK-42 ')
  open({ '# only comments' }, 'WORK-42 ')
  assert(api.nvim_buf_get_lines(0, 0, -1, false)[2] == '# only comments')
  open({ '', 'body on a later line' }, '')
  open({ '', '# verbose commit', 'diff --git a/file b/file' }, '')
  open({ 'WORK-42 existing' }, 'WORK-42 existing')
  open({ '' }, '', root .. '/COMMIT_EDITMSG') -- Same name outside a repository.
  open({ '' }, '', gitdir .. '/MERGE_MSG')
  for _, marker in ipairs({ 'MERGE_HEAD', 'SQUASH_MSG', 'CHERRY_PICK_HEAD', 'REVERT_HEAD', 'rebase-merge', 'rebase-apply', 'sequencer' }) do
    local target = gitdir .. '/' .. marker
    if marker:match('HEAD$') then
      vim.fn.writefile({ git(worktree, 'rev-parse', 'HEAD') }, target)
    elseif marker == 'SQUASH_MSG' then
      vim.fn.writefile({ '' }, target)
    else
      vim.fn.mkdir(target)
    end
    open({ '', '# generated operation' }, '')
    vim.fn.delete(target, 'rf')
  end
  git(worktree, 'config', 'core.commentChar', ';')
  open({ '', '; comment' }, 'WORK-42 ')
  open({ '', '# real message under semicolon comments' }, '')
  git(worktree, 'config', 'core.commentChar', 'auto')
  open({ '', '# unknown auto comment' }, '')
  git(worktree, 'config', 'core.commentString', '//')
  open({ '', '// comment' }, 'WORK-42 ')
  git(worktree, 'config', '--unset', 'core.commentString')
  git(worktree, 'config', '--unset', 'core.commentChar')

  -- Git reads these aliases in order, including across global/local scopes.
  local global_config = root .. '/global-config'
  env.GIT_CONFIG_GLOBAL, vim.env.GIT_CONFIG_GLOBAL = global_config, global_config
  for _, case in ipairs({
    { global = 'commentString = //', key = 'core.commentChar', value = '#', body = '// actual body' },
    { global = 'commentChar = "#"', key = 'core.commentString', value = '//', body = '# actual body' },
    { global = 'commentString = //', key = 'core.commentChar', value = ';', body = '// actual body' },
  }) do
    vim.fn.writefile({ '[core]', case.global }, global_config)
    git(worktree, 'config', case.key, case.value)
    local oracle = original_system({ 'git', '-C', worktree, 'stripspace', '--strip-comments' }, {
      text = true, clear_env = true, env = env,
      stdin = case.value .. ' comment\n' .. case.body .. '\n',
    }):wait(5000)
    assert(oracle.code == 0 and oracle.stdout == case.body .. '\n', 'Git alias order oracle failed: ' .. vim.inspect(oracle))
    open({ '', case.value .. ' comment' }, 'WORK-42 ')
    open({ '', case.body }, '')
    vim.fn.writefile({ '', '', case.value .. ' comment-only template' }, template)
    commit_case('global/local alias override ' .. case.key, repo, 'TEST-123 ')
    git(worktree, 'config', '--unset', case.key)
  end
  env.GIT_CONFIG_GLOBAL, vim.env.GIT_CONFIG_GLOBAL = '/dev/null', '/dev/null'
  vim.fn.writefile({ '', '', '# comment-only template', '# keep this' }, template)
  git(worktree, 'config', 'core.commentString', '//')
  git(worktree, 'config', 'core.commentChar', '#')
  open({ '', '# comment' }, 'WORK-42 ')
  open({ '', '// actual body' }, '')
  commit_case('later commentChar preserves slash message', repo, '// actual body',
    { 'commit', '--allow-empty', '--no-status', '--edit', '-m', '// actual body' })
  git(worktree, 'config', '--unset', 'core.commentString')
  git(worktree, 'config', '--add', 'core.commentString', 'auto')
  open({ '' }, '')
  open({ '', '# unknown auto comment' }, '')
  git(worktree, 'config', '--unset', 'core.commentString')
  git(worktree, 'config', '--unset', 'core.commentChar')

  -- Faults and edits during a bounded Git wait must fail closed.
  for _, fault in ipairs({ 'spawn', 'exit', 'timeout', 'changed', 'readonly', 'unmodifiable' }) do
    vim.system = function(argv, opts)
      if fault == 'spawn' then error('fixture spawn failure') end
      return { wait = function(_, timeout)
        assert(timeout == 300, 'Git calls must be bounded')
        if fault == 'exit' or fault == 'timeout' then return { code = fault == 'exit' and 128 or 124 } end
        if fault == 'changed' then api.nvim_buf_set_lines(0, 0, 1, false, { 'user input' }) end
        if fault == 'readonly' then vim.bo.readonly = true end
        if fault == 'unmodifiable' then vim.bo.modifiable = false end
        return original_system(argv, opts):wait(timeout)
      end }
    end
    open({ '' }, fault == 'changed' and 'user input' or '')
    vim.system = original_system
    vim.bo.readonly, vim.bo.modifiable = false, true
  end
  for _, fault in ipairs({ 'filetype', 'switched' }) do
    vim.cmd('enew!')
    vim.fn.writefile({ '' }, file)
    local changed = false
    vim.system = function(argv, opts)
      if not changed then
        changed = true
        if fault == 'filetype' then
          vim.bo.filetype = 'text'
        else
          local other = api.nvim_create_buf(false, true)
          api.nvim_buf_set_lines(other, 0, -1, false, { 'another buffer' })
          api.nvim_set_current_buf(other)
        end
      end
      return original_system(argv, opts)
    end
    vim.cmd.edit(vim.fn.fnameescape(file))
    vim.system = original_system
    assert(api.nvim_get_current_line() == (fault == 'filetype' and '' or 'another buffer'), fault .. ': wrong buffer changed')
  end

  -- Gitu's external editor path: real git -> existing editor-open.lua -> parent :edit.
  -- The inspection closes the message buffer without writing, releasing --wait.
  vim.cmd('enew!')
  local address = vim.fn.serverstart(root .. '/nvim.sock')
  local seen
  local group = api.nvim_create_augroup('gitcommit-remote-test', {})
  api.nvim_create_autocmd('BufWinEnter', { group = group, callback = function()
    if api.nvim_buf_get_name(0) == file then
      local remote_buf = api.nvim_get_current_buf()
      vim.schedule(function()
        seen = api.nvim_buf_get_lines(remote_buf, 0, -1, false)
        api.nvim_buf_delete(remote_buf, { force = true })
      end)
    end
  end })
  local remote = vim.fn.shellescape(vim.v.progpath) .. ' --headless --clean -l '
    .. vim.fn.shellescape(source .. '/v2/lua/editor-open.lua') .. ' --wait'
  local argv = { 'git', '-C', worktree, 'commit', '--allow-empty' }
  local completed
  original_system(argv, { text = true, clear_env = true, env = vim.tbl_extend('force', env, {
    GIT_EDITOR = remote, NVIM_EDITOR_ADDR = address,
  }) }, function(out) completed = out end)
  assert(vim.wait(10000, function() return completed ~= nil end, 10), 'remote editor timed out')
  assert(completed.code ~= 0 and seen and seen[1] == 'WORK-42 ', 'remote ftplugin path failed: ' .. vim.inspect(completed))
  assert(vim.fn.readfile(file)[1] == '', 'remote message was saved')
  api.nvim_del_augroup_by_id(group)
  vim.fn.serverstop(address)
  for key, value in pairs(previous) do vim.env[key] = value end
  for _, key in ipairs({ 'GIT_DIR', 'GIT_WORK_TREE', 'GIT_COMMON_DIR', 'GIT_NAMESPACE', 'GIT_CONFIG_GLOBAL', 'GIT_CONFIG_NOSYSTEM' }) do
    if previous[key] == nil then vim.env[key] = nil end
  end
  print('PASS: generated Lua; real Git new/amend/entered messages and branch formats; worktree/cwd/env; ordered comment aliases; operation guards; faults/races; remote editor; no auto-save')
end
local ok, err = xpcall(check, debug.traceback)
vim.system = original_system
if not ok then io.stderr:write(err .. '\n') end
vim.fn.delete(root, 'rf')
vim.cmd(ok and 'qa!' or 'cquit 1')
