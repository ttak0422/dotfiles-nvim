-- [nfnl] v2/fnl/kotlin.fnl
vim.env.KOTLIN_LSP_DIR = args.kotlin_lsp_dir
return require("kotlin").setup()
