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
local callback
local function _2_(ctx)
  local bufnr = ctx.buf
  local client = vim.lsp.get_client_by_id(ctx.data.client_id)
  local desc
  local function _3_(d)
    return {noremap = true, silent = true, buffer = bufnr, desc = d}
  end
  desc = _3_
  local function _4_()
    return require("noice.lsp").hover()
  end
  for _, k in ipairs({{"gd", vim.lsp.buf.definition, "go to definition"}, {"gi", vim.lsp.buf.implementation, "go to implementation"}, {"gr", vim.lsp.buf.references, "go to references"}, {"K", _4_, "show doc"}, {"<Leader>K", vim.lsp.buf.signature_help, "show signature"}, {"<Leader>D", vim.lsp.buf.type_definition, "show type"}, {"<Leader>ca", vim.lsp.buf.code_action, "code action"}, {"gD", cmd("Glance definitions"), "go to definition"}, {"gI", cmd("Glance implementations"), "go to impl"}, {"gR", cmd("Glance references"), "go to references"}, {"<leader>cc", cmd("Neogen class"), "class comment"}, {"<leader>cf", cmd("Neogen func"), "fn comment"}, {"<leader>rn", ":IncRename ", "rename"}}) do
    vim.keymap.set("n", k[1], k[2], desc(("\238\171\132 " .. k[3])))
  end
  local function _5_()
    return (":IncRename " .. vim.fn.expand("<cword>"))
  end
  vim.keymap.set("n", "<leader>rN", _5_, {noremap = true, silent = true, expr = true, buffer = bufnr, desc = "rename"})
  if client.supports_method("textDocument/formatting") then
    vim.keymap.set("n", "<leader>cF", vim.lsp.buf.format, desc("\238\171\132 format"))
  else
    vim.keymap.set({"n", "v"}, "<C-CR>", vim.lsp.buf.format, desc("\238\171\132 format"))
  end
  if client.supports_method("textDocument/publishDiagnostics") then
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {update_in_insert = false})
    return nil
  else
    return nil
  end
end
callback = _2_
return vim.api.nvim_create_autocmd("LspAttach", {callback = callback})
