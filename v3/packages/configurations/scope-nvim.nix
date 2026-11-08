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
  plugin = sources.scope-nvim;
  doc = ''
    # Scope.nvim

    ## 概要
    バッファ一覧をタブごとに分け、タブ内の作業対象を保つ。

    ## 主な機能
    - `:bnext`・`:bprev` などでタブ内のバッファを移動。
    - タブ間のバッファ移動と任意のセッション・Telescope 連携。

    ## 使い方
    `require("scope").setup()` で有効化する。`:ScopeMoveBuf <tab_nr>` で現在のバッファを指定タブへ移す。最後の一つの場合はレイアウト維持のためコピーになる。

    ## 要件
    README に最低 Neovim バージョンや必須外部依存の明記なし。Telescope・セッションマネージャー連携は任意。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/tiagovla/scope.nvim/blob/d9ff1926b54c41ae2acf0bdb68119df8c6c4d676/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("scope").setup()
    ''
  );
}
