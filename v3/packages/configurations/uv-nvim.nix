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
    # uv.nvim

    ## 概要
    Python パッケージ管理ツール uv を Neovim から利用する統合。

    ## 主な機能
    - ファイル・選択範囲・関数単位の Python 実行。
    - パッケージ管理と仮想環境の自動有効化。

    ## 使い方
    `:UVRunFile` / `:UVRunSelection` / `:UVRunFunction` で実行する。`:UVAutoActivateToggle` は仮想環境の自動有効化を切り替える。この定義は既定キーマッピングを無効にしている。

    ## 要件
    Neovim 0.7.0 以上、インストール済み uv。picker 統合を使う場合は Snacks.nvim や Telescope.nvim などの対応 UI が必要。

    ## 出典
    [固定リビジョンの README](https://github.com/benomahony/uv.nvim/blob/b0bce1b61584fde99c316aa0587a4996c52df206/README.md)
  '';
  # setup probes Telescope immediately; retain v2's Python entry point so the
  # optional picker does not defeat Telescope's command/module lazy loading.
  lazy = true;
  onFiletypes = [ "python" ];
  onModules = [ "uv" ];
  plugin = sources.uv-nvim;
  config = luaConfig (
    # lua
    ''
      require("uv").setup({ keymaps = false })
    ''
  );
  extraPackages = with pkgs; [ uv ];
}
