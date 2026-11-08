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
    # Markdown Preview for (Neo)vim

    ## 概要
    Markdown をブラウザーでプレビューし、編集やスクロールを同期するプラグイン。

    ## 主な機能
    - 非同期の表示更新とスクロール同期。
    - 数式、Mermaid、図表、目次、ローカル画像などの表示。

    ## 使い方
    Markdown バッファで `:MarkdownPreview` を実行し、`:MarkdownPreviewStop` で停止する。ブラウザーや自動開始などは `g:mkdp_*` のオプションで調整できる。

    ## 要件
    Vim 8.1 以上または Neovim、プレビュー用のブラウザー。README は Node.js / Yarn による導入方法と、それらを使わない事前ビルド版を案内する。

    ## 出典
    [固定リビジョンの README](https://github.com/iamcco/markdown-preview.nvim/blob/a923f5fc5ba36a3b17e289dc35dc17f66d0548ee/README.md)
  '';
  plugin = pkgs.vimPlugins.markdown-preview-nvim;
}
