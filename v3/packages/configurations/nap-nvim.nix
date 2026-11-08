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
  plugin = sources.nap-nvim;
  dependPlugins = [
    definitions.vim-bufsurf
    definitions.marks-nvim
  ];
  config = luaConfig (
    # lua
    ''
      local nap = require("nap")
      local function operator(description, previous, next)
        return {
          prev = { opts = { desc = "< " .. description }, rhs = previous },
          next = { opts = { desc = "> " .. description }, rhs = next },
        }
      end

      local function jump_diagnostic(severity, count)
        return function()
          vim.diagnostic.jump({ severity = { min = severity }, count = count })
        end
      end

      local function older_quickfix_list()
        if vim.fn.getqflist({ nr = 0 }).nr > 1 then
          vim.cmd("silent colder")
        else
          vim.notify("reached start of quickfix list")
        end
      end

      local function newer_quickfix_list()
        if vim.fn.getqflist({ nr = 0 }).nr < vim.fn.getqflist({ nr = "$" }).nr then
          vim.cmd("silent cnewer")
        else
          vim.notify("reached end of quickfix list")
        end
      end

      local function next_harpoon()
        require("harpoon"):list():next()
      end

      nap.setup({
        next_prefix = "]",
        prev_prefix = "[",
        next_repeat = "<c-n>",
        prev_repeat = "<c-p>",
        exclude_default_operators = { "f", "F", "z", "s", "'", "l", "L", "<C-l>", "<M-l>" },
        operators = {
          b = operator("buffer", "<Cmd>bprevious<CR>", "<Cmd>bnext<CR>"),
          B = operator("buffer (history)", "<Cmd>BufSurfBack<CR>", "<Cmd>BufSurfForward<CR>"),
          d = operator("warning",
            jump_diagnostic(vim.diagnostic.severity.WARN, -1),
            jump_diagnostic(vim.diagnostic.severity.WARN, 1)),
          D = operator("error",
            jump_diagnostic(vim.diagnostic.severity.ERROR, -1),
            jump_diagnostic(vim.diagnostic.severity.ERROR, 1)),
          e = operator("edit", "g,", "g;"),
          j = operator("jump", "<C-o>", "<C-i>"),
          -- Preserve v2: both directions advance to Harpoon's next entry.
          h = operator("harpoon", next_harpoon, next_harpoon),
          q = operator("qf (item)", "<Cmd>Qprev<CR>", "<Cmd>Qnext<CR>"),
          ["<C-q>"] = operator("qf (file)", "<Cmd>cpfile<CR>", "<Cmd>cnfile<CR>"),
          ["<M-q>"] = operator("qf (list)", older_quickfix_list, newer_quickfix_list),
          g = nap.gitsigns(),
          m = operator("marks", "<Plug>(Marks-prev)", "<Plug>(Marks-next)"),
          M = operator("bookmarks", "<Plug>(Marks-prev-bookmark)", "<Plug>(Marks-next-bookmark)"),
        },
      })
    ''
  );
}
