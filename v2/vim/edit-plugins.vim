cabbrev <expr> wq getcmdtype() .. getcmdline() ==# ":wq" && &ft == "gitcommit" ? "w \| bprev" : "wq"
