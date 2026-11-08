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
    # colorizer.lua

    ## 概要
    色コードや色名を実際の色で強調表示する Neovim プラグイン。

    ## 主な機能
    - 16 進数の色コードや色名を認識。
    - CSS の色関数や表示方式を任意で設定。

    ## 使い方
    `require("colorizer").setup()` は全 filetype に自動適用する。`:ColorizerAttachToBuffer` / `:ColorizerDetachFromBuffer` で現在バッファへの適用を操作する。

    ## 要件
    Neovim 0.4.0 以上、`termguicolors` の有効化。README は外部依存なし、システムに malloc / free が必要と記載する。

    ## 出典
    [固定リビジョンの README](https://github.com/norcalli/nvim-colorizer.lua/blob/a065833f35a3a7cc3ef137ac88b5381da2ba302e/README.md)
  '';
  plugin = sources.nvim-colorizer-lua;
  lazy = true;
  # Keep all exported commands available before the first load.
  onCommands = [
    "ColorizerToggle"
    "ColorizerAttachToBuffer"
    "ColorizerDetachFromBuffer"
    "ColorizerReloadAllBuffers"
  ];
  onModules = [ "colorizer" ];
  config = luaConfig (
    # lua
    ''
      require("colorizer").setup()
    ''
  );
}
