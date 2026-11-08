{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
{
  plugin = sources.budoux-lua;
  doc = ''
    # budoux.lua

    ## 概要
    BudouX の機械学習モデルで自然な改行位置を求める Lua ライブラリ。

    ## 主な機能
    - 日本語・簡体字中国語・繁体字中国語・タイ語のモデル。
    - 独自モデルによる Parser の生成。

    ## 使い方
    `require("budoux").load_default_japanese_parser()` でパーサーを作り、`parser:parse(text)` でフレーズ配列を取得する。

    ## 要件
    純粋な Lua 実装で外部依存なし。README の CI 対象は Lua 5.1〜5.4 と LuaJIT。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/delphinus/budoux.lua/blob/7f23658b127b9a74aae5b388fefcd997be30cbfc/README.ja.md)
  '';
}
