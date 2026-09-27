-- [nfnl] v2/fnl/kotlin.fnl
vim.env.KOTLIN_LSP_DIR = args.kotlin_lsp_dir
local kotlin = require("kotlin")
local opts = {inlay_hints = {enabled = true}, java_files = false}
kotlin.setup(opts)
if (vim.bo.filetype == "kotlin") then
  return kotlin.setup_kotlin_lsp(opts)
else
  return nil
end
