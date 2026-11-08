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
  preConfig = luaConfig (
    # lua
    ''
      vim.o.expandtab = true
      vim.o.tabstop = 2
      vim.o.shiftwidth = 2
      vim.o.showmatch = true
      vim.o.ph = 20
      vim.o.virtualedit = "block"
      vim.opt.fillchars:append({
        eob = " ",
        fold = " ",
        foldopen = "▾",
        foldsep = " ",
        foldclose = "▸",
        foldinner = " ",
        stl = "─",
        stlnc = "─",
      })
      vim.opt.nrformats:append("unsigned")
    ''
  );
}
