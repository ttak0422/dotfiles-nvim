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
  plugin = sources.fyler-nvim;
  lazy = true;
  onCommands = [ "Fyler" ];
  onModules = [ "fyler" ];
  doc = ''
    # Fyler.nvim

    ## 概要
    バッファ編集のようにファイルシステムを操作する、ツリー表示付きファイルマネージャー。

    ## 主な機能
    - ファイルツリー表示とバッファ形式の編集。
    - ルートディレクトリやウィンドウ形式の指定。

    ## 使い方
    `:Fyler` または `require("fyler").open()` で開く。`:Fyler root_path=<path>` で対象ディレクトリを指定できる。

    ## 要件
    Neovim 0.11 以降。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/A7Lavinraj/fyler.nvim/blob/70e1202434a21b45649dd59ec82dc3330f79125e/README.md)
  '';
  dependPlugins = [
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("fyler").setup({
        close_on_select = true,
        icon_provider = "nvim_web_devicons",
        win = {
          border = "single",
          kind = "replace",
          buf_opts = {},
          win_opts = { number = false, relativenumber = false },
        },
      })
    ''
  );
}
