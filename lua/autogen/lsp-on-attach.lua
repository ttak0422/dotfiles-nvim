-- [nfnl] Compiled from fnl/lsp-on-attach.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_(client, bufnr)
  local map = vim.keymap.set
  local cmd
  local function _2_(c)
    return ("<cmd>" .. c .. "<cr>")
  end
  cmd = _2_
  local desc
  local function _3_(d)
    return {noremap = true, silent = true, buffer = bufnr, desc = d}
  end
  desc = _3_
  local live_rename = require("live-rename")
  vim.api.nvim_create_user_command("Format", "lua vim.lsp.buf.format()", {})
  map("n", "gd", vim.lsp.buf.definition, desc("go to definition"))
  map("n", "gi", vim.lsp.buf.implementation, desc("go to impl"))
  map("n", "gr", vim.lsp.buf.references, desc("go to references"))
  map("n", "gD", cmd("Glance definitions"), desc("go to definition"))
  map("n", "gI", cmd("Glance implementations"), desc("go to impl"))
  map("n", "gR", cmd("Glance references"), desc("go to references"))
  map("n", "K", vim.lsp.buf.hover, desc("show doc"))
  map("n", "<leader>K", vim.lsp.buf.signature_help, desc("show signature"))
  map("n", "<leader>D", vim.lsp.buf.type_definition, desc("show type"))
  map("n", "<leader>rn", live_rename.map({insert = true}), desc("rename"))
  map("n", "<leader>ca", vim.lsp.buf.code_action, desc("code action"))
  map("n", "<leader>cc", cmd("Neogen class"), desc("class comment"))
  map("n", "<leader>cf", cmd("Neogen func"), desc("fn comment"))
  if client.supports_method("textDocument/formatting") then
    map("n", "<leader>cF", cmd("Format"), desc("format"))
  else
  end
  if client.supports_method("textDocument/inlayHint") then
    require("lsp-inlayhints").on_attach(client, bufnr)
  else
  end
  if client.supports_method("textDocument/codeLens") then
    require("virtualtypes").on_attach(client, bufnr)
  else
  end
  if client.supports_method("textDocument/publishDiagnostics") then
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {update_in_insert = false})
    return nil
  else
    return nil
  end
end
return _1_
