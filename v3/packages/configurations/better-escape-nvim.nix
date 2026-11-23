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
  plugin = sources.better-escape-nvim;
  doc = ''
    # better-escape.nvim

    ## 概要
    連続キーによるモード切り替えで、最初の文字の入力待ちを避ける。

    ## 主な機能
    - 複数モードのキー列と Lua 関数に対応。
    - 判定時間と既定マッピングを設定可能。
    - pterm の前景実行ファイル名が除外リストにある場合、端末の `jk` をそのまま渡す。

    ## 使い方
    `require("better_escape").setup()` で `mappings` と `timeout` を設定する。上流の既定例では挿入モードの `jk`・`jj` で Escape を送る。

    ## 要件
    README に Neovim の最低バージョンや必須外部依存の明記なし。

    ## 出典
    - [上流 README（固定リビジョン）](https://github.com/max397574/better-escape.nvim/blob/3f4bc0b326606264ff75967f59091b5ddada0554/readme.md)
  '';
  config = luaConfig (
    # lua
    ''
      require("better_escape").setup({
        default_mappings = false,
        mappings = {
          i = { j = { k = "<Esc>" } },
          c = {},
          t = { j = { k = "<C-\\><C-n>" } },
          v = {},
          s = {},
        },
      })

      -- The action callback cannot suppress the Backspace queued by better-escape.
      -- Bypass its terminal callbacks instead: a TUI has already consumed `j`.
      -- Consult only the live, cached pterm context; never load pterm here.
      local ignored_foregrounds = {
        gitu = true,
        tig = true,
        [".tig-wrapped"] = true, -- Nixpkgs wrapper target
      }
      local previous_terminal_key
      local terminal_maps = vim.api.nvim_get_keymap("t")
      for _, mapping in ipairs(terminal_maps) do
        if mapping.lhs == "j" or mapping.lhs == "k" then
          local key, original = mapping.lhs, mapping.callback
          assert(type(original) == "function", "better-escape terminal callback missing")
          vim.keymap.set("t", key, function()
            local bufnr = vim.api.nvim_get_current_buf()
            local pterm = package.loaded.pterm
            local context = type(pterm) == "table"
              and type(pterm.buffer_context) == "function"
              and pterm.buffer_context(bufnr)
            local passthrough = type(context) == "table"
              and ignored_foregrounds[context.foreground] == true
            local previous = previous_terminal_key
            previous_terminal_key = { bufnr = bufnr, passthrough = passthrough }
            if passthrough then
              return key
            end
            -- Do not complete an escape sequence begun in a different buffer or
            -- before leaving passthrough. A fresh `j` still starts normal `jk`.
            if key == "k" and previous
              and (previous.bufnr ~= bufnr or previous.passthrough) then
              return key
            end
            return original()
          end, {
            expr = mapping.expr == 1,
            noremap = mapping.noremap == 1,
            silent = mapping.silent == 1,
            nowait = mapping.nowait == 1,
            script = mapping.script == 1,
            desc = mapping.desc,
          })
        end
      end
    ''
  );
  tests.better-escape-terminal-passthrough = luaCheck {
    name = "better-escape-terminal-passthrough";
    script = ''
      -- Exercise the real pinned callbacks, intercepting their terminal side effects.
      -- The separate embedded-terminal smoke test also verifies delivered bytes/modes.
      assert(not package.loaded.pterm, "the terminal guard must not eagerly load pterm")
      local function maps(mode)
        local result = {}
        for _, mapping in ipairs(vim.api.nvim_get_keymap(mode)) do
          result[mapping.lhs] = mapping
        end
        return result
      end
      local terminal = maps("t")
      local insert = maps("i")
      for _, key in ipairs({ "j", "k" }) do
        assert(terminal[key].expr == 1 and terminal[key].noremap == 1)
        assert(type(terminal[key].callback) == "function")
      end
      local original_feedkeys = vim.api.nvim_feedkeys
      local emitted = {}
      vim.api.nvim_feedkeys = function(keys) emitted[#emitted + 1] = keys end
      local foreground = "tig"
      local function press(key) return terminal[key].callback() end
      local function clear() emitted = {} end
      local function escape_pair()
        clear()
        assert(press("j") == "j")
        press("k")
        assert(#emitted == 1, "ordinary terminal jk must still run better-escape")
      end
      local first = vim.api.nvim_get_current_buf()
      escape_pair()
      assert(not package.loaded.pterm, "guard must not require a lazy module")
      package.loaded.pterm = {
        buffer_context = function(bufnr)
          if bufnr == first then
            return { foreground = foreground }
          end
        end,
      }
      vim.bo.filetype = "unrelated" -- bypass does not inspect or change filetype
      for _, executable in ipairs({ "gitu", "tig", ".tig-wrapped" }) do
        foreground = executable
        clear()
        assert(press("j") == "j" and press("k") == "k")
        assert(#emitted == 0, executable .. " bypass must not send Backspace or escape")
        assert(vim.bo.filetype == "unrelated")
      end
      for _, executable in ipairs({ "gitu-helper", "tig-wrapped" }) do
        foreground = executable
        escape_pair() -- similarly named executables are not excluded
      end
      foreground = "tig"
      clear()
      assert(press("j") == "j")
      foreground = "zsh"
      assert(press("k") == "k" and #emitted == 0, "do not consume pending j on tig exit")
      escape_pair()
      foreground = "tig"
      clear()
      assert(press("j") == "j")
      vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(false, true))
      assert(press("k") == "k" and #emitted == 0, "do not carry pending j to another buffer")
      escape_pair()
      vim.api.nvim_set_current_buf(first)
      foreground = nil
      escape_pair() -- unknown foreground or old daemon
      foreground = "tig"
      package.loaded.pterm = {} -- old plugin without context API
      escape_pair()
      clear()
      assert(insert.j.callback() == "j")
      insert.k.callback()
      assert(#emitted == 1, "insert jk must still use its original escape action")
      vim.api.nvim_feedkeys = original_feedkeys
      package.loaded.pterm = nil
    '';
  };
}
