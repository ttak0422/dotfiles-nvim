setlocal conceallevel=0

if expand('%:p') =~# '/.vscode/.*\.json$'
  setlocal filetype=jsonc
endif
