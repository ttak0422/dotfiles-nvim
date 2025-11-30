-- [nfnl] v2/fnl/ts-error-translator.fnl
local translator = require("ts-error-translator")
return translator.setup({auto_attach = true, servers = {"astro", "svelte", "ts_ls", "typescript-tools", "volar", "vtsls"}})
