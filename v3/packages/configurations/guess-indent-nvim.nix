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
    # guess-indent.nvim

    ## 概要
    バッファの内容からインデント方式を推定し、ローカルオプションへ反映する。

    ## 主な機能
    - タブかスペースかとインデント幅を推定。
    - filetype / buftype の除外と EditorConfig 優先設定。

    ## 使い方
    `require("guess-indent").setup(...)` で有効化する。既定ではバッファを開くと自動実行され、`:GuessIndent` で手動実行できる。

    ## 要件
    最低バージョン・追加依存は README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/NMAC427/guess-indent.nvim/blob/84a4987ff36798c2fc1169cbaff67960aed9776f/README.md)
  '';
  plugin = sources.guess-indent-nvim;
  config = luaConfig (
    # lua
    ''
      require("guess-indent").setup({
        auto_cmd = true,
        filetype_exclude = { "netrw", "tutor" },
        buftype_exclude = { "help", "nofile", "terminal", "prompt" },
        on_tab_options = { expandtab = false },
        on_space_options = {
          expandtab = true,
          tabstop = "detected",
          softtabstop = "detected",
          shiftwidth = "detected",
        },
        override_editorconfig = false,
      })
    ''
  );
}
