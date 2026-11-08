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
  plugin = sources.videre-nvim;
  doc = ''
    # videre.nvim

    ## 概要
    JSON などの構造化データを、ターミナル上のグラフとして探索する。

    ## 主な機能
    - ノードの折りたたみ、リンク先への移動、表示ルートの変更。
    - スタイル調整とパーサー追加による形式拡張。

    ## 使い方
    JSON ファイルで `:Videre` を実行してグラフを開く。`require("videre").setup()` で罫線などの表示を調整する。

    ## 要件
    最低 Neovim バージョンは README に未記載。YAML・TOML・XML の対応パーサーは任意の追加プラグインで、XML は実験的対応。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/Owen-Dechow/videre.nvim/blob/5e7b39bb17d7381b06bcaae589c2d53854ae5c93/README.md)
  '';
  dependPlugins = [
    definitions.graph_view_yaml_parser
    definitions.graph_view_toml_parser
  ];
  config = luaConfig (
    # lua
    ''
      require("videre").setup({ editor_type = "floating", box_style = "sharp" })
    ''
  );
}
