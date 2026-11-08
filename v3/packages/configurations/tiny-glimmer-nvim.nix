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
    # tiny-glimmer.nvim

    ## 概要
    ヤンク・貼り付けなどの編集操作に、短いハイライトアニメーションを付けるプラグイン。

    ## 主な機能
    - fade、bounce、pulse、rainbow などの描画スタイル。
    - 操作別の有効化と独自アニメーション API。

    ## 使い方
    `require("tiny-glimmer").setup(...)` で操作ごとに設定する。`:TinyGlimmer enable` / `disable` や `:TinyGlimmer fade` で切り替える。この定義は検索演出を無効にし、ヤンク・貼付・undo / redo を有効にしている。

    ## 要件
    Neovim 0.10 以上。README は beta 段階で破壊的変更があり得ると記載する。

    ## 出典
    [固定リビジョンの README](https://github.com/rachartier/tiny-glimmer.nvim/blob/b35d4f7b0eaedb75ff99fa694f4d1ea2ce8ce6c8/README.md)
  '';
  plugin = sources.tiny-glimmer-nvim;
  config = luaConfig (
    # lua
    ''
      require("tiny-glimmer").setup({
        enabled = true,
        overwrite = {
          search = { enabled = false },
          paste = { enabled = true },
          yank = { enabled = true },
          undo = { enabled = true },
          redo = { enabled = true },
        },
      })
    ''
  );
}
