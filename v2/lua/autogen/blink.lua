-- [nfnl] v2/fnl/blink.fnl
vim.opt.completeopt = {}
vim.keymap.set("i", "<C-Space>", "<C-n>", {noremap = true})
local cmp = require("blink.cmp")
local types = require("blink.cmp.types")
local keymap
do
  local lsp_provider
  local function _1_(cmp0)
    return cmp0.show({providers = {"lsp"}})
  end
  lsp_provider = _1_
  local path_provider
  local function _2_(cmp0)
    return cmp0.show({providers = {"path"}})
  end
  path_provider = _2_
  keymap = {preset = "none", ["<C-x>l"] = {"show", lsp_provider}, ["<C-x><C-l>"] = {"show", lsp_provider}, ["<C-x>f"] = {"show", path_provider}, ["<C-x><C-f>"] = {"show", path_provider}, ["<C-e>"] = {"hide"}, ["<C-y>"] = {"select_and_accept"}, ["<C-p>"] = {"select_prev", "fallback_to_mappings"}, ["<C-n>"] = {"select_next", "fallback_to_mappings"}, ["<C-b>"] = {"scroll_documentation_up", "fallback"}, ["<C-f>"] = {"scroll_documentation_down", "fallback"}, ["<Tab>"] = {"snippet_forward", "fallback"}, ["<S-Tab>"] = {"snippet_backward", "fallback"}, ["<C-k>"] = {"show_signature", "hide_signature", "fallback"}}
end
local appearance = {nerd_font_variant = "mono"}
local completion = {documentation = {auto_show = false}}
local sources
local function _3_(_, items)
  local function _4_(item)
    return (item.kind ~= types.CompletionItemKind.Keyword)
  end
  return vim.tbl_filter(_4_, items)
end
sources = {default = {"avante", "snippets", "buffer"}, providers = {lsp = {fallbacks = {}, transform_items = _3_}, avante = {module = "blink-cmp-avante", name = "Avante", opts = {}}}}
local fuzzy = {implementation = "prefer_rust_with_warning", use_frecency = true, use_proximity = true, sorts = {"score", "sort_text"}, prebuilt_binaries = {force_version = nil, force_system_triple = nil, extra_curl_args = {}, proxy = {from_env = true, url = nil}, download = false, ignore_version_mismatch = false}, use_unsafe_no_lock = false}
cmp.setup({keymap = keymap, appearance = appearance, completion = completion, sources = sources, fuzzy = fuzzy})
return vim.lsp.config("*", {capabilities = cmp.get_lsp_capabilities()})
