-- [nfnl] v2/fnl/blink.fnl
vim.opt.completeopt = {}
vim.keymap.set("i", "<C-Space>", "<C-n>", {noremap = true})
local cmp = require("blink.cmp")
local types = require("blink.cmp.types")
local keymap = {preset = "none", ["<C-e>"] = {"hide"}, ["<C-y>"] = {"select_and_accept"}, ["<C-p>"] = {"select_prev", "fallback_to_mappings"}, ["<C-n>"] = {"select_next", "fallback_to_mappings"}, ["<C-b>"] = {"scroll_documentation_up", "fallback"}, ["<C-f>"] = {"scroll_documentation_down", "fallback"}, ["<Tab>"] = {"snippet_forward", "fallback"}, ["<S-Tab>"] = {"snippet_backward", "fallback"}, ["<C-k>"] = {"show_signature", "hide_signature", "fallback"}}
local completion = {accept = {auto_brackets = {enabled = true, force_allow_filetypes = {}, blocked_filetypes = {}}, resolve_timeout_ms = 150}, documentation = {auto_show = true, auto_show_delay_ms = 750, update_delay_ms = 100, treesitter_highlighting = true}, keyword = {range = "prefix"}, menu = {draw = {columns = {{"kind_icon"}, {"label", "label_description"}}}}}
local appearance = {nerd_font_variant = "mono", kind_icons = {Text = "\243\176\137\191", Method = "\243\176\138\149", Function = "\243\176\138\149", Constructor = "\243\176\146\147", Field = "\243\176\156\162", Variable = "\243\176\128\171", Property = "\243\176\156\162", Class = "\243\176\160\177", Interface = "\239\131\168", Struct = "\243\176\153\133", Module = "\239\146\135", Unit = "\238\170\150", Value = "\243\176\142\160", Enum = "\239\133\157", EnumMember = "\239\133\157", Keyword = "\243\176\140\139", Constant = "\243\176\143\191", Snippet = "\239\145\143", Color = "\243\176\143\152", File = "\243\176\136\148", Reference = "\243\176\136\135", Folder = "\243\176\137\139", Event = "\243\177\144\139", Operator = "\243\176\134\149", TypeParameter = "\243\176\151\180"}}
local sources
local function _1_(ctx)
  local _2_ = ctx.trigger.initial_kind
  if (_2_ == "trigger_character") then
    return 0
  elseif (_2_ == "manual") then
    return 0
  else
    local _ = _2_
    return 100
  end
end
local function _4_(_, items)
  local function _5_(item)
    return (item.kind ~= types.CompletionItemKind.Keyword)
  end
  return vim.tbl_filter(_5_, items)
end
local function _6_(ctx)
  return (ctx.trigger.initial_kind ~= "trigger_character")
end
local function _7_(_ctx)
  return 2
end
sources = {default = {"avante", "lsp", "snippets", "buffer"}, providers = {lsp = {fallbacks = {}, min_keyword_length = _1_, transform_items = _4_}, avante = {module = "blink-cmp-avante", name = "Avante", opts = {}}, snippets = {should_show_items = _6_}}, min_keyword_length = _7_}
local snippets = {preset = "luasnip"}
local fuzzy = {implementation = "rust", use_frecency = true, use_proximity = true, sorts = {"score", "sort_text"}, prebuilt_binaries = {force_version = nil, force_system_triple = nil, extra_curl_args = {}, proxy = {from_env = true, url = nil}, download = false, ignore_version_mismatch = false}, use_unsafe_no_lock = false}
cmp.setup({completion = completion, appearance = appearance, fuzzy = fuzzy, keymap = keymap, sources = sources, snippets = snippets})
vim.lsp.config("*", {capabilities = cmp.get_lsp_capabilities()})
local opts = {noremap = true, silent = true}
local lsp_provider
local function _8_()
  return cmp.show({providers = {"lsp"}})
end
lsp_provider = _8_
local path_provider
local function _9_()
  return cmp.show({providers = {"path"}})
end
path_provider = _9_
for _, k in ipairs({{"<C-x>l", lsp_provider}, {"<C-x><C-l>", lsp_provider}, {"<C-x>f", path_provider}, {"<C-x><C-f>", path_provider}}) do
  vim.keymap.set("i", k[1], k[2], (k[3] or opts))
end
return nil
