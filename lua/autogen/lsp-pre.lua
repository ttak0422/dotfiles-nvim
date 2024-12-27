-- [nfnl] Compiled from fnl/lsp-pre.fnl by https://github.com/Olical/nfnl, do not edit.
vim.lsp.set_log_level("ERROR")
do
  local tmp_9_auto = vim.lsp.handlers
  tmp_9_auto["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "none"})
  tmp_9_auto["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {update_in_insert = false})
end
vim.diagnostic.config({severity_sort = true, signs = {text = {[vim.diagnostic.severity.ERROR] = "\239\145\132", [vim.diagnostic.severity.WARN] = "\239\145\132", [vim.diagnostic.severity.INFO] = "\239\145\132", [vim.diagnostic.severity.HINT] = "\239\145\132"}, numhl = {[vim.diagnostic.severity.ERROR] = "", [vim.diagnostic.severity.WARN] = "", [vim.diagnostic.severity.INFO] = "", [vim.diagnostic.severity.HINT] = ""}}, update_in_insert = false, virtual_text = false})
local cmd
local function _1_(c)
  return ("<cmd>" .. c .. "<cr>")
end
cmd = _1_
local NS
local function _2_()
  return require("live-rename").map({insert = true})
end
NS = {{"gd", vim.lsp.buf.definition, "\238\171\132 go to definition"}, {"gi", vim.lsp.buf.implementation, "\238\171\132 go to implementation"}, {"gr", vim.lsp.buf.references, "\238\171\132 go to references"}, {"K", vim.lsp.buf.hover, "\238\171\132 show doc"}, {"<Leader>K", vim.lsp.buf.signature_help, "\238\171\132 show signature"}, {"<Leader>D", vim.lsp.buf.type_definition, "\238\171\132 show type"}, {"<Leader>ca", vim.lsp.buf.code_action, "\238\171\132 code action"}, {"gD", cmd("Glance definitions"), "\238\171\132 go to definition"}, {"gI", cmd("Glance implementations"), "\238\171\132 go to impl"}, {"gR", cmd("Glance references"), "\238\171\132 go to references"}, {"<leader>cc", cmd("Neogen class"), "\238\171\132 class comment"}, {"<leader>cf", cmd("Neogen func"), "\238\171\132 fn comment"}, {"<leader>rn", _2_, "\238\171\132 fn comment"}}
local callback
local function _3_(ctx)
  local bufnr = ctx.buf
  local client = vim.lsp.get_client_by_id(ctx.data.client_id)
  local desc
  local function _4_(d)
    return {noremap = true, silent = true, buffer = bufnr, desc = d}
  end
  desc = _4_
  for _, k in ipairs(NS) do
    vim.keymap.set("n", k[1], k[2], desc(k[3]))
  end
  if client.supports_method("textDocument/formatting") then
    vim.keymap.set("n", "<leader>cF", vim.lsp.buf.format, desc("\238\171\132 format"))
  else
  end
  if client.supports_method("textDocument/publishDiagnostics") then
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {update_in_insert = false})
  else
  end
  if client.supports_method("textDocument/inlayHint") then
    require("lsp-inlayhints").on_attach(client, bufnr)
  else
  end
  if client.supports_method("textDocument/codeLens") then
    return require("virtualtypes").on_attach(client, bufnr)
  else
    return nil
  end
end
callback = _3_
return vim.api.nvim_create_autocmd("LspAttach", {callback = callback})
