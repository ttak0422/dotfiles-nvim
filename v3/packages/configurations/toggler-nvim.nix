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
  plugin = sources.toggler-nvim;
  dependPlugins = [
    definitions.telescope-nvim
  ];
  config = luaConfig (
    # lua
    ''
      local toggler = require("toggler")

      local function with_keep_window(callback)
        return function()
          local win = vim.api.nvim_get_current_win()
          callback()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
          end
        end
      end

      local function filetype_exists(filetype)
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == filetype then
            return true
          end
        end
        return false
      end

      local quickfix_open = false
      toggler.register("qf", {
        open = with_keep_window(function()
          if not quickfix_open then
            vim.cmd.copen()
            quickfix_open = true
          end
        end),
        close = function()
          if quickfix_open then
            vim.cmd.cclose()
            quickfix_open = false
          end
        end,
        is_open = function()
          quickfix_open = filetype_exists("qf")
          return quickfix_open
        end,
      })

      do
        local harpoon_open = false
        local function toggle()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list(), { title = "", border = "single" })
        end
        toggler.register("harpoon", {
          open = function()
            if not harpoon_open then
              toggle()
            end
          end,
          close = function()
            if harpoon_open then
              toggle()
            end
          end,
          is_open = function()
            harpoon_open = filetype_exists("harpoon")
            return harpoon_open
          end,
        })
      end

      do
        local recent_type
        local function register_trouble(kind, opts)
          toggler.register("trouble-" .. kind, {
            open = with_keep_window(function()
              require("trouble").open(opts)
              recent_type = kind
            end),
            close = function()
              local trouble = package.loaded.trouble
              if trouble then
                trouble.close()
              end
            end,
            is_open = function()
              local trouble = package.loaded.trouble
              return trouble ~= nil and trouble.is_open() and recent_type == kind
            end,
          })
        end
        register_trouble("doc", { mode = "diagnostics", filter = { buf = 0 } })
        register_trouble("ws", { mode = "diagnostics" })
      end

      do
        local terminal_windows = {}
        local function float_config()
          local width = math.max(1, math.floor(vim.o.columns * 0.95))
          local height = math.max(1, math.floor((vim.o.lines - 2) * 0.95))
          return {
            relative = "editor",
            row = math.floor((vim.o.lines - height) / 2),
            col = math.floor((vim.o.columns - width) / 2),
            width = width,
            height = height,
            style = "minimal",
            border = "single",
          }
        end
        local function tab_terminals()
          local tab = vim.api.nvim_get_current_tabpage()
          terminal_windows[tab] = terminal_windows[tab] or {}
          return terminal_windows[tab]
        end
        local function is_open(index)
          local term = tab_terminals()[index]
          return term and vim.api.nvim_win_is_valid(term.win) and vim.api.nvim_win_get_buf(term.win) == term.buf
        end
        local function open(index)
          local terms = tab_terminals()
          if is_open(index) then
            vim.api.nvim_set_current_win(terms[index].win)
          else
            local buf = vim.api.nvim_create_buf(false, true)
            vim.bo[buf].bufhidden = "wipe"
            terms[index] = { win = vim.api.nvim_open_win(buf, true, float_config()) }
          end
          -- The managed plugin owns PTY size authority and history reset ACKs.
          local session = "vim_tab" .. vim.api.nvim_get_current_tabpage() .. "_idx" .. index
          require("pterm").open(session)
          terms[index].buf = vim.api.nvim_get_current_buf()
        end
        vim.api.nvim_create_autocmd("VimResized", {
          group = vim.api.nvim_create_augroup("pterm_terminal_floats", { clear = true }),
          callback = function()
            for _, terms in pairs(terminal_windows) do
              for _, term in pairs(terms) do
                if vim.api.nvim_win_is_valid(term.win) and vim.api.nvim_win_get_buf(term.win) == term.buf then
                  vim.api.nvim_win_set_config(term.win, float_config())
                end
              end
            end
          end,
        })
        for index = 0, 9 do
          toggler.register("term" .. index, {
            open = function() open(index) end,
            close = function()
              if is_open(index) then
                vim.api.nvim_win_close(tab_terminals()[index].win, true)
              end
            end,
            is_open = function() return is_open(index) end,
          })
        end
      end

      do
        local dapui
        toggler.register("dapui", {
          open = function()
            dapui = dapui or require("dapui")
            dapui:open({ reset = true })
          end,
          close = function()
            if dapui then
              dapui.close()
            end
          end,
          is_open = function()
            for _, layout in ipairs(require("dapui.windows").layouts) do
              if layout:is_open() then
                return true
              end
            end
            return false
          end,
        })
      end

      do
        local aerial
        toggler.register("aerial", {
          open = function()
            aerial = aerial or require("aerial")
            aerial.open()
          end,
          close = function()
            if aerial then
              aerial.close()
            end
          end,
          is_open = function() return filetype_exists("aerial") end,
        })
      end
    ''
  );
}
