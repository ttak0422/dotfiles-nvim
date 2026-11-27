vim.o.columns, vim.o.lines = 120, 40

-- Keep the actual Track commands and asynchronous Telescope finder, but isolate
-- the vault and note writes. Worktab uses real Neovim tabs.
require("track")
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, "p")
local file = tmp .. "/existing.md"
vim.fn.writefile({ "fixture" }, file)
local cli = tmp .. "/track"
local payload = vim.json.encode({ results = { { title = "foo123", path = file, note_id = 1 } } })
vim.fn.writefile({ "#!/bin/sh", "printf '%s\\n' " .. vim.fn.shellescape(payload) }, cli)
vim.fn.setfperm(cli, "rwx------")
require("track.client").bin = function() return cli end
package.loaded["track.vault"] = { current_name = function() return "" end }
local created, opened = {}, {}
package.loaded["track.create"] = { create = function(title) created[#created + 1] = title end }
require("track.editor_view").open = function(path) opened[#opened + 1] = path; return true end

local function picker()
  local buf = vim.api.nvim_get_current_buf()
  assert(vim.bo[buf].filetype == "TelescopePrompt")
  return buf, require("telescope.actions.state").get_current_picker(buf)
end
local function press(key, mode)
  local callback = vim.fn.maparg(key, mode or "i", false, true).callback
  assert(type(callback) == "function", "missing mapping: " .. key)
  callback()
end
local function selected(value, track_picker)
  assert(vim.wait(5000, function()
    local entry = require("telescope.actions.state").get_selected_entry()
    return entry and value(entry.value)
      and (not track_picker or (track_picker.finder:can_select("foo") and track_picker.finder:owns(entry)))
  end, 10), "fixture result was not selected")
end

assert(not package.loaded.telescope, "Track setup loaded Telescope before its first search")
vim.cmd("Track search_title foo")
local _, title = picker()
selected(function(value) return value.path == file end, title)
title:set_prompt("  exact title  ")
press("<C-o>", "n")
assert(vim.deep_equal(created, { "exact title" }) and #opened == 0)

vim.cmd("Track search_body foo")
local buf, body = picker()
selected(function(value) return value.path == file end, body)
body:set_prompt("   ")
press("<C-o>")
assert(vim.api.nvim_buf_is_valid(buf) and #created == 1)
body:set_prompt("exact body")
press("<C-o>")
assert(vim.deep_equal(created, { "exact title", "exact body" }))

vim.cmd("Telescope track search_body default_text=foo")
local _, extension_body = picker()
extension_body:set_prompt("from extension")
press("<C-o>")
assert(vim.deep_equal(created, { "exact title", "exact body", "from extension" }))

vim.cmd("Telescope track search_title default_text=foo")
local _, extension_search = picker()
selected(function(value) return value.path == file end, extension_search)
press("<CR>")
assert(vim.deep_equal(opened, { file }), "Track Enter no longer opens the selected note")

local worktab = require("worktab")
local home = vim.api.nvim_get_current_tabpage()
local longer = worktab.tabnew("foo123")
vim.api.nvim_set_current_tabpage(home)
vim.cmd("Telescope worktab default_text=foo")
picker()
selected(function(value) return value.handle == longer end)
press("<C-o>")
local exact = vim.api.nvim_get_current_tabpage()
assert(exact ~= longer and worktab.get_name() == "foo")
local count = #vim.api.nvim_list_tabpages()
vim.api.nvim_set_current_tabpage(home)
vim.cmd("Telescope worktab default_text=foo123")
local tab_prompt, tabs = picker()
tabs:set_prompt("  ")
press("<C-o>", "n")
assert(vim.api.nvim_get_current_buf() == tab_prompt and #vim.api.nvim_list_tabpages() == count)
tabs:set_prompt("foo")
press("<C-o>", "n")
assert(vim.api.nvim_get_current_tabpage() == exact and #vim.api.nvim_list_tabpages() == count)
vim.api.nvim_set_current_tabpage(home)
vim.cmd("Telescope worktab default_text=foo123")
picker()
selected(function(value) return value.handle == longer end)
press("<CR>")
assert(vim.api.nvim_get_current_tabpage() == longer and #vim.api.nvim_list_tabpages() == count)

vim.fn.delete(tmp, "rf")
