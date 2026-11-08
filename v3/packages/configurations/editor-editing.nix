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
  config = luaConfig (
    # lua
    ''
      vim.cmd([=[
      cabbrev <expr> wq getcmdtype() .. getcmdline() ==# ":wq" && &ft == "gitcommit" ? "w \| b#" : "wq"
      ]=])
    ''
    # lua
    + ''
      vim.cmd([=[
        au FileType * setlocal formatoptions-=ro
        au WinEnter * checktime
        vnoremap ; :
        nnoremap ; :
        noremap gy "+y
        inoremap <C-l> <Nop>
      ]=])

      local function map(mode, lhs, rhs, description)
        vim.keymap.set(mode, lhs, rhs, {
          noremap = true,
          silent = true,
          desc = description,
        })
      end

      map("n", "<Leader>m", function()
        require("treesj").toggle({ split = { recursive = false } })
      end, " join/split")
      map("n", "<Leader>M", function()
        require("treesj").toggle({ split = { recursive = true } })
      end, " join/split (recursive)")
      map("n", "<Leader>O", "<Cmd>Other<CR>")
      map("x", "<Leader>T", ":Translate JA<CR>")

      for key, action in pairs({
        ["<Left>"] = "goto_start",
        ["<Down>"] = "goto_next",
        ["<Up>"] = "goto_prev_start",
        ["<Right>"] = "goto_end",
      }) do
        map("n", key, function() require("foldnav")[action]() end)
      end

      for mode, dial_mode in pairs({ n = "normal", x = "visual" }) do
        for key, direction in pairs({ ["<C-a>"] = "increment", ["<C-x>"] = "decrement" }) do
          map(mode, key, function()
            require("dial.map").manipulate(direction, dial_mode)
          end)
          map(mode, "g" .. key, function()
            require("dial.map").manipulate(direction, "g" .. dial_mode)
          end)
        end
      end
    ''
  );
}
