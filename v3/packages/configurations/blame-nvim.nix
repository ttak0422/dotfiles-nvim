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
    # blame.nvim

    ## 概要
    Git blame の結果を Neovim 内に表示するプラグイン。

    ## 主な機能
    - 専用ウィンドウと仮想テキストの表示方式。
    - コミット情報の表示と過去のファイル状態への移動。

    ## 使い方
    `:BlameToggle [view] [options]` で表示を切り替える。既定では `i` でコミット情報、`<CR>` で詳細、`<Tab>` / `<BS>` で履歴を移動する。

    ## 要件
    最低バージョン・追加依存の一覧は README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/FabijanZulj/blame.nvim/blob/179da7aaacce7c52874af636255ede72dd6fe796/README.md)
  '';
  plugin = sources.blame-nvim;
  lazy = true;
  onCommands = [ "BlameToggle" ];
  onModules = [ "blame" ];
  config = luaConfig (
    # lua
    ''
      require("blame").setup({
        date_format = "%Y-%m-%d",
        virtual_style = "right_align",
        relative_date_if_recent = false,
        focus_blame = true,
        merge_consecutive = false,
        max_summary_width = 30,
        commit_detail_view = "vsplit",
        mappings = {
          commit_info = "i",
          stack_push = "<TAB>",
          stack_pop = "<BS>",
          show_commit = "<CR>",
          close = { "<esc>", "q" },
        },
      })
    ''
  );
}
