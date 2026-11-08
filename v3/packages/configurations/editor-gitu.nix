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
      local augroup = vim.api.nvim_create_augroup("ttak-gitu", { clear = false })

      local function is_gitu_buffer(buf)
        return vim.api.nvim_buf_is_valid(buf)
          and (vim.b[buf].gitu == true or vim.api.nvim_buf_get_name(buf):match("term://.*:gitu$") ~= nil)
      end

      local function normal_window_count()
        local count = 0
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_config(win).relative == "" then
            count = count + 1
          end
        end
        return count
      end

      local function split_for_gitu()
        vim.cmd(vim.o.columns / vim.o.lines > 2.5 and "vsplit" or "split")
      end

      local function startinsert_if_current(buf)
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_current_buf() == buf then
            vim.cmd.startinsert()
          end
        end)
      end

      local function with_editor_origin(win, buf, callback)
        local previous = {
          win = vim.env.NVIM_EDITOR_WIN,
          buf = vim.env.NVIM_EDITOR_BUF,
          use_origin = vim.env.NVIM_EDITOR_USE_ORIGIN,
        }
        vim.env.NVIM_EDITOR_USE_ORIGIN = "1"
        vim.env.NVIM_EDITOR_WIN = tostring(win)
        vim.env.NVIM_EDITOR_BUF = tostring(buf)
        local ok, result = pcall(callback)
        vim.env.NVIM_EDITOR_USE_ORIGIN = previous.use_origin
        vim.env.NVIM_EDITOR_WIN = previous.win
        vim.env.NVIM_EDITOR_BUF = previous.buf
        if not ok then
          error(result)
        end
        return result
      end

      local function focus_gitu_buffer(buf)
        local wins = vim.fn.win_findbuf(buf)
        if #wins > 0 then
          vim.api.nvim_set_current_win(wins[1])
        else
          if normal_window_count() == 1 then
            split_for_gitu()
          end
          vim.api.nvim_win_set_buf(0, buf)
        end
        startinsert_if_current(buf)
      end

      local function delete_gitu_buffer(buf)
        pcall(function()
          require("snacks").bufdelete({ buf = buf, force = true })
        end)
      end

      local function close_gitu_buffer(buf, win, did_split)
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        if did_split and vim.api.nvim_win_is_valid(win) and pcall(vim.api.nvim_win_close, win, true) then
          return
        end
        delete_gitu_buffer(buf)
      end

      local function gitu()
        local running_buf = vim.iter(vim.api.nvim_list_bufs()):find(function(buf)
          return is_gitu_buffer(buf) and vim.b[buf].gitu_running == true
        end)
        if running_buf then
          focus_gitu_buffer(running_buf)
          return
        end

        local did_split = normal_window_count() == 1
        if did_split then
          split_for_gitu()
        end
        vim.cmd.enew()
        local buf = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()
        vim.b[buf].gitu = true
        vim.b[buf].gitu_running = true
        vim.bo[buf].buflisted = false
        vim.bo[buf].bufhidden = "wipe"
        vim.api.nvim_create_autocmd("BufEnter", {
          group = augroup,
          buffer = buf,
          callback = function()
            startinsert_if_current(buf)
          end,
        })
        local job = with_editor_origin(win, buf, function()
          return vim.fn.jobstart({ "gitu" }, {
            term = true,
            on_exit = function(_, status)
              if vim.api.nvim_buf_is_valid(buf) then
                vim.b[buf].gitu_running = false
              end
              vim.schedule(function()
                if status == 0 then
                  close_gitu_buffer(buf, win, did_split)
                else
                  vim.notify("gitu exited with code " .. status, vim.log.levels.WARN)
                end
              end)
            end,
          })
        end)
        if job <= 0 then
          vim.notify("failed to start gitu", vim.log.levels.ERROR)
          delete_gitu_buffer(buf)
          return
        end
        vim.cmd.startinsert()
      end

      vim.api.nvim_create_user_command("Gitu", gitu, {})
      vim.api.nvim_create_user_command("GituClear", function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if is_gitu_buffer(buf) then
            delete_gitu_buffer(buf)
          end
        end
      end, {})
    ''
  );
}
