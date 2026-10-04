-- CRATES_PLUGIN_DIR=<pinned crates> NFNL_PLUGIN_DIR=<pinned nfnl>
-- nvim --headless -u NONE -i NONE -l tests/crates-config.lua
local function check()
  for _, name in ipairs({ 'CRATES_PLUGIN_DIR', 'NFNL_PLUGIN_DIR' }) do
    vim.opt.rtp:append(assert(vim.env[name], name))
  end
  local path = 'v2/fnl/crates.fnl'
  local compiled = '-- [nfnl] ' .. path .. '\n' .. require('nfnl.fennel')['compile-string'](
    table.concat(vim.fn.readfile(path), '\n'), { filename = path })
  assert(compiled == table.concat(vim.fn.readfile('v2/lua/autogen/crates.lua'), '\n'))
  local warnings = {}
  vim.notify = function(message, level)
    if level and level >= vim.log.levels.WARN then warnings[#warnings + 1] = message end
  end
  local legacy_loaded = false
  package.preload['null-ls'] = function()
    legacy_loaded = true
    error('legacy integration must not load')
  end
  local root = vim.fn.tempname()
  vim.fn.mkdir(root, 'p')
  vim.fn.writefile({ '[package]', 'name = "fixture"', 'version = "0.1.0"' }, root .. '/Cargo.toml')
  vim.cmd.edit(vim.fn.fnameescape(root .. '/Cargo.toml'))
  vim.bo.filetype = 'toml'
  dofile('v2/lua/autogen/crates.lua')
  local client
  assert(vim.wait(3000, function()
    client = vim.lsp.get_clients({ bufnr = 0, name = 'crates.nvim' })[1]
    return client and client.initialized
  end, 20), 'in-process LSP did not attach')
  assert(client.server_capabilities.codeActionProvider)
  assert(client.server_capabilities.hoverProvider)
  assert(not client.server_capabilities.completionProvider, 'completion setting must remain unchanged')
  assert(not require('crates.state').cfg.null_ls.enabled and not legacy_loaded)
  assert(not package.loaded['crates.null-ls'])
  -- Exercise the native LSP action transport without querying a crate registry.
  local actions = require('crates.actions')
  local original, invoked = actions.get_actions, false
  actions.get_actions = function()
    return { { name = 'fixture action', action = function() invoked = true end } }
  end
  local response = client:request_sync('textDocument/codeAction', {
    textDocument = { uri = vim.uri_from_bufnr(0) },
    range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 0 } },
    context = { diagnostics = {} },
  }, 3000, 0)
  assert(response and response.result and #response.result == 1)
  local command = response.result[1].command
  client.commands[command.command](command, { bufnr = vim.api.nvim_get_current_buf() })
  assert(invoked, 'native code action did not execute')
  actions.get_actions = original
  vim.api.nvim_exec_autocmds('BufRead', { buffer = 0 })
  assert(#vim.lsp.get_clients({ bufnr = 0, name = 'crates.nvim' }) == 1, 'duplicate crates clients')
  assert(#warnings == 0, table.concat(warnings, '\n'))
  client:stop()
  vim.fn.delete(root, 'rf')
  print('PASS: crates generated config, native LSP attach/actions/hover, no legacy source or deprecation warning')
end
local ok, err = xpcall(check, debug.traceback)
if not ok then io.stderr:write(err .. '\n') end
vim.cmd(ok and 'qa!' or 'cquit 1')
