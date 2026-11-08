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
    # Todo Comments

    ## 概要
    コード中の TODO や FIXME などをハイライト・検索する。

    ## 主な機能
    - キーワードと別名、サイン、ハイライトを設定できる。
    - quickfix、ロケーションリスト、任意の検索 UI に結果を表示する。

    ## 使い方
    `:TodoQuickFix`、`:TodoLocList`、`:TodoTelescope` を使う。`require("todo-comments").jump_next()` / `jump_prev()` で移動する。既定の検索対象はキーワードにコロンが続く形。

    ## 要件
    Neovim 0.8.0 以上。検索には ripgrep と plenary.nvim を使用する。Trouble、Telescope、FzfLua は任意連携。アイコンには対応フォントまたは代替文字が必要。

    ## 出典
    [固定バージョンの README](https://github.com/folke/todo-comments.nvim/blob/31e3c38ce9b29781e4422fc0322eb0a21f4e8668/README.md)
  '';

  plugin = sources.todo-comments-nvim;
  dependPlugins = [
    definitions.nvim-web-devicons
    definitions.trouble-nvim
  ];
  config = luaConfig (
    # lua
    ''
      require("todo-comments").setup({
        signs = true,
        keywords = {
          FIX = { icon = "", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          TODO = { icon = "", color = "info" },
          HACK = { icon = "", color = "warning" },
          WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = "", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = "", color = "hint", alt = { "INFO" } },
          TEST = { icon = "", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        },
      })
    ''
  );
  extraPackages = with pkgs; [ ripgrep ];
}
