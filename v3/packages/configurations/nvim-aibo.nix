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
    # Aibo

    ## 概要
    AI アシスタントや対話型 CLI を Neovim のコンソールと入力窓で扱う。

    ## 主な機能
    - Claude、Codex、Ollama などのツール別操作を提供する。
    - 任意の対話型 CLI、プロンプト入力、ウィンドウ切り替えに対応する。

    ## 使い方
    `:Aibo codex`、`:Aibo claude`、`:Aibo python -i` のように起動する。ノーマルモードの `<CR>` で送信する。`<C-c>` はツールへ Esc を送り、`g<C-c>` は割り込みを送る。

    ## 要件
    Neovim 0.10.0 以上と利用する対話型 CLI が必要。README はベータ版で API や機能が変わり得ると明記している。

    ## 出典
    [固定バージョンの README](https://github.com/lambdalisue/nvim-aibo/blob/0505c2ef5471d43fb48df5823ede9705b9c9e73e/README.md)
  '';

  plugin = sources.nvim-aibo;
  config = luaConfig (
    # lua
    ''
      require("aibo").setup({
        prompt = {
          no_default_mappings = false,
          on_attach = function(bufnr)
            local opts = { buffer = bufnr, nowait = true, silent = true }
            for _, key in ipairs({ "<C-n>", "<C-p>", "<Down>", "<Up>" }) do
              vim.keymap.set({ "n", "i" }, key, "<Plug>(aibo-send)" .. key, opts)
            end
            vim.keymap.set({ "n", "i" }, "<C-c>", "<Plug>(aibo-send)<Esc>", opts)
            vim.keymap.set("n", "<CR>", "<Plug>(aibo-submit)", opts)
            vim.keymap.set("i", "<C-s>", "<Plug>(aibo-submit)", opts)
          end,
        },
        console = { no_default_mappings = false, on_attach = function() end },
        tools = {
          claude = { no_default_mappings = false, on_attach = function() end },
          codex = {},
        },
      })
    ''
  );
}
