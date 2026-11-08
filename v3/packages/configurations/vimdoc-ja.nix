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
  plugin = sources.vimdoc-ja;
  doc = ''
    # vimdoc-ja

    ## 概要
    Vim 付属ヘルプの日本語訳を配布するプロジェクト。

    ## 主な機能
    - 日本語ヘルプの配布と HTML 版の公開。

    ## 使い方
    README は詳しい導入・利用方法を上流 wiki に案内している。ブラウザーでは [日本語 HTML ヘルプ](https://vim-jp.org/vimdoc-ja/) を参照できる。

    ## 要件
    README に必要な Vim / Neovim バージョンや設定手順の明記なし。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/vim-jp/vimdoc-ja/blob/cd987f402218ccea794230ad067dad4b522017e9/README.md)
  '';
}
