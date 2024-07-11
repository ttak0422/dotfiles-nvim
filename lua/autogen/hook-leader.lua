-- [nfnl] Compiled from fnl/hook-leader.fnl by https://github.com/Olical/nfnl, do not edit.
vim.api.nvim_del_keymap("n", "<Leader>")
do
  local opts = {noremap = true, silent = true}
  local desc
  local function _1_(d)
    return {noremap = true, silent = true, desc = d}
  end
  desc = _1_
  local cmd
  local function _2_(c)
    return ("<cmd>" .. c .. "<cr>")
  end
  cmd = _2_
  local lcmd
  local function _3_(c)
    return cmd(("lua " .. c))
  end
  lcmd = _3_
  local N = {{"<Leader>ff", cmd("Telescope live_grep_args"), desc("search by content")}, {"<Leader>fF", cmd("Telescope ast_grep"), desc("search by AST")}, {"<Leader>ft", cmd("Telescope sonictemplate templates"), desc("search templates")}, {"<Leader>fh", cmd("Legendary"), desc("Search command palette")}, {"<Leader>H", lcmd("require('harpoon').ui:toggle_quick_menu(require('harpoon'):list(),{border='none'})"), desc("Show registered file")}, {"<Leader>ha", lcmd("require('harpoon'):list():add()"), desc("Register file")}, {"<Leader>nn", cmd("Neorg journal today"), desc("Enter Neorg (today journal)")}, {"<Leader>no", cmd("Neorg toc"), desc("Show Neorg TOC")}, {"<Leader>N", cmd("Neorg"), desc("Enter Neorg")}, {"<Leader>G", cmd("Neogit"), desc("Neovim git client")}, {"<Leader>tb", lcmd("require('lir.float').toggle()"), desc("Toggle lir")}, {"<Leader>tB", lcmd("require('oil').open()"), desc("Toggle oil")}, {"<leader>q", cmd("BufDel")}, {"<leader>Q", cmd("BufDel!")}, {"<leader>tm", lcmd("require('codewindow').toggle_minimap()"), desc("toggle minimap")}}
  for _, K in ipairs(N) do
    vim.keymap.set("n", K[1], K[2], (K[3] or opts))
  end
end
local function _4_()
  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Leader>", true, false, true), "m", true)
end
return vim.schedule(_4_)
