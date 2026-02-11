-- [nfnl] v2/fnl/blink.fnl
vim.opt.completeopt = {}
for lhs, rhs in pairs({["<C-Space>"] = "<C-n>", ["<C-S-Space>"] = "<C-p>", ["<C-a>"] = "<Home>", ["<C-e>"] = "<End>"}) do
  vim.keymap.set("i", lhs, rhs, {noremap = true})
end
vim.cmd("\ncnoremap <expr> <C-a> '<Home>'\ncnoremap <expr> <C-e> '<End>'\ncnoremap <expr> <C-b> '<Left>'\ncnoremap <expr> <C-f> '<Right>'\n         ")
local cmp = require("blink.cmp")
local types = require("blink.cmp.types")
local function _1_(cmp0)
  if cmp0.is_visible() then
    return cmp0.hide()
  else
    return true
  end
end
local function _3_(ctx)
  local case_4_ = ctx.trigger.initial_kind
  if (case_4_ == "trigger_character") then
    return 0
  elseif (case_4_ == "manual") then
    return 0
  else
    local _ = case_4_
    return 100
  end
end
local function _6_(_, items)
  local function _7_(item)
    return (item.kind ~= types.CompletionItemKind.Keyword)
  end
  return vim.tbl_filter(_7_, items)
end
local function _8_(ctx)
  return (ctx.trigger.initial_kind ~= "trigger_character")
end
local function _9_(_ctx)
  return 2
end
local _10_
do
  local search_src = {"buffer"}
  local cmd_src = {"cmdline", "buffer"}
  local function _11_(cmp0)
    return cmp0.show_and_insert_or_accept_single({initial_selected_item_idx = -1})
  end
  local function _12_()
    local case_13_ = vim.fn.getcmdtype()
    if (case_13_ == "/") then
      return search_src
    elseif (case_13_ == "?") then
      return search_src
    elseif (case_13_ == ":") then
      return cmd_src
    elseif (case_13_ == "@") then
      return cmd_src
    else
      return nil
    end
  end
  _10_ = {enabled = true, keymap = {preset = "none", ["<Tab>"] = {"show_and_insert_or_accept_single", "select_next"}, ["<S-Tab>"] = {_11_, "select_prev"}, ["<C-space>"] = {"show", "fallback"}, ["<C-n>"] = {"select_next", "fallback"}, ["<C-p>"] = {"select_prev", "fallback"}, ["<Right>"] = {"select_next", "fallback"}, ["<Left>"] = {"select_prev", "fallback"}, ["<C-y>"] = {"select_and_accept", "fallback"}, ["<C-e>"] = {"cancel", "fallback_to_mappings"}, ["<End>"] = {"hide", "fallback"}}, sources = _12_}
end
cmp.setup({completion = {accept = {auto_brackets = {enabled = true, force_allow_filetypes = {}, blocked_filetypes = {}, kind_resolution = {enabled = true, blocked_filetypes = {"typescriptreact", "javascriptreact", "vue", "kotlin"}}, semantic_token_resolution = {enabled = true, blocked_filetypes = {"java"}, timeout_ms = 400}}, resolve_timeout_ms = 150}, documentation = {auto_show = true, auto_show_delay_ms = 500, update_delay_ms = 100, treesitter_highlighting = true}, keyword = {range = "prefix"}, menu = {draw = {columns = {{"kind_icon"}, {"label", "label_description"}}}}}, signature = {enabled = true}, appearance = {nerd_font_variant = "mono", kind_icons = {Text = "\243\176\137\191", Method = "\243\176\138\149", Function = "\243\176\138\149", Constructor = "\243\176\146\147", Field = "\243\176\156\162", Variable = "\243\176\128\171", Property = "\243\176\156\162", Class = "\243\176\160\177", Interface = "\239\131\168", Struct = "\243\176\153\133", Module = "\239\146\135", Unit = "\238\170\150", Value = "\243\176\142\160", Enum = "\239\133\157", EnumMember = "\239\133\157", Keyword = "\243\176\140\139", Constant = "\243\176\143\191", Snippet = "\239\145\143", Color = "\243\176\143\152", File = "\243\176\136\148", Reference = "\243\176\136\135", Folder = "\243\176\137\139", Event = "\243\177\144\139", Operator = "\243\176\134\149", TypeParameter = "\243\176\151\180"}}, fuzzy = {implementation = "rust", frecency = {enabled = true, path = (vim.fn.stdpath("state") .. "/blink/cmp/frecency.dat"), unsafe_no_lock = false}, use_proximity = true, sorts = {"score", "sort_text"}, prebuilt_binaries = {force_version = nil, force_system_triple = nil, extra_curl_args = {}, proxy = {from_env = true, url = nil}, download = false, ignore_version_mismatch = false}}, keymap = {preset = "none", ["<C-e>"] = {"cancel", "fallback_to_mappings", _1_, "fallback_to_mappings"}, ["<C-y>"] = {"select_and_accept"}, ["<C-p>"] = {"select_prev", "fallback_to_mappings"}, ["<C-n>"] = {"select_next", "fallback_to_mappings"}, ["<C-b>"] = {"scroll_documentation_up", "fallback"}, ["<C-f>"] = {"scroll_documentation_down", "fallback"}, ["<Tab>"] = {"snippet_forward", "fallback"}, ["<S-Tab>"] = {"snippet_backward", "fallback"}, ["<C-k>"] = {"show_signature", "hide_signature", "fallback"}}, sources = {default = {"lsp", "snippets", "buffer"}, per_filetype = {}, providers = {lsp = {fallbacks = {}, min_keyword_length = _3_, transform_items = _6_}, snippets = {should_show_items = _8_}}, min_keyword_length = _9_}, snippets = {preset = "luasnip"}, cmdline = _10_, term = {enabled = false}})
vim.lsp.config("*", {capabilities = cmp.get_lsp_capabilities()})
local opts = {noremap = true, silent = true}
local lsp_provider
local function _15_()
  return cmp.show({providers = {"lsp"}})
end
lsp_provider = _15_
local path_provider
local function _16_()
  return cmp.show({providers = {"path"}})
end
path_provider = _16_
for _, k in ipairs({{"<C-x>l", lsp_provider}, {"<C-x><C-l>", lsp_provider}, {"<C-x>f", path_provider}, {"<C-x><C-f>", path_provider}}) do
  vim.keymap.set("i", k[1], k[2], (k[3] or opts))
end
return nil
