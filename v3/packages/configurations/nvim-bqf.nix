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
  plugin = sources.nvim-bqf;
  doc = ''
    # nvim-bqf

    ## 概要
    Neovim の quickfix ウィンドウにプレビューと絞り込みを加える。

    ## 主な機能
    - バッファ内容のプレビューと強調表示。
    - サインでの項目選別と任意の fzf フィルター。

    ## 使い方
    通常どおり `:copen` で quickfix を開く。上流既定操作では `<Tab>` で項目を選別し、`zn`・`zN` でリストを作り直す。`:BqfToggle` で機能を切り替える。

    ## 要件
    Neovim 0.6.1 以降。fzf 0.42.0 以降と nvim-treesitter は任意。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/kevinhwang91/nvim-bqf/blob/c282a62bec6c0621a1ef5132aa3f4c9fc4dcc2c7/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("bqf").setup({
        func_map = {
          open = "<CR>",
          openc = "o",
          drop = "O",
          split = "<C-s>",
          vsplit = "<C-v>",
          tab = "<C-t>",
          tabb = "",
          tabc = "",
          tabdrop = "",
          ptogglemode = "zp",
          ptoggleitem = "p",
          ptoggleauto = "P",
          pscrollup = "<C-b>",
          pscrolldown = "<C-f>",
          pscrollorig = "zo",
          prevfile = "",
          nextfile = "",
          prevhist = "",
          nexthist = "",
          lastleave = [['"]],
          stoggleup = "<S-Tab>",
          stoggledown = "<Tab>",
          stogglevm = "<Tab>",
          stogglebuf = "'<Tab>",
          sclear = "z<Tab>",
          filter = "zn",
          filterr = "zN",
          fzffilter = "",
        },
      })
    ''
  );
}
