-- [nfnl] v2/fnl/track.fnl
require("track").setup({vault_dir = (os.getenv("HOME") .. "/track/")})
return require("telescope").load_extension("track")
