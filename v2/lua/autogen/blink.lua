-- [nfnl] Compiled from v2/fnl/blink.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local cmp = require("blink.cmp")
  local keymap = {preset = "default"}
  local appearance = {nerd_font_variant = "mono"}
  local completion = {documentation = {auto_show = false}}
  local sources = {default = {"lsp", "path", "snippets", "buffer"}}
  local fuzzy = {implementation = "prefer_rust_with_warning", use_frecency = true, use_proximity = true, sorts = {"score", "sort_text"}, prebuilt_binaries = {force_version = nil, force_system_triple = nil, extra_curl_args = {}, proxy = {from_env = true, url = nil}, download = false, ignore_version_mismatch = false}, use_unsafe_no_lock = false}
  cmp.setup({keymap = keymap, appearance = appearance, completion = completion, sources = sources, fuzzy = fuzzy})
end
return vim.lsp.config("*", {capabilities = require("blink.cmp").get_lsp_capabilities()})
