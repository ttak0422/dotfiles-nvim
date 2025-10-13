-- [nfnl] v2/fnl/quart.fnl
local quarto = require("quarto")
local lspFeatures = {enabled = true, chunks = "curly", languages = {"r", "python", "julia", "bash", "html"}, diagnostics = {enabled = true, triggers = {"BufWritePost"}}, completion = {enabled = true}}
local codeRunner = {enabled = true, default_method = "molten", ft_runners = {python = "molten"}, never_run = {"yaml"}}
return quarto.setup({closePreviewOnExit = true, lspFeatures = lspFeatures, codeRunner = codeRunner, debug = false})
