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
  doc = ''
    # RustOwl

    ## 概要
    Rust の所有権移動、借用、変数の生存期間を下線で可視化するツール。

    ## 主な機能
    - 生存期間・不変借用・可変借用・move・エラーを色分け。
    - Rust の保存時に解析し、対象上で待つと結果を表示。

    ## 使い方
    README は変数や関数呼出しにカーソルを合わせて待つ操作を案内する。この定義は自動表示を無効にし、接続後の `<LocalLeader>to` で表示を切り替える。

    ## 要件
    Neovim など VS Code 以外では RustOwl 本体の事前インストールが必要。README の Neovim 導入例は `cargo install rustowl`。最低 Neovim バージョンは未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/cordx56/rustowl/blob/61a893c0e1b8c25389b17593bcfedcfecc5d44fc/README.md)
  '';
  plugin = sources.rustowl.overrideAttrs {
    # WIP: use `cargo binstall rustowl`
    # runtimeDeps = with pkgs.v2; [ rustowl ];
  };
  config = luaConfig (
    # lua
    ''
      local rustowl = require("rustowl")
      rustowl.setup({
        auto_attach = true,
        auto_enable = false,
        idle_time = 1000,
        highlight_style = "underline",
        client = {
          on_attach = function(_, buffer)
            vim.keymap.set("n", "<LocalLeader>to", function()
              rustowl.toggle(buffer)
            end, { buffer = buffer, desc = "Toggle RustOwl" })
          end,
        },
      })
    ''
  );
}
