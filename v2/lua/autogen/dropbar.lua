-- [nfnl] v2/fnl/dropbar.fnl
local dropbar = require("dropbar")
local utils = require("dropbar.utils")
local sources = require("dropbar.sources")
local icons
local function _1_(_path)
  return ""
end
icons = {ui = {bar = {separator = "\239\145\160 ", extends = "\226\128\166"}, menu = {separator = " ", indicator = "\239\145\160 "}}, kinds = {file_icon = _1_, symbols = {Array = "", BlockMappingPair = "", Boolean = "", BreakStatement = "", Call = "", CaseStatement = "", Class = "", Color = "", Constant = "", Constructor = "", ContinueStatement = "", Copilot = "", Declaration = "", Delete = "", DoStatement = "", Element = "", Enum = "", EnumMember = "", Event = "", Field = "", File = "", Folder = "", ForStatement = "", Function = "", GotoStatement = "", Identifier = "", IfStatement = "", Interface = "", Keyword = "", List = "", Log = "", Lsp = "", Macro = "", MarkdownH1 = "\243\176\137\171 ", MarkdownH2 = "\243\176\137\172 ", MarkdownH3 = "\243\176\137\173 ", MarkdownH4 = "\243\176\137\174 ", MarkdownH5 = "\243\176\137\175 ", MarkdownH6 = "\243\176\137\176 ", Method = "", Module = "", Namespace = "", Null = "", Number = "", Object = "", Operator = "", Package = "", Pair = "", Property = "", Reference = "", Regex = "", Repeat = "", Return = "", RuleSet = "", Scope = "", Section = "", Snippet = "", Specifier = "", Statement = "", String = "", Struct = "", SwitchStatement = "", Table = "", Terminal = "", Text = "", Type = "", TypeParameter = "", Unit = "", Value = "", Variable = "", WhileStatement = ""}}}
local bar
local function _2_(buf, _)
  local _3_ = {vim.bo[buf].ft, vim.bo[buf].buftype}
  if ((_3_[1] == "markdown") and true) then
    local _0 = _3_[2]
    return {sources.path, sources.markdown}
  elseif (true and (_3_[2] == "terminal")) then
    local _0 = _3_[1]
    return {sources.terminal}
  else
    local _0 = _3_
    return {sources.path}
  end
end
bar = {attach_events = {"BufWinEnter", "BufWritePost"}, update_events = {win = {"CursorMoved", "WinResized", "InsertLeave"}, buf = {"BufModifiedSet", "FileChangedShellPost"}, global = {"DirChanged", "VimResized"}}, sources = _2_}
local menu
do
  local select
  local function _5_()
    local _6_ = utils.menu.get_current()
    if (nil ~= _6_) then
      local menu0 = _6_
      local cursor = vim.api.nvim_win_get_cursor(menu0.win)
      local component = menu0.entries[cursor[1]]:first_clickable(cursor[2])
      if (nil ~= component) then
        return menu0:click_on(component, nil, 1, "l")
      else
        return nil
      end
    else
      return nil
    end
  end
  select = _5_
  local fuzzy
  local function _9_()
    local _10_ = utils.menu.get_current()
    if (nil ~= _10_) then
      local menu0 = _10_
      return menu0:fuzzy_find_open()
    else
      return nil
    end
  end
  fuzzy = _9_
  menu = {keymaps = {q = "<C-w>q", ["<Esc>"] = "<C-w>q", H = "<C-w>q", L = select, ["<CR>"] = select, i = fuzzy}}
end
local sources0
local _12_
do
  local default_vault = vim.pesc(vim.uv.fs_realpath(vim.fn.fnamemodify((os.getenv("HOME") .. "/vaults/default/"), ":p:h")))
  local function _13_(buf, _win)
    local buf_path = vim.api.nvim_buf_get_name(buf)
    if ((vim.bo[buf].ft == "markdown") and buf_path:find(("^" .. default_vault))) then
      return default_vault
    else
      local found = vim.fs.find({".git"}, {path = buf_path, upward = true})
      if (#found > 0) then
        return vim.fn.fnamemodify(found[1], ":h")
      else
        return vim.fn.getcwd()
      end
    end
  end
  _12_ = _13_
end
sources0 = {path = {relative_to = _12_}}
return dropbar.setup({icons = icons, bar = bar, menu = menu, sources = sources0})
