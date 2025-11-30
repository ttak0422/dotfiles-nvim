(local translator (require :ts-error-translator))

(translator.setup {:auto_attach true
                   :servers [:astro
                             :svelte
                             :ts_ls
                             :typescript-tools
                             :volar
                             :vtsls]})
