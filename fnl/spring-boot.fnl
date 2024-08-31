;; FIXME: completion doesn't work collectly
(set vim.g.spring_boot
     {:jdt_extensions_path (.. args.vscode_spring_boot_path :/jars)
      :jdt_extensions_jars [:io.projectreactor.reactor-core.jar
                            :org.reactivestreams.reactive-streams.jar
                            :jdt-ls-commons.jar
                            :jdt-ls-extension.jar
                            :sts-gradle-tooling.jar]})

(let [M (require :spring_boot)
      server {:cmd [args.java_path
                    :-jar
                    (vim.fn.glob (.. args.vscode_spring_boot_path
                                     :/language-server/
                                     :spring-boot-language-server-*.jar))
                    :-Dsts.lsp.client=vscode
                    :-Dlogging.level.org.springframework=OFF]}]
  (M.setup {:ls_path (.. args.vscode_spring_boot_path :/language-server)
            : server}))
