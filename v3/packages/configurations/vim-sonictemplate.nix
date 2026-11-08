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
    # sonictemplate

    ## 概要
    コードのテンプレートを補完・挿入する。

    ## 主な機能
    - ファイルタイプ別のテンプレート補完を提供する。
    - 後置補完を提供する。

    ## 使い方
    `:Template <Tab>` で候補を選ぶ。README の Perl 例では `:Template package` または `:Template script` を実行すると、内容を挿入して入力箇所へカーソルを移す。

    ## 要件
    README に最低バージョンや追加の依存要件の記載はない。

    ## 出典
    [固定バージョンの README](https://github.com/mattn/vim-sonictemplate/blob/050450414ca69885df7c26936821d74678ff4904/README.md)
  '';

  plugin = sources.vim-sonictemplate;
  preConfig = luaConfig (
    let
      template = pkgs.stdenv.mkDerivation {
        pname = "sonictemplate";
        version = "custom";
        src = ../support/sonic;
        installPhase = ''
          mkdir $out
          cp -r ./* $out
        '';
      };
    in
    # lua
    ''
      vim.g.sonictemplate_vim_template_dir = "${template}"
      vim.g.sonictemplate_key = 0
      vim.g.sonictemplate_intelligent_key = 0
      vim.g.sonictemplate_postfix_key = 0
    ''
  );
}
