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
    # Glance

    ## 概要
    現在の編集位置を離れずに LSP の参照先をプレビューする。

    ## 主な機能
    - 定義・型定義・参照・実装を一覧とプレビューで表示する。
    - プレビュー内の編集や quickfix への転送に対応する。

    ## 使い方
    `:Glance references`、`:Glance definitions`、`:Glance type_definitions`、`:Glance implementations` を使う。`:Glance resume` で前回の表示を再開する。

    ## 要件
    Neovim 0.9.0 以上と設定済み LSP クライアント。背景の文脈を維持する `preserve_win_context` は 0.10.0 以上。Trouble に開く連携は任意機能で、この設定では有効。

    ## 出典
    [固定バージョンの README](https://github.com/DNLHC/glance.nvim/blob/5a8eab1c1c48bfa19a33b556328a3c553138366e/README.md)
  '';

  plugin = sources.glance-nvim;
  lazy = true;
  onCommands = [ "Glance" ];
  onModules = [ "glance" ];
  dependPlugins = [
    definitions.trouble-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("glance").setup({
        border = { enable = true, top_char = "━", bottom_char = "━" },
        folds = { fold_closed = "▸", fold_open = "▾", folded = true },
        use_trouble_qf = true,
      })
    ''
  );
}
