local telescope = require("telescope")
local builtin = require("telescope.builtin")
local config = require("telescope.config")
local state = require("telescope.actions.state")
local actions = require("telescope.actions")
local root = vim.env.HOME .. "/repos/display-repo"
local relative = "nested/unique-file.txt"
local absolute = root .. "/" .. relative
vim.fn.mkdir(root .. "/nested", "p")
vim.fn.writefile({ "unique-content-needle" }, absolute)
vim.fn.system({ "git", "-C", root, "init", "-q" })
vim.fn.system({ "git", "-C", root, "add", relative })
vim.cmd.cd(root)
vim.o.columns, vim.o.lines = 220, 60
assert(vim.deep_equal(config.values.path_display, { "truncate" }))
for _, name in ipairs({ "find_files", "git_files", "oldfiles", "buffers" }) do
  assert(vim.deep_equal(config.pickers[name].path_display, { "filename_first" }), name)
end
for _, name in ipairs({ "live_grep", "grep_string" }) do
  assert(config.pickers[name].path_display == nil, name)
end
local function entry(open, filename_first)
  vim.cmd.stopinsert()
  local previous_prompt = vim.api.nvim_get_current_buf()
  open()
  assert(vim.wait(3000, function()
    local selected = state.get_selected_entry()
    return vim.bo.filetype == "TelescopePrompt"
      and vim.api.nvim_get_current_buf() ~= previous_prompt
      and selected ~= nil
      and (filename_first or selected.text == "unique-content-needle")
  end, 10))
  local e = state.get_selected_entry()
  local display = type(e.display) == "function" and e:display() or e.display
  if filename_first then
    assert(display:find("unique-file.txt", 1, true) < display:find("nested", 1, true), display)
  else
    assert(display:find("nested", 1, true) < display:find("unique-file.txt", 1, true), display)
  end
  assert(e.ordinal:find("nested/unique-file.txt", 1, true), e.ordinal)
  actions.close(vim.api.nvim_get_current_buf())
end
entry(function() builtin.find_files({ cwd = root, previewer = false }) end, true)
entry(function() builtin.git_files({ cwd = root, previewer = false }) end, true)
vim.v.oldfiles = { absolute }
entry(function() builtin.oldfiles({ cwd = root, previewer = false }) end, true)
vim.cmd.edit(vim.fn.fnameescape(absolute))
entry(function() builtin.buffers({ cwd = root, previewer = false }) end, true)
entry(function() builtin.grep_string({ cwd = root, search = "unique-content-needle", previewer = false }) end, false)
-- Display formatting must not rewrite absolute values, search ordinals or action paths.
local maker = require("telescope.make_entry")
for _, filename in ipairs({ relative, absolute }) do
  local plain = maker.gen_from_file({ cwd = root, path_display = { "truncate" } })(filename)
  local first = maker.gen_from_file({ cwd = root, path_display = { "filename_first" } })(filename)
  for _, key in ipairs({ "value", "ordinal", "filename", "path" }) do
    assert(first[key] == plain[key], key)
  end
end
-- ghq keeps its old repository display, then its native Enter opens configured git_files.
local bin = vim.env.HOME .. "/ghq-fixture"
vim.fn.writefile({ "#!/bin/sh", "printf '%s\\n' '" .. root .. "'" }, bin)
vim.fn.setfperm(bin, "rwx------")
telescope.extensions.ghq.list({ bin = bin, cwd = vim.env.HOME, previewer = false })
assert(vim.wait(3000, function() local selected = state.get_selected_entry(); return selected and selected.value == root end, 10))
local e = state.get_selected_entry()
assert(e.value == root and e.ordinal == root and e.path == root)
local display = e:display()
assert(display == "repos/display-repo", display)
actions.select_default(vim.api.nvim_get_current_buf())
assert(vim.wait(3000, function()
  local selected = state.get_selected_entry()
  return selected and selected.value == relative
end, 10))
e = state.get_selected_entry()
display = e:display()
assert(display:find("unique-file.txt", 1, true) < display:find("nested", 1, true), display)
actions.select_default(vim.api.nvim_get_current_buf())
assert(vim.api.nvim_buf_get_name(0) == absolute, "selection path changed")
