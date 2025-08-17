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
local path = require("obsidian.path")
local note = require("obsidian.note")
local workspaces = {{name = "default", path = default_vault}}
local daily_notes = {folder = "journal", date_format = "%Y-%m-%d", default_tags = {"journal"}, template = nil}
local completion = {blink = true, min_chars = 1, create_new = true, nvim_cmp = false}
local ui = {ignore_conceal_warn = true}
local callbacks
local function _4_(_, _note)
  local function _5_()
    if api.cursor_link(nil, nil, true) then
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
obsidian.setup({workspaces = workspaces, daily_notes = daily_notes, completion = completion, ui = ui, callbacks = callbacks, statusline = {enabled = false}, footer = {enabled = false}, log_level = vim.log.levels.WARN, legacy_commands = false})
local dir = _G.Obsidian.dir
local opts = _G.Obsidian.opts
local get_branch
local function _8_()
  local out = vim.system({"git", "rev-parse", "--abbrev-ref", "HEAD"}):wait()
  if (out.code == 0) then
    return out.stdout:gsub("%s+", "")
  else
    return error("branch not found")
  end
end
get_branch = _8_
local ObsidianScratch
local function _10_()
  local scratch_path = (path:new(dir) / "scratch.md")
  local id = scratch_path.stem
  local _11_
  if scratch_path:exists() then
    _11_ = note.from_file(scratch_path, opts.load)
  else
    _11_ = note.create({id = id, aliases = {}, tags = {}, dir = scratch_path:parent()}):write({template = nil})
  end
  return _11_:open()
end
ObsidianScratch = _10_
local ObsidianGitBranch
local function _13_()
  local branch = get_branch()
  local rel_path = vim.fs.relpath(vim.fn.expand("~"), vim.fn.getcwd())
  local target = path:new((dir / rel_path / branch))
  local _14_
  if target:exists() then
    _14_ = note.from_file(target, opts.load)
  else
    _14_ = note.create({id = (rel_path .. "/" .. branch), aliases = {}, tags = {vim.fn.fnamemodify(vim.fn.getcwd(), ":t"), branch}, dir = path:parent()}):write({template = nil})
  end
  return _14_:open()
end
ObsidianGitBranch = _13_
for lhs, rhs in pairs({ObsidianScratch = ObsidianScratch, ObsidianGitBranch = ObsidianGitBranch}) do
  vim.api.nvim_create_user_command(lhs, rhs, {})
end
return nil
