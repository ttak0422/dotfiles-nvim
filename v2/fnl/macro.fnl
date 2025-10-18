(macro cond [...]
  (let [xs [...]
        n (length xs)]
    (assert (> n 0) "cond: at least one clause is required")
    (assert (= (% n 2) 0) "cond clauses must be pairs: test expr ...")
    (var acc nil)
    (for [i n 2 -2]
      (let [a (. xs (- i 1))
            b (. xs i)]
        (if (= a `_)
            (do
              (assert (= i n) "cond: _ must be the last clause")
              (set acc b))
            (set acc `(if ,a ,b ,acc)))))
    acc))
