-- [nfnl] v2/fnl/treesitter.fnl
require("nvim-treesitter").setup({install_dir = args.install_dir})
do
  local M = require("nvim-treesitter-textobjects")
  M.setup({select = {lookahead = true}, move = {set_jumps = true}})
end
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "&filetype ==# 'markdown' || &filetype ==# 'markdown_inline' ? 0 : v:lua.vim.treesitter.foldexpr()"
local function _1_(event)
  if ((event.match == "markdown") or (event.match == "markdown_inline")) then
    vim.treesitter.stop(event.buf)
    vim.bo.indentexpr = ""
    local function _2_()
      if (vim.api.nvim_buf_is_valid(event.buf) and ((vim.bo[event.buf].ft == "markdown") or (vim.bo[event.buf].ft == "markdown_inline")) and (vim.fn.exists("#context_commentstring_ft") == 1)) then
        return vim.api.nvim_clear_autocmds({group = "context_commentstring_ft", event = "CursorHold", buffer = event.buf})
      else
        return nil
      end
    end
    return vim.schedule(_2_)
  else
    pcall(vim.treesitter.start)
    if (vim.bo.indentexpr == "") then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      return nil
    else
      return nil
    end
  end
end
vim.api.nvim_create_autocmd("FileType", {callback = _1_})
vim.g.matchup_matchparen_offscreen = {method = "popup"}
vim.g.matchup_treesitter_stopline = 500
vim.g.matchup_treesitter_disabled = {"markdown", "markdown_inline"}
return nil
