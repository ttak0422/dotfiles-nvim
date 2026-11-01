-- Isolated regression test for the vtsls-only publishDiagnostics override.
vim.opt.rtp:append(assert(vim.env.NFNL_PLUGIN_DIR, 'NFNL_PLUGIN_DIR'))
local method = 'textDocument/publishDiagnostics'
local native_handler = vim.lsp.handlers[method]
local clients, roots = {}, {}
local function check()
  local path = 'v2/fnl/after/lsp/vtsls.fnl'
  local compiled = '-- [nfnl] '
    .. path
    .. '\n'
    .. require('nfnl.fennel')['compile-string'](table.concat(vim.fn.readfile(path), '\n'), { filename = path })
  assert(compiled == table.concat(vim.fn.readfile('v2/lua/autogen/after/lsp/vtsls.lua'), '\n'), 'Fennel/Lua parity')
  local config = dofile('v2/lua/autogen/after/lsp/vtsls.lua')
  local handler = assert(config.handlers[method])
  assert(vim.lsp.handlers[method] == native_handler, 'must not replace the global handler')
  assert(
    config.on_init == nil and config.on_attach == nil and config.before_init == nil,
    'must not add initialization/attach callbacks'
  )
  assert(config.settings.typescript.suggestionActions == nil, 'must keep other suggestions enabled')
  local received
  vim.lsp.handlers[method] = function(err, result, ctx, opts)
    received = { err = err, result = result, ctx = ctx, opts = opts }
    return 'forwarded', 42
  end
  local diagnostics = {
    { code = 80001, message = 'CommonJS', severity = 4 },
    { code = '80001', message = 'CommonJS (string)', severity = 4 },
    { code = 2322, message = 'type error', severity = 1, data = { detail = true } },
    { code = 6133, message = 'unused', severity = 4, tags = { 1 } },
    { message = 'no code' },
    { code = 'TS80001', message = 'different code' },
  }
  local result = { uri = 'file:///tmp/vtsls-test.js', version = 17, diagnostics = diagnostics, extra = { token = 1 } }
  local before = vim.deepcopy(result)
  local ctx, opts = { client_id = 7, method = method }, { virtual_text = false }
  local a, b = handler(nil, result, ctx, opts)
  assert(a == 'forwarded' and b == 42, 'return contract')
  assert(received.ctx == ctx and received.opts == opts and received.err == nil, 'argument contract')
  assert(received.result ~= result and received.result.diagnostics ~= diagnostics, 'must copy payload/list')
  assert(vim.deep_equal(result, before), 'must not mutate incoming payload')
  assert(
    received.result.uri == result.uri and received.result.version == 17 and received.result.extra == result.extra,
    'metadata must survive'
  )
  assert(
    vim.deep_equal(received.result.diagnostics, { diagnostics[3], diagnostics[4], diagnostics[5], diagnostics[6] }),
    'must filter only numeric/string 80001 and preserve order/details'
  )
  handler(nil, { uri = result.uri, version = 18, diagnostics = { diagnostics[1], diagnostics[2] } }, ctx, opts)
  assert(#received.result.diagnostics == 0 and received.result.version == 18, 'must forward an empty clear')
  for _, value in ipairs({ {}, { diagnostics = {} } }) do
    handler(nil, value, ctx, opts)
    assert(vim.deep_equal(received.result, value), 'empty/missing diagnostics')
  end
  handler(nil, nil, ctx, opts)
  assert(received.result == nil and received.err == nil, 'nil result contract')
  local err = { code = -32603, message = 'failure' }
  handler(err, result, ctx, opts)
  assert(received.err == err and received.result == result, 'error payload must pass through')
  handler(err, nil, ctx, opts)
  assert(received.err == err and received.result == nil, 'error/nil contract')
  -- A wrapper installed after config loading must still receive notifications.
  local later = false
  vim.lsp.handlers[method] = function()
    later = true
  end
  handler(nil, result, ctx, opts)
  assert(later, 'later diagnostic wrappers must be preserved')
  vim.lsp.handlers[method] = native_handler

  -- Native Neovim dispatch, two distinct clients: only vtsls receives the override.
  local dispatchers = {}
  local function start(name, handlers)
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(buf, vim.fn.tempname() .. '.js')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'module.exports = {};' })
    local id = assert(vim.lsp.start({
      name = name,
      handlers = handlers,
      cmd = function(dispatch)
        dispatchers[name] = dispatch
        local closing, request_id = false, 0
        return {
          request = function(request_method, _, callback)
            request_id = request_id + 1
            vim.schedule(function()
              callback(nil, request_method == 'initialize' and { capabilities = {} } or nil)
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
            dispatch.on_exit(0, 0)
          end,
        }
      end,
    }, { bufnr = buf }))
    clients[#clients + 1] = id
    assert(vim.wait(3000, function()
      return vim.lsp.get_client_by_id(id).initialized
    end, 10))
    return id, buf
  end
  local vtsls_id, vtsls_buf = start('vtsls', config.handlers)
  local other_id, other_buf = start('other-server')
  local function publish(name, buf, items)
    dispatchers[name].notification(method, { uri = vim.uri_from_bufnr(buf), version = 1, diagnostics = items })
  end
  local function diagnostic(code)
    return {
      code = code,
      message = tostring(code),
      severity = 4,
      range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 1 } },
    }
  end
  local function displayed(id, buf)
    return vim.diagnostic.get(buf, { namespace = vim.lsp.diagnostic.get_namespace(id, false) })
  end
  publish('vtsls', vtsls_buf, { diagnostic(80001), diagnostic(6133) })
  publish('other-server', other_buf, { diagnostic(80001) })
  assert(
    vim.wait(3000, function()
      return #displayed(vtsls_id, vtsls_buf) == 1 and #displayed(other_id, other_buf) == 1
    end, 10),
    'native notifications must be delivered'
  )
  assert(
    #displayed(vtsls_id, vtsls_buf) == 1 and displayed(vtsls_id, vtsls_buf)[1].code == 6133,
    'native vtsls dispatch'
  )
  assert(
    #displayed(other_id, other_buf) == 1 and displayed(other_id, other_buf)[1].code == 80001,
    'other server 80001 must remain visible'
  )
  publish('vtsls', vtsls_buf, { diagnostic(80001) })
  assert(
    vim.wait(3000, function()
      return #displayed(vtsls_id, vtsls_buf) == 0
    end, 10),
    'filtered-only notification must clear stale diagnostics'
  )

  -- Real pinned vtsls: inspect the wire payload before filtering, then the UI state.
  local root = vim.fn.tempname()
  roots[#roots + 1] = root
  vim.fn.mkdir(root, 'p')
  vim.fn.writefile({ '{"type":"commonjs"}' }, root .. '/package.json')
  vim.fn.writefile(
    { '{"compilerOptions":{"checkJs":true,"module":"commonjs","target":"es2020"},"include":["*.js"]}' },
    root .. '/jsconfig.json'
  )
  vim.fn.writefile({
    '// @ts-check',
    '/** @type {number} */',
    'const value = "wrong";',
    'function greet() {',
    '  const unused = 1;',
    '  return value;',
    '}',
    'module.exports = greet;',
  }, root .. '/fixture.js')
  vim.cmd.edit(root .. '/fixture.js')
  vim.bo.filetype = 'javascript'
  local buf, raw_codes, raw_hint = vim.api.nvim_get_current_buf(), {}, false
  local live = vim.deepcopy(config)
  live.name, live.root_dir = 'vtsls', root
  live.cmd = { assert(vim.env.VTSLS_TEST_SERVER, 'VTSLS_TEST_SERVER'), '--stdio' }
  live.settings.typescript.disableAutomaticTypeAcquisition = true
  live.handlers[method] = function(error, params, context, options)
    if params then
      for _, d in ipairs(params.diagnostics) do
        raw_codes[d.code] = true
        if d.code ~= 80001 and d.severity == 4 then
          raw_hint = true
        end
      end
    end
    return handler(error, params, context, options)
  end
  local id = assert(vim.lsp.start(live, { bufnr = buf }))
  clients[#clients + 1] = id
  assert(
    vim.wait(20000, function()
      return raw_codes[80001] and raw_codes[2322] and raw_hint and #displayed(id, buf) >= 2
    end, 50),
    'real vtsls must emit CommonJS, type error and another hint: ' .. vim.inspect(raw_codes)
  )
  local client = assert(vim.lsp.get_client_by_id(id))
  assert(client.server_capabilities.diagnosticProvider == nil, 'pinned server unexpectedly uses pull diagnostics')
  local visible_codes = {}
  for _, d in ipairs(displayed(id, buf)) do
    assert(d.code ~= 80001 and d.code ~= '80001', 'CommonJS suggestion leaked')
    visible_codes[d.code] = true
  end
  assert(visible_codes[2322] and visible_codes[6133], 'other errors and suggestions must remain visible')
  print(
    'PASS: Fennel/Lua parity, exact filtering/contracts, payload metadata, native clear/client isolation, real vtsls '
      .. client.server_info.version
      .. ' raw=80001/2322/6133 visible=2322/6133, push diagnostics'
  )
end
local ok, err = xpcall(check, debug.traceback)
vim.lsp.handlers[method] = native_handler
for _, id in ipairs(clients) do
  local client = vim.lsp.get_client_by_id(id)
  if client then
    client:stop(true)
  end
end
for _, root in ipairs(roots) do
  vim.fn.delete(root, 'rf')
end
if not ok then
  io.stderr:write(err .. '\n')
end
vim.cmd(ok and 'qa!' or 'cquit 1')
