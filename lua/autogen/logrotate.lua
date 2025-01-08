-- [nfnl] Compiled from fnl/logrotate.fnl by https://github.com/Olical/nfnl, do not edit.
return require("logrotate").setup({targets = {(vim.fn.stdpath("state") .. "/lsp.log")}, interval = "daily"})
