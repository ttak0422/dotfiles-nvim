-- [nfnl] v2/fnl/buffer-plugins.fnl
local cachedir = vim.fn.stdpath("cache")
for k, v in pairs({updatetime = 100, hidden = true, autoread = true, undofile = true, undodir = (cachedir .. "/undo"), swapfile = true, directory = (cachedir .. "/swap"), backup = true, backupcopy = "yes", backupdir = (cachedir .. "/backup"), foldcolumn = 1, foldlevel = 99, foldlevelstart = 99, foldenable = true, equalalways = false, startofline = false}) do
  vim.opt[k] = v
end
local opts = {noremap = true, silent = true}
local desc
local function _1_(d)
  return {noremap = true, silent = true, desc = d}
end
desc = _1_
local function _2_()
  return require("open").open_cword()
end
for _, k in ipairs({{"<Leader>U", "<Cmd>UndotreeToggle<CR>", desc("\239\136\132 undotree")}, {"gx", _2_, desc("open")}}) do
  vim.keymap.set("n", k[1], k[2], (k[3] or opts))
end
return nil
