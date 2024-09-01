-- [nfnl] Compiled from fnl/spring-boot.fnl by https://github.com/Olical/nfnl, do not edit.
vim.g.spring_boot = {jdt_extensions_path = (args.vscode_spring_boot_path .. "/jars"), jdt_extensions_jars = {"io.projectreactor.reactor-core.jar", "org.reactivestreams.reactive-streams.jar", "jdt-ls-commons.jar", "jdt-ls-extension.jar", "sts-gradle-tooling.jar"}}
do
  local M = require("spring_boot")
  local server = {cmd = {args.java_path, "-jar", vim.fn.glob((args.vscode_spring_boot_path .. "/language-server/" .. "spring-boot-language-server-*.jar")), "-Dsts.lsp.client=vscode", "-Dlogging.level.org.springframework=OFF"}}
  M.setup({ls_path = (args.vscode_spring_boot_path .. "/language-server"), server = server})
end
vim.g.spring_boot = {jdt_extensions_path = (args.vscode_spring_boot_path .. "/jars"), jdt_extensions_jars = {"io.projectreactor.reactor-core.jar", "org.reactivestreams.reactive-streams.jar", "jdt-ls-commons.jar", "jdt-ls-extension.jar", "sts-gradle-tooling.jar"}}
return nil
