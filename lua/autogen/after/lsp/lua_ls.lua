-- [nfnl] Compiled from fnl/after/lsp/lua_ls.fnl by https://github.com/Olical/nfnl, do not edit.
return {settings = {Lua = {runtime = {version = "LuaJIT", special = {reload = "require"}}, diagnostics = {globals = {"vim"}}}, workspace = {library = {vim.fn.expand("$VIMRUNTIME/lua")}}, telemetry = {enable = false}}}
