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
  plugin = sources.spring-boot-nvim;
  doc = ''
    # Spring Boot Nvim

    ## 概要
    VSCode Spring Boot 拡張の機能を Neovim の LSP に取り込む。

    ## 主な機能
    - Bean・Web endpoint の検索。
    - application.properties / application.yml の補完・移動とコードアクション。

    ## 使い方
    `:SpringBoot` で検索対象を選び、`:SpringBoot Beans` で Bean を直接検索する。`:checkhealth spring_boot` でサーバーや Java の検出状態を確認できる。

    ## 要件
    Neovim 0.12 以降、Java 実行環境と Spring Boot language server の jar。Java 連携には nvim-jdtls などを使用し、fzf-lua / Telescope の picker は任意。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/JavaHello/spring-boot.nvim/blob/9880be48170a21d97444b1eba75853fd3bad33c3/README_en.md)
  '';
  dependPlugins = [
    definitions.nvim-jdtls
  ];
}
