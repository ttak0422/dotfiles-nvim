-- [nfnl] Compiled from fnl/prelude.fnl by https://github.com/Olical/nfnl, do not edit.
vim.loader.enable()
for k, v in pairs({langmenu = "none", shortmess = (vim.o.shortmess .. "sWcCS"), cmdheight = 0, termguicolors = true, number = true, foldcolumn = "1", signcolumn = "yes", showtabline = 0, laststatus = 0, foldlevel = 99, foldlevelstart = 99, splitkeep = "screen", showmode = false}) do
  vim.o[k] = v
end
vim.g.mapleader = " "
vim.g.maplocalleader = ","
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
  local mk_toggle
  local function _4_()
    local state = {pre_id = nil, ["open?"] = false}
    local function _5_(id, mod, args)
      local function _6_()
        if (state.pre_id ~= id) then
          require("toolwindow").open_window(mod, args)
          state["open?"] = true
        else
          if state["open?"] then
            require("toolwindow").close()
            state["open?"] = false
          else
            require("toolwindow").open_window(mod, args)
            state["open?"] = true
          end
        end
        state["pre_id"] = id
        return nil
      end
      return _6_
    end
    return _5_
  end
  mk_toggle = _4_()
  for _, K in ipairs({{"ff", cmd("Telescope live_grep_args"), desc("search by content")}, {"fF", cmd("Telescope ast_grep"), desc("search by AST")}, {"ft", cmd("Telescope sonictemplate templates"), desc("search templates")}, {"fh", cmd("Legendary"), desc("Search command palette")}, {"H", lcmd("require('harpoon').ui:toggle_quick_menu(require('harpoon'):list(),{border='none'})"), desc("Show registered file")}, {"ha", lcmd("require('harpoon'):list():add()"), desc("Register file")}, {"fp", cmd("Ddu -name=fd file_fd"), desc("search by file name")}, {"fP", cmd("Ddu -name=ghq ghq"), desc("search repo (ghq)")}, {"fru", cmd("Ddu -name=mru mru"), desc("MRU (Most Recently Used files)")}, {"frw", cmd("Ddu -name=mrw mrw"), desc("MRW (Most Recently Written files)")}, {"frr", cmd("Ddu -name=mrr mrr"), desc("MRR (Most Recent git Repositories)")}, {"mq", cmd("MarksQFListBuf"), desc("marks in current buffer")}, {"mQ", cmd("MarksQFListGlobal"), desc("marks in all buffer")}, {"U", cmd("UndotreeToggle", desc("toggle undotree"))}, {"nn", cmd("Neorg journal today"), desc("Enter Neorg (today journal)")}, {"no", cmd("Neorg toc"), desc("Show Neorg TOC")}, {"N", cmd("Neorg"), desc("Enter Neorg")}, {"fn", cmd("NeorgFuzzySearch"), desc("find Neorg linkable")}, {"G", cmd("Neogit"), desc("\239\135\147 client")}, {"gb", cmd("ToggleGitBlame"), desc("\239\135\147 blame")}, {"tb", lcmd("require('lir.float').toggle()"), desc("Toggle lir")}, {"tB", lcmd("require('oil').open()"), desc("Toggle oil")}, {"q", cmd("BufDel"), desc("close buffer")}, {"Q", cmd("BufDelAll"), desc("close all buffers")}, {"A", cmd("tabclose")}, {"tc", cmd("ColorizerToggle"), desc("toggle colorizer")}, {"tt", cmd("NoNeckPain"), desc("toggle no neck pain")}, {"tm", lcmd("require('codewindow').toggle_minimap()"), desc("toggle minimap")}, {"tj", cmd("lua require('treesj').toggle({ split = { recursive = false }})"), desc("toggle split/join")}, {"tJ", cmd("lua require('treesj').toggle({ split = { recursive = true }})"), desc("toggle recursive split/join")}, {"tq", mk_toggle(1, "qf", nil), desc("toggle quickfix")}, {"td", mk_toggle(2, "trouble", {mode = "diagnostics", filter = {buf = 0}}), desc("toggle diagnostics (document)")}, {"tD", mk_toggle(3, "trouble", {mode = "diagnostics"}), desc("toggle diagnostics (workspace)")}}) do
    vim.keymap.set("n", ("<Leader>" .. K[1]), K[2], (K[3] or opts))
  end
  for _, K in ipairs({{"R", cmd("FlowRunSelected")}}) do
    vim.keymap.set("v", K[1], K[2], (K[3] or opts))
  end
  for i = 0, 9 do
    vim.keymap.set({"n", "t", "i"}, ("<C-" .. i .. ">"), mk_toggle((4 + i), "terminal", {idx = i}), opts)
  end
end
vim.cmd("colorscheme morimo")
return require("config-local").setup({silent = true})
