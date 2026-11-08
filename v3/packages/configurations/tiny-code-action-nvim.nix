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
    # tiny-code-action.nvim

    ## 概要
    LSP のコードアクションを差分表示し、選択・実行する。

    ## 主な機能
    - 複数の picker と差分表示バックエンドから選択できる。
    - アクション名の表示や選択操作をカスタマイズできる。

    ## 使い方
    `require("tiny-code-action").code_action()` をノーマル・ビジュアルモードのキーに割り当てる。この定義は delta バックエンドと Telescope picker を使用する。

    ## 要件
    言語サーバーのコードアクションを利用する。delta バックエンドには delta が必要。Telescope、Snacks、fzf-lua は選択した picker に応じた任意依存。既定アイコンには Nerd Fonts を使うか、signs を変更する。

    ## 出典
    [固定バージョンの README](https://github.com/rachartier/tiny-code-action.nvim/blob/91a9c32228e9a7761d241023d9ebb9d11d8fb10d/README.md)
  '';

  plugin = sources.tiny-code-action-nvim.overrideAttrs {
    runtimeDeps = with pkgs; [ delta ];
  };
  dependPlugins = [ definitions.telescope-nvim ];
  config = luaConfig (
    # lua
    ''
      require("tiny-code-action").setup({
        backend = "delta",
        picker = { "telescope", opts = { winborder = "single" } },
      })
    ''
  );
}
