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
  plugin = emptyPlugin "filetypePlugins";
  dependPlugins = [
    {
      plugin = ts-error-translator-nvim;
      config = luaConfig (
        # lua
        ''
          local translator = require("ts-error-translator")
          return translator.setup({auto_attach = true, servers = {"astro", "svelte", "ts_ls", "typescript-tools", "volar", "vtsls"}})
        ''
      );
    }
    {
      plugin = sfcc-nvim;
      config = luaConfig (''
        vim.api.nvim_create_autocmd('FileType', {
          pattern = 'javascript',
          callback = function(event)
            vim.keymap.set('n', 'gf', function() require('sfcc').gf() end,
              { buffer = event.buf, desc = 'SFCC cartridge gf' })
          end,
        })
      '');
    }
    {
      plugin = uv-nvim;
      config = luaConfig (
        # lua
        ''
          return require("uv").setup({keymaps = false})
        ''
      );
      extraPackages = with pkgs; [ uv ];
    }
    {
      plugin = kotlin-nvim;
      config = luaConfig ({
        code = # lua
          ''
            vim.env.KOTLIN_LSP_DIR = args.kotlin_lsp_dir
            local kotlin = require("kotlin")
            local opts = {inlay_hints = {enabled = true}, java_files = false}
            kotlin.setup(opts)
            if (vim.bo.filetype == "kotlin") then
              return kotlin.setup_kotlin_lsp(opts)
            else
              return nil
            end
          '';
        args.kotlin_lsp_dir = "${pkgs.v2.kotlin-lsp}/libexec/kotlin-lsp";
      });
    }
    {
      plugin = csvview-nvim;
      config = luaConfig (
        # lua
        ''
          local M = require("csvview")
          local keymaps = {textobject_field_inner = {"if", mode = {o = "x"}}, textobject_field_outer = {"af", mode = {o = "x"}}, jump_next_field_end = {"<Tab>", mode = {n = "v"}}, jump_prev_field_end = {"<S-Tab>", mode = {n = "v"}}, jump_next_row = {"<Enter>", mode = {n = "v"}}, jump_prev_row = {"<S-Enter>", mode = {n = "v"}}}
          return M.setup({keymaps = keymaps, view = {display_mode = "border"}})
        ''
      );
    }
    {
      plugin = nvim-ts-autotag;
      config = luaConfig (
        # lua
        ''
          local autotag = require("nvim-ts-autotag")
          local filetypes = {"javascript", "typescript", "jsx", "tsx", "vue", "html"}
          return autotag.setup({filetypes = filetypes})
        ''
      );
    }
    {
      plugin = pkgs.vimPlugins.markdown-preview-nvim;
    }
    {
      plugin = crates-nvim;
      config = luaConfig (
        # lua
        ''
          local crates = require("crates")
          local lsp = {enabled = true, actions = true, hover = true, completion = false}
          return crates.setup({lsp = lsp})
        ''
      );
    }
    {
      plugin = emptyPlugin "filetypePlugins-8";
      dependPlugins = [
        vim-nix
      ];
    }
    {
      plugin = nfnl;
      dependPlugins = [
        conjure
      ];
      extraPackages = with pkgs; [
        sd
        fd
      ];
    }
    {
      plugin = nginx-vim.overrideAttrs (_: {
        src = pkgs.nix-filter {
          root = nginx-vim.src;
          exclude = [ "ftdetect/nginx.vim" ];
        };
      });
    }
  ];
  doc = "Enabled v2/default filetypePlugins configuration, loaded at startup. See the migration inventory in the core cartridge documentation.";
}
