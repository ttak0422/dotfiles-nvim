-- [nfnl] Compiled from fnl/crates.fnl by https://github.com/Olical/nfnl, do not edit.
return require("crates").setup({lsp = {enabled = true, on_attach = dofile(args.on_attach_path), actions = true, hover = true, completion = false}}, "null_ls", {enabled = true, name = "crates.nvim"})
