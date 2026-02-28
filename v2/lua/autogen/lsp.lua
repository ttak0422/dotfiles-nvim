-- [nfnl] v2/fnl/lsp.fnl
vim.lsp.set_log_level(vim.log.levels.ERROR)
local diagnostic_min_severity = {kotlin_ls = vim.diagnostic.severity.INFO}
do
  local tmp_9_ = vim.lsp.handlers
  local _1_
  do
    local handler = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {update_in_insert = false})
    local function _2_(err, result, ctx, config)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local min_sev
      if client then
        min_sev = diagnostic_min_severity[client.name]
      else
        min_sev = nil
      end
      if (min_sev and result and result.diagnostics) then
        local function _4_(d)
          return (d.severity <= min_sev)
        end
        result.diagnostics = vim.tbl_filter(_4_, result.diagnostics)
      else
      end
      return handler(err, result, ctx, config)
    end
    _1_ = _2_
  end
  tmp_9_["textDocument/publishDiagnostics"] = _1_
end
vim.diagnostic.config({severity_sort = true, signs = {text = {[vim.diagnostic.severity.ERROR] = "\239\145\132", [vim.diagnostic.severity.WARN] = "\239\145\132", [vim.diagnostic.severity.INFO] = "\239\145\132", [vim.diagnostic.severity.HINT] = "\239\145\132"}, numhl = {[vim.diagnostic.severity.ERROR] = "", [vim.diagnostic.severity.WARN] = "", [vim.diagnostic.severity.INFO] = "", [vim.diagnostic.severity.HINT] = ""}}, update_in_insert = false, virtual_text = false})
local function _6_(ctx)
  return dofile(args.attach_path)({buf = ctx.buf, client = vim.lsp.get_client_by_id(ctx.data.client_id)})
end
vim.api.nvim_create_autocmd("LspAttach", {desc = "register lsp keymaps", callback = _6_})
return vim.lsp.enable({"bashls", "cssls", "dartls", "denols", "dhall_lsp_server", "fennel_ls", "gopls", "harper_ls", "html", "jsonls", "lua_ls", "marksman", "nil_ls", "pyright", "rubocop", "ruff", "solargraph", "taplo", "terraformls", "vtsls", "yamlls"})
