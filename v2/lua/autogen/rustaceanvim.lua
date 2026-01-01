-- [nfnl] v2/fnl/rustaceanvim.fnl
local default_settings = {["rust-analyzer"] = {files = {excludeDirs = {".direnv", ".git", ".venv", "bin", "node_modules", "target"}}}}
vim.g.rustaceanvim = {server = {default_settings = default_settings}}
return nil
