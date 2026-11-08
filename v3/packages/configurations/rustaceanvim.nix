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
    # rustaceanvim

    ## 概要
    rust-analyzer 固有機能を Neovim から利用する Rust 開発支援。

    ## 主な機能
    - Rust 用 LSP を自動設定し、コードアクションやホバー操作を拡張する。
    - 実行対象の選択や、任意のデバッグ連携を提供する。

    ## 使い方
    Rust ファイルを開くと初期化され、`setup()` は不要。`:RustLsp codeAction`、`:RustLsp hover actions`、`:RustLsp runnables` を使う。rust-analyzer の LSP を別途重複設定しない。

    ## 要件
    Neovim 0.12 以上と rust-analyzer。Cargo プロジェクトには cargo、デバッグにはアダプターと nvim-dap、クレートグラフには Graphviz の dot が必要。

    ## 出典
    [固定バージョンの README](https://github.com/mrcjkb/rustaceanvim/blob/v9.2.1/README.md)
  '';

  plugin = pkgs.vimPlugins.rustaceanvim.overrideAttrs {
    runtimeDeps = with pkgs; [
      rust-analyzer-unwrapped
    ];
  };
  config = luaConfig (
    # lua
    ''
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              files = {
                excludeDirs = { ".direnv", ".git", ".venv", "bin", "node_modules", "target" },
              },
            },
          },
        },
      }
    ''
  );
}
