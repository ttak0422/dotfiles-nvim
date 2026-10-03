;; NODE_PATH is a fallback: Node resolves project-local ESLint before this Nix copy.
;; A fixed server command lets Neovim apply cmd_env (lspconfig's cmd callback does not).
{:cmd [:vscode-eslint-language-server :--stdio]
 :cmd_env {:NODE_PATH args.node_path}
 ;; null avoids nodePath taking precedence over a nested project's node_modules.
 :settings {:nodePath vim.NIL
            ;; Keep formatting with Prettier/Biome; retain ESLint code actions.
            :format false}}
