-- [nfnl] v2/fnl/other.fnl
local other = require("other-nvim")
local transformers = require("other-nvim.builtin.transformers")
local mappings = {"c", "clojure", "elixir", "golang", "python", "react", "rust"}
local transformers0 = {camelToKebap = transformers.camelToKebap, kebapToCamel = transformers.kebapToCamel, pluralize = transformers.pluralize, singularize = transformers.singularize}
local keybindings = {["<cr>"] = "open_file_by_command()", ["<esc>"] = "close_window()", ["<C-w>o"] = "open_file()", ["<C-w>t"] = "open_file_tabnew()", ["<C-w>q"] = "close_window()", ["<C-w>v"] = "open_file_vs()", ["<C-w>s"] = "open_file_sp()"}
return other.setup({showMissingFiles = true, mappings = mappings, transformers = transformers0, keybindings = keybindings, rememberBuffers = false})
