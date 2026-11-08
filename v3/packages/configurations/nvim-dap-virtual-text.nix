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
  plugin = sources.nvim-dap-virtual-text;
  doc = ''
    # nvim-dap-virtual-text

    ## 概要
    nvim-dap の変数値をソースコード上の仮想テキストで表示する。

    ## 主な機能
    - 変更・新規変数の強調と例外停止理由の表示。
    - 変数の表示位置・整形方法の調整。

    ## 使い方
    `require("nvim-dap-virtual-text").setup()` で有効化する。コマンドを有効にした場合は `:DapVirtualTextToggle` で表示を切り替えられる。

    ## 要件
    nvim-dap、対象言語の Tree-sitter パーサーと `locals.scm` クエリー。Neovim 0.9 以降では nvim-treesitter 自体は必須ではなく、インライン表示は 0.10 以降。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/theHamsta/nvim-dap-virtual-text/blob/fbdb48c2ed45f4a8293d0d483f7730d24467ccb6/README.md)
  '';
  dependPlugins = [
    definitions.nvim-dap
    definitions.nvim-treesitter
  ];
  config = luaConfig ''
    require("nvim-dap-virtual-text").setup({
      virt_text_pos = "inline",
      display_callback = function(variable)
        return " = " .. variable.value:gsub("%s+", " ")
      end,
    })
  '';
}
