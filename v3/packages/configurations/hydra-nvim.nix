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
  plugin = sources.hydra-nvim;
  config = luaConfig (
    # lua
    ''
      local hydra = require("hydra")
      local saved = {}
      hydra.setup({ timeout = false })

      local function draw(direction)
        return function()
          require("draw-line").draw(direction)
        end
      end

      local function box(style)
        return function()
          local ok, err = require("draw-line").box_visual(style)
          if not ok then
            vim.notify(err, vim.log.levels.WARN)
          end
        end
      end

      hydra({
        name = "Draw Diagram",
        mode = "n",
        body = "<Leader>V",
        heads = {
          { "H", draw("h") },
          { "J", draw("j") },
          { "K", draw("k") },
          { "L", draw("l") },
          { "r", box("double"), { mode = "x" } },
          { "f", box("single"), { mode = "x" } },
          { "v", box("heavy"), { mode = "x" } },
          { "<Esc>", nil, { desc = "close", exit = true } },
        },
        config = {
          invoke_on_body = true,
          color = "pink",
          on_enter = function()
            saved.win = vim.api.nvim_get_current_win()
            saved.virtualedit = vim.wo.virtualedit
            saved.selection = vim.o.selection
            vim.api.nvim_set_option_value("virtualedit", "all", { scope = "local" })
            vim.api.nvim_set_option_value("selection", "inclusive", {})
          end,
          on_exit = function()
            if vim.api.nvim_win_is_valid(saved.win) then
              vim.api.nvim_set_option_value("virtualedit", saved.virtualedit, {
                win = saved.win,
                scope = "local",
              })
            end
            vim.api.nvim_set_option_value("selection", saved.selection, {})
          end,
          hint = {
            type = "window",
            position = "bottom-right",
            float_opts = { border = "single" },
          },
        },
        hint = [[:Move    Select region with <C-v>
      -------  -------------------------
         _K_     _r_: surround double
       _H_   _L_   _f_: surround single
         _J_     _v_: surround bold]],
      })
    ''
  );
}
