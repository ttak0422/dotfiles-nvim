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
  plugin = sources.worktab-nvim;
  doc = ''
    # worktab.nvim

    ## 概要
    Neovim のタブに作業内容を示す名前を付ける。

    ## 主な機能
    - タブ変数に名前を保存し、タブ終了時に自動で破棄。
    - 名前・タブハンドルでの移動と任意の Telescope picker。

    ## 使い方
    `:Tabnew api` で名前付きタブを作る。`require("worktab").set_name("api")`・`get_name()`・`goto_tab("api")` で名前を操作する。

    ## 要件
    README に最低 Neovim バージョンや必須外部依存の明記なし。Telescope 連携は任意。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/ttak0422/worktab.nvim/blob/32d4bf1ebc2169dca0da30cfa3d31a2d0fb8d3a7/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      local worktab = require("worktab")
      vim.api.nvim_create_user_command("Tabnew", function(opts)
        vim.cmd.tabnew()
        if opts.args ~= "" then
          worktab.set_name(opts.args)
        end
      end, { nargs = "?", desc = "Open a new tab with an optional name" })
    ''
  );
}
