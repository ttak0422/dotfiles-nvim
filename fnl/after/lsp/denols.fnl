{:single_file_support false
 :workspace_required true
 :root_markers [:deno.json :deno.jsonc :.deno_project]
 :init_options {:lint true
                :unstable false
                :suggest {:completeFunctionCalls true
                          :names true
                          :paths true
                          :autoImports true
                          :imports {:autoDiscover true :hosts (vim.empty_dict)}}}
 :settings {:deno {:enable true}}}
