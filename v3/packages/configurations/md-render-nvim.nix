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
    # md-render.nvim

    ## 概要
    Markdown を編集バッファとは別の表示領域で整形する、Neovim 内蔵型プレビューア。

    ## 主な機能
    - 表・callout・折り畳み・クリック可能なリンクを表示。
    - 日本語の禁則処理と任意の BudouX 分かち書き。
    - 対応環境では画像・動画・図を表示。

    ## 使い方
    `:MdRender` はフローティング表示、`:MdRender tab` はタブ表示、`:MdRender split` はソースとプレビューの並列表示。`:MdRender pager` はページャーモード。

    ## 要件
    Neovim 0.12 以上。画像・動画には Kitty graphics protocol 対応端末が必要。FFmpeg、Mermaid CLI、PlantUML、各言語パーサーなどは機能別の任意依存で、導入だけでは全機能の利用は保証されない。

    ## 出典
    [固定リビジョンの README](https://github.com/delphinus/md-render.nvim/blob/4f6d73a276356bc23dbffa594d2a54dc978e98bb/README.md)
  '';
  plugin = sources.md-render-nvim;
  dependPlugins = [
    definitions.nvim-web-devicons
    definitions.budoux-lua
  ];
}
