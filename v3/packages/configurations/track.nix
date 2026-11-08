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
    # track

    ## 概要
    Go 製 CLI / LSP エンジン、SQLite 索引、Neovim フロントエンドを組み合わせた journal / Zettelkasten ノートツール。

    ## 主な機能
    - ノートの解析・索引・リンク解決を共通エンジンで処理。
    - CLI、LSP ナビゲーション、ローカル Web workspace を提供。

    ## 使い方
    `:Track markdown` は保存済みの現在の Markdown を外部の読取専用ビューアーで開く。ノートとしての取込は行わず、保存して再実行すると更新される。本文だけでなく `.track/` のメタデータもバックアップ対象にする。

    ## 要件
    README の Nix 対応環境は x86_64 / aarch64 Linux と Apple silicon macOS。Nix 版プラグインは対応する track / track-lsp のパスを組み込む。最低 Neovim バージョンは未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/ttak0422/track/blob/8a7ed55ee32d4ff7f9dbfb4620e60fea81bdb0fc/README.md)
  '';
  lazy = true;
  onCommands = [ "Track" ];
  onModules = [ "track" ];
  plugin = sources.track;
  dependPlugins = [
    definitions.plenary-nvim
  ];
  extraPackages = with pkgs; [ track-cli ];
  config = luaConfig (
    # lua
    ''
      require("track").setup({ vault_dir = os.getenv("HOME") .. "/track/" })
    ''
  );
}
