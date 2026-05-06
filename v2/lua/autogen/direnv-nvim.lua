-- [nfnl] v2/fnl/direnv-nvim.fnl
if (vim.g.direnv_nvim_original_path == nil) then
  vim.g.direnv_nvim_original_path = (vim.env.PATH or "")
else
end
local function split_path(path)
  if (path and (path ~= "")) then
    return vim.split(path, ":", {plain = true, trimempty = true})
  else
    return {}
  end
end
local function merge_path(current, original)
  local items = split_path(current)
  local seen = {}
  for _, item in ipairs(items) do
    seen[item] = true
  end
  for _, item in ipairs(split_path(original)) do
    if not seen[item] then
      table.insert(items, item)
      seen[item] = true
    else
    end
  end
  return table.concat(items, ":")
end
local function _4_()
  vim.env.PATH = merge_path(vim.env.PATH, vim.g.direnv_nvim_original_path)
  return nil
end
vim.api.nvim_create_autocmd("User", {pattern = "DirenvLoaded", callback = _4_})
return require("direnv").setup({autoload_direnv = true, statusline = {enabled = false}, keybindings = {}, notifications = {silent_autoload = true}})
