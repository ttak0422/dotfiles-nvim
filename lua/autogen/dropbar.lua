-- [nfnl] Compiled from fnl/dropbar.fnl by https://github.com/Olical/nfnl, do not edit.
local M = setmetatable({utils = require("dropbar.utils"), api = require("dropbar.api"), sources = require("dropbar.sources")}, {__index = require("dropbar")})
local general = {update_events = {win = {"CursorMoved", "InsertLeave", "WinResized"}, buf = {"BufModifiedSet", "FileChangedShellPost"}, global = {"DirChanged", "VimResized"}}}
local icons
do
  local kinds = {use_devicons = true, symbols = {Array = "", Boolean = "", BreakStatement = "", Call = "", CaseStatement = "", Class = "", Color = "", Constant = "", Constructor = "", ContinueStatement = "", Copilot = "", Declaration = "", Delete = "", DoStatement = "", Enum = "", EnumMember = "", Event = "", Field = "", File = "", Folder = "", ForStatement = "", Function = "", H1Marker = "", H2Marker = "", H3Marker = "", H4Marker = "", H5Marker = "", H6Marker = "", Identifier = "", IfStatement = "", Interface = "", Keyword = "", List = "", Log = "", Lsp = "", Macro = "", MarkdownH1 = "", MarkdownH2 = "", MarkdownH3 = "", MarkdownH4 = "", MarkdownH5 = "", MarkdownH6 = "", Method = "", Module = "", Namespace = "", Null = "", Number = "", Object = "", Operator = "", Package = "", Pair = "", Property = "", Reference = "", Regex = "", Repeat = "", Scope = "", Snippet = "", Specifier = "", Statement = "", String = "", Struct = "", SwitchStatement = "", Terminal = "", Text = "", Type = "", TypeParameter = "", Unit = "", Value = "", Variable = "", WhileStatement = ""}}
  local ui = {bar = {separator = " \226\150\184 ", extends = "\226\128\166"}, menu = {separator = " ", indicator = " \226\150\184 "}}
  icons = {enable = true, kinds = kinds, ui = ui}
end
local bar
local function _1_(buf, _)
  print(vim.bo[buf].buftype)
  if (vim.bo[buf].buftype == "terminal") then
    return {M.sources.terminal}
  else
    return {M.sources.path}
  end
end
bar = {sources = _1_}
local sources = {path = {preview = false}}
local menu
do
  local select
  local function _3_()
    local _4_ = M.utils.menu.get_current()
    if (nil ~= _4_) then
      local menu0 = _4_
      local cursor = vim.api.nvim_win_get_cursor(menu0.win)
      local component = menu0.entries[cursor[1]]:first_clickable(cursor[2])
      if (nil ~= component) then
        return menu0:click_on(component, nil, 1, "l")
      else
        return nil
      end
    else
      local _ = _4_
      return nil
    end
  end
  select = _3_
  local fuzzy
  local function _7_()
    local _8_ = M.utils.menu.get_current()
    if (nil ~= _8_) then
      local menu0 = _8_
      return menu0:fuzzy_find_open()
    else
      local _ = _8_
      return nil
    end
  end
  fuzzy = _7_
  menu = {keymaps = {q = "<C-w>q", ["<Esc>"] = "<C-w>q", ["<CR>"] = select, H = "<C-w>q", L = select, i = fuzzy}, scrollbar = {enable = true}}
end
return M.setup({general = general, icons = icons, bar = bar, sources = sources, menu = menu})
