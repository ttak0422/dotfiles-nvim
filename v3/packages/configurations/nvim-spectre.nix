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
    # nvim-spectre

    ## 概要
    プロジェクト内の検索と置換を専用パネルで操作するプラグイン。

    ## 主な機能
    - 正規表現検索とパス glob による絞り込み。
    - 対象を選んでファイル横断の置換。

    ## 使い方
    `:Spectre` または `require("spectre").toggle()` で開く。`open_file_search({ select_word = true })` は現在ファイルを検索する。直接 undo できないため、README は置換前のコミットを勧めている。

    ## 要件
    plenary.nvim。検索・置換には対応する外部ツールを使う。README の既定例は ripgrep / sed、この定義は ripgrep / sd を選ぶ。アイコンや trouble.nvim は任意。

    ## 出典
    [固定リビジョンの README](https://github.com/nvim-pack/nvim-spectre/blob/72f56f7585903cd7bf92c665351aa585e150af0f/README.md)
  '';
  plugin = sources.nvim-spectre;
  dependPlugins = [
    definitions.plenary-nvim
    definitions.nvim-web-devicons
  ];
  config = luaConfig (
    # lua
    ''
      require("spectre").setup({
        default = {
          find = { cmd = "rg", options = {} },
          replace = { cmd = "sd" },
        },
        color_devicons = false,
        is_block_ui_break = false,
        live_update = false,
      })
    ''
  );
  extraPackages = with pkgs; [
    ripgrep
    sd
  ];
}
