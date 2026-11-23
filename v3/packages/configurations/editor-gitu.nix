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
  extraPackages = with pkgs; [
    pkgs.gitu
  ];
  config = luaConfig (
    # lua
    ''
      local group = vim.api.nvim_create_augroup("ttak-gitu", { clear = true })
      local sessions = {}
      -- The child keeps its editor endpoint across detach/reattach. Do not
      -- automatically attach an old instance's session with a stale endpoint.
      local instance = table.concat({ vim.v.servername, vim.fn.getpid(), vim.uv.hrtime() }, ":")

      local function worktree()
        local result = vim.system(
          { "git", "rev-parse", "--show-toplevel" },
          { cwd = vim.fn.getcwd(), text = true, timeout = 2000 }
        ):wait()
        if result.code ~= 0 then
          return nil
        end
        local path = (result.stdout or ""):gsub("\n$", "")
        return vim.uv.fs_realpath(path)
      end

      local function split_if_single_window()
        local count = 0
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_get_config(win).relative == "" then
            count = count + 1
          end
        end
        if count == 1 then
          vim.cmd(vim.o.columns / vim.o.lines > 2.5 and "vsplit" or "split")
          return true
        end
        return false
      end

      local function with_editor_origin(win, callback)
        local origin = {
          NVIM_EDITOR_ADDR = vim.v.servername,
          NVIM_EDITOR_WIN = tostring(win),
          NVIM_EDITOR_BUF = "",
          NVIM_EDITOR_USE_ORIGIN = "1",
        }
        local saved = {}
        for key, value in pairs(origin) do
          saved[key] = vim.env[key]
          vim.env[key] = value
        end
        local ok, err = pcall(callback)
        for key in pairs(origin) do
          vim.env[key] = saved[key]
        end
        return ok, err
      end

      local function close_split(win, buf)
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
          pcall(vim.api.nvim_win_close, win, true)
        end
      end

      local function gitu()
        local root = worktree()
        if not root then
          vim.notify("Gitu requires a Git working tree", vim.log.levels.WARN)
          return
        end
        local ok, pterm = pcall(require, "pterm")
        if not ok then
          vim.notify("Gitu could not load pterm: " .. tostring(pterm), vim.log.levels.ERROR)
          return
        end
        local name = "gitu-" .. vim.fn.sha256(instance .. "\001" .. root):sub(1, 24)
        local entry = sessions[name]
        if entry and entry.buf and vim.api.nvim_buf_is_valid(entry.buf) and pterm.is_connected(name) then
          local wins = vim.fn.win_findbuf(entry.buf)
          if #wins > 0 then
            vim.api.nvim_set_current_win(wins[1])
          else
            split_if_single_window()
            vim.api.nvim_win_set_buf(0, entry.buf)
          end
          vim.cmd.startinsert()
          return
        end

        if not entry and vim.tbl_contains(pterm.list(), name) then
          vim.notify("Gitu session name already in use; refusing to take ownership", vim.log.levels.ERROR)
          return
        end
        local did_split = split_if_single_window()
        local win = vim.api.nvim_get_current_win()
        local opened, err = with_editor_origin(win, function()
          -- Launch the TUI itself; quitting it ends the managed PTY.
          pterm.open(name, { name, "gitu" })
        end)
        local buf = vim.api.nvim_get_current_buf()
        if not opened or not pterm.is_connected(name) or vim.api.nvim_buf_get_name(buf) ~= "pterm://" .. name then
          if did_split then
            close_split(win, buf)
          end
          vim.notify("Gitu could not start pterm" .. (err and ": " .. tostring(err) or ""), vim.log.levels.ERROR)
          return
        end

        -- This is a dedicated direct Gitu child, even before the first daemon
        -- foreground sample. Never infer this from a pterm buffer name alone.
        vim.b[buf].gitu_pterm_session = name
        entry = { buf = buf, split = did_split and win or nil }
        sessions[name] = entry
        vim.api.nvim_create_autocmd("TermClose", {
          group = group,
          buffer = buf,
          once = true,
          callback = function()
            -- The bridge can end while the daemon is still alive. Keep
            -- instance ownership so GituClear can also stop detached sessions.
            entry.buf = nil
            if entry.split then
              close_split(entry.split, buf)
            end
          end,
        })
      end

      vim.api.nvim_create_user_command("Gitu", gitu, {})
      vim.api.nvim_create_user_command("GituClear", function()
        local pterm = package.loaded.pterm
        if type(pterm) ~= "table" then
          return
        end
        local live = pterm.list()
        local function has_children(name)
          return vim.iter(live):any(function(other)
            return vim.startswith(other, name .. "/")
          end)
        end
        for name, entry in pairs(sessions) do
          if not vim.tbl_contains(live, name) then
            if entry.buf and pterm.is_connected(name) then
              vim.notify("Gitu session not ready; retry GituClear or quit Gitu", vim.log.levels.WARN)
            else
              sessions[name] = nil
            end
          elseif has_children(name) then
            vim.notify("GituClear will not kill a session with descendants: " .. name, vim.log.levels.WARN)
          else
            -- The instance created this exact private leaf. Never kill a
            -- namespace, a discovered session, or a leaf with children.
            pterm.kill(name)
            if not vim.tbl_contains(pterm.list(), name) then
              sessions[name] = nil
            end
          end
        end
      end, { desc = "Stop only this Neovim's dedicated Gitu sessions" })
    ''
  );
}
