-- [nfnl] v2/fnl/tiny-code-action.fnl
return require("tiny-code-action").setup({backend = "delta", picker = {"telescope", opts = {winborder = "single"}}})
