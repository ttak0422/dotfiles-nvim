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
  plugin = sources.marks-nvim;
  doc = ''
    # marks.nvim

    ## 概要
    Vim のマークを可視化し、登録・削除・移動を補助する。

    ## 主な機能
    - サイン列への表示とフロートによるプレビュー。
    - マークや注釈付きブックマークを location / quickfix リストへ出力。

    ## 使い方
    `require("marks").setup()` で設定する。`:MarksListBuf` で現在バッファのマークを一覧化し、`:MarksToggleSigns` でサイン表示を切り替える。

    ## 要件
    Neovim 0.5 以降。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/chentoast/marks.nvim/blob/f353e8c08c50f39e99a9ed474172df7eddd89b72/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("marks").setup({
        default_mappings = true,
        refresh_interval = 500,
        sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
      })
    ''
  );
}
