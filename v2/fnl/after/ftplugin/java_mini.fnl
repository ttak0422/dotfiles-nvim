(local jdk8_path args.jdk8_path)
(local jdk11_path args.jdk11_path)
(local jdk17_path args.jdk17_path)
(local jdk21_path args.jdk21_path)
(local java_path args.java_path)
(local jdtls_jar_pattern args.jdtls_jar_pattern)
(local jdtls_config_path args.jdtls_config_path)
(local lombok_jar_path args.lombok_jar_path)
(local attach_path args.attach_path)

(local jdtls (require :jdtls))

(local root_dir (vim.fs.root 0 [:gradlew :mvnw :.git]))
(local workspace_dir (.. (os.getenv :HOME) :/.local/share/eclipse/
                         (-> root_dir
                             (vim.fn.fnamemodify ":p:h")
                             (string.gsub "/" "_"))))

(if (not (-?> (vim.uv.fs_stat workspace_dir)
              (. type)
              (= :directory)))
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
                                     :io.micrometer.shaded.*]
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
                                                 :path jdk21_path}]}
                      java {:autobuild disabled
                            :maxConcurrentBuilds 8
                            :signatureHelp enabled
                            :format disabled
                            : configuration
                            : completion
                            : edit
                            : sources
                            :referencesCodeLens {:enabled true}
                            :implementationsCodeLens {:enabled true}
                            :inlayHints {:parameterNames {:enabled :all}}}]
                  {: java}))

(local bundles [])
(local extendedClientCapabilities
       (vim.tbl_deep_extend :force jdtls.extendedClientCapabilities
                            {:resolveAdditionalTextEditsSupport true
                             :progressReportProvider false}))

(local init_options {: bundles : extendedClientCapabilities})
(local on_attach
       (fn [client bufnr]
         ((dofile attach_path) {:buf bufnr : client})))

(local flags {:allow_incremental_sync true :debounce_text_changes 300})
(local handlers {:language/status (fn [])})

(vim.defer_fn #(jdtls.start_or_attach {:name :jdtls
                                       : root_dir
                                       : cmd
                                       : settings
                                       : init_options
                                       : on_attach
                                       : flags
                                       : handlers})
  100)
