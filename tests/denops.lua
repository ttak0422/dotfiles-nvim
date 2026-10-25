-- Run through tests/denops.py with the payload.json from a built bundler-nvim-v2.
local payload = vim.json.decode(table.concat(vim.fn.readfile(vim.env.DENOPS_TEST_PAYLOAD), '\n'))
local lazy, packages = payload.pluginConfig.lazy, payload.meta.packagePaths
local root = assert(vim.env.DENOPS_TEST_TMP)
local function equal(actual, expected)
  assert(vim.deep_equal(actual, expected), vim.inspect({ actual = actual, expected = expected }))
end
local function request(name, method, args)
  return vim.fn['denops#request'](name, method, args or {})
end
local function run()
  vim.cmd(lazy.denops.preConfig.code)
  if vim.env.DENOPS_TEST_DENO then vim.g['denops#deno'] = vim.env.DENOPS_TEST_DENO end
  vim.g['denops#deno_dir'] = assert(vim.env.DENO_DIR)
  vim.g['denops#server#restart_threshold'] = 0
  for _, name in ipairs({ 'denops-vim', 'skkeleton', 'skkeleton-henkan-highlight',
    'vim-mr', 'gin.vim', 'plenary-nvim', 'telescope-nvim', 'telescope-mr' }) do
    vim.opt.rtp:append(assert(packages[name], name))
  end
  local gin = lazy.commandPlugins.depends[5]
  assert(gin.package == packages['gin.vim'])
  vim.cmd(gin.preConfig.code)
  equal(vim.g.gin_proxy_disable_editor, true)
  vim.cmd('runtime! plugin/**/*.vim')
  vim.fn['denops#server#start']()
  for _, name in ipairs({ 'skkeleton', 'gin', 'mr' }) do
    assert(vim.wait(55000, function() return vim.fn['denops#plugin#is_loaded'](name) == 1 end, 20),
      name .. ': ' .. vim.fn.execute('messages'))
  end
  equal(vim.fn['denops#server#status'](), 'running')
  print('Denops: server running; skkeleton/gin/mr registered')

  local skk = lazy.inputPlugins.depends[5]
  equal(skk.packages, { packages.skkeleton, packages['skkeleton-henkan-highlight'] })
  -- Select the production dictionary branch without consulting a user's SKK server.
  local system = vim.system
  vim.system = function(argv, opts)
    if argv[1] == 'lsof' then return { wait = function() return { stdout = '' } end } end
    return system(argv, opts)
  end
  local ok, err = pcall(assert(loadstring(skk.postConfig)))
  vim.system = system
  assert(ok, err)
  vim.fn['skkeleton#config']({
    globalDictionaries = { { root .. '/dict', 'utf-8' } }, userDictionary = root .. '/user-dict',
  })
  vim.fn['skkeleton#register_keymap']('input', '<C-g>', 'kakuteiUndo')
  equal(vim.fn['skkeleton#get_config']().sources, { 'skk_dictionary' })

  vim.cmd('edit ' .. vim.fn.fnameescape(root .. '/repo/tracked.txt'))
  vim.cmd('GinStatus')
  assert(vim.wait(5000, function()
    return vim.bo.filetype == 'gin-status' and table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'):find('untracked.txt', 1, true)
  end, 20), vim.fn.execute('messages'))
  vim.cmd('enew!')
  print('Gin: production proxy setting and fixture status passed')

  local file = root .. '/repo/tracked.txt'
  vim.cmd('edit ' .. vim.fn.fnameescape(file))
  vim.fn['mr#mru#stop_recording']()
  vim.fn['mr#mrw#stop_recording']()
  vim.fn['mr#mrr#stop_recording']()
  vim.fn['mr#mrd#stop_recording']()
  for _, kind in ipairs({ 'mru', 'mrw', 'mrr', 'mrd' }) do
    local entry = kind == 'mrd' and root .. '/repo' or file
    local filename = vim.fn.expand(vim.g['mr#' .. kind .. '#filename'])
    vim.fn.mkdir(vim.fn.fnamemodify(filename, ':h'), 'p')
    vim.fn.writefile({ entry }, filename)
    equal(request('mr', kind .. ':list'), { entry })
    equal(vim.fn['mr#' .. kind .. '#list'](), { entry })
  end
  local telescope = require('telescope')
  telescope.setup({ defaults = { initial_mode = 'normal' } })
  telescope.load_extension('mr')
  for _, kind in ipairs({ 'mru', 'mrw', 'mrr', 'mrd' }) do
    telescope.extensions.mr[kind]({ previewer = false })
    local picker = require('telescope.actions.state').get_current_picker(vim.api.nvim_get_current_buf())
    assert(vim.wait(3000, function() return picker.manager and picker.manager:num_results() == 1 end, 20))
    equal(picker.manager:get_entry(1).value, kind == 'mrd' and root .. '/repo' or file)
    require('telescope.actions').close(picker.prompt_bufnr)
  end
  print('MR: four real dispatchers, Vim lists and Telescope pickers passed')
  vim.cmd('enew!')
  vim.cmd('set backspace=indent,eol,start')

  local namespace = vim.api.nvim_create_namespace('skkeleton-henkan')
  local steps = {
    { 'i<C-j>', function()
      equal(vim.fn['skkeleton#is_enabled'](), true)
      equal(request('skkeleton', 'getCandidates', { 'かな' }), { '仮名', 'カナ' })
    end },
    { 'kana', function() equal(vim.api.nvim_get_current_line(), 'かな') end },
    { 'jk', function() equal(vim.fn.mode(), 'n') end },
    { 'gg0d$', function() equal(vim.api.nvim_get_current_line(), '') end },
    { 'i<C-j>Kana', function()
      equal(vim.api.nvim_get_current_line(), 'かな')
      assert(#vim.api.nvim_buf_get_extmarks(0, namespace, 0, -1, {}) > 0)
    end },
    { '<Space>', function()
      equal(vim.api.nvim_get_current_line(), '仮名')
      equal(vim.g['skkeleton#state'].phase, 'henkan')
    end },
    { '<C-j>', function() equal(vim.api.nvim_get_current_line(), '仮名') end },
    { '<C-g>', function()
      equal(vim.g['skkeleton#state'].phase, 'henkan')
    end },
    { '<Space>', function() equal(vim.api.nvim_get_current_line(), 'カナ') end },
    { '<C-j>', function() equal(vim.api.nvim_get_current_line(), 'カナ') end },
    { '<Esc>', function()
      equal(vim.api.nvim_get_current_line(), 'カナ')
      equal(vim.api.nvim_buf_get_extmarks(0, namespace, 0, -1, {}), {})
    end },
  }
  local index = 0
  local function advance()
    local passed, failure = pcall(function()
      if index > 0 then steps[index][2]() end
      index = index + 1
      if steps[index] then
        vim.api.nvim_input(vim.api.nvim_replace_termcodes(steps[index][1], true, false, true))
        vim.defer_fn(advance, 200)
      else
        equal(vim.v.errmsg, '')
        print('Skkeleton: kana, jk escape, conversion, kakuteiUndo, candidate selection and highlight passed')
        vim.fn['denops#server#stop']()
        vim.cmd('qa!')
      end
    end)
    if not passed then
      io.stderr:write('Denops step ' .. index .. ': ' .. tostring(failure) .. '\n' .. vim.fn.execute('messages') .. '\n')
      vim.fn['denops#server#stop']()
      vim.cmd('cquit 1')
    end
  end
  vim.defer_fn(advance, 100)
end
local ok, err = xpcall(run, debug.traceback)
if not ok then
  io.stderr:write(err .. '\n' .. vim.fn.execute('messages') .. '\n')
  pcall(vim.fn['denops#server#stop'])
  vim.cmd('cquit 1')
end
