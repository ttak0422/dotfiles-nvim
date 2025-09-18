-- [nfnl] v2/fnl/lsp.fnl
vim.lsp.set_log_level(vim.log.levels.ERROR)
do
  local tmp_9_ = vim.lsp.handlers
  tmp_9_["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "none"})
  tmp_9_["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {update_in_insert = false})
end
vim.diagnostic.config({severity_sort = true, signs = {text = {[vim.diagnostic.severity.ERROR] = "\239\145\132", [vim.diagnostic.severity.WARN] = "\239\145\132", [vim.diagnostic.severity.INFO] = "\239\145\132", [vim.diagnostic.severity.HINT] = "\239\145\132"}, numhl = {[vim.diagnostic.severity.ERROR] = "", [vim.diagnostic.severity.WARN] = "", [vim.diagnostic.severity.INFO] = "", [vim.diagnostic.severity.HINT] = ""}}, update_in_insert = false, virtual_text = false})
local function _1_(ctx)
  return dofile(args.attach_path)({buf = ctx.buf, client = vim.lsp.get_client_by_id(ctx.data.client_id)})
end
vim.api.nvim_create_autocmd("LspAttach", {desc = "register lsp keymaps", callback = _1_})
return vim.lsp.enable({"bashls", "cssls", "dartls", "denols", "dhall_lsp_server", "rubocop", "fennel_ls", "gopls", "html", "jsonls", "kotlin_language_server", "lua_ls", "marksman", "nil_ls", "pyright", "solargraph", "taplo", "typos_lsp", "vtsls", "yamlls"})
