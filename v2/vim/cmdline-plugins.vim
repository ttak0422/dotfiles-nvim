cabbrev <expr> r getcmdtype() .. getcmdline() ==# ":r" ? [getchar(), ""][1] .. "%s//g<Left><Left>" : (getcmdline() ==# "'<,'>r" ?  [getchar(), ""][1] .. "s//g<Left><Left>" : "r")
cabbrev <expr> git getcmdtype() .. getcmdline() ==# ":git" ? [getchar(), ""][1] .. "Gin " : "git"
