-- [nfnl] v2/fnl/project.fnl
local project = require("project_nvim")
return project.setup({scope_chdir = "tab", detection_methods = {"pattern"}, patterns = {".git"}, manual_mode = false})
