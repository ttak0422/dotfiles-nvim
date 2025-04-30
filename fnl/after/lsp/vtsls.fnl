(local climb (require :climbdir))
(local marker (require :climbdir.marker))

{:single_file_support false
 :settings {:separate_diagnostic_server true
            :publish_diagnostic_on :insert_leave
            :typescript {:suggest {:completeFunctionCalls true}
                         :preferences {:importModuleSpecifier :relative}}}
 :root_dir (fn [path]
             (climb.climb path
                          (marker.one_of (marker.has_readable_file :package.json)
                                         (marker.has_directory :node_modules))
                          {:halt (marker.one_of (marker.has_readable_file :deno.json))}))
 :flags {:debounce_text_changes 1000}
 :vtsls {:experimental {:completion {:enableServerSideFuzzyMatch true}}}}
