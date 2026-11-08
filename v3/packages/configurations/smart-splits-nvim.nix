{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  luaCheck,
  inputs',
}:
with sources;
{
  plugin = sources.smart-splits-nvim;
  doc = ''
    # smart-splits.nvim

    ## 概要
    上下左右の方向を基準に、ウィンドウの移動・サイズ変更を行う。

    ## 主な機能
    - 分割ウィンドウのリサイズ、移動、バッファ交換。
    - 画面端の挙動設定と任意の外部 multiplexer 連携。

    ## 使い方
    `:SmartResizeLeft` などでサイズを変更し、`:SmartCursorMoveRight` などで移動する。Lua API からキーに割り当てることもできる。

    ## 要件
    Neovim 0.11 以降。multiplexer 連携には別配布の対応バックエンドが必要で、コア単体には含まれない。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/mrjones2014/smart-splits.nvim/blob/fdd0142633ae78b175ff29043953e701215a34dd/README.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("smart-splits").setup({
        ignored_filetypes = { "nofile", "quickfix", "prompt" },
        ignored_buftypes = { "NvimTree" },
        resize = { ignored_events = { "BufEnter", "WinEnter" } },
      })
    ''
  );

  tests.smart-splits-resize = luaCheck {
    name = "smart-splits-resize";
    ui = true;
    script = ''
      local api = vim.api
      local config = require("smart-splits.config")
      assert(#config.issues() == 0, "smart-splits configuration must use supported options")
      assert(vim.deep_equal(config.resize.ignored_events, { "BufEnter", "WinEnter" }),
        "resize must retain the configured ignored events")

      vim.cmd.only()
      vim.cmd.enew()
      vim.cmd.vsplit()
      vim.cmd.wincmd("h")
      local left = api.nvim_get_current_win()
      local width = api.nvim_win_get_width(left)
      local eventignore = vim.o.eventignore
      local observed
      local group = api.nvim_create_augroup("SmartSplitsResizeTest", { clear = true })
      api.nvim_create_autocmd("OptionSet", {
        group = group,
        pattern = "eventignore",
        callback = function()
          if vim.tbl_contains(vim.opt.eventignore:get(), "BufEnter")
            and vim.tbl_contains(vim.opt.eventignore:get(), "WinEnter") then
            observed = true
          end
        end,
      })
      vim.cmd.SmartResizeRight("4")
      assert(api.nvim_win_get_width(left) == width + 4, "resize command must grow the split")
      assert(api.nvim_get_current_win() == left, "resize must retain the focused window")
      assert(observed, "resize must suppress the configured events while changing windows")
      assert(vim.o.eventignore == eventignore, "resize must restore eventignore afterwards")
      vim.cmd.SmartResizeLeft("4")
      assert(api.nvim_win_get_width(left) == width, "repeated resize must restore the original width")
      vim.cmd.SmartCursorMoveRight()
      assert(api.nvim_get_current_win() ~= left, "cursor movement must still work")
      api.nvim_del_augroup_by_id(group)
    '';
  };
}
