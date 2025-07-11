-- [nfnl] v2/fnl/init.fnl
vim.loader.enable()
vim.cmd("language messages en_US.UTF-8")
pcall(dofile, vim.fn.expand("$HOME/config.lua"))
for opt, kvp in pairs({opt = {langmenu = "none", timeoutlen = 1000, shortmess = (vim.o.shortmess .. "sWcS"), cmdheight = 0, number = true, signcolumn = "yes", showtabline = 0, laststatus = 0, splitkeep = "screen", foldcolumn = "1", foldlevel = 99, foldlevelstart = 99, foldenable = true, showmode = false, wrap = false}, env = {VISUAL = "nvr --remote-wait-silent", EDITOR = "nvr --remote-wait-silent", GIT_EDITOR = "nvr --remote-wait-silent"}, g = {mapleader = " ", maplocalleader = ",", loaded_netrw = 1, loaded_netrwPlugin = 1}}) do
  for k, v in pairs(kvp) do
    vim[opt][k] = v
  end
end
do
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
  for m, ks in pairs({n = {{"\194\165", "\\"}, {"<esc><esc>", "<Cmd>nohl<CR>"}, {"<C-t>", "<Cmd>OpenMenu<CR>"}, {"<Leader>q", "<Cmd>BufDel<CR>", desc("close buffer")}, {"<Leader>Q", "<Cmd>BufDelAll<CR>", desc("close all buffers")}, {"<Leader>A", "<Cmd>tabclose<CR>"}, {"<Leader>tq", toggle("qf"), desc("\239\136\132 quickfix")}, {"<Leader>tb", lua_("lir.float", "toggle"), desc("\239\136\132 explorer")}, {"<Leader>tB", lua_("oil", "open"), desc("\239\136\132 explorer")}, {"<Leader>td", toggle("trouble-doc"), desc("\239\136\132 diagnostics (doc)")}, {"<Leader>tD", toggle("trouble-ws"), desc("\239\136\132 diagnostics (ws)")}, {"<Leader>tR", lua_("spectre", "toggle"), desc("\239\136\132 replace")}, {"<Leader>H", toggle("harpoon"), desc("\243\176\162\183 show items")}, {"<Leader>ha", "<Cmd>lua require('harpoon'):list():add()<CR>", desc("\243\176\162\183 register item")}, {"<Leader>ff", "<Cmd>Telescope live_grep_args<CR>", desc("\238\169\173 livegrep")}, {"<Leader>fp", "<Cmd>Telescope find_files<CR>", desc("\238\169\173 files")}, {"<Leader>fP", "<Cmd>Telescope projects<CR>", desc("\238\169\173 project files")}, {"<Leader>fb", "<Cmd>TelescopeBuffer<CR>", desc("\238\169\173 buffer")}, {"<Leader>ft", "<Cmd>Telescope sonictemplate templates<CR>", desc("\238\169\173 template")}, {"<Leader>fn", "<Cmd>NeorgFuzzySearch<CR>", desc("\238\152\179 fuzzy search")}, {"<Leader>fN", "<Cmd>NeorgFindFile<CR>", desc("\238\152\179 find file")}, {"<Leader>G", "<Cmd>Gitu<CR>", desc("\239\135\147 client")}, {"<Leader>gb", toggle("blame"), desc("\239\135\147 blame")}, {"<Leader>go", "<Cmd>TracePR<CR>", desc("\239\135\147 open PR")}, {"<Leader>N", "<Cmd>Neorg<CR>", desc("\238\152\179 enter")}, {"<Leader>ny", "<Cmd>Neorg journal yesterday<CR>", desc("\238\152\179 yesterday")}, {"<Leader>nt", "<Cmd>Neorg journal today<CR>", desc("\238\152\179 today")}, {"<Leader>nT", "<Cmd>Neorg journal tomorrow<CR>", desc("\238\152\179 tomorrow")}, {"<Leader>nn", "<Cmd>NeorgScratch<CR>", desc("\238\152\179 scratch")}, {"<Leader>ngg", "<Cmd>NeorgGit<CR>", desc("\238\152\179 Git")}, {"<Leader>ngb", "<Cmd>NeorgGitBranch<CR>", desc("\238\152\179 Git (branch)")}}, i = {{"\194\165", "\\"}}, c = {{"\194\165", "\\"}}, t = {{"\194\165", "\\"}, {"<S-Space>", "<Space>"}}, v = {{"\194\165", "\\"}, {"<C-t>", "<Cmd>OpenMenu<CR>"}}}) do
    for _, k in ipairs(ks) do
      vim.keymap.set(m, k[1], k[2], (k[3] or opts))
    end
  end
  for i = 0, 9 do
    vim.keymap.set({"n", "t", "i"}, ("<C-" .. i .. ">"), toggle(("term" .. i)), opts)
  end
end
vim.cmd("colorscheme morimo")
for _, p in ipairs({"nvim-notify", "treesitter", "gitsigns", "lir", "dap", "git-conflict", "lir"}) do
  require("morimo").load(p)
end
return require("config-local").setup({silent = true})
