-- [nfnl] v2/fnl/harpoon.fnl
local harpoon = require("harpoon")
local function display(item)
  local value = (item.value or "")
  local repo = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
  local fname = vim.fn.fnamemodify(value, ":t")
  local dir = vim.fn.fnamemodify(value, ":h")
  if ((dir == ".") or (dir == "")) then
    return string.format("%s  %s", fname, repo)
  else
    return string.format("%s  %s/%s", fname, repo, dir)
  end
end
local function _2_()
  return vim.uv.cwd()
end
return harpoon.setup({settings = {key = _2_, save_on_toggle = false, sync_on_ui_close = false}, default = {display = display}})
