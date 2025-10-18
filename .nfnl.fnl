(local core (require :nfnl.core))
(local config (require :nfnl.config))

(fn derivePath [path]
  (-> path
      (string.gsub :fnl/ :lua/autogen/)
      (string.gsub :.fnl :.lua)))

(core.merge (config.default {:rtp-patterns [".*"]})
            {:source-file-patterns [:fnl/**/*.fnl]
             :fnl-path->lua-path derivePath})
