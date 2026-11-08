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
  doc = ''
    # switch.vim

    ## 概要
    カーソル位置の文字列を、パターンに応じて別の表現へ切り替えるプラグイン。

    ## 主な機能
    - true / false などの文字列を置換。
    - 独自定義と逆方向の切り替えに対応。

    ## 使い方
    `:Switch` で切り替え、リスト形式の定義には `:SwitchReverse` で逆方向に移動する。この定義は `g:switch_mapping` に `-` を指定している。マッピング経由の操作はドットリピートに対応する。

    ## 要件
    最低バージョン・追加依存は README 未記載。

    ## 出典
    [固定リビジョンの README](https://github.com/AndrewRadev/switch.vim/blob/70ad8c66c694c60e9d13342493f51d5b7dddc42d/README.md)
  '';
  plugin = sources.switch-vim;
  preConfig = luaConfig ({
    language = "vim";
    code = # vim
      ''
        let g:switch_mapping = '-'
      '';
  });

  tests.switch-configured-mapping-roundtrip = luaCheck {
    name = "switch-configured-mapping-roundtrip";
    script = ''
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "value = true" })
      vim.api.nvim_win_set_cursor(0, { 1, 8 })
      assert(vim.g.switch_mapping == "-", "Switch mapping configuration changed")
      assert(vim.fn.maparg("-", "n"):find("<Plug>(Switch)", 1, true),
        "Configured '-' must invoke Switch")
      vim.cmd.normal("-")
      assert(vim.api.nvim_get_current_line() == "value = false", "Switch must toggle true to false")
      vim.cmd.normal("-")
      assert(vim.api.nvim_get_current_line() == "value = true", "Switch must toggle false to true")
    '';
  };
}
