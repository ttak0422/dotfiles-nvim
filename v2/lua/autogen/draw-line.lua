-- [nfnl] v2/fnl/draw-line.fnl
local hydra = require("hydra")
local float_opts = {border = "single"}
local saved = {}
hydra.setup({timeout = false})
local function draw(direction)
  return require("draw-line").draw(direction)
end
local function box(style)
  local ok, err = require("draw-line").box_visual(style)
  if not ok then
    return vim.notify(err, vim.log.levels.WARN)
  else
    return nil
  end
end
local heads
local function _2_()
  return draw("h")
end
local function _3_()
  return draw("j")
end
local function _4_()
  return draw("k")
end
local function _5_()
  return draw("l")
end
local function _6_()
  return box("double")
end
local function _7_()
  return box("single")
end
local function _8_()
  return box("heavy")
end
heads = {{"H", _2_}, {"J", _3_}, {"K", _4_}, {"L", _5_}, {"r", _6_, {mode = "x"}}, {"f", _7_, {mode = "x"}}, {"v", _8_, {mode = "x"}}, {"<Esc>", nil, {desc = "close", exit = true}}}
local config
local function _9_()
  saved.win = vim.api.nvim_get_current_win()
  saved.virtualedit = vim.wo.virtualedit
  saved.selection = vim.o.selection
  vim.api.nvim_set_option_value("virtualedit", "all", {scope = "local"})
  return vim.api.nvim_set_option_value("selection", "inclusive", {})
end
local function _10_()
  if vim.api.nvim_win_is_valid(saved.win) then
    vim.api.nvim_set_option_value("virtualedit", saved.virtualedit, {win = saved.win, scope = "local"})
  else
  end
  return vim.api.nvim_set_option_value("selection", saved.selection, {})
end
config = {invoke_on_body = true, color = "pink", on_enter = _9_, on_exit = _10_, hint = {type = "window", position = "bottom-right", float_opts = float_opts}}
local hint = ":Move    Select region with <C-v>\n-------  -------------------------\n   _K_     _r_: surround double\n _H_   _L_   _f_: surround single\n   _J_     _v_: surround bold"
return hydra({name = "Draw Diagram", mode = "n", body = "<Leader>V", heads = heads, config = config, hint = hint})
