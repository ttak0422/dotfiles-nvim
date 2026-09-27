-- Run from the repository root with an isolated Neovim:
-- KOTLIN_PLUGIN_DIR=<pinned plugin> KOTLIN_LSP_DIR=<server>/libexec/kotlin-lsp \
-- NFNL_PLUGIN_DIR=<pinned nfnl> nvim --headless -u NONE -i NONE -l tests/kotlin-config.lua
local function check()
  for _, env in ipairs({ "KOTLIN_PLUGIN_DIR", "NFNL_PLUGIN_DIR" }) do
    vim.opt.runtimepath:append(assert(vim.env[env], env .. " is required"))
  end
  local server = assert(vim.env.KOTLIN_LSP_DIR, "KOTLIN_LSP_DIR is required")

  -- Builds consume these Lua files, not the Fennel sources.
  for _, name in ipairs({ "kotlin", "lsp" }) do
    local path = "v2/fnl/" .. name .. ".fnl"
    local compiled = "-- [nfnl] " .. path .. "\n"
      .. require("nfnl.fennel")["compile-string"](table.concat(vim.fn.readfile(path), "\n"), {
        filename = path,
      })
    assert(compiled == table.concat(vim.fn.readfile("v2/lua/autogen/" .. name .. ".lua"), "\n"),
      name .. ": generated Lua differs from Fennel compilation")
  end

  -- Keep the real plugin setup, but prevent spawning servers in this config test.
  local enabled = {}
  vim.lsp.enable = function(name)
    enabled[name] = true
  end
  vim.bo.filetype = "kotlin"
  _G.args = { kotlin_lsp_dir = server }
  dofile("v2/lua/autogen/kotlin.lua")
  assert(enabled.kotlin_lsp, "the first Kotlin buffer must enable the server without another FileType event")
  local config = vim.lsp.config.kotlin_lsp
  assert(vim.deep_equal(config.filetypes, { "kotlin" }), "Java must remain with jdtls")
  local settings = config.handlers["workspace/configuration"](nil, {
    items = { { section = "jetbrains.kotlin" } },
  }, {})[1]
  assert(settings.hints.parameters == true and settings.hints["type.property"] == true)

  -- Capture the wrapped diagnostic handler; verify forwarding and client scope.
  local received
  vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, opts)
    received = { err = err, result = result, ctx = ctx, opts = opts }
    return "forwarded"
  end
  local client_name = "kotlin_lsp"
  vim.lsp.get_client_by_id = function()
    return client_name and { name = client_name } or nil
  end
  dofile("v2/lua/autogen/lsp.lua")
  local handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
  local ctx, opts = { client_id = 1 }, {}
  local diagnostics = {
    { severity = 1 }, { severity = 2 }, { severity = 3 }, { severity = 4 }, {},
  }
  local result = { diagnostics = vim.deepcopy(diagnostics) }
  assert(handler(nil, result, ctx, opts) == "forwarded")
  assert(#received.result.diagnostics == 4, "only Kotlin HINT diagnostics should be filtered")
  assert(received.result.diagnostics[4].severity == nil, "missing severity must survive")
  assert(received.ctx == ctx and received.opts == opts)
  for _, name in ipairs({ "jdtls", "kotlin_ls", false }) do
    client_name = name
    result = { diagnostics = vim.deepcopy(diagnostics) }
    handler(nil, result, ctx, opts)
    assert(vim.deep_equal(received.result.diagnostics, diagnostics), "unrelated clients must be unchanged")
  end
  client_name = "kotlin_lsp"
  handler("error", nil, ctx, opts)
  assert(received.err == "error" and received.result == nil)
  handler(nil, {}, ctx, opts)
  assert(received.result.diagnostics == nil)
  print("PASS: Fennel/Lua parity, first-buffer setup, Java exclusion, hints, diagnostic filtering")
end

local ok, err = pcall(check)
if not ok then
  io.stderr:write(tostring(err) .. "\n")
  vim.cmd.cquit()
end
