{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  emptyPlugin,
  inputs',
}:
with sources;
with definitions;
{
  plugin = emptyPlugin "preBufferPlugins";
  dependPlugins = [
    {
      plugin = git-conflict-nvim;
      config = luaConfig (
        # lua
        ''
          local git_conflict = require("git-conflict")
          return git_conflict.setup()
        ''
      );
    }
    {
      plugin = diffview-nvim;
      config = luaConfig (
        # lua
        ''
          local diffview = require("diffview")
          return diffview.setup({icons = {folder_closed = "\238\151\191", folder_open = "\238\151\190"}, signs = {fold_closed = "\226\150\184", fold_open = "\226\150\190", done = "\226\156\147"}})
        ''
      );
    }
  ];
  preConfig = luaConfig (
    # lua
    ''
      for k, v in pairs({expandtab = true, tabstop = 2, shiftwidth = 2, showmatch = true, ph = 20, virtualedit = "block"}) do
        vim.o[k] = v
      end
      vim.opt.fillchars:append({eob = " ", fold = " ", foldopen = "\226\150\190", foldsep = " ", foldclose = "\226\150\184", foldinner = " ", stl = "\226\148\128", stlnc = "\226\148\128"})
      return vim.opt.nrformats:append("unsigned")
    ''
  );
  doc = "Enabled v2/default preBufferPlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
