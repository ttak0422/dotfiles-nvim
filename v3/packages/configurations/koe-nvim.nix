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
    # koe.nvim

    ## 概要
    macOS の SpeechAnalyzer / SpeechTranscriber を使い、日本語音声を端末内で文字起こしするプラグイン。

    ## 主な機能
    - 認識途中の結果をインライン表示し、確定結果を行として挿入。
    - Insert / Terminal モードで動作し、モードを離れると停止。

    ## 使い方
    `require("koe").setup({ locale = "ja-JP" })` で設定する。この定義では Insert / Terminal モードの `<M-t>` が `koe.toggle` を呼ぶ。`:checkhealth koe` で環境を確認できる。自動では録音を開始しない。

    ## 要件
    Apple silicon の macOS 26 以上、Neovim 0.10 以上、Neovim を実行するアプリのマイク権限。Neovide は音声入力 entitlement の修正を含む版が必要。

    ## 出典
    [固定リビジョンの README](https://github.com/ttak0422/koe.nvim/blob/c4f466418361c08ac727c46271bbde2474df7e7e/README.md)
  '';
  plugin = sources.koe-nvim;
  config = luaConfig (
    # lua
    ''
      local koe = require("koe")
      koe.setup({ locale = "ja-JP" })
      vim.keymap.set({ "i", "t" }, "<M-t>", koe.toggle, {
        silent = true,
        desc = "koe: dictation toggle",
      })
    ''
  );
}
