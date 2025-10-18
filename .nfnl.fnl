(fn derivePath [path]
  (-> path
      (string.gsub :fnl/ :lua/autogen/)
      (string.gsub :.fnl :.lua)))

{:fnl-path->lua-path derivePath}
