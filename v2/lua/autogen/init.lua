-- [nfnl] v2/fnl/init.fnl
vim.loader.enable()
if ((vim.env.NVIM_AUTO_REMOTE == "1") and vim.env.NVIM and (#vim.fn.argv() > 0)) then
  local sent = false
  do
    local ok, chan = pcall(vim.fn.sockconnect, "pipe", vim.env.NVIM, {rpc = true})
    if (ok and (chan > 0)) then
      for _, f in ipairs(vim.fn.argv()) do
        local rok, _ = pcall(vim.rpcrequest, chan, "nvim_cmd", {cmd = "edit", args = {vim.fn.fnamemodify(f, ":p")}}, {})
        if rok then
          sent = true
        end
      end
      vim.fn.chanclose(chan)
    else
    end
  end
  if sent then
    vim.cmd("qa!")
    return
  end
else
end
if (vim.v.servername and (vim.v.servername ~= "")) then
  vim.env.NVIM_EDITOR_ADDR = vim.v.servername
else
end
if vim.g._editor_open_cmd then
  vim.env.EDITOR = vim.g._editor_open_cmd
else
end
if vim.g._editor_open_cmd_wait then
  vim.env.GIT_EDITOR = vim.g._editor_open_cmd_wait
else
end
vim.cmd("language messages en_US.UTF-8")
pcall(dofile, vim.fn.expand("$HOME/config.lua"))
for opt, kvp in pairs({opt = {langmenu = "none", timeoutlen = 1000, shortmess = (vim.o.shortmess .. "sWcS"), cmdheight = 0, signcolumn = "yes", laststatus = 0, showtabline = 0, splitkeep = "screen", foldcolumn = "1", foldlevel = 99, foldlevelstart = 99, foldenable = true, switchbuf = "", splitbelow = true, splitright = true, winborder = "single", number = false, showmode = false, wrap = false}, g = {mapleader = " ", maplocalleader = ",", loaded_netrw = 1, loaded_netrwPlugin = 1, no_plugin_maps = true}}) do
  for k, v in pairs(kvp) do
    vim[opt][k] = v
  end
end
do
  local S = require("snacks")
  local opts = {noremap = true, silent = true}
  local desc
  local function _6_(d)
    return {noremap = true, silent = true, desc = d}
  end
  desc = _6_
  local lua_
  local function _7_(mod, f, opt)
    local function _8_()
      if (opt == nil) then
        return require(mod)[f]()
      else
        return require(mod)[f](opt)
      end
    end
    return _8_
  end
  lua_ = _7_
  local toggle
  local function _10_(id)
    local function _11_()
      return require("toggler").toggle(id)
    end
    return _11_
  end
  toggle = _10_
  local function _12_()
    if (vim.bo.buftype == "") then
      return require("lir.float").toggle()
    else
      return vim.notify("Not a file buffer", "warn")
    end
  end
  local function _14_()
    return vim.cmd(("Telescope mr mru cwd=" .. vim.fn.fnameescape(vim.fn.getcwd())))
  end
  local function _15_()
    return vim.cmd(("Telescope mr mrr cwd=" .. vim.fn.fnameescape(vim.fn.getcwd())))
  end
  local function _16_()
    return vim.cmd(("Telescope mr mrw cwd=" .. vim.fn.fnameescape(vim.fn.getcwd())))
  end
  for m, ks in pairs({n = {{"j", "gj"}, {"k", "gk"}, {"\194\165", "\\"}, {"<esc><esc>", "<Cmd>nohl<CR>"}, {"*", "<Plug>(asterisk-z*)", {silent = true}}, {"#", "<Plug>(asterisk-z#)", {silent = true}}, {"g*", "<Plug>(asterisk-gz*)", {silent = true}}, {"g#", "<Plug>(asterisk-gz#)", {silent = true}}, {"<C-Space>", "<Cmd>OpenMenu<CR>"}, {"<Leader>q", S.bufdelete.delete, desc("close buffer")}, {"<Leader>Q", S.bufdelete.all, desc("close all buffers")}, {"<Leader>A", "<Cmd>tabclose<CR>"}, {"<Leader>tq", toggle("qf"), desc("\239\136\132 quickfix")}, {"<Leader>tb", _12_, desc("\239\136\132 explorer")}, {"<Leader>tB", lua_("oil", "open"), desc("\239\136\132 explorer")}, {"<Leader>td", toggle("trouble-doc"), desc("\239\136\132 diagnostics (doc)")}, {"<Leader>tD", toggle("trouble-ws"), desc("\239\136\132 diagnostics (ws)")}, {"<Leader>tR", lua_("spectre", "toggle"), desc("\239\136\132 replace")}, {"<Leader>H", toggle("harpoon"), desc("\243\176\162\183 show items")}, {"<Leader>ha", "<Cmd>lua require('harpoon'):list():add()<CR>", desc("\243\176\162\183 register item")}, {"<Leader>ff", "<Cmd>Telescope live_grep_args<CR>", desc("\238\169\173 livegrep")}, {"<Leader>fp", "<Cmd>Telescope find_files find_command=rg,--files,--hidden,-g,!.git<CR>", desc("\238\169\173 files")}, {"<Leader>Ff", "<Cmd>Telescope live_grep_args cwd=~/ghq<CR>", desc("\238\169\173 livegrep (ghq)")}, {"<Leader>Fp", "<Cmd>Telescope find_files cwd=~/ghq<CR>", desc("\238\169\173 files (ghq)")}, {"<Leader>fP", "<Cmd>Telescope ghq<CR>", desc("\238\169\173 project files")}, {"<Leader>fb", "<Cmd>TelescopeBuffer<CR>", desc("\238\169\173 buffer")}, {"<Leader>fB", "<Cmd>TelescopeBufferName<CR>", desc("\238\169\173 buffer")}, {"<Leader>ft", "<Cmd>Telescope sonictemplate templates<CR>", desc("\238\169\173 template")}, {"<Leader>fru", _14_, desc("\238\169\173 MRU")}, {"<Leader>frr", _15_, desc("\238\169\173 MRR")}, {"<Leader>frw", _16_, desc("\238\169\173 MRW")}, {"<Leader>Fru", "<Cmd>Telescope mr mru<CR>", desc("\238\169\173 MRU")}, {"<Leader>Frr", "<Cmd>Telescope mr mrr<CR>", desc("\238\169\173 MRR")}, {"<Leader>Frw", "<Cmd>Telescope mr mrw<CR>", desc("\238\169\173 MRW")}, {"<Leader>fn", "<Cmd>NeorgFuzzySearch<CR>", desc("\238\152\179 fuzzy search")}, {"<Leader>fN", "<Cmd>NeorgFindFile<CR>", desc("\238\152\179 find file")}, {"<Leader>G", "<Cmd>Gitu<CR>", desc("\239\135\147 client")}, {"<Leader>go", "<Cmd>TracePR<CR>", desc("\239\135\147 open PR")}, {"<Leader>N", "<Cmd>Neorg<CR>", desc("\238\152\179 enter")}, {"<Leader>ny", "<Cmd>Neorg journal yesterday<CR>", desc("\238\152\179 yesterday")}, {"<Leader>nt", "<Cmd>Neorg journal today<CR>", desc("\238\152\179 today")}, {"<Leader>nT", "<Cmd>Neorg journal tomorrow<CR>", desc("\238\152\179 tomorrow")}, {"<Leader>nn", "<Cmd>NeorgScratch<CR>", desc("\238\152\179 scratch")}, {"<Leader>ngg", "<Cmd>NeorgGit<CR>", desc("\238\152\179 Git")}, {"<Leader>ngb", "<Cmd>NeorgGitBranch<CR>", desc("\238\152\179 Git (branch)")}, {"<Leader>aa", "<Cmd>AvanteAsk<CR>"}, {"<Leader>at", "<Cmd>AvanteToggle<CR>"}, {"<Leader>ot", "<Cmd>Obsidian today<CR>", desc("\239\137\137 journal today")}, {"<Leader>oy", "<Cmd>Obsidian yesterday<CR>", desc("\239\137\137 journal yesterday")}, {"<Leader>oo", "<Cmd>ObsidianScratch<CR>", desc("\239\137\137 new note")}, {"<Leader>ogg", "<Cmd>ObsidianGit<CR>", desc("\239\137\137 Git")}, {"<Leader>ogb", "<Cmd>ObsidianGitBranch<CR>", desc("\239\137\137 Git branch")}, {"<Leader>on", "<Cmd>Obsidian new<CR>", desc("\239\137\137 new note")}, {"<Leader>fo", "<Cmd>Obsidian search<CR>", desc("\239\137\137 fuzzy search")}}, i = {{"\194\165", "\\"}}, c = {{"\194\165", "\\"}}, t = {{"\194\165", "\\"}, {"<S-Space>", "<Space>"}}, v = {{"\194\165", "\\"}, {"<C-t>", "<Cmd>OpenMenu<CR>"}}}) do
    for _, k in ipairs(ks) do
      vim.keymap.set(m, k[1], k[2], (k[3] or opts))
    end
  end
  for i = 0, 9 do
    vim.keymap.set({"n", "t", "i"}, ("<C-" .. i .. ">"), toggle(("term" .. i)), opts)
  end
end
vim.cmd("colorscheme morimo")
return require("config-local").setup({silent = true})