-- Isolated regression test: nvim --headless -u NONE -i NONE -l tests/checkmake.lua
local function check()
  for _, key in ipairs({ 'NONE_LS_PLUGIN_DIR', 'NFNL_PLUGIN_DIR', 'PLENARY_PLUGIN_DIR' }) do
    vim.opt.rtp:append(assert(vim.env[key], key))
  end
  local path = 'v2/fnl/none-ls.fnl'
  local compiled = '-- [nfnl] ' .. path .. '\n' .. require('nfnl.fennel')['compile-string'](
    table.concat(vim.fn.readfile(path), '\n'), { filename = path })
  assert(compiled == table.concat(vim.fn.readfile('v2/lua/autogen/none-ls.lua'), '\n'))

  local null_ls = require('null-ls')
  local setup, config = null_ls.setup
  null_ls.setup = function(value) config = value end
  _G.args = { idea = '/unused' }
  dofile('v2/lua/autogen/none-ls.lua')
  null_ls.setup = setup
  assert(#config.sources == 36, 'source coverage changed')
  local checkmake
  for _, source in ipairs(config.sources) do
    if source.name == 'checkmake' then checkmake = source end
  end
  assert(checkmake)
  assert(null_ls.builtins.diagnostics.checkmake.generator.opts.format == 'line', 'modified shared builtin')
  assert(not checkmake.generator.opts.ignore_stderr, 'stderr must remain available')

  local root = vim.fn.tempname()
  vim.fn.mkdir(root, 'p')
  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(buf, root .. '/Makefile')
  local function run(source, content)
    local result, completed
    source.generator.fn({ bufnr = buf, bufname = root .. '/Makefile', content = content }, function(value)
      result, completed = value, true
    end)
    assert(vim.wait(10000, function() return completed end, 10), 'generator timed out')
    return result or {}
  end
  -- Exercise the real packaged checkmake process and the built-in temp-file path.
  for missing = 0, 2 do
    local content = { '.PHONY: all clean test', 'all:' }
    if missing < 2 then table.insert(content, 'clean:') end
    if missing < 1 then table.insert(content, 'test:') end
    local result = run(checkmake, content)
    assert(not result._generator_err, result._generator_err)
    assert(#result == missing, 'incorrect real violation count: ' .. #result)
    for _, diagnostic in ipairs(result) do assert(diagnostic.code == 'minphony') end
  end
  local error_source = checkmake.with({ args = { root .. '/missing.mk' }, to_temp_file = false })
  assert(run(error_source, {})._generator_err:find('failed to parse', 1, true), 'lost real process error')

  local fixture = root .. '/fixture.sh'
  local source = checkmake.with({ command = fixture, to_temp_file = false })
  local function sample(stdout, stderr, code, expected)
    local script = table.concat({ '#!' .. assert(vim.env.CHECKMAKE_TEST_SHELL),
      'printf %s ' .. vim.fn.shellescape(stdout),
      'printf %s ' .. vim.fn.shellescape(stderr) .. ' >&2', 'exit ' .. code }, '\n')
    vim.fn.writefile(vim.split(script, '\n', { plain = true }), fixture)
    assert(vim.fn.setfperm(fixture, 'rwx------') == 1)
    local result = run(source, { 'all:' })
    if type(expected) == 'number' then
      assert(not result._generator_err, result._generator_err)
      assert(#result == expected, 'incorrect fixture count')
      if expected > 0 then
        assert(result[1].row == '1' and result[1].code == 'minphony' and result[1].message == 'missing target')
      end
    else
      assert(result._generator_err and result._generator_err:find(expected, 1, true),
        'error was suppressed: ' .. vim.inspect(result))
    end
  end
  local one = '1:minphony:missing target\n'
  local two = one .. '2:minphony:another target\n'
  sample('', '', 0, 0)
  sample(one, '', 1, 1) -- Older checkmake without the summary.
  sample(one, 'Error: violations found (1)\n', 1, 1)
  sample(two, 'Error: violations found (2)\n', 1, 2)
  sample(one:gsub('\n', '\r\n'), 'Error: violations found (1)', 1, 1)
  sample('', 'Error: cannot read file\n', 1, 'cannot read file')
  sample(one, 'Error: violations found (x)\n', 1, 'violations found (x)')
  sample(one, 'Error: violations found (0)\n', 1, 'violations found (0)')
  sample(one, 'Error: violations found (2)\n', 1, 'violations found (2)')
  sample('', 'Error: violations found (1)\n', 1, 'violations found (1)')
  sample(one, 'Error: violations found (1)\nError: another failure\n', 1, 'another failure')
  sample(one, 'warning\nError: violations found (1)\n', 1, 'warning')
  sample('execution failed', '', 2, 'execution failed')
  sample(one, 'execution failed', 2, 'execution failed')
  assert(null_ls.builtins.diagnostics.checkmake.generator.opts.format == 'line')
  vim.api.nvim_buf_delete(buf, { force = true })
  vim.fn.delete(root, 'rf')
  print('PASS: checkmake clean/one/two violations, real errors, exact summaries, count mismatch, shared builtin unchanged')
end
local ok, err = xpcall(check, debug.traceback)
if not ok then io.stderr:write(err .. '\n') end
vim.cmd(ok and 'qa!' or 'cquit 1')
