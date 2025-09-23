-- [nfnl] v2/fnl/lazydev.fnl
local function _1_(root_dir)
  return not vim.uv.fs_stat((root_dir .. "/.luarc.json"))
end
require("lazydev").setup({library = {}, enabled = _1_})
return require("blink.cmp").add_source_provider("lazydev", {name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100})
