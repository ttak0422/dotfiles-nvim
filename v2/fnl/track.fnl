((. (require :track) :setup) {:vault_dir (.. (os.getenv :HOME) :/track/)})

((. (require :telescope) :load_extension) :track)
