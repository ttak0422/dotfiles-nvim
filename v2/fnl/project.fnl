(local project (require :project_nvim))

(project.setup {:manual_mode false
                :scope_chdir :tab
                :detection_methods [:pattern]
                :patterns [:.git]})
