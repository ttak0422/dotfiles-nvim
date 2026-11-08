{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
{
  doc = ''
    # telescope-sonictemplate.nvim

    ## 概要
    vim-sonictemplate のテンプレートを Telescope から選ぶための統合。

    ## 主な機能
    - Telescope picker でテンプレートを選択。

    ## 使い方
    extension の読込後、`:Telescope sonictemplate templates` または `require("telescope").extensions.sonictemplate.templates{}` を実行する。

    ## 要件
    telescope.nvim、vim-sonictemplate。最低バージョンは README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/tamago324/telescope-sonictemplate.nvim/blob/9edeeea022d9e35287fa80a91ed5bffb950cc096/README.md)
  '';
  plugin = sources.telescope-sonictemplate-nvim;
}
