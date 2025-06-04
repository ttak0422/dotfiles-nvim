-- [nfnl] v2/fnl/after/ftplugin/norg.fnl
for k, v in pairs({conceallevel = 3, concealcursor = "n", swapfile = false, wrap = false}) do
  vim.opt_local[k] = v
end
vim.opt_local.iskeyword:append({"$", "/"})
local opts = {noremap = true, silent = true}
local function desc(d)
  return {silent = true, buffer = true, desc = d, noremap = false}
end
local function skip_next_update()
  return require("neorg.core.modules").get_module("core.esupports.metagen").skip_next_update()
end
local function feed_keys(ks)
  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(ks, true, false, true), "n", false)
end
local normal
local function _1_()
  skip_next_update()
  return feed_keys("u<C-o>")
end
local function _2_()
  skip_next_update()
  return feed_keys("<C-r><C-o>")
end
normal = {{"u", _1_, desc("\238\152\179 undo")}, {"<C-r>", _2_, desc("\238\152\179 redo")}, {"<LocalLeader>nn", "<Plug>(neorg.dirman.new-note)", desc("\238\152\179 Create a new note")}, {"<LocalLeader>no", "<Cmd>Neorg toc<CR>", desc("\238\152\179 TOC")}, {"<LocalLeader>tu", "<Plug>(neorg.qol.todo-items.todo.task-undone)", desc("\238\152\179 Mark as undone")}, {"<LocalLeader>tp", "<Plug>(neorg.qol.todo-items.todo.task-pending)", desc("\238\152\179 Mark as pending")}, {"<LocalLeader>td", "<Plug>(neorg.qol.todo-items.todo.task-done)", desc("\238\152\179 Mark as done")}, {"<LocalLeader>th", "<Plug>(neorg.qol.todo-items.todo.task-on-hold)", desc("\238\152\179 Mark as on hold")}, {"<LocalLeader>tc", "<Plug>(neorg.qol.todo-items.todo.task-cancelled)", desc("\238\152\179 Mark as on cancelled")}, {"<LocalLeader>tr", "<Plug>(neorg.qol.todo-items.todo.task-recurring)", desc("\238\152\179 Mark as recurring")}, {"<LocalLeader>ti", "<Plug>(neorg.qol.todo-items.todo.task-important)", desc("\238\152\179 Mark as important")}, {"<LocalLeader>ta", "<Plug>(neorg.qol.todo-items.todo.task-ambiguous)", desc("\238\152\179 Mark as ambiguous")}, {"<C-Space>", "<Plug>(neorg.qol.todo-items.todo.task-cycle)", desc("\238\152\179 Cycle task")}, {"<CR>", "<Plug>(neorg.esupports.hop.hop-link)", desc("\238\152\179 Jump to link")}, {"<LocalLeader>lt", "<Plug>(neorg.pivot.list.toggle)", desc("\238\152\179 Toggle (un)ordered list")}, {"<LocalLeader>li", "<Plug>(neorg.pivot.list.invert)", desc("\238\152\179 Invert (un)ordered list")}, {"<LocalLeader>E", "<Plug>(neorg.looking-glass.magnify-code-block)", desc("\238\152\179 Edit code block")}, {"<LocalLeader>id", "<Plug>(neorg.tempus.insert-date)", desc("\238\152\179 Insert date")}, {"<LocalLeader>O", ":execute 'Neorg export to-file ' . expand('%:r') . '.md'<cr>", desc("\238\152\179 Export as markdown")}}
local insert = {{"<C-t>", "<C-o><Plug>(neorg.promo.promote)", desc("\238\152\179 Promote object")}, {"<C-d>", "<C-o><Plug>(neorg.promo.demote)", desc("\238\152\179 Demote object")}}
local visual = {{">", "<Plug>(neorg.promo.promote.range)", desc("\238\152\179 Promote range")}, {"<", "<Plug>(neorg.promo.demote.range)", desc("\238\152\179 Demote range")}, {"<LocalLeader>C", ":Neorg export to-clipboard markdown<cr>", desc("\238\152\179 Export to clipboard")}}
for mode, ks in pairs({n = normal, i = insert, v = visual}) do
  for _, k in ipairs(ks) do
    vim.keymap.set(mode, k[1], k[2], (k[3] or opts))
  end
end
return nil
