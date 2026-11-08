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
  plugin = sources.tabout-nvim;
  doc = ''
    # tabout.nvim

    ## 概要
    挿入時に括弧・引用符などの内側から外側へカーソルを移動する。

    ## 主な機能
    - 前方・後方への tab-out。
    - 対象の囲み、除外 filetype、通常の Tab へのフォールバック設定。

    ## 使い方
    `require("tabout").setup()` で設定する。上流既定例では `<Tab>`・`<S-Tab>` で囲みの外へ移動し、`:TaboutToggle` で有効状態を切り替える。

    ## 要件
    Neovim 0.5 以降と、使用する各言語の Tree-sitter パーサー。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/abecodes/tabout.nvim/blob/9a3499480a8e53dcaa665e2836f287e3b7764009/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("tabout").setup({
        tabkey = "<Tab>",
        backwards_tabkey = "<S-Tab>",
        default_tab = "<C-t>",
        default_shift_tab = "<C-d>",
        enable_backwards = true,
        act_as_shift_tab = false,
        act_as_tab = false,
        completion = false,
        ignore_beginning = false,
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = "`", close = "`" },
          { open = "(", close = ")" },
          { open = "[", close = "]" },
          { open = "{", close = "}" },
          { open = "<", close = ">" },
        },
      })
    ''
  );
}
