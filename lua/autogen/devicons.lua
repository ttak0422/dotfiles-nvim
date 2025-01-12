-- [nfnl] Compiled from fnl/devicons.fnl by https://github.com/Olical/nfnl, do not edit.
local M = require("nvim-web-devicons")
local override_by_filename = {}
local override_by_extension = {norg = {icon = "\238\152\179", name = "Neorg"}}
return M.setup({override_by_filename = override_by_filename, override_by_extension = override_by_extension, color_icons = false})
