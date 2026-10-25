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
  local requests, formatting = 0, {}
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
              result = { capabilities = { inlayHintProvider = hints, documentFormattingProvider = true, positionEncoding = 'utf-16' } }
            elseif method == 'textDocument/inlayHint' then
              requests = requests + 1
              result = { { position = { line = 0, character = 11 }, label = ': number' } }
            elseif method == 'textDocument/formatting' then
              formatting[name] = (formatting[name] or 0) + 1
              result = {}
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
  start('null-ls', false, buf)
  local format, control_enter
  for _, map in ipairs(api.nvim_buf_get_keymap(buf, 'n')) do
    if map.lhs == '<Space>cF' or map.lhs == ' cF' or map.lhs == '\\cF' then format = map.callback end
    if map.lhs == '<C-CR>' then control_enter = map.callback end
  end
  assert(format and control_enter, 'formatting mappings missing: ' .. vim.inspect(api.nvim_buf_get_keymap(buf, 'n')))
  local native_format = vim.lsp.buf.format
  local options
  vim.lsp.buf.format = function(opts)
    options = opts
    native_format(opts)
  end
  for _, filetype in ipairs({ 'java', 'groovy', 'kotlin' }) do
    vim.bo.filetype = filetype
    for _, invoke in ipairs({ format, control_enter }) do
      formatting = {}
      invoke()
      assert(options.name == 'null-ls' and options.timeout_ms == 65000, 'IDEA deadline/client selection')
      assert(vim.deep_equal(formatting, { ['null-ls'] = 1 }), 'competing formatter: ' .. vim.inspect(formatting))
    end
  end
  vim.bo.filetype = 'lua'
  format()
  assert(options.name == nil and options.timeout_ms == 1000, 'non-JVM default changed')
  control_enter()
  assert(options.name == nil and options.timeout_ms == 10000, 'non-JVM Ctrl-Enter changed')
  vim.lsp.buf.format = native_format
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
