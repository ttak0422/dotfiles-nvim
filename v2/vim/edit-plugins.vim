cabbrev <expr> wq getcmdtype() .. getcmdline() ==# ":wq" && &ft == "gitcommit" ? "w \| b#" : "wq"
