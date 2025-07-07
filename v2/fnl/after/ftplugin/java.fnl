(local jdk8_path args.jdk8_path)
(local jdk11_path args.jdk11_path)
(local jdk17_path args.jdk17_path)
(local jdk21_path args.jdk21_path)
(local jdk23_path args.jdk23_path)
(local java_path args.java_path)
(local jdtls_jar_pattern args.jdtls_jar_pattern)
(local jdtls_config_path args.jdtls_config_path)
(local java_debug_jar_pattern args.java_debug_jar_pattern)
(local java_test_jar_pattern args.java_test_jar_pattern)
(local lombok_jar_path args.lombok_jar_path)
(local vscode_spring_boot_path args.vscode_spring_boot_path)

(local jdtls (require :jdtls))
(local jdtls_dap (require :jdtls.dap))
(local spring_boot (require :spring_boot))

(local root_dir (vim.fs.root 0 [:gradlew :mvnw :.git]))

(fn setup []
  (let [workspace_dir (.. (os.getenv :HOME) :/.local/share/eclipse/
                          (-> root_dir
                              (vim.fn.fnamemodify ":p:h")
                              (string.gsub "/" "_")))
        dir? (fn [path]
               (-?> (vim.uv.fs_stat path)
                    (. type)
                    (= :directory)))
        cmd [java_path
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
             workspace_dir]
        settings (let [enabled {:enabled true}
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
                       configuration {:runtimes [{:name :JavaSE-1.8
                                                  :path jdk8_path}
                                                 {:name :JavaSE-11
                                                  :path jdk11_path}
                                                 {:name :JavaSE-17
                                                  :path jdk17_path}
                                                 {:name :JavaSE-21
                                                  :path jdk21_path}
                                                 {:name :JavaSE-23
                                                  :path jdk23_path}]}
                       java {:autobuild disabled
                             :maxConcurrentBuilds 8
                             :signatureHelp enabled
                             :format disabled
                             : configuration
                             : completion
                             : edit
                             : sources}]
                   {: java})
        bundles (let [debug_jars (-> (vim.fn.glob java_debug_jar_pattern 1)
                                     (vim.split "\n"))
                      test_jars (-> (vim.fn.glob java_test_jar_pattern 1)
                                    (vim.split "\n"))
                      jar_filter (fn [_ v]
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
                      (: :totable)))
        extendedClientCapabilities (vim.tbl_deep_extend :force
                                                        jdtls.extendedClientCapabilities
                                                        {:resolveAdditionalTextEditsSupport true
                                                         :progressReportProvider false})
        init_options {: bundles : extendedClientCapabilities}
        on_attach (fn [client bufnr]
                    (let [build_timeout 10000
                          desc (fn [desc] {:silent true :buffer bufnr : desc})
                          with_compile (fn [f]
                                         (fn []
                                           (if vim.bo.modified
                                               (vim.cmd :w))
                                           (client.request_sync :java/buildWorkspace
                                                                false
                                                                build_timeout
                                                                bufnr)
                                           (f)))]
                      (jdtls_dap.setup_dap {:hotcodereplace :auto})
                      (jdtls_dap.setup_dap_main_class_configs)
                      (each [_ k (ipairs [; [:<LocalLeader>o
                                          ;  jdtls.organize_imports
                                          ;  (opts " organize imports")]
                                          [:<LocalLeader>Tt
                                           (with_compile jdtls.test_nearest_method)
                                           (desc " test nearest")]
                                          [:<LocalLeader>TT
                                           (with_compile jdtls.test_class)
                                           (desc " test class")]])]
                        (vim.keymap.set :n (. k 1) (. k 2) (. k 3)))))
        flags {:allow_incremental_sync true :debounce_text_changes 300}
        handlers {:language/status (fn [])}]
    (if (not (dir? workspace_dir))
        (vim.uv.fs_mkdir workspace_dir 493))
    (jdtls.start_or_attach {: root_dir
                            : cmd
                            : settings
                            : init_options
                            : on_attach
                            : flags
                            : handlers})
    (if (not vim.g.spring_boot_initialized)
        (do
          (set vim.g.spring_boot_initialized true)
          (spring_boot.setup {:ls_path (.. vscode_spring_boot_path
                                           :/language-server)
                              :server {:cmd [java_path
                                             :-jar
                                             (vim.fn.glob (.. vscode_spring_boot_path
                                                              :/language-server/
                                                              :spring-boot-language-server-*.jar))
                                             :-Dsts.lsp.client=vscode
                                             :-Dlogging.level.org.springframework=OFF]}})))))

(setup)
