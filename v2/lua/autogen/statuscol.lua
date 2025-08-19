-- [nfnl] v2/fnl/statuscol.fnl
local statuscol = require("statuscol")
local builtin = require("statuscol.builtin")
local segments = {{sign = {namespace = {"gitsigns"}, maxwidth = 1, colwidth = 1, wrap = true}}, {text = {builtin.foldfunc}, click = "v:lua.ScFa"}, {text = {builtin.lnumfunc, " "}, click = "v:lua.ScLa"}}
local function setup()
  return statuscol.setup({segments = segments})
end
setup()
return vim.api.nvim_create_autocmd({"BufReadPost"}, {pattern = {"*"}, callback = setup})
