-- [nfnl] v2/fnl/init.fnl
vim.loader.enable()
vim.cmd("language messages en_US.UTF-8")
for opt, kvp in pairs({opt = {langmenu = "none", timeoutlen = 1000, shortmess = (vim.o.shortmess .. "sWcS"), cmdheight = 0, number = true, signcolumn = "yes", showtabline = 0, laststatus = 0, foldcolumn = "1", splitkeep = "screen", showmode = false}, env = {VISUAL = "nvr --remote-wait-silent", EDITOR = "nvr --remote-wait-silent", GIT_EDITOR = "nvr --remote-wait-silent"}, g = {mapleader = " ", maplocalleader = ",", loaded_netrw = 1, loaded_netrwPlugin = 1}}) do
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
  local git
  local function _5_()
    if (#vim.api.nvim_list_wins() == 1) then
      local w = vim.api.nvim_win_get_width(0)
      local h = (vim.api.nvim_win_get_height(0) * 2.1)
      if (h > w) then
        vim.cmd.split()
      else
        vim.cmd.vsplit()
      end
    else
    end
    vim.cmd.enew()
    local bufnr = vim.api.nvim_get_current_buf()
    local on_exit
    local function _8_()
      if (#vim.api.nvim_list_wins() ~= 1) then
        local buf = vim.fn.bufnr("#")
        if ((buf ~= -1) and vim.api.nvim_buf_is_valid(buf)) then
          return vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
        else
          return nil
        end
      else
        if vim.api.nvim_buf_is_valid(bufnr) then
          return vim.api.nvim_buf_delete(bufnr, {force = true})
        else
          return nil
        end
      end
    end
    on_exit = _8_
    vim.fn.termopen("gitu", {on_exit = on_exit})
    vim.cmd.startinsert()
    vim.bo[bufnr]["bufhidden"] = "wipe"
    vim.bo[bufnr]["swapfile"] = false
    vim.bo[bufnr]["buflisted"] = false
    vim.api.nvim_create_autocmd("BufLeave", {buffer = bufnr, once = true, callback = on_exit})
    local function _12_()
    end
    return vim.api.nvim_create_autocmd("TermClose", {buffer = bufnr, once = true, callback = _12_})
  end
  git = _5_
  local toggle
  local function _13_(id)
    local function _14_()
      return require("toggler").toggle(id)
    end
    return _14_
  end
  toggle = _13_
  for m, ks in pairs({n = {{"\194\165", "\\"}, {"<esc><esc>", "<Cmd>nohl<CR>"}, {"<Leader>q", "<Cmd>BufDel<CR>", desc("close buffer")}, {"<Leader>Q", "<Cmd>BufDelAll<CR>", desc("close all buffers")}, {"<Leader>A", "<Cmd>tabclose<CR>"}, {"<Leader>tq", toggle("qf"), desc("\239\136\132 quickfix")}, {"<Leader>tb", lua_("lir.float", "toggle"), desc("\239\136\132 explorer")}, {"<Leader>tB", lua_("oil", "open"), desc("\239\136\132 explorer")}, {"<Leader>td", toggle("trouble-doc"), desc("\239\136\132 diagnostics (doc)")}, {"<Leader>tD", toggle("trouble-ws"), desc("\239\136\132 diagnostics (ws)")}, {"<Leader>H", toggle("harpoon"), desc("\243\176\162\183 show items")}, {"<Leader>ha", "<Cmd>lua require('harpoon'):list():add()<CR>", desc("\243\176\162\183 register item")}, {"<Leader>ff", "<Cmd>Telescope live_grep_args<CR>", desc("\238\169\173 livegrep")}, {"<Leader>fF", "<Cmd>Telescope ast_grep<CR>", desc("\238\169\173 AST")}, {"<Leader>fp", "<Cmd>Telescope find_files hidden=true<CR>", desc("\238\169\173 files")}, {"<Leader>fP", "<Cmd>Telescope projects<CR>", desc("\238\169\173 project files")}, {"<Leader>fb", "<Cmd>TelescopeBuffer<CR>", desc("\238\169\173 buffer")}, {"<Leader>ft", "<Cmd>Telescope sonictemplate templates<CR>", desc("\238\169\173 template")}, {"<Leader>G", git, desc("\239\135\147 client")}, {"<Leader>gb", toggle("blame"), desc("\239\135\147 blame")}, {"<Leader>go", "<Cmd>TracePR<CR>", desc("\239\135\147 open PR")}}, i = {{"\194\165", "\\"}}, c = {{"\194\165", "\\"}}, t = {{"\194\165", "\\"}, {"<S-Space>", "<Space>"}}, v = {{"\194\165", "\\"}}}) do
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
