-- Real native LSP clients/requests, without the removed inlay-hints plugin.
vim.opt.rtp:append(assert(vim.env.NFNL_PLUGIN_DIR, 'NFNL_PLUGIN_DIR'))
local api = vim.api
local clients, notices = {}, {}
vim.notify = function(message, level)
  if (level or 0) >= vim.log.levels.WARN then
    notices[#notices + 1] = message
  end
end
package.preload['inlay-hints'] = function()
  error('removed plugin was loaded')
end
local function check()
  local path = 'v2/fnl/lsp-attach.fnl'
  local compiled = '-- [nfnl] '
    .. path
    .. '\n'
    .. require('nfnl.fennel')['compile-string'](table.concat(vim.fn.readfile(path), '\n'), { filename = path })
  assert(compiled == table.concat(vim.fn.readfile('v2/lua/autogen/lsp-attach.lua'), '\n'), 'Fennel parity')
  local attach = dofile('v2/lua/autogen/lsp-attach.lua')
  local buf = api.nvim_get_current_buf()
  api.nvim_buf_set_lines(buf, 0, -1, false, { 'local value = 1' })
  api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
      attach({ buf = event.buf, client = vim.lsp.get_client_by_id(event.data.client_id) })
    end,
  })
  local requests = 0
  local function start(name, hints, target)
    local id = assert(vim.lsp.start({
      name = name,
      cmd = function(dispatchers)
        local closing, request_id = false, 0
        return {
          request = function(method, _, callback)
            request_id = request_id + 1
            local result
            if method == 'initialize' then
              result = { capabilities = { inlayHintProvider = hints, positionEncoding = 'utf-16' } }
            elseif method == 'textDocument/inlayHint' then
              requests = requests + 1
              result = { { position = { line = 0, character = 11 }, label = ': number' } }
            end
            vim.schedule(function()
              callback(nil, result)
            end)
            return true, request_id
          end,
          notify = function()
            return true
          end,
          is_closing = function()
            return closing
          end,
          terminate = function()
            closing = true
            dispatchers.on_exit(0, 0)
          end,
        }
      end,
    }, { bufnr = target }))
    clients[#clients + 1] = id
    assert(vim.wait(3000, function()
      return vim.lsp.get_client_by_id(id).initialized
    end, 10))
    return vim.lsp.get_client_by_id(id)
  end
  start('without-hints', false, buf)
  assert(vim.b[buf].lsp_attached and not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
  local maps = api.nvim_buf_get_keymap(buf, 'n')
  local found = {}
  for _, map in ipairs(maps) do
    found[map.lhs] = true
  end
  assert(found.gd and found.gi and found.gr and found.gpd and found.gpi and found.gpr, 'LSP mappings lost')
  -- A later supporting client must enable hints even when mappings already exist.
  start('with-hints', true, buf)
  assert(
    vim.wait(3000, function()
      return requests > 0 and #vim.lsp.inlay_hint.get({ bufnr = buf }) == 1
    end, 10),
    'native inlay request/result missing'
  )
  assert(vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
  assert(#api.nvim_buf_get_keymap(buf, 'n') == #maps, 'duplicate mappings')
  local other = api.nvim_create_buf(true, false)
  api.nvim_set_current_buf(other)
  start('other-without-hints', false, other)
  assert(not vim.lsp.inlay_hint.is_enabled({ bufnr = other }), 'enabled unrelated buffer')
  assert(vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
  assert(not package.loaded['inlay-hints'])
  for _, command in ipairs({ 'InlayHintsEnable', 'InlayHintsDisable', 'InlayHintsToggle' }) do
    assert(vim.fn.exists(':' .. command) == 0, 'obsolete plugin command')
  end
  assert(#notices == 0, vim.inspect(notices))
  print(
    'PASS: native inlay request/result, unsupported/multiple clients, buffer isolation, LSP mappings, no removed plugin'
  )
end
local ok, err = xpcall(check, debug.traceback)
for _, id in ipairs(clients) do
  local client = vim.lsp.get_client_by_id(id)
  if client then
    client:stop(true)
  end
end
if not ok then
  io.stderr:write(err .. '\n')
end
vim.cmd(ok and 'qa!' or 'cquit 1')
