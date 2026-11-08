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
  plugin = sources.direnv-nvim;
  doc = ''
    # direnv.nvim

    ## 概要
    プロジェクトの `.envrc` を通じて Direnv の環境変数を Neovim に取り込む。

    ## 主な機能
    - `.envrc` の許可・拒否・再読み込み・編集。
    - 任意の自動読み込み、状態表示、イベント連携。

    ## 使い方
    `require("direnv").setup()` 後、`:Direnv status` で状態を確認し、`:Direnv allow`・`:Direnv reload` などで操作する。

    ## 要件
    Neovim 0.8.0 以降、PATH 上の Direnv 2.33.0 以降。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/NotAShelf/direnv.nvim/blob/9258f9f10c4c729d8296fce0e3ecb12543daad06/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      if vim.g.direnv_nvim_original_path == nil then
        vim.g.direnv_nvim_original_path = vim.env.PATH or ""
      end
      local function split_path(path)
        return vim.split(path or "", ":", { plain = true, trimempty = true })
      end
      local function merge_path(current, original)
        local items = split_path(current)
        local seen = {}
        for _, item in ipairs(items) do
          seen[item] = true
        end
        for _, item in ipairs(split_path(original)) do
          if not seen[item] then
            table.insert(items, item)
            seen[item] = true
          end
        end
        return table.concat(items, ":")
      end
      vim.api.nvim_create_autocmd("User", {
        pattern = "DirenvLoaded",
        callback = function()
          vim.env.PATH = merge_path(vim.env.PATH, vim.g.direnv_nvim_original_path)
        end,
      })
      require("direnv").setup({
        autoload_direnv = true,
        statusline = { enabled = false },
        keybindings = {},
        notifications = { silent_autoload = true },
      })
    ''
  );
  extraPackages = with pkgs; [ direnv ];
}
