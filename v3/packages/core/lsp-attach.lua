return function(ctx)
  local bufnr = ctx.buf
  if ctx.client and ctx.client:supports_method("textDocument/inlayHint", bufnr) then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
  if vim.b[bufnr].lsp_attached then
    return
  end
  vim.b[bufnr].lsp_attached = true

  local function options(description)
    return { noremap = true, silent = true, buffer = bufnr, desc = " " .. description }
  end
  local function code_action()
    require("tiny-code-action").code_action()
  end
  for _, mapping in ipairs({
    { "gd", vim.lsp.buf.definition, "go to definition" },
    { "gi", vim.lsp.buf.implementation, "go to implementation" },
    { "gr", vim.lsp.buf.references, "go to references" },
    { "<Leader>K", vim.lsp.buf.signature_help, "show signature" },
    { "<Leader>D", vim.lsp.buf.type_definition, "show type" },
    { "<Leader>ca", code_action, "code action" },
    { "gpd", "<Cmd>lua require('goto-preview').goto_preview_definition()<CR>", "preview definition" },
    { "gpi", "<Cmd>lua require('goto-preview').goto_preview_implementation()<CR>", "preview implementation" },
    { "gpr", "<Cmd>lua require('goto-preview').goto_preview_references()<CR>", "preview references" },
    { "gP", "<Cmd>lua require('goto-preview').close_all_win()<CR>", "close all preview" },
    { "gD", "<Cmd>Glance definitions<CR>", "go to definition" },
    { "gI", "<Cmd>Glance implementations<CR>", "go to impl" },
    { "gR", "<Cmd>Glance references<CR>", "go to references" },
    { "<Leader>cc", "<Cmd>Neogen class<CR>", "class comment" },
    { "<Leader>cf", "<Cmd>Neogen func<CR>", "fn comment" },
    { "<Leader>rn", ":IncRename ", "rename" },
  }) do
    vim.keymap.set("n", mapping[1], mapping[2], options(mapping[3]))
  end
  vim.keymap.set("n", "<Leader>rN", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
  end, { noremap = true, silent = true, expr = true, buffer = bufnr, desc = "rename" })

  local function format(timeout)
    -- none-ls owns the JVM formatter choice. Allow IDEA's 60s deadline plus cleanup.
    local jvm = ({ java = true, groovy = true, kotlin = true })[vim.bo[bufnr].filetype]
    vim.lsp.buf.format({
      bufnr = bufnr,
      timeout_ms = jvm and 65000 or timeout,
      name = jvm and "null-ls" or nil,
    })
  end
  vim.keymap.set("n", "<Leader>cF", function() format(1000) end, options("format"))
  vim.keymap.set({ "n", "v" }, "<C-CR>", function() format(10000) end, options("format"))
end
