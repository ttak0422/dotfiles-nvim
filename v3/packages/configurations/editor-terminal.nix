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
      -- One Escape leaves terminal mode; a second Escape is sent to the terminal.
      vim.cmd([[
        tnoremap <ESC> <c-\><c-n><Plug>(esc)
        nnoremap <Plug>(esc)<ESC> i<ESC>
      ]])

      local state = {}
      local sync_input
      local set_option = vim.api.nvim_set_option_value

      local function restore_winbars()
        for win, value in pairs(state.winbars or {}) do
          if vim.api.nvim_win_is_valid(win) then
            set_option("winbar", value, { win = win })
          end
        end
      end

      local function original_window(win)
        local zoom = package.loaded["neo-zoom"]
        return zoom and zoom.zoom_book and zoom.zoom_book[win] or win
      end

      local function terminal_channel(buf)
        local ok, channel = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
        if ok and type(channel) == "number" then
          return channel
        end
      end

      local function focus_terminal(win, buf, cursor)
        if not win or not vim.api.nvim_win_is_valid(win) then
          return
        end
        vim.api.nvim_set_current_win(win)
        if cursor then
          pcall(vim.api.nvim_win_set_cursor, win, cursor)
        end
        if buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
          vim.schedule(function()
            if vim.api.nvim_get_current_win() == win and vim.api.nvim_get_current_buf() == buf then
              vim.cmd.startinsert()
            end
          end)
        end
      end

      local function send_input()
        local valid = state.term_buf and vim.api.nvim_buf_is_valid(state.term_buf)
          and terminal_channel(state.term_buf) == state.channel
        local text = table.concat(vim.api.nvim_buf_get_lines(state.buf, 0, -1, false), "\n") .. "\r"
        local ok, err = false, "terminal is unavailable"
        if valid then
          if text == "\r" then
            ok = true
          else
            ok, err = pcall(vim.api.nvim_chan_send, state.channel, text)
          end
        end
        -- Keep the draft when the terminal has exited or sending fails.
        if not ok then
          vim.notify("terminal input retained: " .. err, vim.log.levels.ERROR)
        end
        return ok
      end

      local function close_input(send)
        sync_input()
        if send and not send_input() then
          return
        end
        local buf, win = state.buf, state.win
        local term_buf, term_win, term_cursor = state.term_buf, state.term_win, state.term_cursor
        restore_winbars()
        if win and vim.api.nvim_win_is_valid(win) then
          pcall(vim.api.nvim_win_close, win, true)
        end
        if buf and vim.api.nvim_buf_is_valid(buf) then
          pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
        state = {}
        focus_terminal(term_win, term_buf, term_cursor)
      end

      local function set_input_keymaps(buf)
        local opts = { buffer = buf, noremap = true, nowait = true, silent = true }
        local function cancel() close_input(false) end
        local function accept() close_input(true) end
        -- Escape remains available for SKK mode changes rather than closing the popup.
        vim.keymap.set({ "n", "i" }, "<C-c>", cancel, opts)
        vim.keymap.set("n", "<leader>q", cancel, opts)
        vim.keymap.set("n", "<leader>Q", cancel, opts)
        vim.keymap.set({ "n", "i" }, "<C-s>", accept, opts)
      end

      local function start_input()
        sync_input()
        if state.win and vim.api.nvim_win_is_valid(state.win)
          and vim.api.nvim_get_current_win() == state.win
          and not vim.api.nvim_win_get_config(state.win).hide then
          vim.cmd.startinsert()
          local keys = vim.api.nvim_replace_termcodes("<Plug>(goda-skk-enable)", true, false, true)
          vim.api.nvim_feedkeys(keys, "m", false)
        end
      end

      local function input_float_config(term_win, width, height)
        -- Use screen coordinates, not buffer rows that may include long scrollback.
        local cursor_row, cursor_col = vim.fn.winline() - 1, vim.fn.wincol() - 1
        local win_height = vim.api.nvim_win_get_height(term_win)
        local win_width = vim.api.nvim_win_get_width(term_win)
        local border_size = 2
        local row = cursor_row + 1
        if row + height + border_size > win_height then
          row = math.max(0, cursor_row - height - border_size)
        end
        return {
          relative = "win",
          win = term_win,
          -- Stay above the owner terminal but below an unrelated zoom window.
          zindex = (vim.api.nvim_win_get_config(term_win).zindex or 0) + 1,
          style = "minimal",
          border = "single",
          title = " SKK input ",
          title_pos = "center",
          width = width,
          height = height,
          row = row,
          col = math.min(cursor_col, math.max(0, win_width - width - border_size)),
        }
      end

      sync_input = function()
        if not state.win then
          return
        end
        if not vim.api.nvim_win_is_valid(state.win) then
          restore_winbars()
          state = {}
          return
        end

        local zoom = package.loaded["neo-zoom"]
        local wins = vim.api.nvim_tabpage_list_wins(state.tab)
        local function owns_terminal(win)
          return win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == state.term_buf
        end
        local owner = owns_terminal(state.home_win) and state.home_win
          or owns_terminal(state.term_win) and state.term_win or nil
        local zoom_win
        for _, win in ipairs(wins) do
          if zoom and zoom.zoom_book and zoom.zoom_book[win] then
            zoom_win = win
            if owns_terminal(win) and (win == state.term_win or zoom.zoom_book[win] == state.home_win) then
              owner = win
            end
          end
        end
        if owner ~= state.term_win then
          restore_winbars()
        end
        state.term_win = owner

        local hidden = not owner or (zoom_win ~= nil and owner ~= zoom_win)
        local config = { relative = "editor", row = 0, col = 0 }
        if owner then
          config = vim.api.nvim_win_call(owner, function()
            local width = math.max(10, math.min(80, vim.api.nvim_win_get_width(owner) - 4))
            return input_float_config(owner, width, 5)
          end)
          if state.winbars[owner] == nil then
            state.winbars[owner] = vim.api.nvim_get_option_value("winbar", { win = owner, scope = "local" })
          end
          set_option("winbar", hidden and state.winbars[owner] or "", { win = owner })
        end
        config.hide = hidden
        vim.api.nvim_win_set_config(state.win, config)

        -- Hidden input windows must not retain focus and hide the cursor.
        if hidden and vim.api.nvim_get_current_win() == state.win then
          local target = zoom_win or owner
          for _, win in ipairs(wins) do
            if not target and win ~= state.win and vim.api.nvim_win_get_config(win).relative == "" then
              target = win
            end
          end
          if target then
            vim.api.nvim_set_current_win(target)
          end
        end
      end

      -- NeoZoom swaps the original split's buffer; resolve ownership after its events.
      local sync_pending = false
      vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "WinClosed", "BufWipeout", "TabEnter" }, {
        group = vim.api.nvim_create_augroup("TerminalSkkInput", { clear = true }),
        callback = function()
          if not sync_pending then
            sync_pending = true
            vim.schedule(function()
              sync_pending = false
              sync_input()
            end)
          end
        end,
      })

      local function open_input()
        if state.win and vim.api.nvim_win_is_valid(state.win) then
          if not state.term_win and vim.api.nvim_get_current_tabpage() == state.tab
            and vim.api.nvim_get_current_buf() == state.term_buf then
            state.home_win = original_window(vim.api.nvim_get_current_win())
          end
          sync_input()
          if vim.api.nvim_win_get_config(state.win).hide then
            vim.notify("SKK input draft belongs to another terminal window", vim.log.levels.WARN)
            return
          end
          vim.api.nvim_set_current_win(state.win)
          vim.schedule(start_input)
          return
        end

        local term_buf, term_win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
        local term_cursor = vim.api.nvim_win_get_cursor(term_win)
        local channel = terminal_channel(term_buf)
        if not channel then
          vim.notify("Terminal SKK input is only available in terminal buffers", vim.log.levels.WARN)
          return
        end
        local width = math.max(10, math.min(80, vim.api.nvim_win_get_width(term_win) - 4))
        local buf = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(buf, true, input_float_config(term_win, width, 5))
        state = {
          buf = buf,
          win = win,
          term_buf = term_buf,
          term_win = term_win,
          home_win = original_window(term_win),
          tab = vim.api.nvim_win_get_tabpage(term_win),
          winbars = {},
          term_cursor = term_cursor,
          channel = channel,
        }
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].filetype = "skk-terminal-input"
        vim.api.nvim_buf_set_name(buf, "skk-terminal-input://" .. buf)
        for name, value in pairs({
          signcolumn = "no",
          foldcolumn = "0",
          winbar = "",
          number = false,
          relativenumber = false,
          wrap = false,
        }) do
          set_option(name, value, { win = win })
        end
        sync_input()
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
        set_input_keymaps(buf)
        vim.schedule(start_input)
      end

      vim.keymap.set("t", "<C-g>", open_input, { noremap = true, silent = true, desc = "SKK input helper" })
    ''
  );
}
