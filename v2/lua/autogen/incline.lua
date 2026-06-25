-- [nfnl] v2/fnl/incline.fnl
local incline = require("incline")
local ignored_buftypes = {nofile = true, prompt = true, help = true, quickfix = true}
local git_root_cache = {}
local function buf_git_root(name)
  if (name == "") then
    return nil
  else
    local cached = git_root_cache[name]
    if (cached == nil) then
      local root = (vim.fs.root(name, {".git"}) or false)
      git_root_cache[name] = root
      if (root == false) then
        return nil
      else
        return root
      end
    else
      if (cached == false) then
        return nil
      else
        return cached
      end
    end
  end
end
local maven_prefixes = {java = {"src/main/java/", "src/test/java/"}, kotlin = {"src/main/kotlin/", "src/test/kotlin/"}, scala = {"src/main/scala/", "src/test/scala/"}}
local function highlighted(text, group)
  return {text, group = group}
end
local function emphasized(text, color)
  return {text, guifg = color, gui = "bold"}
end
local function normalize_path(path, filetype)
  local result = path
  for _, prefix in ipairs((maven_prefixes[filetype] or {})) do
    if vim.startswith(result, prefix) then
      result = string.sub(result, (#prefix + 1))
    else
    end
  end
  return result
end
local function file_context(buf, win)
  local name = vim.api.nvim_buf_get_name(buf)
  local git_root = buf_git_root(name)
  local filename = vim.fn.fnamemodify(name, ":t")
  local relative
  if git_root then
    relative = string.sub(name, (#git_root + 2))
  else
    relative = vim.fn.fnamemodify(name, ":.")
  end
  local path = normalize_path(vim.fn.fnamemodify(relative, ":h"), vim.bo[buf].filetype)
  local path0
  if (vim.api.nvim_win_get_width(win) < 100) then
    path0 = vim.fn.pathshorten(path)
  else
    path0 = path
  end
  local _8_
  if (filename == "") then
    _8_ = "[No Name]"
  else
    _8_ = filename
  end
  return {filename = _8_, path = path0}
end
local function append_git(result, buf)
  local status
  do
    local t_10_ = vim.b
    if (nil ~= t_10_) then
      t_10_ = t_10_[buf]
    else
    end
    if (nil ~= t_10_) then
      t_10_ = t_10_.gitsigns_status_dict
    else
    end
    status = t_10_
  end
  if status then
    for _, change in ipairs({{"added", " \239\145\151 ", vim.g.terminal_color_10}, {"changed", " \239\145\153 ", vim.g.terminal_color_12}, {"removed", " \239\145\152 ", vim.g.terminal_color_9}}) do
      local key = change[1]
      local icon = change[2]
      local color = change[3]
      local count = (status[key] or 0)
      if (count > 0) then
        table.insert(result, emphasized((icon .. count), color))
      else
      end
    end
    return nil
  else
    return nil
  end
end
local function append_diagnostics(result, buf)
  for _, diagnostic in ipairs({{vim.diagnostic.severity.ERROR, " \239\129\151 ", "DiagnosticError"}, {vim.diagnostic.severity.WARN, " \239\129\177 ", "DiagnosticWarn"}}) do
    local severity = diagnostic[1]
    local icon = diagnostic[2]
    local group = diagnostic[3]
    local count = #vim.diagnostic.get(buf, {severity = severity})
    if (count > 0) then
      table.insert(result, highlighted((icon .. count), group))
    else
    end
  end
  return nil
end
local function append_window_context(result, props)
  if props.focused then
    table.insert(result, " ")
    do
      local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      local function _16_()
        if (cwd == "") then
          return "ROOT"
        else
          return cwd
        end
      end
      table.insert(result, _16_())
    end
    do
      local status
      do
        local t_17_ = vim.b
        if (nil ~= t_17_) then
          t_17_ = t_17_[props.buf]
        else
        end
        if (nil ~= t_17_) then
          t_17_ = t_17_.gitsigns_status_dict
        else
        end
        status = t_17_
      end
      if status then
        local head = (status.head or "")
        local dirty = (((status.added or 0) + (status.changed or 0) + (status.removed or 0)) > 0)
        if (head ~= "") then
          local _20_
          if dirty then
            _20_ = "*"
          else
            _20_ = ""
          end
          table.insert(result, (" (" .. head .. _20_ .. ")"))
        else
        end
      else
      end
    end
    local _let_24_ = vim.api.nvim_win_get_cursor(props.win)
    local line = _let_24_[1]
    local column = _let_24_[2]
    return table.insert(result, highlighted((" " .. string.format("%4d,%-3d", line, (column + 1)) .. " "), "WinBar"))
  else
    return nil
  end
end
local function render(props)
  local filetype = vim.bo[props.buf].filetype
  if not (vim.startswith(filetype, "git") or (filetype == "Trouble") or (filetype == "skk-terminal-input")) then
    local _let_26_ = file_context(props.buf, props.win)
    local filename = _let_26_.filename
    local path = _let_26_.path
    local result = {" "}
    if vim.bo[props.buf].modified then
      table.insert(result, highlighted("\239\145\132 ", "DiagnosticWarn"))
    else
    end
    append_git(result, props.buf)
    append_diagnostics(result, props.buf)
    table.insert(result, " ")
    table.insert(result, highlighted(filename, "Title"))
    if ((path ~= "") and (path ~= ".")) then
      table.insert(result, " ")
      table.insert(result, highlighted(path, "WinBar"))
    else
    end
    append_window_context(result, props)
    return result
  else
    return nil
  end
end
local function _30_(_, buftype)
  return (ignored_buftypes[buftype] ~= nil)
end
incline.setup({window = {padding = 0, margin = {horizontal = 0, vertical = 0}, zindex = 30, placement = {horizontal = "right", vertical = "top"}}, hide = {cursorline = "smart", focused_win = false, only_win = false}, ignore = {floating_wins = true, buftypes = _30_, filetypes = {"Trouble", "skk-terminal-input"}, unlisted_buffers = false}, highlight = {groups = {InclineNormal = {group = "WinBar", default = false}, InclineNormalNC = {group = "WinBarNC", default = false}}}, render = render})
local group = vim.api.nvim_create_augroup("incline-user-refresh", {clear = true})
local refresh
local function _31_()
  return vim.schedule(incline.refresh)
end
refresh = _31_
vim.api.nvim_create_autocmd({"BufModifiedSet", "DiagnosticChanged", "DirChanged"}, {group = group, callback = refresh})
return vim.api.nvim_create_autocmd("User", {group = group, pattern = "GitSignsUpdate", callback = refresh})
