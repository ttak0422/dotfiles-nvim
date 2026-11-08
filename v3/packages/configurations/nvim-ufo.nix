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
    # nvim-ufo

    ## 概要
    折り畳みの見た目と操作を拡張し、LSP・Tree-sitter などから fold 範囲を取得する。

    ## 主な機能
    - fold provider の選択とフォールバック。
    - 折り畳み内部のプレビューと foldlevel を維持する開閉 API。

    ## 使い方
    `require("ufo").setup(...)` で設定する。この定義は Tree-sitter、indent の順に provider を使い、`zR` / `zM` を `openAllFolds` / `closeAllFolds` に割り当てる。`:UfoInspect` で状態を確認できる。

    ## 要件
    Neovim 0.7.2 以上、導入例では promise-async を使用。coc.nvim は任意。ufo provider を使う場合は大きい foldlevel が必要。

    ## 出典
    [固定リビジョンの README](https://github.com/kevinhwang91/nvim-ufo/blob/ab3eb124062422d276fae49e0dd63b3ad1062cfc/README.md)
  '';
  plugin = sources.nvim-ufo;
  dependPlugins = [
    definitions.promise-async
  ];
  config = luaConfig (
    # lua
    ''
      local ufo = require("ufo")
      ufo.setup({
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      })
      for _, mapping in ipairs({
        { "zR", ufo.openAllFolds, " open all folds" },
        { "zr", ufo.openFoldsExceptKinds, " open folds" },
        { "zM", ufo.closeAllFolds, " close all folds" },
        { "zm", ufo.closeAllFolds, " close all folds" },
      }) do
        vim.keymap.set("n", mapping[1], mapping[2], {
          noremap = true,
          silent = true,
          desc = mapping[3],
        })
      end
    ''
  );
}
