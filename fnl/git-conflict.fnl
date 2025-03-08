(let [M (require :git-conflict)] (M.setup))

(case (. package.loaded :morimo)
  morimo (if (= vim.g.colors_name :morimo)
             (morimo.load :git-conflict)))
