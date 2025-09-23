-- [nfnl] v2/fnl/lazydev.fnl
require("lazydev").setup({library = {}})
return require("blink.cmp").add_source_provider("lazydev", {name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100})
