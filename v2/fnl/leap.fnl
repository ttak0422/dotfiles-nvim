(local leap (require :leap))
(local spooky (require :leap-spooky))

(leap.set_default_mappings)

; r,Rを範囲指定の後に指定できるようになる
(spooky.setup {})
