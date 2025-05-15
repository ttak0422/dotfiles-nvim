(let [languages {}
      init_options {:documentFormatting true :documentRangeFormatting true}]
  {:single_file_support true
   :filetypes (vim.tbl_keys languages)
   :settings {:rootMarkers [:.git/] : languages}
   : init_options})
