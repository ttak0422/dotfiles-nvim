{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
with sources;
{
  config = luaConfig (
    # lua
    ''
      vim.cmd([=[
        cabbrev <expr> r getcmdtype() .. getcmdline() ==# ":r" ? [getchar(), ""][1] .. "%s//g<Left><Left>" : (getcmdline() ==# "'<,'>r" ? [getchar(), ""][1] .. "s//g<Left><Left>" : "r")
      ]=])
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.hlsearch = true
      vim.opt.incsearch = true
      vim.keymap.set("n", "<Leader>/", function()
        vim.cmd("vimgrep //gj %")
      end, { noremap = true, silent = true, desc = "register search results to qf" })
      vim.keymap.set("n", "<Leader>?", function()
        vim.cmd("vimgrepadd //gj %")
      end, { noremap = true, silent = true, desc = "add search results to qf" })
    ''
  );
}
