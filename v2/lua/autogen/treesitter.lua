-- [nfnl] v2/fnl/treesitter.fnl
require("nvim-treesitter").setup({install_dir = args.install_dir})
do
  local M = require("nvim-treesitter-textobjects")
  M.setup({select = {lookahead = true}, move = {set_jumps = true}})
end
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
local function _1_()
  pcall(vim.treesitter.start)
  if (vim.bo.indentexpr == "") then
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    return nil
  else
    return nil
  end
end
return vim.api.nvim_create_autocmd("FileType", {callback = _1_})
