-- [nfnl] Compiled from fnl/dropbar.fnl by https://github.com/Olical/nfnl, do not edit.
local M = setmetatable({utils = require("dropbar.utils"), api = require("dropbar.api"), sources = require("dropbar.sources")}, {__index = require("dropbar")})
local general = {update_events = {win = {"CursorMoved", "InsertLeave", "WinResized"}, buf = {"BufModifiedSet", "FileChangedShellPost"}, global = {"DirChanged", "VimResized"}}}
local icons
do
  local kinds = {use_devicons = true, symbols = {Array = "", Boolean = "", BreakStatement = "", Call = "", CaseStatement = "", Class = "", Color = "", Constant = "", Constructor = "", ContinueStatement = "", Copilot = "", Declaration = "", Delete = "", DoStatement = "", Enum = "", EnumMember = "", Event = "", Field = "", File = "", Folder = "", ForStatement = "", Function = "", H1Marker = "", H2Marker = "", H3Marker = "", H4Marker = "", H5Marker = "", H6Marker = "", Identifier = "", IfStatement = "", Interface = "", Keyword = "", List = "", Log = "", Lsp = "", Macro = "", MarkdownH1 = "", MarkdownH2 = "", MarkdownH3 = "", MarkdownH4 = "", MarkdownH5 = "", MarkdownH6 = "", Method = "", Module = "", Namespace = "", Null = "", Number = "", Object = "", Operator = "", Package = "", Pair = "", Property = "", Reference = "", Regex = "", Repeat = "", Scope = "", Snippet = "", Specifier = "", Statement = "", String = "", Struct = "", SwitchStatement = "", Terminal = "", Text = "", Type = "", TypeParameter = "", Unit = "", Value = "fnl/test", Variable = "", WhileStatement = ""}}
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
return M.setup({general = general, icons = icons, bar = bar})
