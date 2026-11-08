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
