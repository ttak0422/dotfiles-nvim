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
    # nfnl

    ## 概要
    Fennel を保存時に Lua へコンパイルし、Neovim 設定やプラグインを開発するためのツール。

    ## 主な機能
    - `.nfnl.fnl` のあるプロジェクトで自動起動。
    - コンパイルエラーの通知と既存 Lua の上書き保護。

    ## 使い方
    プロジェクトのルートに `.nfnl.fnl` を置き、Fennel ファイルを保存する。最初に設定ファイルを信頼するか確認される。`:NfnlFile` は対応する生成済み Lua を実行する。

    ## 要件
    Neovim 0.9.0 以上。Fennel バッファの ftplugin で起動し、手動 require や遅延読込設定は不要。

    ## 出典
    [固定リビジョンの README](https://github.com/Olical/nfnl/blob/7a4ba217167fee57e9bf175405636ced49aa9f83/README.md)
  '';
  plugin = sources.nfnl;
  dependPlugins = [
    definitions.conjure
  ];
  extraPackages = with pkgs; [
    sd
    fd
  ];
}
