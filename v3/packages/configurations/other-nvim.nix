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
  plugin = sources.other-nvim;
  doc = ''
    # other.nvim

    ## 概要
    現在のファイルに関連する実装・テスト・ビューなどを規則に基づいて開く。

    ## 主な機能
    - 組み込み・独自のファイル対応ルール。
    - 候補が複数ある場合の選択 UI と選択記憶。

    ## 使い方
    `require("other-nvim").setup()` に mappings を設定する。`:Other` で関連ファイル、`:Other test` で test 文脈、`:OtherSplit`・`:OtherVSplit` で分割表示する。

    ## 要件
    README の指定は Neovim > 0.7。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/rgroli/other.nvim/blob/1d48e090f6d1d53dda9fb5094af3f2006ebbb858/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      local transformers = require("other-nvim.builtin.transformers")
      require("other-nvim").setup({
        showMissingFiles = true,
        rememberBuffers = false,
        mappings = { "c", "clojure", "elixir", "golang", "python", "react", "rust" },
        transformers = {
          camelToKebap = transformers.camelToKebap,
          kebapToCamel = transformers.kebapToCamel,
          pluralize = transformers.pluralize,
          singularize = transformers.singularize,
        },
        keybindings = {
          ["<cr>"] = "open_file_by_command()",
          ["<esc>"] = "close_window()",
          ["<C-w>o"] = "open_file()",
          ["<C-w>t"] = "open_file_tabnew()",
          ["<C-w>q"] = "close_window()",
          ["<C-w>v"] = "open_file_vs()",
          ["<C-w>s"] = "open_file_sp()",
        },
      })
    ''
  );
}
