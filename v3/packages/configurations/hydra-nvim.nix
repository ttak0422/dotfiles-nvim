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
    # Hydra.nvim

    ## 概要
    共通プレフィックスに続くキー操作を繰り返せる、一時的なキー操作モードを定義する。

    ## 主な機能
    - body と heads による連続操作。
    - ヒント表示、終了条件、開始・終了フックを設定。

    ## 使い方
    `require("hydra")({ body = ..., heads = ..., config = ... })` で操作群を作る。`invoke_on_body` は body のみで開始する設定。この定義は `<Leader>V` で描画用の操作群に入る。

    ## 要件
    最低バージョン・追加依存は README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/nvimtools/hydra.nvim/blob/f3d4822060376cb253d4cc0d5af2c272c28de2a7/README.md)
  '';
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
