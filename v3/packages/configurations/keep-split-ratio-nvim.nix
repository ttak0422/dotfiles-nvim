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
    # keep-split-ratio.nvim

    ## 概要
    端末やエディターのサイズ変更時に縦分割の幅の比率を維持する。

    ## 主な機能
    - `VimResized` 時にタブごとの分割比率を復元する。
    - `winfixwidth` のウィンドウは幅を維持する。

    ## 使い方
    プラグインの設定後は UI のサイズ変更に追従する。README の導入例は lazy.nvim の `opts = {}`。`:set winfixwidth` を設定した分割は固定幅として扱う。

    ## 要件
    README に最低バージョンや追加の依存要件の記載はない。

    ## 出典
    [固定バージョンの README](https://github.com/adlrwbr/keep-split-ratio.nvim/blob/906aa5196e194dca12c7729069760d42e77ddcff/README.md)
  '';

  plugin = sources.keep-split-ratio-nvim;
  config = luaConfig (
    # lua
    ''
      require("keep-split-ratio").setup()
    ''
  );
}
