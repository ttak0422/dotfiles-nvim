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
local api = require("obsidian.api")
local workspaces = {{name = "default", path = default_vault}}
local daily_notes = {folder = "journal", date_format = "%Y-%m-%d", default_tags = {"journal"}, template = nil}
local completion = {blink = true, min_chars = 2, create_new = true, nvim_cmp = false}
local ui = {ignore_conceal_warn = true}
local callbacks
local function _4_(_, _note)
  local function _5_()
    if api.cursor_on_markdown_link(nil, nil, true) then
      return vim.cmd("Obsidian follow_link")
    else
      if api.cursor_tag() then
        return vim.cmd("Obsidian tags")
      else
        return nil
      end
    end
  end
  return vim.keymap.set("n", "<CR>", _5_, {expr = true, buffer = true, desc = "Obsidian Smart Action"})
end
callbacks = {enter_note = _4_}
return obsidian.setup({workspaces = workspaces, daily_notes = daily_notes, completion = completion, ui = ui, callbacks = callbacks, footer = {enabled = false}, log_level = vim.log.levels.WARN})
