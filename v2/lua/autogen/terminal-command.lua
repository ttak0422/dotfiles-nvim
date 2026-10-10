-- [nfnl] v2/fnl/terminal-command.fnl
if (vim.fn.exists(":Terminal") == 0) then
  local function _1_(opts)
    require("toggler")
    return vim.api.nvim_cmd({cmd = "Terminal", args = opts.fargs, count = opts.count}, {})
  end
  local function _2_(_, line, pos)
    return vim.fn.getcompletion(string.gsub(string.sub(line, 1, pos), "^.-Terminal%s*", ""), "shellcmdline")
  end
  return vim.api.nvim_create_user_command("Terminal", _1_, {nargs = "*", count = 0, complete = _2_, desc = "Open a terminal slot; command arguments apply only on first creation"})
else
  return nil
end
