(local config (require :dial.config))
(local augend (require :dial.augend))

(local default [;; nonnegative decimal number (0 1 2 3 ...)
                augend.integer.alias.decimal
                ;; nonnegative hex number  (0x01 0x1a1f etc.)
                augend.integer.alias.hex
                ;; date (2022/02/19 etc.)
                (. augend.date.alias "%Y/%m/%d")
                ;; date (2022-02-19 etc.)
                (. augend.date.alias "%Y-%m-%d")
                ;; boolean value (true <-> false)
                augend.constant.alias.bool
                ;; semantic versioning
                augend.semver.alias.semver])

(config.augends:register_group {: default})
