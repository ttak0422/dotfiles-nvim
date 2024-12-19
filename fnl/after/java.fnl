(let [jdtls (setmetatable {:setup (require :jdtls.setup)
                           :dap (require :jdtls.dap)}
                          {:__index (require :jdtls)})
      spring_boot (require :spring_boot)
      enabled {:enabled true}
      disabled {:enabled false}
      root_dir (jdtls.setup.find_root [:.git :mvnw :gradlew]) ;
      ;; init_options
      extendedClientCapabilities (let [c jdtls.extendedClientCapabilities]
                                   (tset c :resolveAdditionalTextEditsSupport
                                         true)
                                   c)
      debug_jars (vim.split (vim.fn.glob args.java_debug_jar_pattern 1) "\n")
      test_jars (vim.split (vim.fn.glob args.java_test_jar_pattern 1) "\n")
      bundles (let [tbl []]
                (each [_ v (ipairs debug_jars)]
                  (if (not= "" v) (table.insert tbl v)))
                (each [_ v (ipairs test_jars)]
                  (if (and (not= "" v)
                           (not (vim.endswith v
                                              :com.microsoft.java.test.runner-jar-with-dependencies.jar))
                           (not (vim.endswith v :jacocoagent.jar)))
                      (table.insert tbl v)))
                (each [_ v (ipairs (spring_boot.java_extensions))]
                  (table.insert tbl v))
                tbl)
      init_options {: bundles : extendedClientCapabilities}
      settings (let [autobuild disabled
                     maxConcurrentBuilds 8
                     ; contentProvider  { :preferred  "fernflower" } ;; TODO:
                     saveActions {:organizeImports false}
                     sources {:organizeImports {:starThreshold 9999
                                                :staticStarThreshold 9999}}
                     favoriteStaticMembers [; :org.junit.Assert.*
                                            ; :org.junit.Assume.*
                                            :org.junit.jupiter.api.Assertions.*
                                            :org.junit.jupiter.api.Assumptions.*
                                            :org.junit.jupiter.api.DynamicContainer.*
                                            :org.junit.jupiter.api.DynamicTest.*
                                            :org.assertj.core.api.Assertions.*
                                            :org.mockito.Mockito.*
                                            :org.mockito.ArgumentMatchers.*
                                            :org.mockito.Answers.*
                                            :org.mockito.Mockito.*]
                     ;; configuration
                     ; runtimes [{:name :JavaSE-17 :path args.java17_path :default true}
                     ;           {:name :JavaSE-22 :path args.java22_path}]
                     ; configuration {: runtimes} ;
                     ;; completion
                     filteredTypes [:java.awt.*
                                    :com.sun.*
                                    :sun.*
                                    :jdk.*
                                    :org.gaalvm.*
                                    :io.micrometer.shaded.*]
                     completion {: favoriteStaticMembers : filteredTypes}
                     edit {:validateAllOpenBuffersOnChanges false
                           :smartSemicolonDetection enabled}
                     signatureHelp {:enabled true :description enabled}]
                 {:java {: autobuild
                         : maxConcurrentBuilds
                         : signatureHelp
                         : saveActions
                         : edit
                         : completion
                         ; : configuration
                         : sources}}) ;
      ;; cmd
      home (os.getenv :HOME)
      work_space (.. home :/.local/share/eclipse/
                     (: (vim.fn.fnamemodify root_dir ":p:h") :gsub "/" "_"))
      cmd [args.java_path
           ; JDWPの有効化 デバッグ用途
           ; "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044"
           :-Declipse.application=org.eclipse.jdt.ls.core.id1
           :-Dosgi.bundles.defaultStartLevel=4
           :-Declipse.product=org.eclipse.jdt.ls.core.product
           (.. :-Dosgi.sharedConfiguration.area= args.jdtls_config_path)
           :-Dosgi.sharedConfiguration.area.readOnly=true
           :-Dosgi.checkConfiguration=true
           "-Dosgi.configuration.c:ascaded=true"
           :-Dlog.protocol=true
           :-Dlog.level=ERROR
           "-Xlog:disable"
           :-Xms1G
           :-Xmx12G
           ; lombok jar
           (.. "-javaagent:" args.lombok_jar_path)
           ; jdtls jar
           :-jar
           (vim.fn.glob args.jdtls_jar_pattern)
           ; :-configuration
           ; args.jdtls_config_path
           :-data
           work_space]
      handlers {:language/status (fn [])} ;
      capabilities (dofile args.capabilities_path)
      build_timeout 10000
      on_attach (fn [client bufnr]
                  (let [opts (fn [desc] {:silent true :buffer bufnr : desc})
                        with_compile (fn [f]
                                       (fn []
                                         (if vim.bo.modified
                                             (vim.cmd :w))
                                         (client.request_sync :java/buildWorkspace
                                                              false
                                                              build_timeout
                                                              bufnr)
                                         (f)))
                        N [[:<LocalLeader>o
                            jdtls.organize_imports
                            (opts "[JDTLS] organize imports")]
                           ; [:<LocalLeader>tt
                           ;  (with_compile jdtls.test_nearest_method)
                           ;  (opts "[JDTLS] test nearest")]
                           ; [:<LocalLeader>tT
                           ;  (with_compile jdtls.test_class)
                           ;  (opts "[JDTLS] test class")]
                           ]]
                    ((dofile args.on_attach_path) client bufnr)
                    (jdtls.dap.setup_dap {:hotcodereplace :auto})
                    (jdtls.dap.setup_dap_main_class_configs)
                    (each [_ k (ipairs N)]
                      (vim.keymap.set :n (. k 1) (. k 2) (. k 3)))))
      config {: root_dir
              : settings
              : cmd
              : capabilities
              : on_attach
              : handlers
              : init_options}]
  (set vim.g.jdtjdt bundles)
  (jdtls.start_or_attach config))
