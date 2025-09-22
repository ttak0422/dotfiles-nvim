-- [nfnl] v2/fnl/blink.fnl
vim.opt.completeopt = {}
for lhs, rhs in pairs({["<C-Space>"] = "<C-n>", ["<C-S-Space>"] = "<C-p>", ["<C-a>"] = "<Home>", ["<C-e>"] = "<End>"}) do
  vim.keymap.set("i", lhs, rhs, {noremap = true})
end
local cmp = require("blink.cmp")
local types = require("blink.cmp.types")
local keymap
local function _1_(cmp0)
  if cmp0.is_visible() then
    return cmp0.hide()
  else
    return true
  end
end
keymap = {preset = "none", ["<C-e>"] = {_1_, "fallback_to_mappings"}, ["<C-y>"] = {"select_and_accept"}, ["<C-p>"] = {"select_prev", "fallback_to_mappings"}, ["<C-n>"] = {"select_next", "fallback_to_mappings"}, ["<C-b>"] = {"scroll_documentation_up", "fallback"}, ["<C-f>"] = {"scroll_documentation_down", "fallback"}, ["<Tab>"] = {"snippet_forward", "fallback"}, ["<S-Tab>"] = {"snippet_backward", "fallback"}, ["<C-k>"] = {"show_signature", "hide_signature", "fallback"}}
local signature = {enabled = true}
local completion = {accept = {auto_brackets = {enabled = true, force_allow_filetypes = {}, blocked_filetypes = {"kotlin"}}, resolve_timeout_ms = 150}, documentation = {auto_show = true, auto_show_delay_ms = 750, update_delay_ms = 100, treesitter_highlighting = true}, keyword = {range = "prefix"}, menu = {draw = {columns = {{"kind_icon"}, {"label", "label_description"}}}}}
local appearance = {nerd_font_variant = "mono", kind_icons = {Text = "\243\176\137\191", Method = "\243\176\138\149", Function = "\243\176\138\149", Constructor = "\243\176\146\147", Field = "\243\176\156\162", Variable = "\243\176\128\171", Property = "\243\176\156\162", Class = "\243\176\160\177", Interface = "\239\131\168", Struct = "\243\176\153\133", Module = "\239\146\135", Unit = "\238\170\150", Value = "\243\176\142\160", Enum = "\239\133\157", EnumMember = "\239\133\157", Keyword = "\243\176\140\139", Constant = "\243\176\143\191", Snippet = "\239\145\143", Color = "\243\176\143\152", File = "\243\176\136\148", Reference = "\243\176\136\135", Folder = "\243\176\137\139", Event = "\243\177\144\139", Operator = "\243\176\134\149", TypeParameter = "\243\176\151\180"}}
local cmdline
do
  local search_src = {"buffer"}
  local cmd_src = {"cmdline", "buffer"}
  local function _3_()
    local _4_ = vim.fn.getcmdtype()
    if (_4_ == "/") then
      return search_src
    elseif (_4_ == "?") then
      return search_src
    elseif (_4_ == ":") then
      return cmd_src
    elseif (_4_ == "@") then
      return cmd_src
    else
      return nil
    end
  end
  cmdline = {enabled = true, keymap = {preset = "cmdline"}, sources = _3_}
end
local sources
local function _6_(ctx)
  local _7_ = ctx.trigger.initial_kind
  if (_7_ == "trigger_character") then
    return 0
  elseif (_7_ == "manual") then
    return 0
  else
    local _ = _7_
    return 100
  end
end
local function _9_(_, items)
  local function _10_(item)
    return (item.kind ~= types.CompletionItemKind.Keyword)
  end
  return vim.tbl_filter(_10_, items)
end
local function _11_(ctx)
  return (ctx.trigger.initial_kind ~= "trigger_character")
end
local function _12_(_ctx)
  return 2
end
sources = {default = {"avante", "lsp", "snippets", "buffer"}, per_filetype = {AvanteInput = {"avante", "buffer"}}, providers = {lsp = {fallbacks = {}, min_keyword_length = _6_, transform_items = _9_}, avante = {module = "blink-cmp-avante", name = "Avante", opts = {}}, snippets = {should_show_items = _11_}}, min_keyword_length = _12_}
local snippets = {preset = "luasnip"}
local fuzzy = {implementation = "rust", frecency = {enabled = true, path = (vim.fn.stdpath("state") .. "/blink/cmp/frecency.dat"), unsafe_no_lock = false}, use_proximity = true, sorts = {"score", "sort_text"}, prebuilt_binaries = {force_version = nil, force_system_triple = nil, extra_curl_args = {}, proxy = {from_env = true, url = nil}, download = false, ignore_version_mismatch = false}}
cmp.setup({completion = completion, signature = signature, appearance = appearance, fuzzy = fuzzy, keymap = keymap, sources = sources, snippets = snippets, cmdline = cmdline})
vim.lsp.config("*", {capabilities = cmp.get_lsp_capabilities()})
local opts = {noremap = true, silent = true}
local lsp_provider
local function _13_()
  return cmp.show({providers = {"lsp"}})
end
lsp_provider = _13_
local path_provider
local function _14_()
  return cmp.show({providers = {"path"}})
end
path_provider = _14_
for _, k in ipairs({{"<C-x>l", lsp_provider}, {"<C-x><C-l>", lsp_provider}, {"<C-x>f", path_provider}, {"<C-x><C-f>", path_provider}}) do
  vim.keymap.set("i", k[1], k[2], (k[3] or opts))
end
return nil
