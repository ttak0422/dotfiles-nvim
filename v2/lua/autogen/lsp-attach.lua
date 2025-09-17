-- [nfnl] v2/fnl/lsp-attach.fnl
local function _1_(ctx)
  if not vim.b.lsp_attached then
    vim.b.lsp_attached = true
    local bufnr = ctx.buf
    local desc
    local function _2_(d)
      return {noremap = true, silent = true, buffer = bufnr, desc = d}
    end
    desc = _2_
    local function _3_()
      local ok, noice_lsp = pcall(require, "noice.lsp")
      if ok then
        return noice_lsp.hover()
      else
        return vim.lsp.buf.hover()
      end
    end
    for _, k in ipairs({{"gd", vim.lsp.buf.definition, "go to definition"}, {"gi", vim.lsp.buf.implementation, "go to implementation"}, {"gr", vim.lsp.buf.references, "go to references"}, {"<Leader>K", vim.lsp.buf.signature_help, "show signature"}, {"<Leader>D", vim.lsp.buf.type_definition, "show type"}, {"<Leader>ca", vim.lsp.buf.code_action, "code action"}, {"K", _3_, "show doc"}, {"gpd", "<Cmd>lua require('goto-preview').goto_preview_definition()<CR>", "preview definition"}, {"gpi", "<Cmd>lua require('goto-preview').goto_preview_implementation()<CR>", "preview implementation"}, {"gpr", "<Cmd>lua require('goto-preview').goto_preview_references()<CR>", "preview references"}, {"gP", "<Cmd>lua require('goto-preview').close_all_win()<CR>", "close all preview"}, {"gD", "<Cmd>Glance definitions<CR>", "go to definition"}, {"gI", "<Cmd>Glance implementations<CR>", "go to impl"}, {"gR", "<Cmd>Glance references<CR>", "go to references"}, {"<leader>cc", "<Cmd>Neogen class<CR>", "class comment"}, {"<leader>cf", "<Cmd>Neogen func<CR>", "fn comment"}, {"<leader>rn", ":IncRename ", "rename"}}) do
      vim.keymap.set("n", k[1], k[2], desc(("\238\171\132 " .. k[3])))
    end
    local function _5_()
      return (":IncRename " .. vim.fn.expand("<cword>"))
    end
    vim.keymap.set("n", "<leader>rN", _5_, {noremap = true, silent = true, expr = true, buffer = bufnr, desc = "rename"})
    vim.keymap.set("n", "<leader>cF", vim.lsp.buf.format, desc("\238\171\132 format"))
    local function _6_()
      return vim.lsp.buf.format({timeout_ms = 10000})
    end
    return vim.keymap.set({"n", "v"}, "<C-CR>", _6_, desc("\238\171\132 format"))
  else
    return nil
  end
end
return _1_
