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
  local cmd
  local function _3_(c)
    return ("<cmd>" .. c .. "<cr>")
  end
  cmd = _3_
  local git
  local function _4_()
    vim.cmd("enew")
    local bufnr = vim.api.nvim_get_current_buf()
    local on_exit
    local function _5_()
      local function _6_()
        if vim.api.nvim_buf_is_valid(bufnr) then
          return vim.api.nvim_buf_delete(bufnr, {force = true})
        else
          return nil
        end
      end
      return _6_
    end
    on_exit = _5_
    vim.fn.termopen("gitu", {on_exit = on_exit})
    vim.cmd("startinsert")
    vim.bo[bufnr]["bufhidden"] = "wipe"
    vim.bo[bufnr]["swapfile"] = false
    vim.bo[bufnr]["buflisted"] = false
    local function _8_()
      return vim.api.nvim_feedkeys("i", "n", false)
    end
    return vim.api.nvim_create_autocmd("TermClose", {buffer = bufnr, once = true, callback = _8_})
  end
  git = _4_
  local toggle
  local function _9_(id)
    local function _10_()
      return require("toggler").toggle(id)
    end
    return _10_
  end
  toggle = _9_
  for m, ks in pairs({n = {{"\194\165", "\\"}, {";", ":"}, {"tq", toggle("qf"), desc("\239\136\132 quickfix")}, {"tb", cmd("lua require('lir.float').toggle()"), desc("\239\136\132 explorer")}, {"tB", cmd("lua require('oil').open()"), desc("\239\136\132 explorer")}, {"<Leader>G", git, desc("\239\135\147 client")}}, i = {{"\194\165", "\\"}}, c = {{"\194\165", "\\"}}, t = {{"\194\165", "\\"}, {"<S-Space>", "<Space>"}}, v = {{"\194\165", "\\"}, {";", ":"}}}) do
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
