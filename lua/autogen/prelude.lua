-- [nfnl] Compiled from fnl/prelude.fnl by https://github.com/Olical/nfnl, do not edit.
vim.loader.enable()
vim.cmd("language messages en_US.UTF-8")
for k, v in pairs({langmenu = "none", shortmess = (vim.o.shortmess .. "sWcS"), cmdheight = 0, termguicolors = true, number = true, signcolumn = "yes", showtabline = 0, laststatus = 0, foldlevel = 99, foldlevelstart = 99, foldcolumn = "1", splitkeep = "screen", completeopt = {}, wrap = false}) do
  vim.opt[k] = v
end
for k, v in pairs({mapleader = " ", maplocalleader = ",", loaded_netrw = 1, loaded_netrwPlugin = 1}) do
  vim.g[k] = v
end
do
  local O = {noremap = true, silent = true}
  local D
  local function _1_(d)
    return {noremap = true, silent = true, desc = d}
  end
  D = _1_
  local C
  local function _2_(c)
    return ("<cmd>" .. c .. "<cr>")
  end
  C = _2_
  local L
  local function _3_(c)
    return C(("lua " .. c))
  end
  L = _3_
  local T
  local function _4_(id)
    local function _5_()
      return require("toggler").toggle(id)
    end
    return _5_
  end
  T = _4_
  for _, K in ipairs({{"ff", C("Telescope live_grep_args"), D("search by content")}, {"fF", C("Telescope ast_grep"), D("search by AST")}, {"fb", C("TelescopeB"), D("search by buffer")}, {"ft", C("Telescope sonictemplate templates"), D("search templates")}, {"fh", C("Legendary"), D("Search command palette")}, {"H", L("require('harpoon').ui:toggle_quick_menu(require('harpoon'):list(),{border='none'})"), D("Show registered file")}, {"ha", L("require('harpoon'):list():add()"), D("Register file")}, {"fp", C("Ddu -name=files file_fd"), D("search by file name")}, {"fP", C("Ddu -name=ghq ghq"), D("search repo (ghq)")}, {"fru", C("Ddu -name=mru mru"), D("MRU (Most Recently Used files)")}, {"frw", C("Ddu -name=mrw mrw"), D("MRW (Most Recently Written files)")}, {"frr", C("Ddu -name=mrr mrr"), D("MRR (Most Recent git Repositories)")}, {"frd", C("Ddu -name=mrd mrd"), D("MRD (Most Recent Directories)")}, {"mq", C("MarksQFListBuf"), D("marks in current buffer")}, {"mQ", C("MarksQFListGlobal"), D("marks in all buffer")}, {"U", C("UndotreeToggle", D("toggle undotree"))}, {"nt", C("Neorg journal today"), D("\238\152\179 Today")}, {"ny", C("Neorg journal yesterday"), D("\238\152\179 Yesterday")}, {"N", C("Neorg"), D("\238\152\179 Enter")}, {"nn", C("NeorgUID"), D("\238\152\179 UID")}, {"ngg", C("NeorgGit"), D("\238\152\179 Git")}, {"ngb", C("NeorgGitBranch"), D("\238\152\179 Git (branch)")}, {"fn", C("NeorgFuzzySearch"), D("find Neorg linkable")}, {"G", T("gitu"), D("\239\135\147 client")}, {"gb", T("blame"), D("\239\135\147 blame")}, {"tb", L("require('lir.float').toggle()"), D("\239\136\133  explorer")}, {"tB", L("require('oil').open()"), D("\239\136\133  explorer")}, {"q", C("BufDel"), D("close buffer")}, {"Q", C("BufDelAll"), D("close all buffers")}, {"A", C("tabclose")}, {"ts", C("Screenkey toggle"), D("toggle screenkey")}, {"tc", C("ColorizerToggle"), D("toggle colorizer")}, {"tt", C("NoNeckPain"), D("toggle no neck pain")}, {"tm", L("require('codewindow').toggle_minimap()"), D("toggle minimap")}, {"to", C("AerialToggle"), D("toggle outline")}, {"tj", C("lua require('treesj').toggle({ split = { recursive = false }})"), D("toggle split/join")}, {"tJ", C("lua require('treesj').toggle({ split = { recursive = true }})"), D("toggle recursive split/join")}, {"tq", T("qf"), D("toggle quickfix")}, {"td", T("trouble-doc"), D("toggle diagnostics (document)")}, {"tD", T("trouble-ws"), D("toggle diagnostics (workspace)")}, {"tR", L("require('spectre').toggle()"), D("toggle spectre")}, {"ta", C("TCopilotChatToggle")}, {"aa", C("AvanteAsk"), D("\238\128\137Avante Ask")}, {"at", C("TAvanteToggle"), D("\238\128\137Avante Toggle")}}) do
    vim.keymap.set("n", ("<Leader>" .. K[1]), K[2], (K[3] or O))
  end
  for m, ks in pairs({n = {{"\194\165", "\\"}, {"<C-t>", C("OpenMenu")}}, i = {{"\194\165", "\\"}}, c = {{"\194\165", "\\"}}, t = {{"\194\165", "\\"}}, v = {{"R", C("FlowRunSelected")}, {"<C-t>", C("OpenMenu")}}}) do
    for _, k in ipairs(ks) do
      vim.keymap.set(m, k[1], k[2], (k[3] or O))
    end
  end
  for i = 0, 9 do
    vim.keymap.set({"n", "t", "i"}, ("<C-" .. i .. ">"), T(("term" .. i)), O)
  end
end
return require("config-local").setup({silent = true})
