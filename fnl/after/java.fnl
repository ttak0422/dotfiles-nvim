(local java_path args.java_path)
(local lombok_jar_path args.lombok_jar_path)
(local jdtls_jar_pattern args.jdtls_jar_pattern)
(local jdtls_config_path args.jdtls_config_path)
(local java_debug_jar_pattern args.java_debug_jar_pattern)
(local java_test_jar_pattern args.java_test_jar_pattern)

(local jdtls (require :jdtls))
(local jdtls_dap (require :jdtls.dap))
(local spring_boot (require :spring_boot))

(local root_dir (vim.fs.root 0 [:gradlew :mvnw :.git]))
(local workspace_dir (.. (os.getenv :HOME) :/.local/share/eclipse/
                         (-> root_dir
                             (vim.fn.fnamemodify ":p:h")
                             (string.gsub "/" "_"))))

(local capabilities (dofile args.capabilities_path))

(fn dir? [path]
  (-?> (vim.uv.fs_stat path)
       (. type)
       (= :directory)))

(if (not (dir? workspace_dir))
    (vim.uv.fs_mkdir workspace_dir 493))

(local cmd [java_path
            :-Declipse.application=org.eclipse.jdt.ls.core.id1
            :-Dosgi.bundles.defaultStartLevel=4
            :-Declipse.product=org.eclipse.jdt.ls.core.product
            (.. :-Dosgi.sharedConfiguration.area= jdtls_config_path)
            :-Dosgi.sharedConfiguration.area.readOnly=true
            :-Dosgi.checkConfiguration=true
            :-Dosgi.configuration.cascaded=true
            :-Dlog.protocol=true
            :-Dlog.level=ERROR
            "-Xlog:disable"
            "-XX:+AlwaysPreTouch"
            :-Xmx10g
            (.. "-javaagent:" lombok_jar_path)
            :--add-modules=ALL-SYSTEM
            :--add-opens
            :java.base/java.util=ALL-UNNAMED
            :--add-opens
            :java.base/java.lang=ALL-UNNAMED
            :-jar
            (vim.fn.glob jdtls_jar_pattern)
            :-data
            workspace_dir])

(local settings (let [enabled {:enabled true}
                      disabled {:enabled false}
                      favoriteStaticMembers [:io.crate.testing.Asserts.assertThat
                                             :java.util.Objects.requireNonNull
                                             :java.util.Objects.requireNonNullElse
                                             :org.assertj.core.api.Assertions.*
                                             :org.assertj.core.api.Assertions.assertThat
                                             :org.assertj.core.api.Assertions.assertThatExceptionOfType
                                             :org.assertj.core.api.Assertions.assertThatThrownBy
                                             :org.assertj.core.api.Assertions.catchThrowable
                                             :org.hamcrest.CoreMatchers.*
                                             :org.hamcrest.MatcherAssert.assertThat
                                             :org.hamcrest.Matchers.*
                                             :org.junit.jupiter.api.Assertions.*
                                             :org.junit.jupiter.api.Assumptions.*
                                             :org.junit.jupiter.api.DynamicContainer.*
                                             :org.junit.jupiter.api.DynamicTest.*
                                             :org.mockito.Answers.*
                                             :org.mockito.ArgumentMatchers.*
                                             :org.mockito.Mockito.*]
                      filteredTypes [:java.awt.*
                                     :com.sun.*
                                     :sun.*
                                     :jdk.*
                                     :io.micrometer.shaded.*
                                     :javax.*]
                      completion {: favoriteStaticMembers : filteredTypes}
                      edit {:validateAllOpenBuffersOnChanges false
                            :smartSemicolonDetection enabled}
                      sources {:organizeImports {:starThreshold 9999
                                                 :staticStarThreshold 9999}}
                      java {:autobuild disabled
                            :maxConcurrentBuilds 8
                            :signatureHelp enabled
                            : completion
                            : edit
                            : sources}]
                  {: java}))

(local bundles (let [debug_jars (-> (vim.fn.glob java_debug_jar_pattern 1)
                                    (vim.split "\n"))
                     test_jars (-> (vim.fn.glob java_test_jar_pattern 1)
                                   (vim.split "\n"))
                     jar_filter (fn [_k v]
                                  (and (not= "" v)
                                       (not (vim.endswith v
                                                          :com.microsoft.java.test.runner-jar-with-dependencies.jar))
                                       (not (vim.endswith v :jacocoagent.jar))))]
                 (-> []
                     (vim.list_extend debug_jars)
                     (vim.list_extend test_jars)
                     (vim.list_extend (spring_boot.java_extensions))
                     (ipairs)
                     (vim.iter)
                     (: :filter jar_filter)
                     (: :map (fn [_ v] v))
                     (: :totable))))

(set vim.g.debug_bundles bundles)

(local extendedClientCapabilities
       (vim.tbl_deep_extend :force jdtls.extendedClientCapabilities
                            {:resolveAdditionalTextEditsSupport true
                             :progressReportProvider false}))

(local init_options {: bundles : extendedClientCapabilities})

(local on_attach
       (fn [client bufnr]
         (let [build_timeout 10000
               opts (fn [desc] {:silent true :buffer bufnr : desc})
               with_compile (fn [f]
                              (fn []
                                (if vim.bo.modified
                                    (vim.cmd :w))
                                (client.request_sync :java/buildWorkspace false
                                                     build_timeout bufnr)
                                (f)))]
           (jdtls_dap.setup_dap {:hotcodereplace :auto})
           (jdtls_dap.setup_dap_main_class_configs)
           (each [_ k (ipairs [[:<LocalLeader>OO
                                (fn []
                                  (os.execute (.. "rm -rf " workspace_dir)))
                                (opts " clean workspace")]
                               ; [:<LocalLeader>o
                               ;  jdtls.organize_imports
                               ;  (opts " organize imports")]
                               [:<LocalLeader>Tt
                                (with_compile jdtls.test_nearest_method)
                                (opts " test nearest")]
                               [:<LocalLeader>TT
                                (with_compile jdtls.test_class)
                                (opts " test class")]])]
             (vim.keymap.set :n (. k 1) (. k 2) (. k 3))))))

(local flags {:allow_incremental_sync true :debounce_text_changes 300})

(local handlers {:language/status (fn [])})

(jdtls.start_or_attach {: root_dir
                        : cmd
                        : settings
                        : init_options
                        : on_attach
                        : flags
                        : capabilities
                        : handlers})
