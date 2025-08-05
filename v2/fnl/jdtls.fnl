(vim.api.nvim_create_user_command :JdtDelteteWorkspaceData
                                  #(let [root_dir (vim.fs.root 0
                                                               [:gradlew
                                                                :mvnw
                                                                :.git])
                                         workspace_dir (.. (os.getenv :HOME)
                                                           :/.local/share/eclipse/
                                                           (-> root_dir
                                                               (vim.fn.fnamemodify ":p:h")
                                                               (string.gsub "/"
                                                                            "_")))]
                                     (do
                                       (os.execute (.. "rm -rf " workspace_dir))
                                       (vim.notify "Deleted JDTLS workspace data.")))
                                  {})
