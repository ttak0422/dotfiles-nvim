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
    # claudecode.nvim

    ## 概要
    Claude Code CLI と Neovim を連携させる Lua 実装の IDE 統合。

    ## 主な機能
    - ファイルや選択範囲を Claude のコンテキストに追加。
    - 提案された変更の差分表示と承認・拒否。

    ## 使い方
    `:ClaudeCode` で端末を開き、`:ClaudeCodeAdd %` で現在のファイル、Visual 選択後の `:ClaudeCodeSend` で選択範囲を送る。差分には `:ClaudeCodeDiffAccept` / `:ClaudeCodeDiffDeny` を使う。

    ## 要件
    Neovim 0.8.0 以上、インストール済み Claude Code CLI。README は拡張端末機能用に snacks.nvim を挙げている。

    ## 出典
    [固定リビジョンの README](https://github.com/coder/claudecode.nvim/blob/af04fbf9c27c5c06b4d1ff022b551aa94e1df4aa/README.md)
  '';
  plugin = sources.claudecode-nvim;
  lazy = true;
  # Keep all exported commands available before the first load.
  onCommands = [
    "ClaudeCode"
    "ClaudeCodeStart"
    "ClaudeCodeStop"
    "ClaudeCodeStatus"
    "ClaudeCodeSend"
    "ClaudeCodeTreeAdd"
    "ClaudeCodeAdd"
    "ClaudeCodeFocus"
    "ClaudeCodeOpen"
    "ClaudeCodeClose"
    "ClaudeCodeSendText"
    "ClaudeCodeDiffAccept"
    "ClaudeCodeDiffDeny"
    "ClaudeCodeCloseAllDiffs"
    "ClaudeCodeSelectModel"
  ];
  onModules = [ "claudecode" ];
  dependPlugins = [ definitions.snacks-nvim ];
  config = luaConfig (
    # lua
    ''
      require("claudecode").setup({
        terminal = {
          split_side = "right",
          split_width_percentage = 0.45,
          provider = "auto",
          auto_close = true,
        },
        keys = {},
      })
    ''
  );
}
