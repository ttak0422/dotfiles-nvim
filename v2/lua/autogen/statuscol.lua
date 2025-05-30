-- [nfnl] v2/fnl/statuscol.fnl
local statuscol = require("statuscol")
local builtin = require("statuscol.builtin")
local segments = {{text = {"%s"}, maxwidth = 2, click = "v:lua.ScSa"}, {text = {builtin.lnumfunc}, click = "v:lua.ScLa"}, {text = {" ", builtin.foldfunc, " "}, click = "v:lua.ScFa"}}
local function setup()
  if (vim.o.statuscolumn == "") then
    return statuscol.setup({segments = segments})
  else
    return nil
  end
end
setup()
return vim.api.nvim_create_autocmd({"BufReadPost"}, {pattern = {"*"}, callback = setup})
