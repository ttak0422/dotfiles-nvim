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
  plugin = sources.better-escape-nvim;
  doc = ''
    # better-escape.nvim

    ## 概要
    連続キーによるモード切り替えで、最初の文字の入力待ちを避ける。

    ## 主な機能
    - 複数モードのキー列と Lua 関数に対応。
    - 判定時間と既定マッピングを設定可能。

    ## 使い方
    `require("better_escape").setup()` で `mappings` と `timeout` を設定する。上流の既定例では挿入モードの `jk`・`jj` で Escape を送る。

    ## 要件
    README に Neovim の最低バージョンや必須外部依存の明記なし。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/max397574/better-escape.nvim/blob/3f4bc0b326606264ff75967f59091b5ddada0554/readme.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("better_escape").setup({
        default_mappings = false,
        mappings = {
          i = { j = { k = "<Esc>" } },
          c = {},
          t = { j = { k = "<C-\\><C-n>" } },
          v = {},
          s = {},
        },
      })
    ''
  );
}
