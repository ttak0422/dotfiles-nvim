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
      local cache_dir = vim.fn.stdpath("cache")
      for name, value in pairs({
        updatetime = 100,
        hidden = true,
        autoread = true,
        undofile = true,
        undodir = cache_dir .. "/undo",
        swapfile = true,
        directory = cache_dir .. "/swap",
        backup = true,
        backupcopy = "yes",
        backupdir = cache_dir .. "/backup",
        listchars = "tab:> ,trail:-",
        list = true,
        equalalways = false,
        startofline = false,
      }) do
        vim.opt[name] = value
      end

      local function toggle(id)
        return function()
          require("toggler").toggle(id)
        end
      end

      local mappings = {
        { "<Leader>tz", "<Cmd>NeoZoomToggle<CR>", " zoom" },
        { "<Leader>to", toggle("aerial"), " outline" },
        { "<Leader>U", "<Cmd>Atone<CR>", " undotree" },
        { "gx", function() require("open").open_cword() end, "open" },
        { "<Leader>gb", "<Cmd>BlameToggle<CR>", " blame" },
        { "<LocalLeader>db", function() require("dap").toggle_breakpoint() end, " breakpoint" },
        { "<LocalLeader>dr", function() require("dap").repl.toggle() end, " repl" },
        { "<LocalLeader>dl", function() require("dap").run_last() end, " run last" },
        { "<LocalLeader>dd", toggle("dapui"), " run last" },
      }
      for _, mapping in ipairs(mappings) do
        vim.keymap.set("n", mapping[1], mapping[2], {
          noremap = true,
          silent = true,
          desc = mapping[3],
        })
      end
    ''
  );
}
