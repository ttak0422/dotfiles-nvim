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
    # open.nvim

    ## 概要
    カーソル下の単語などを、文字列に応じた opener で開くプラグイン。

    ## 主な機能
    - GitHub の owner/repository 形式などを解釈。
    - 独自 opener とフォールバックを登録可能。

    ## 使い方
    `require("open").open_cword()` でカーソル下の単語を開く。README は `gx` への割当例を示すが既定マッピングはない。`register_opener(...)` で処理を追加できる。

    ## 要件
    plenary.nvim。複数候補の選択 UI を置き換える dressing.nvim / telescope-ui-select.nvim は任意。最低 Neovim バージョンは README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/ofirgall/open.nvim/blob/c74263bbbad4437d56ea123aec883314b9dd5371/README.md)
  '';
  plugin = sources.open-nvim;
  config = luaConfig (''
    require("open").setup({
      system_open = {
        cmd = "${if pkgs.stdenv.isDarwin then "open" else "xdg-open"}",
        args = {},
      }
    })
  '');
}
