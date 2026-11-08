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
  plugin = sources.replua-nvim;
  doc = ''
    # replua.nvim

    ## 概要
    Neovim 内で Lua を試し、結果をコメントとして確認する scratch バッファ。

    ## 主な機能
    - 現在行・周辺ブロック・バッファ全体の評価。
    - 戻り値と print 出力の追記、バッファごとの評価環境。

    ## 使い方
    `:RepluaOpen` で開き、`:RepluaEval` でバッファ全体を評価する。`:RepluaOpen!` は新しい環境を作成し、`:RepluaReset` は現在の評価環境をリセットする。

    ## 要件
    README に最低 Neovim バージョンや必須外部依存の明記なし。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/mghaight/replua.nvim/blob/8ed56f58aaec2d22e61907c46fbbc2a1d15b2ffd/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("replua").setup({
        keymaps = {
          eval_line = "<LocalLeader>rl",
          eval_block = "<LocalLeader>rr",
          eval_buffer = "<LocalLeader>rA",
        },
      })
    ''
  );
}
