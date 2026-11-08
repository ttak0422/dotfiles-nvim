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
  plugin = sources.kotlin-nvim;
  config = luaConfig ({
    code = # lua
      ''
        vim.env.KOTLIN_LSP_DIR = args.kotlin_lsp_dir
        local kotlin = require("kotlin")
        local options = {
          inlay_hints = { enabled = true },
          java_files = false,
        }
        kotlin.setup(options)
        if vim.bo.filetype == "kotlin" then
          kotlin.setup_kotlin_lsp(options)
        end
      '';
    args.kotlin_lsp_dir = "${pkgs.v2.kotlin-lsp}/libexec/kotlin-lsp";
  });
}
