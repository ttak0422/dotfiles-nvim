{:single_file_support false
 :workspace_required true
 :root_markers [:tsconfig.json :package.json :jsconfig.json :.node_project]
 :settings {:separate_diagnostic_server true
            :publish_diagnostic_on :insert_leave
            :typescript {:suggest {:completeFunctionCalls true}
                         :preferences {:importModuleSpecifier :relative}}}
 :flags {:debounce_text_changes 1000}
 :vtsls {:experimental {:completion {:enableServerSideFuzzyMatch true}}}}
