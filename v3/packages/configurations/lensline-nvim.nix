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
  plugin = sources.lensline-nvim;
  doc = ''
    # lensline.nvim

    ## 概要
    関数の上や横に、参照数や作者などの文脈情報を表示する。

    ## 主な機能
    - 参照・定義・実装、Git 作者、診断などの provider。
    - 複数プロファイルと表示位置・対象範囲の切り替え。

    ## 使い方
    `require("lensline").setup()` で設定する。`:LenslineProfile` でプロファイルを切り替え、`:LenslineToggleView` で表示を、`:LenslineToggleEngine` で処理全体を切り替える。

    ## 要件
    README は Neovim 0.8 以降を掲示。LSP 使用情報は接続先サーバーの対応能力に依存する。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/oribarilan/lensline.nvim/blob/4fafcfaeedac2d20bd5902213393982c4218bc3a/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("lensline").setup({
        debounce_ms = 1000,
        focused_debounce_ms = 200,
        profiles = {
          {
            name = "default",
            style = { placement = "inline", prefix = "", render = "focused" },
          },
        },
      })
    ''
  );
}
