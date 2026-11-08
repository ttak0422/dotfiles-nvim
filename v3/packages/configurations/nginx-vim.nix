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
  plugin = sources.nginx-vim.overrideAttrs (_: {
    src = pkgs.nix-filter {
      root = sources.nginx-vim.src;
      exclude = [ "ftdetect/nginx.vim" ];
    };
  });
  doc = ''
    # nginx.vim

    ## 概要
    Nginx 設定ファイル向けの Vim 構文ハイライトを拡張する。

    ## 主な機能
    - IPv4 / IPv6、各種ディレクティブ、埋め込み ERB・Jinja・Lua の強調。
    - 安全でない `ssl_protocols` の値をエラーとして強調。

    ## 使い方
    プラグインとして読み込み、Nginx 設定の構文強調に使う。専用コマンドや API は README に未記載。

    ## 要件
    最低実行バージョンは README に未記載。Vim の標準パッケージ機構を利用する導入例は Vim 8 以降を対象とする。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/chr4/nginx.vim/blob/3f1ce6c24ba3b5bde979cfac2c017612d7bfd311/README.md)
  '';
}
