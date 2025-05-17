-- [nfnl] Compiled from v2/fnl/init.fnl by https://github.com/Olical/nfnl, do not edit.
vim.loader.enable()
vim.cmd("language messages en_US.UTF-8")
for opt, kvp in pairs({opt = {langmenu = "none", shortmess = (vim.o.shortmess .. "sWcS"), cmdheight = 0, number = true, signcolumn = "yes", showtabline = 0, laststatus = 0, foldcolumn = "1", splitkeep = "screen", showmode = false}, env = {VISUAL = "nvr --remote-silent", EDITOR = "nvr --remote-silent", GIT_EDITOR = "nvr --remote-silent"}, g = {mapleader = " ", maplocalleader = ",", loaded_netrw = 1, loaded_netrwPlugin = 1}}) do
  for k, v in pairs(kvp) do
    vim[opt][k] = v
  end
end
local function _1_()
  vim.opt_local.formatoptions:remove("r")
  return vim.opt_local.formatoptions:remove("o")
end
vim.api.nvim_create_autocmd("FileType", {pattern = "*", callback = _1_})
do
  local opts = {noremap = true, silent = true}
  local desc
  local function _2_(d)
    return {noremap = true, silent = true, desc = d}
  end
  desc = _2_
  local lua_
  local function _3_(mod, f, opt)
    local function _4_()
      if (opt == nil) then
        return require(mod)[f]()
      else
        return require(mod)[f](opt)
      end
    end
    return _4_
  end
  lua_ = _3_
  local git
  local function _6_()
    vim.cmd("enew")
    local bufnr = vim.api.nvim_get_current_buf()
    local on_exit
    local function _7_()
      local function _8_()
        if vim.api.nvim_buf_is_valid(bufnr) then
          return vim.api.nvim_buf_delete(bufnr, {force = true})
        else
          return nil
        end
      end
      return _8_
    end
    on_exit = _7_
    vim.fn.termopen("gitu", {on_exit = on_exit})
    vim.cmd("startinsert")
    vim.bo[bufnr]["bufhidden"] = "wipe"
    vim.bo[bufnr]["swapfile"] = false
    vim.bo[bufnr]["buflisted"] = false
    vim.api.nvim_create_autocmd("BufLeave", {buffer = bufnr, once = true, callback = on_exit})
    local function _10_()
      return vim.api.nvim_feedkeys("i", "n", false)
    end
    return vim.api.nvim_create_autocmd("TermClose", {buffer = bufnr, once = true, callback = _10_})
  end
  git = _6_
  local toggle
  local function _11_(id)
    local function _12_()
      return require("toggler").toggle(id)
    end
    return _12_
  end
  toggle = _11_
  for m, ks in pairs({n = {{"\194\165", "\\"}, {";", ":"}, {"j", "gj"}, {"k", "gk"}, {"<esc><esc>", "<Cmd>nohl<CR>"}, {"<Leader>q", "<Cmd>BufDel<CR>", desc("close buffer")}, {"<Leader>Q", "<Cmd>BufDelAll<CR>", desc("close all buffers")}, {"<Leader>A", "<Cmd>tabclose<CR>"}, {"<Leader>tq", toggle("qf"), desc("\239\136\132 quickfix")}, {"<Leader>tb", lua_("lir.float", "toggle"), desc("\239\136\132 explorer")}, {"<Leader>tB", lua_("oil", "open"), desc("\239\136\132 explorer")}, {"<Leader>H", toggle("harpoon"), desc("\243\176\162\183 show items")}, {"<Leader>ha", "<Cmd>lua require('harpoon'):list():add()<CR>", desc("\243\176\162\183 register item")}, {"<Leader>ff", "<Cmd>Telescope live_grep_args<CR>", desc("\238\169\173 livegrep")}, {"<Leader>fF", "<Cmd>Telescope ast_grep<CR>", desc("\238\169\173 AST")}, {"<Leader>fb", "<Cmd>TelescopeBuffer<CR>", desc("\238\169\173 buffer")}, {"<Leader>ft", "<Cmd>Telescope sonictemplate templates<CR>", desc("\238\169\173 template")}, {"<Leader>G", git, desc("\239\135\147 client")}, {"<Leader>gb", toggle("blame"), desc("\239\135\147 blame")}, {"<Leader>go", "<Cmd>TracePR<CR>", desc("\239\135\147 open PR")}}, i = {{"\194\165", "\\"}}, c = {{"\194\165", "\\"}}, t = {{"\194\165", "\\"}, {"<S-Space>", "<Space>"}}, v = {{"\194\165", "\\"}, {";", ":"}}}) do
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
