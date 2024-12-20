-- [nfnl] Compiled from fnl/other.fnl by https://github.com/Olical/nfnl, do not edit.
local other = require("other-nvim")
local window = require("other-nvim.helper.window")
local util = require("other-nvim.helper.util")
local builtinMappings = require("other-nvim.builtin.mappings")
local transformers = require("other-nvim.builtin.transformers")
local mappings = {"golang", {context = "test file nested", pattern = "/src/main/(.*)/(.*)%.java$", target = "/src/test/%1/%2Test.java"}, {context = "sut file nested", pattern = "/src/test/(.*)/(.*)Test%.java$", target = "/src/main/%1/%2.java"}, {context = "sut file nested", pattern = "/src/test/(.*)/(.*)Tests%.java$", target = "/src/main/%1/%2.java"}, {pattern = "(.*).([tj]sx?)$", target = "%1.test.%2", context = "test"}, {pattern = "(.*).([tj]sx?)$", target = "%1.spec.%2", context = "spec"}, {pattern = "(.*).test.([tj]sx?)$", target = "%1.%2", context = "implementation"}, {pattern = "(.*).spec.([tj]sx?)$", target = "%1.%2", context = "implementation"}}
local transformers0 = {camelToKebap = transformers.camelToKebap, kebapToCamel = transformers.kebapToCamel, pluralize = transformers.pluralize, singularize = transformers.singularize}
local keybindings = {["<cr>"] = "open_file_by_command()", ["<esc>"] = "close_window()", q = "close_window()", ["<C-c>"] = "close_window()", o = "open_file()", t = "open_file_tabnew()", v = "open_file_vs()", s = "open_file_sp()"}
local style = {border = "none", seperator = "|", newFileIndicator = "(* new *)", width = 0.7, minHeight = 2}
return other.setup({showMissingFiles = true, rememberBuffers = true, mappings = mappings, transformers = transformers0, keybindings = keybindings, style = style})
