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
  plugin = sources.trouble-nvim;
  doc = ''
    # Trouble

    ## 概要
    診断、LSP の参照、quickfix などを見やすいリストやツリーで表示する。

    ## 主な機能
    - 診断・シンボル・呼び出し関係などの複数表示モード。
    - フィルター・並べ替え・表示ウィンドウの調整。

    ## 使い方
    `:Trouble diagnostics toggle` で診断一覧を開閉する。`:Trouble symbols toggle` でシンボル一覧を表示し、`filter.buf=0` などのオプションで対象を絞る。

    ## 要件
    Neovim 0.9.2 以降。0.10 未満では markdown / markdown_inline パーサーが必要。README は LSP 設定、診断ハイライト対応テーマ、既定アイコン用フォントを要求し、nvim-web-devicons は任意。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/folke/trouble.nvim/blob/bd67efe408d4816e25e8491cc5ad4088e708a69a/README.md)
  '';
  dependPlugins = [
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("trouble").setup({
        auto_close = false,
        auto_open = false,
        auto_preview = false,
        auto_refresh = true,
        auto_jump = false,
        focus = false,
        restore = true,
        follow = true,
        indent_guides = true,
        max_items = 200,
        multiline = true,
        pinned = false,
        warn_no_results = false,
        open_no_results = true,
        win = {},
        preview = { type = "main", scratch = true },
        throttle = {
          refresh = 20,
          update = 10,
          render = 10,
          follow = 100,
          preview = { ms = 100, debounce = true },
        },
        modes = {
          lsp_references = { params = { include_declaration = true } },
          lsp_base = { params = { include_current = false } },
          symbols = {
            desc = "document symbols",
            mode = "lsp_document_symbols",
            focus = false,
            win = { position = "right" },
            filter = {
              ["not"] = { ft = "lua", kind = "Package" },
              any = {
                ft = { "help", "markdown" },
                kind = {
                  "Class", "Constructor", "Enum", "Field", "Function", "Interface", "Method",
                  "Module", "Namespace", "Package", "Property", "Struct", "Trait",
                },
              },
            },
          },
        },
        icons = {
          indent = {
            top = "│ ",
            middle = "├╴",
            last = "└╴",
            fold_open = " ",
            fold_closed = " ",
            ws = "  ",
          },
          folder_closed = " ",
          folder_open = " ",
          kinds = {
            Array = " ",
            Boolean = "󰨙 ",
            Class = " ",
            Constant = "󰏿 ",
            Constructor = " ",
            Enum = " ",
            EnumMember = " ",
            Event = " ",
            Field = " ",
            File = " ",
            Function = "󰊕 ",
            Interface = " ",
            Key = " ",
            Method = "󰊕 ",
            Module = " ",
            Namespace = "󰦮 ",
            Null = " ",
            Number = "󰎠 ",
            Object = " ",
            Operator = " ",
            Package = " ",
            Property = " ",
            String = " ",
            Struct = "󰆼 ",
            TypeParameter = " ",
            Variable = "󰀫 ",
          },
        },
      })
    ''
  );
}
