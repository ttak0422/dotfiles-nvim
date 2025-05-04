(local climb (require :climbdir))
(local marker (require :climbdir.marker))

{:single_file_support false
 :root_dir (fn [path]
             (climb.climb path
                          (marker.one_of (marker.has_readable_file :deno.json)
                                         (marker.has_readable_file :deno.jsonc)
                                         (marker.has_directory :denops))
                          {:halt (marker.one_of (marker.has_readable_file :package.json)
                                                (marker.has_directory :node_modules))}))
 :init_options {:lint true
                :unstable false
                :suggest {:completeFunctionCalls true
                          :names true
                          :paths true
                          :autoImports true
                          :imports {:autoDiscover true :hosts (vim.empty_dict)}}}
 :settings {:deno {:enable true}}}
