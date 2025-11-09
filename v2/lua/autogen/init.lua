-- [nfnl] v2/fnl/init.fnl
vim.loader.enable()
vim.cmd("language messages en_US.UTF-8")
pcall(dofile, vim.fn.expand("$HOME/config.lua"))
for opt, kvp in pairs({opt = {langmenu = "none", timeoutlen = 1000, shortmess = (vim.o.shortmess .. "sWcS"), cmdheight = 0, signcolumn = "yes", showtabline = 0, laststatus = 0, splitkeep = "screen", foldcolumn = "1", foldlevel = 99, foldlevelstart = 99, foldenable = true, switchbuf = "", splitbelow = true, splitright = true, number = false, showmode = false, wrap = false}, env = {EDITOR = "nvr -cc b# --remote", GIT_EDITOR = "nvr -cc b# --remote-wait"}, g = {mapleader = " ", maplocalleader = ",", loaded_netrw = 1, loaded_netrwPlugin = 1}}) do
  for k, v in pairs(kvp) do
    vim[opt][k] = v
  end
end
do
  local S = require("snacks")
  local opts = {noremap = true, silent = true}
  local desc
  local function _1_(d)
    return {noremap = true, silent = true, desc = d}
  end
  desc = _1_
  local lua_
  local function _2_(mod, f, opt)
    local function _3_()
      if (opt == nil) then
        return require(mod)[f]()
      else
        return require(mod)[f](opt)
      end
    end
    return _3_
  end
  lua_ = _2_
  local toggle
  local function _5_(id)
    local function _6_()
      return require("toggler").toggle(id)
    end
    return _6_
  end
  toggle = _5_
  local function _7_()
    if (vim.bo.buftype == "") then
      return require("lir.float").toggle()
    else
      return vim.notify("Not a file buffer", "warn")
    end
  end
  local function _9_()
    return vim.cmd(("Telescope mr mru cwd=" .. vim.fn.fnameescape(vim.fn.getcwd())))
  end
  local function _10_()
    return vim.cmd(("Telescope mr mrr cwd=" .. vim.fn.fnameescape(vim.fn.getcwd())))
  end
  local function _11_()
    return vim.cmd(("Telescope mr mrw cwd=" .. vim.fn.fnameescape(vim.fn.getcwd())))
  end
  for m, ks in pairs({n = {{"j", "gj"}, {"k", "gk"}, {"\194\165", "\\"}, {"<esc><esc>", "<Cmd>nohl<CR>"}, {"<C-Space>", "<Cmd>OpenMenu<CR>"}, {"<Leader>q", S.bufdelete.delete, desc("close buffer")}, {"<Leader>Q", S.bufdelete.all, desc("close all buffers")}, {"<Leader>A", "<Cmd>tabclose<CR>"}, {"<Leader>tq", toggle("qf"), desc("\239\136\132 quickfix")}, {"<Leader>tb", _7_, desc("\239\136\132 explorer")}, {"<Leader>tB", lua_("oil", "open"), desc("\239\136\132 explorer")}, {"<Leader>td", toggle("trouble-doc"), desc("\239\136\132 diagnostics (doc)")}, {"<Leader>tD", toggle("trouble-ws"), desc("\239\136\132 diagnostics (ws)")}, {"<Leader>tR", lua_("spectre", "toggle"), desc("\239\136\132 replace")}, {"<Leader>H", toggle("harpoon"), desc("\243\176\162\183 show items")}, {"<Leader>ha", "<Cmd>lua require('harpoon'):list():add()<CR>", desc("\243\176\162\183 register item")}, {"<Leader>ff", "<Cmd>Telescope live_grep_args<CR>", desc("\238\169\173 livegrep")}, {"<Leader>fp", lua_("fff", "find_files"), desc("\238\169\173 files")}, {"<Leader>Ff", "<Cmd>Telescope live_grep_args cwd=~/ghq<CR>", desc("\238\169\173 livegrep (ghq)")}, {"<Leader>Fp", lua_("fff", "find_files_in_dir", "~/ghq"), desc("\238\169\173 files (ghq)")}, {"<Leader>fP", "<Cmd>Telescope ghq<CR>", desc("\238\169\173 project files")}, {"<Leader>fb", "<Cmd>TelescopeBuffer<CR>", desc("\238\169\173 buffer")}, {"<Leader>fB", "<Cmd>TelescopeBufferName<CR>", desc("\238\169\173 buffer")}, {"<Leader>ft", "<Cmd>Telescope sonictemplate templates<CR>", desc("\238\169\173 template")}, {"<Leader>fru", _9_, desc("\238\169\173 MRU")}, {"<Leader>frr", _10_, desc("\238\169\173 MRR")}, {"<Leader>frw", _11_, desc("\238\169\173 MRW")}, {"<Leader>Fru", "<Cmd>Telescope mr mru<CR>", desc("\238\169\173 MRU")}, {"<Leader>Frr", "<Cmd>Telescope mr mrr<CR>", desc("\238\169\173 MRR")}, {"<Leader>Frw", "<Cmd>Telescope mr mrw<CR>", desc("\238\169\173 MRW")}, {"<Leader>fn", "<Cmd>NeorgFuzzySearch<CR>", desc("\238\152\179 fuzzy search")}, {"<Leader>fN", "<Cmd>NeorgFindFile<CR>", desc("\238\152\179 find file")}, {"<Leader>G", "<Cmd>Gitu<CR>", desc("\239\135\147 client")}, {"<Leader>go", "<Cmd>TracePR<CR>", desc("\239\135\147 open PR")}, {"<Leader>N", "<Cmd>Neorg<CR>", desc("\238\152\179 enter")}, {"<Leader>ny", "<Cmd>Neorg journal yesterday<CR>", desc("\238\152\179 yesterday")}, {"<Leader>nt", "<Cmd>Neorg journal today<CR>", desc("\238\152\179 today")}, {"<Leader>nT", "<Cmd>Neorg journal tomorrow<CR>", desc("\238\152\179 tomorrow")}, {"<Leader>nn", "<Cmd>NeorgScratch<CR>", desc("\238\152\179 scratch")}, {"<Leader>ngg", "<Cmd>NeorgGit<CR>", desc("\238\152\179 Git")}, {"<Leader>ngb", "<Cmd>NeorgGitBranch<CR>", desc("\238\152\179 Git (branch)")}, {"<Leader>ot", "<Cmd>Obsidian today<CR>", desc("\239\137\137 journal today")}, {"<Leader>oy", "<Cmd>Obsidian yesterday<CR>", desc("\239\137\137 journal yesterday")}, {"<Leader>oo", "<Cmd>ObsidianScratch<CR>", desc("\239\137\137 new note")}, {"<Leader>ogg", "<Cmd>ObsidianGit<CR>", desc("\239\137\137 Git")}, {"<Leader>ogb", "<Cmd>ObsidianGitBranch<CR>", desc("\239\137\137 Git branch")}, {"<Leader>on", "<Cmd>Obsidian new<CR>", desc("\239\137\137 new note")}, {"<Leader>fo", "<Cmd>Obsidian search<CR>", desc("\239\137\137 fuzzy search")}}, i = {{"\194\165", "\\"}}, c = {{"\194\165", "\\"}}, t = {{"\194\165", "\\"}, {"<S-Space>", "<Space>"}}, v = {{"\194\165", "\\"}, {"<C-t>", "<Cmd>OpenMenu<CR>"}}}) do
    for _, k in ipairs(ks) do
      vim.keymap.set(m, k[1], k[2], (k[3] or opts))
    end
  end
  for i = 0, 9 do
    vim.keymap.set({"n", "t", "i"}, ("<C-" .. i .. ">"), toggle(("term" .. i)), opts)
  end
end
vim.cmd("colorscheme sorairo")
return require("config-local").setup({silent = true})
