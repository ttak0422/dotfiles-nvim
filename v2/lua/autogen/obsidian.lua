-- [nfnl] v2/fnl/obsidian.fnl
local function dir_3f(path)
  local tmp_3_ = vim.uv.fs_stat(path)
  if (nil ~= tmp_3_) then
    local tmp_3_0 = tmp_3_[type]
    if (nil ~= tmp_3_0) then
      return (tmp_3_0 == "directory")
    else
      return nil
    end
  else
    return nil
  end
end
local default_vault = vim.fn.fnamemodify((os.getenv("HOME") .. "/vaults/default/"), ":p:h")
if not dir_3f(default_vault) then
  vim.fn.mkdir(default_vault, "p")
else
end
local obsidian = require("obsidian")
local workspaces = {{name = "default", path = default_vault}}
local daily_notes = {folder = "notes/journal", date_format = "%Y-%m-%d", alias_format = "%B %-d %Y", default_tags = {"journal"}, template = nil}
local completion = {blink = true, min_chars = 2, create_new = true, nvim_cmp = false}
return obsidian.setup({workspaces = workspaces, daily_notes = daily_notes, completion = completion, notes_subdir = "notes", log_level = vim.log.levels.WARN})
