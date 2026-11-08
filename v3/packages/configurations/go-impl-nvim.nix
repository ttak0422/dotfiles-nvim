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
    # go-impl.nvim

    ## 概要
    Go の構造体にインターフェース実装を生成するプラグイン。

    ## 主な機能
    - Tree-sitter による receiver の検出。
    - 非同期のインターフェース選択とジェネリック型引数の入力。

    ## 使い方
    Go ファイルの構造体にカーソルを置き、`:GoImplOpen` または `require("go-impl").open()` を実行する。receiver とインターフェース、必要な型引数を選ぶ。この定義は snacks picker を指定する。

    ## 要件
    Neovim 0.12.0 以上、josharian/impl、nui.nvim。fuzzy finder は snacks.nvim / fzf-lua / telescope.nvim のいずれか。

    ## 出典
    [固定リビジョンの README](https://github.com/fang2hou/go-impl.nvim/blob/17465887f14f8a00f453cdc75bfb41a11c114cbf/README.md)
  '';
  plugin = sources.go-impl-nvim;
  dependPlugins = [
    definitions.nui-nvim
    definitions.snacks-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("go-impl").setup({
        picker = "snacks",
        icons = {
          interface = { text = " ", hl = "GoImplInterfaceIcon" },
          go = { text = " ", hl = "GoImplGoBlue" },
        },
        prompt = {
          receiver = "󰆼  ",
          interface = "  ",
          generic = "󰘻  {name} ",
        },
      })
    ''
  );
}
