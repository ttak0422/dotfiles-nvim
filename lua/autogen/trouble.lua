-- [nfnl] Compiled from fnl/trouble.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("trouble")
local win = {}
local preview = {type = "main", scratch = true}
local throttle = {refresh = 20, update = 10, render = 10, follow = 100, preview = {ms = 100, debounce = true}}
local keys
local function _1_(view)
  return view:filter({buf = 0}, {toggle = true})
end
local function _2_(view)
  local f = view:get_filter("severity")
  local severity
  local function _3_()
    if f then
      return f.filter.severity
    else
      return 0
    end
  end
  severity = ((_3_() + 1) % 5)
  return view:filter({severity = severity}, {id = "severity", template = "{hl:Title}Filter:{hl} {severity}", del = (severity == 0)})
end
keys = {["?"] = "help", r = "refresh", R = "toggle_refresh", q = "close", ["<c-c>"] = "close", o = "jump_close", ["<esc>"] = "cancel", ["<cr>"] = "jump", ["}"] = "next", ["]]"] = "next", ["{"] = "prev", ["[["] = "prev", dd = "delete", d = {action = "delete", mode = "v"}, i = "inspect", p = "preview", P = "toggle_preview", zo = "fold_open", zO = "fold_open_recursive", zc = "fold_close", zC = "fold_close_recursive", za = "fold_toggle", zA = "fold_toggle_recursive", zm = "fold_more", zM = "fold_close_all", zr = "fold_more", zR = "fold_open_all", zx = "fold_update", zX = "fold_update_all", zn = "fold_disable", zN = "fold_enable", zi = "fold_toggle_enable", gb = {action = _1_, desc = "Toggle Current Buffer Filter"}, s = {action = _2_, desc = "Toggle Severity Filter"}}
local modes = {lsp_references = {params = {include_declaration = true}}, lsp_base = {params = {include_current = false}}, symbols = {desc = "document symbols", mode = "lsp_document_symbols", win = {position = "right"}, filter = {["not"] = {ft = "lua", kind = "Package"}, any = {ft = {"help", "markdown"}, kind = {"Class", "Constructor", "Enum", "Field", "Function", "Interface", "Method", "Module", "Namespace", "Package", "Property", "Struct", "Trait"}}}, focus = false}}
local icons = {indent = {top = "\226\148\130 ", middle = "\226\148\156\226\149\180", last = "\226\148\148\226\149\180", fold_open = "\239\145\188 ", fold_closed = "\239\145\160 ", ws = "  "}, folder_closed = "\238\151\191 ", folder_open = "\238\151\190 ", kinds = {Array = "\238\170\138 ", Boolean = "\243\176\168\153 ", Class = "\238\173\155 ", Constant = "\243\176\143\191 ", Constructor = "\239\144\163 ", Enum = "\239\133\157 ", EnumMember = "\239\133\157 ", Event = "\238\170\134 ", Field = "\239\128\171 ", File = "\238\169\187 ", Function = "\243\176\138\149 ", Interface = "\239\131\168 ", Key = "\238\170\147 ", Method = "\243\176\138\149 ", Module = "\239\146\135 ", Namespace = "\243\176\166\174 ", Null = "\238\138\153 ", Number = "\243\176\142\160 ", Object = "\238\170\139 ", Operator = "\238\173\164 ", Package = "\239\146\135 ", Property = "\239\128\171 ", String = "\238\170\177 ", Struct = "\243\176\134\188 ", TypeParameter = "\238\170\146 ", Variable = "\243\176\128\171 "}}
return M.setup({auto_preview = true, auto_refresh = true, restore = true, follow = true, indent_guides = true, max_items = 200, multiline = true, warn_no_results = true, win = win, preview = preview, throttle = throttle, keys = keys, modes = modes, icons = icons, open_no_results = false, pinned = false, auto_jump = false, focus = false, auto_close = false, auto_open = false, debug = false})
