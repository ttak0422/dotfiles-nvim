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
  local mk_toggle
  local function _4_()
    local state = {pre_id = nil, ["open?"] = false}
    local function _5_(id, mod, args)
      local function _6_()
        local T = require("toolwindow")
        if (state.pre_id ~= id) then
          T.open_window(mod, args)
          do end (state)["open?"] = true
        else
          if state["open?"] then
            T.close()
            do end (state)["open?"] = false
          else
            T.open_window(mod, args)
            do end (state)["open?"] = true
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
  local N = {{"<Leader>ff", cmd("Telescope live_grep_args"), desc("search by content")}, {"<Leader>fF", cmd("Telescope ast_grep"), desc("search by AST")}, {"<Leader>ft", cmd("Telescope sonictemplate templates"), desc("search templates")}, {"<Leader>fh", cmd("Legendary"), desc("Search command palette")}, {"<Leader>H", lcmd("require('harpoon').ui:toggle_quick_menu(require('harpoon'):list(),{border='none'})"), desc("Show registered file")}, {"<Leader>ha", lcmd("require('harpoon'):list():add()"), desc("Register file")}, {"<Leader>fp", cmd("Ddu -name=fd file_fd"), desc("search by file name")}, {"<Leader>fP", cmd("Ddu -name=ghq ghq"), desc("search repo (ghq)")}, {"<Leader>fru", cmd("Ddu -name=mru mru"), desc("MRU (Most Recently Used files)")}, {"<Leader>frw", cmd("Ddu -name=mrw mrw"), desc("MRW (Most Recently Written files)")}, {"<leader>mq", cmd("MarksQFListBuf"), desc("marks in current buffer")}, {"<leader>mQ", cmd("MarksQFListGlobal"), desc("marks in all buffer")}, {"<leader>U", cmd("UndotreeToggle", desc("toggle undotree"))}, {"<Leader>nn", cmd("Neorg journal today"), desc("Enter Neorg (today journal)")}, {"<Leader>no", cmd("Neorg toc"), desc("Show Neorg TOC")}, {"<Leader>N", cmd("Neorg"), desc("Enter Neorg")}, {"<Leader>fn", cmd("Neorg keybind norg core.integrations.telescope.find_linkable"), desc("find Neorg linkable")}, {"<Leader>G", cmd("Neogit"), desc("Neovim git client")}, {"<Leader>tb", lcmd("require('lir.float').toggle()"), desc("Toggle lir")}, {"<Leader>tB", lcmd("require('oil').open()"), desc("Toggle oil")}, {"<leader>q", cmd("BufDel")}, {"<leader>Q", cmd("BufDel!")}, {"<leader>tm", lcmd("require('codewindow').toggle_minimap()"), desc("toggle minimap")}, {"<leader>tj", cmd("lua require('treesj').toggle({ split = { recursive = false }})"), desc("toggle split/join")}, {"<leader>tJ", cmd("lua require('treesj').toggle({ split = { recursive = true }})"), desc("toggle recursive split/join")}, {"<leader>tq", mk_toggle(1, "quickfix", nil), desc("toggle quickfix")}, {"<leader>td", mk_toggle(2, "trouble", {mode = "diagnostics", filter = {buf = 0}}), desc("toggle diagnostics (document)")}, {"<leader>tD", mk_toggle(3, "trouble", {mode = "diagnostics"}), desc("toggle diagnostics (workspace)")}}
  local V = {{"<Leader>T", cmd("Translate")}, {"<leader>r", cmd("FlowRunSelected")}}
  for _, K in ipairs(N) do
    vim.keymap.set("n", K[1], K[2], (K[3] or opts))
  end
  for _, K in ipairs(V) do
    vim.keymap.set("n", K[1], K[2], (K[3] or opts))
  end
end
local function _9_()
  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Leader>", true, false, true), "m", true)
end
return vim.schedule(_9_)
