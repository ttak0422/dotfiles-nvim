{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
{
  plugin = sources.telescope-live-grep-args-nvim;
  doc = ''
    # Telescope live grep args

    ## 概要
    Telescope の live grep に検索コマンドの引数を入力できる拡張。

    ## 主な機能
    - 検索語とディレクトリ・glob・型指定などの同時入力。
    - クォート補助や自動クォートの調整。

    ## 使い方
    `require("telescope").load_extension("live_grep_args")` 後、`require("telescope").extensions.live_grep_args.live_grep_args()` を呼ぶ。入力例は `"foo" --iglob **/test/**`。

    ## 要件
    telescope.nvim と使用する grep コマンド。README の検索例は ripgrep を使用し、最低バージョンは未記載。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/nvim-telescope/telescope-live-grep-args.nvim/blob/53e9df55b3651dd7cf77e172f1e8c9a17407acca/README.md)
  '';
}
