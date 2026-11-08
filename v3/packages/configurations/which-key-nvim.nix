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
  plugin = sources.which-key-nvim;
  doc = ''
    # Which Key

    ## 概要
    キー入力に続くマッピング候補をポップアップで表示する。

    ## 主な機能
    - 複数モードのマッピング説明と表示レイアウト。
    - マーク・レジスター・操作一覧、継続表示する Hydra mode。

    ## 使い方
    プレフィックス入力後の候補を選ぶ。ポップアップでは `<Esc>` で閉じ、`<BS>` で一段戻る。`require("which-key").show({ global = false })` でバッファローカルの割り当てを表示できる。

    ## 要件
    Neovim 0.9.4 以降。アイコン用の mini.icons・nvim-web-devicons・Nerd Font は任意。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/folke/which-key.nvim/blob/3aab2147e74890957785941f0c1ad87d0a44c15a/README.md)
  '';
  dependPlugins = [
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("which-key").setup({
        preset = "helix",
        delay = function(context)
          return context.plugin and 50 or 200
        end,
        icons = { mappins = true, rules = false },
      })
    ''
  );
}
