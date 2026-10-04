-- Run with an isolated Neovim (-u NONE -i NONE -l), from the repository root.
-- Required: NONE_LS_PLUGIN_DIR, NFNL_PLUGIN_DIR, PLENARY_PLUGIN_DIR,
-- LSPCONFIG_PLUGIN_DIR, ESLINT_NODE_PATH; prettier and vscode-eslint-language-server on PATH.
local function check()
  for _, key in ipairs({ 'NONE_LS_PLUGIN_DIR', 'NFNL_PLUGIN_DIR', 'PLENARY_PLUGIN_DIR', 'LSPCONFIG_PLUGIN_DIR' }) do
    vim.opt.rtp:append(assert(vim.env[key], key))
  end
  for _, name in ipairs({ 'none-ls', 'lsp', 'after/lsp/eslint' }) do
    local path = 'v2/fnl/' .. name .. '.fnl'
    local compiled = '-- [nfnl] ' .. path .. '\n' .. require('nfnl.fennel')['compile-string'](
      table.concat(vim.fn.readfile(path), '\n'), { filename = path })
    assert(compiled == table.concat(vim.fn.readfile('v2/lua/autogen/' .. name .. '.lua'), '\n'), name)
  end

  -- Load the real config and assert the migration does not silently drop sources.
  local null_ls = require('null-ls')
  local setup, config = null_ls.setup
  null_ls.setup = function(value) config = value end
  _G.args = { idea = '/unused' }
  dofile('v2/lua/autogen/none-ls.lua')
  null_ls.setup = setup
  assert(#config.sources == 36, 'unexpected source coverage: ' .. #config.sources)
  local prettier
  for _, source in ipairs(config.sources) do
    assert(source.name ~= 'eslint', 'duplicate ESLint diagnostics')
    if source.name == 'prettier' then prettier = source end
  end
  assert(prettier)
  -- Upstream root detection must remain opt-in and exclude Deno projects.
  local root_dir = vim.lsp.config.eslint.root_dir
  local gate = vim.fn.tempname()
  vim.fn.mkdir(gate, 'p')
  local gate_buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(gate_buf, gate .. '/test.js')
  local selected
  root_dir(gate_buf, function(value) selected = value end)
  assert(not selected, 'ESLint must not attach without project config')
  vim.fn.writefile({ '' }, gate .. '/eslint.config.mjs')
  vim.fn.writefile({ '' }, gate .. '/package-lock.json')
  root_dir(gate_buf, function(value) selected = value end)
  assert(selected, 'flat config must enable ESLint')
  vim.fn.writefile({ '{}' }, gate .. '/deno.json')
  selected = nil
  root_dir(gate_buf, function(value) selected = value end)
  assert(not selected, 'Deno must not receive duplicate ESLint diagnostics')
  vim.api.nvim_buf_delete(gate_buf, { force = true })
  vim.fn.delete(gate, 'rf')
  local enabled, enable = {}, vim.lsp.enable
  vim.lsp.enable = function(names) for _, name in ipairs(names) do enabled[name] = true end end
  args = { attach_path = '/unused' }
  dofile('v2/lua/autogen/lsp.lua')
  assert(enabled.eslint and not enabled.harper_ls)
  vim.lsp.enable = enable
  -- Avoid user keymaps while testing real attach/detach.
  vim.api.nvim_clear_autocmds({ event = 'LspAttach' })

  local root = vim.fn.tempname()
  vim.fn.mkdir(root .. '/.git', 'p')
  vim.fn.writefile({ '{}' }, root .. '/package.json')
  vim.fn.writefile({ 'module.exports = [{ rules: { "no-undef": "error" } }];' }, root .. '/eslint.config.cjs')
  local path = root .. '/index.js'
  vim.fn.writefile({ 'missingName(  1 )' }, path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  vim.bo.filetype = 'javascript'
  local buf = vim.api.nvim_get_current_buf()
  local function wait_for(predicate, message)
    assert(vim.wait(15000, predicate, 50), message)
  end
  local function get_client(name)
    return vim.lsp.get_clients({ bufnr = buf, name = name })[1]
  end
  config.sources = { prettier }
  setup(config)
  vim.api.nvim_exec_autocmds('FileType', { buffer = buf })
  wait_for(function() return get_client('null-ls') end, 'none-ls did not attach')
  local function format()
    vim.lsp.buf.format({ bufnr = buf, name = 'null-ls', timeout_ms = 15000 })
    assert(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == 'missingName(1);', 'Prettier failed')
  end
  format()
  local old = get_client('null-ls')
  old:stop()
  wait_for(function() return old:is_stopped() and require('null-ls.client').get_client() == nil end, 'none-ls failed to stop')
  require('null-ls.client').try_add()
  wait_for(function() local client = get_client('null-ls'); return client and client.id ~= old.id end,
    'none-ls did not restart')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'missingName(  1 )' })
  format()

  args = { node_path = assert(vim.env.ESLINT_NODE_PATH) }
  local eslint = dofile('v2/lua/autogen/after/lsp/eslint.lua')
  assert(eslint.settings.format == false)
  vim.lsp.config('eslint', eslint)
  vim.lsp.enable('eslint')
  wait_for(function() return get_client('eslint') end, 'ESLint did not attach')
  wait_for(function()
    for _, diagnostic in ipairs(vim.diagnostic.get(buf)) do
      if diagnostic.code == 'no-undef' then return true end
    end
    return false
  end, 'ESLint did not report no-undef')
  local client = get_client('eslint')
  assert(not client:supports_method('textDocument/formatting', buf), 'ESLint must not compete with Prettier')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'console;' })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'const answer = 1;' })
  vim.api.nvim_exec_autocmds('TextChanged', { buffer = buf })
  vim.cmd.write()
  wait_for(function() return #vim.diagnostic.get(buf) == 0 end, 'ESLint diagnostics did not clear: ' .. vim.inspect(vim.diagnostic.get(buf)))
  -- A nested package's ESLint must win over the Nix fallback, as with the old CLI resolver.
  local local_module = root .. '/nested/node_modules/eslint'
  vim.fn.mkdir(local_module, 'p')
  local marker = root .. '/local-eslint-used'
  vim.fn.writefile({ 'require("fs").writeFileSync(' .. vim.json.encode(marker) .. ', "yes");',
    'module.exports = require(' .. vim.json.encode(args.node_path .. '/eslint') .. ');' }, local_module .. '/index.js')
  vim.fn.writefile({ '{}' }, local_module .. '/package.json')
  vim.fn.writefile({ '{}' }, root .. '/nested/package.json')
  local nested = root .. '/nested/local.js'
  vim.fn.writefile({ 'missingAgain();' }, nested)
  vim.cmd.edit(vim.fn.fnameescape(nested))
  vim.bo.filetype = 'javascript'
  vim.api.nvim_exec_autocmds('FileType', { buffer = 0 })
  wait_for(function() return vim.fn.filereadable(marker) == 1 end, 'project-local ESLint was bypassed')
  wait_for(function() return #vim.diagnostic.get(0) > 0 end, 'nested ESLint diagnostics missing')
  client:stop(true)
  get_client('null-ls'):stop(true)
  vim.fn.delete(root, 'rf')
  print('PASS: generated config, Harper inactive, source coverage, Prettier graceful restart, ESLint diagnostics lifecycle')
end
local ok, err = xpcall(check, debug.traceback)
if not ok then io.stderr:write(err .. '\n') end
vim.cmd(ok and 'qa!' or 'cquit 1')
