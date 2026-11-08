{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
{
  plugin = sources.lspkind-nvim;
  doc = ''
    # lspkind.nvim

    ## 概要
    補完候補の種類を VS Code 風のアイコンで見分けやすくする。

    ## 主な機能
    - LSP・スニペット・パスなどの補完候補に記号を追加。
    - Nerd Fonts / Codicons のプリセットと独自記号。

    ## 使い方
    `require("lspkind").init()` で表示方法を設定する。nvim-cmp と連携する場合は `lspkind.cmp_format` を使う。

    ## 要件
    Neovim 0.7 以降。選択したプリセットに対応する Nerd Fonts または VS Code Codicons フォント。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/onsails/lspkind.nvim/blob/c7274c48137396526b59d86232eabcdc7fed8a32/README.md)
  '';
}
