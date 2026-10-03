-- [nfnl] v2/fnl/after/lsp/eslint.fnl
return {cmd = {"vscode-eslint-language-server", "--stdio"}, cmd_env = {NODE_PATH = args.node_path}, settings = {nodePath = vim.NIL, format = false}}
