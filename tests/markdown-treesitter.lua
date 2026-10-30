-- Exercise real FileType/plugin lifecycles, including Neovim's Markdown ftplugin.
local api = vim.api
for path in assert(vim.env.MARKDOWN_TEST_PLUGINS):gmatch('[^:]+') do
  vim.opt.rtp:append(path)
end
local notices = {}
vim.notify = function(message, level)
  if (level or 0) >= vim.log.levels.WARN then
    notices[#notices + 1] = message
  end
end
local function config(name)
  local path = 'v2/fnl/' .. name .. '.fnl'
  local compiled = '-- [nfnl] '
    .. path
    .. '\n'
    .. require('nfnl.fennel')['compile-string'](table.concat(vim.fn.readfile(path), '\n'), { filename = path })
  assert(compiled == table.concat(vim.fn.readfile('v2/lua/autogen/' .. name .. '.lua'), '\n'), name .. ' parity')
  return dofile('v2/lua/autogen/' .. name .. '.lua')
end
local function drain()
  vim.wait(650, function()
    return false
  end, 10)
  vim.cmd.redraw()
end
local function check()
  vim.cmd('filetype plugin indent on')
  vim.cmd('syntax on')
  -- Match the actual generated after/ftplugin location.
  local after = vim.fn.tempname()
  vim.fn.mkdir(after .. '/after/ftplugin', 'p')
  vim.fn.writefile(
    vim.fn.readfile('v2/lua/autogen/after/ftplugin/markdown.lua'),
    after .. '/after/ftplugin/markdown.lua'
  )
  vim.opt.rtp:append(after .. '/after')
  local image_opts
  package.preload.image = function()
    return {
      setup = function(opts)
        image_opts = opts
      end,
    }
  end
  config('image')
  assert(not vim.tbl_contains(image_opts.integrations.markdown.filetypes, 'markdown'), 'image parsing enabled')
  assert(vim.tbl_contains(image_opts.integrations.markdown.filetypes, 'vimwiki'), 'vimwiki changed')
  config('after/ftplugin/markdown') -- also check Fennel parity
  args = { install_dir = assert(vim.env.MARKDOWN_TEST_PARSERS) }
  if vim.env.MARKDOWN_TEST_EARLY_PLUGINS then
    vim.cmd('runtime plugin/matchup.vim')
    vim.cmd('runtime plugin/ts_context_commentstring.lua')
  end
  config('treesitter')
  vim.cmd('runtime plugin/matchup.vim')
  vim.cmd('runtime plugin/ts_context_commentstring.lua')
  config('ufo')
  config('hlchunk')
  config('tabout')
  config('aerial')
  require('aerial').sync_load()
  config('autopairs')
  local parses = 0
  local LanguageTree = require('vim.treesitter.languagetree')
  local parse = LanguageTree.parse
  LanguageTree.parse = function(self, ...)
    local source = self:source()
    if
      type(source) == 'number'
      and api.nvim_buf_is_valid(source)
      and vim.tbl_contains({ 'markdown', 'markdown_inline' }, vim.bo[source].ft)
    then
      parses = parses + 1
    end
    return parse(self, ...)
  end
  local function markdown(lines, suffix)
    local path = vim.fn.tempname() .. (suffix or '.md')
    vim.fn.writefile(lines, path)
    vim.cmd.edit(path)
    local buf = api.nvim_get_current_buf()
    drain()
    assert(vim.bo.ft == 'markdown', 'fixture filetype')
    assert(not vim.treesitter.highlighter.active[buf], 'Markdown highlighter attached')
    assert(vim.bo.indentexpr == '', 'Markdown TS indentation')
    assert(vim.fn.eval(vim.wo.foldexpr) == 0, 'Markdown TS fold expression')
    assert(vim.bo.syntax == 'markdown', 'regex syntax lost')
    assert(vim.fn.maparg('gO', 'n', false, true).buffer ~= 1, 'native TS outline mapping remains')
    assert(
      vim.tbl_isempty(api.nvim_get_autocmds({ event = 'CursorHold', group = 'context_commentstring_ft', buffer = buf })),
      'context query callback remains'
    )
    assert(not require('tabout').valid_filetype(), 'TS tabout enabled')
    assert(not vim.tbl_contains(vim.b.matchup_active_engines.all or {}, 'tree_sitter'), 'TS matchup enabled')
    local before = parses
    assert(before == 0, 'Markdown parsed during opening: ' .. before)
    for _, event in ipairs({
      'CursorMoved',
      'CursorMovedI',
      'CursorHold',
      'InsertEnter',
      'InsertLeave',
      'TextChanged',
      'TextChangedI',
    }) do
      api.nvim_exec_autocmds(event, { buffer = buf })
    end
    api.nvim_buf_set_lines(buf, 1, 1, false, { 'edited [link](target.md)' })
    vim.cmd('normal! Gzz')
    vim.cmd('normal! oordinary text')
    drain()
    assert(api.nvim_buf_get_lines(buf, -2, -1, false)[1]:find('ordinary text'), 'ordinary editing broken')
    assert(not vim.treesitter.highlighter.active[buf], 'highlighter reattached after editing')
    assert(parses == before, 'Markdown parsed during editing/cursor/folding: ' .. (parses - before))
    local _, backend = require('aerial.backends').get(buf)
    assert(backend == 'markdown', 'regex outline backend unavailable: ' .. tostring(backend))
    assert(require('ufo').getFolds(buf, 'indent'), 'indent folding unavailable')
    vim.cmd.write()
    drain()
    assert(parses == before, 'Markdown parsed after saving')
    assert(vim.deep_equal(vim.fn.readfile(path), api.nvim_buf_get_lines(buf, 0, -1, false)), 'save changed content')
    return buf
  end
  local small = markdown({
    '# Heading',
    '',
    '[link](target.md)',
    '- [ ] task',
    '![image](missing.png)',
    '```lua',
    'return 1',
    '```',
  })
  local long = { '# Large note' }
  for _ = 1, 2000 do
    long[#long + 1] = ('[link](target.md) text '):rep(30)
  end
  markdown(long, '.markdown')
  vim.cmd('vsplit')
  vim.cmd.buffer(small)
  drain()
  assert(not vim.treesitter.highlighter.active[small] and vim.fn.eval(vim.wo.foldexpr) == 0, 'Markdown split')
  vim.cmd.enew()
  api.nvim_buf_set_lines(0, 0, -1, false, { 'local value = { 1, 2 }', 'return value' })
  vim.bo.ft = 'lua'
  drain()
  assert(vim.treesitter.highlighter.active[api.nvim_get_current_buf()], 'Lua highlighting changed')
  assert(vim.bo.indentexpr == 'GetLuaIndent()', 'Lua indentation changed: ' .. vim.bo.indentexpr)
  assert(vim.wo.foldexpr == 'v:lua.vim.treesitter.foldexpr()', 'Lua fold expression inherited Markdown options')
  assert(require('tabout').valid_filetype() ~= false, 'Lua tabout disabled')
  vim.bo.ft = 'markdown_inline'
  drain()
  assert(not vim.treesitter.highlighter.active[api.nvim_get_current_buf()], 'inline highlighter remains')
  assert(parses == 0, 'inline parsed during filetype change')
  local before = parses
  api.nvim_exec_autocmds('CursorHold', {})
  drain()
  assert(parses == before, 'inline parsed on hold')
  assert(#notices == 0, table.concat(notices, '\n'))
  vim.fn.delete(after, 'rf')
  print('Markdown Tree-sitter lifecycle checks passed')
end
local ok, err = xpcall(check, debug.traceback)
if not ok then
  io.stderr:write(err .. '\n')
  vim.cmd('cquit 1')
end
vim.cmd('qa!')
