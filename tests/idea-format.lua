-- Real none-ls requests/processes; only the expensive IDE is a synthetic CLI.
local root, client
local function check()
  for _, key in ipairs({ 'NONE_LS_PLUGIN_DIR', 'NFNL_PLUGIN_DIR', 'PLENARY_PLUGIN_DIR' }) do
    vim.opt.rtp:append(assert(vim.env[key], key))
  end
  local path = 'v2/fnl/none-ls.fnl'
  local compiled = '-- [nfnl] '
    .. path
    .. '\n'
    .. require('nfnl.fennel')['compile-string'](table.concat(vim.fn.readfile(path), '\n'), { filename = path })
  assert(compiled == table.concat(vim.fn.readfile('v2/lua/autogen/none-ls.lua'), '\n'), 'Fennel parity')
  root = vim.fn.tempname() .. ' idea fixture'
  vim.fn.mkdir(root .. '/.git', 'p')
  local style = root .. '/chosen style.xml'
  vim.fn.writefile({ '<code_scheme name="Probe" version="173"/>' }, style)
  local style_before = vim.fn.readfile(style)
  local command = root .. '/idea'
  local shell = assert(vim.env.IDEA_TEST_SHELL)
  local function script(body)
    vim.fn.writefile(vim.split('#!' .. shell .. '\n' .. body, '\n', { plain = true }), command)
    assert(vim.fn.setfperm(command, 'rwx------') == 1)
  end
  local null_ls = require('null-ls')
  local setup, config = null_ls.setup
  null_ls.setup = function(value)
    config = value
  end
  args = { idea = command, idea_formatter_path = 'v2/lua/idea-format.lua', idea_vm_options = '/pinned/idea.vmoptions' }
  dofile('v2/lua/autogen/none-ls.lua')
  null_ls.setup = setup
  local sources = {}
  for _, source in ipairs(config.sources) do
    sources[source.name] = source
  end
  local idea = assert(sources.idea)
  assert(idea.generator.opts.timeout == 60000)
  -- Selection is exclusive; an IDEA failure must not silently switch styles.
  for _, selected in ipairs({ false, true }) do
    vim.g.idea_format = selected and style or nil
    assert(idea.generator.opts.runtime_condition() == selected)
    assert(sources.google_java_format.generator.opts.runtime_condition() ~= selected)
    assert(sources.ktlint.generator.opts.runtime_condition() ~= selected)
  end
  local file = root .. '/Sample.java'
  vim.fn.writefile({ '// disk sentinel' }, file)
  vim.cmd.edit(vim.fn.fnameescape(file))
  vim.bo.filetype = 'java'
  local buf = vim.api.nvim_get_current_buf()
  local original = 'public class Sample{int n=1;}'
  local formatted = 'public class Sample { int n = 1; }'
  local notices = {}
  vim.notify = function(message, level)
    notices[#notices + 1] = { tostring(message), level }
  end
  -- Short process deadline makes timeout tests deterministic; production is 60s.
  config.sources = { idea.with({ timeout = 2000 }) }
  setup(config)
  require('null-ls.client').try_add()
  assert(
    vim.wait(3000, function()
      client = vim.lsp.get_clients({ bufnr = buf, name = 'null-ls' })[1]
      return client and client.initialized
    end, 10),
    'none-ls did not attach'
  )
  local function format(expected, error_text)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { original })
    notices = {}
    vim.lsp.buf.format({ bufnr = buf, name = 'null-ls', timeout_ms = 5000 })
    assert(
      table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n') == expected,
      'unexpected edits: ' .. vim.inspect(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) .. ' ' .. vim.inspect(notices)
    )
    if error_text then
      assert(
        #notices == 1 and notices[1][1]:find(error_text, 1, true) and notices[1][2] == vim.log.levels.ERROR,
        'error not surfaced: ' .. vim.inspect(notices)
      )
    else
      assert(#notices == 0, vim.inspect(notices))
    end
    assert(vim.deep_equal(vim.fn.readfile(file), { '// disk sentinel' }), 'original file changed')
    assert(vim.deep_equal(vim.fn.readfile(style), style_before), 'selected style changed')
    assert(#vim.fn.glob(root .. '/.null-ls_*', false, true) == 0, 'temporary source leaked')
  end
  format(original, 'not executable')
  script('exit 7') -- No stdout/stderr: the exit status itself must be checked.
  format(original, 'code 7')
  script('echo "public class Corrupted {}" > "$4"; echo "IDE error" >&2; exit 3')
  format(original, 'IDE error')
  script('echo "public class Corrupted {}" > "$4"; echo "unexpected warning" >&2')
  format(original, 'unexpected warning') -- Exit zero plus stderr also rejects edits.
  script('while :; do :; done') -- No child left behind when vim.system kills it.
  format(original, 'timed out')
  vim.g.idea_format = root .. '/missing style.xml'
  format(original, 'not readable')
  vim.g.idea_format = style
  local marker = root .. '/runtime'
  script(table.concat({
    '[ "$1" = format ] && [ "$2" = -s ] || exit 11',
    '[ "$3" = ' .. vim.fn.shellescape(style) .. ' ] || exit 12',
    '[ "$(cat "$4")" = ' .. vim.fn.shellescape(original) .. ' ] || exit 13',
    '[ "$PWD" -ef ' .. vim.fn.shellescape(root) .. ' ] || exit 14',
    '[ "$IDEA_VM_OPTIONS" = /pinned/idea.vmoptions ] || exit 15',
    'case "${4##*/}" in .null-ls_*_Sample.java) ;; *) exit 16 ;; esac',
    '[ "$(dirname "$4")" -ef ' .. vim.fn.shellescape(root) .. ' ] || exit 18',
    'test -f "$IDEA_PROPERTIES" || exit 17',
    'cat "$IDEA_PROPERTIES" > ' .. vim.fn.shellescape(marker),
    'sleep 1.1', -- Longer than the old <leader>cF deadline.
    'echo ' .. vim.fn.shellescape(formatted) .. ' > "$4"',
    'echo "IDE progress must not enter the buffer"',
  }, '\n'))
  format(formatted) -- Also proves retries work after each failed invocation.
  local properties = vim.fn.readfile(marker)
  assert(#properties == 4)
  local seen = {}
  for _, line in ipairs(properties) do
    local name, dir = line:match('^idea%.(%w+)%.path=(.+)$')
    assert(name and vim.fn.isdirectory(dir) == 1 and not seen[dir], 'runtime isolation: ' .. line)
    assert(not dir:find('/Library/', 1, true), 'GUI runtime directory reused')
    seen[dir] = true
  end
  -- Two overlapping actions must not launch IDEs sharing the runtime dirs.
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { original })
  vim.fn.delete(marker)
  notices = {}
  local completed = 0
  local function request()
    client:request('textDocument/formatting', vim.lsp.util.make_formatting_params(), function()
      completed = completed + 1
    end, buf)
  end
  request()
  assert(
    vim.wait(1000, function()
      return vim.fn.filereadable(marker) == 1
    end, 10),
    'IDE did not start'
  )
  request()
  assert(
    vim.wait(3000, function()
      return completed == 2
    end, 10),
    'concurrent requests did not finish'
  )
  assert(#notices == 1 and notices[1][1]:find('already running', 1, true), 'concurrent IDE was not rejected')
  vim.g.idea_format = nil
  null_ls.register(sources.google_java_format)
  format('public class Sample {\n  int n = 1;\n}')
  print(
    'PASS: IDEA exclusive selection, missing executable, exit status/stderr, timeout, retry, isolated runtime, unsaved buffer, original/style/temp preservation'
  )
end
local ok, err = xpcall(check, debug.traceback)
if client then
  client:stop(true)
end
if root then
  vim.fn.delete(root, 'rf')
end
if not ok then
  io.stderr:write(err .. '\n')
end
vim.cmd(ok and 'qa!' or 'cquit 1')
