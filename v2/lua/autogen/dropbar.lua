-- [nfnl] v2/fnl/dropbar.fnl
local dropbar = require("dropbar")
local api = require("dropbar.api")
local utils = require("dropbar.utils")
local sources = require("dropbar.sources")
local icons
local function _1_(_path)
  return ""
end
icons = {ui = {bar = {separator = "\239\145\160 ", extends = "\226\128\166"}, menu = {separator = " ", indicator = "\239\145\160 "}}, kinds = {file_icon = _1_, symbols = {Array = "", BlockMappingPair = "", Boolean = "", BreakStatement = "", Call = "", CaseStatement = "", Class = "", Color = "", Constant = "", Constructor = "", ContinueStatement = "", Copilot = "", Declaration = "", Delete = "", DoStatement = "", Element = "", Enum = "", EnumMember = "", Event = "", Field = "", File = "", Folder = "", ForStatement = "", Function = "", GotoStatement = "", Identifier = "", IfStatement = "", Interface = "", Keyword = "", List = "", Log = "", Lsp = "", Macro = "", MarkdownH1 = "", MarkdownH2 = "", MarkdownH3 = "", MarkdownH4 = "", MarkdownH5 = "", MarkdownH6 = "", Method = "", Module = "", Namespace = "", Null = "", Number = "", Object = "", Operator = "", Package = "", Pair = "", Property = "", Reference = "", Regex = "", Repeat = "", Return = "", RuleSet = "", Scope = "", Section = "", Snippet = "", Specifier = "", Statement = "", String = "", Struct = "", SwitchStatement = "", Table = "", Terminal = "", Text = "", Type = "", TypeParameter = "", Unit = "", Value = "", Variable = "", WhileStatement = ""}}}
local bar
local function _2_(buf, _)
  local _3_ = {vim.bo[buf].ft, vim.bo[buf].buftype}
  if (true and (_3_[2] == "terminal")) then
    local _0 = _3_[1]
    return {sources.terminal}
  else
    local _0 = _3_
    return {sources.path}
  end
end
bar = {attach_events = {"BufWinEnter", "BufWritePost"}, update_events = {win = {"WinResized"}, buf = {}, global = {"DirChanged", "VimResized"}}, sources = _2_}
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
  local find
  local function _13_(path)
    return vim.fs.find({".git"}, {path = path, upward = true})
  end
  find = _13_
  local function _14_(buf, _win)
    local path = vim.api.nvim_buf_get_name(buf)
    local ft
    do
      local t_15_ = vim.bo[buf]
      if (nil ~= t_15_) then
        t_15_ = t_15_.ft
      else
      end
      ft = t_15_
    end
    local _17_
    if (ft == "markdown") then
      local vault = (vim.uv.fs_realpath(vim.fn.fnamemodify((os.getenv("HOME") .. "/vaults/default/"), ":p:h")) or "")
      if vim.startswith(path, vault) then
        _17_ = vault
      else
        _17_ = nil
      end
    else
      if ((ft == "java") or (ft == "kotlin") or (ft == "scala")) then
        local root = vim.fn.fnamemodify((find(path)[1] or ""), ":h")
        for _, p in pairs({"/src/main/java", "/src/main/kotlin", "/src/main/scala", "/src/test/java", "/src/test/kotlin", "/src/test/scala"}) do
          local l = (root .. p)
          if vim.startswith(path, l) then
            return l
          else
          end
        end
        _17_ = nil
      else
        _17_ = nil
      end
    end
    local or_24_ = _17_
    if not or_24_ then
      local found = find(path)
      if (#found > 0) then
        or_24_ = vim.fn.fnamemodify(found[1], ":h")
      else
        or_24_ = nil
      end
    end
    return or_24_
  end
  _12_ = _14_
end
sources0 = {path = {relative_to = _12_}}
dropbar.setup({icons = icons, bar = bar, menu = menu, sources = sources0})
return vim.keymap.set("n", "gB", api.pick, {noremap = true, silent = true, desc = "pick file"})
