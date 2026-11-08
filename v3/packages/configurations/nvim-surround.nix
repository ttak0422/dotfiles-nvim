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
  plugin = sources.nvim-surround;
  config = luaConfig (
    # lua
    ''
      vim.g.nvim_surround_no_insert_mappings = true
      vim.g.nvim_surround_no_normal_mappings = true
      vim.g.nvim_surround_no_visual_mappings = true
      require("nvim-surround").setup({})

      local mappings = {
        { "i", "<C-g>s", "insert", "Add a surrounding pair around the cursor (insert mode)" },
        { "i", "<C-g>S", "insert-line", "Add a surrounding pair around the cursor, on new lines (insert mode)" },
        { "n", "ys", "normal", "Add a surrounding pair around a motion (normal mode)" },
        { "n", "yss", "normal-cur", "Add a surrounding pair around the current line (normal mode)" },
        { "n", "yS", "normal-line", "Add a surrounding pair around a motion, on new lines (normal mode)" },
        { "n", "ySS", "normal-cur-line", "Add a surrounding pair around the current line, on new lines (normal mode)" },
        { "x", "Y", "visual", "Add a surrounding pair around a visual selection" },
        { "x", "gY", "visual-line", "Add a surrounding pair around a visual selection, on new lines" },
        { "n", "ds", "delete", "Delete a surrounding pair" },
        { "n", "cs", "change", "Change a surrounding pair" },
        { "n", "cS", "change-line", "Change a surrounding pair, on new lines" },
      }
      for _, mapping in ipairs(mappings) do
        vim.keymap.set(mapping[1], mapping[2], "<Plug>(nvim-surround-" .. mapping[3] .. ")", {
          noremap = true,
          silent = true,
          desc = mapping[4],
        })
      end
    ''
  );
}
