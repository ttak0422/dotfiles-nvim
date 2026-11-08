# Core is a cartridge: root startup metadata, owned runtime tree and final setup.
{
  pkgs,
  nginxPlugin ? pkgs.vimPlugins.nginx-vim,
  ...
}:
let
  nvim = "${pkgs.neovim-unwrapped}/bin/nvim";
  editorOpenScript = ./editor-open.lua;
  # 軽量エディタラッパー: +N や file:N を --line=N に変換して nvim -l に渡す
  editorWrapper = pkgs.writeShellScript "nvim-editor-open" ''
    remote_args=()
    local_args=()
    for a in "$@"; do
      case "$a" in
        --wait)
          remote_args+=("--wait")
          ;;
        --)
          remote_args+=("--")
          local_args+=("--")
          ;;
        +[0-9]*)
          remote_args+=("--line=''${a#+}")
          local_args+=("$a")
          ;;
        *)
          if [[ "$a" =~ ^(.+):([0-9]+)$ ]]; then
            remote_args+=("--line=''${BASH_REMATCH[2]}" "''${BASH_REMATCH[1]}")
            local_args+=("+''${BASH_REMATCH[2]}" "''${BASH_REMATCH[1]}")
          else
            remote_args+=("$a")
            local_args+=("$a")
          fi
          ;;
      esac
    done
    if [[ -z "''${NVIM_EDITOR_ADDR:-''${NVIM:-}}" ]]; then
      unset VIMINIT
      if [[ -n "''${NVIM_V3_INIT:-}" ]]; then
        exec "${nvim}" -u "$NVIM_V3_INIT" "''${local_args[@]}"
      fi
      exec "${nvim}" "''${local_args[@]}"
    fi
    exec "${nvim}" --headless --clean -l "${editorOpenScript}" "''${remote_args[@]}"
  '';
  # --wait 固定のエディタラッパー (GIT_EDITOR 用)
  editorWrapperWait = pkgs.writeShellScript "nvim-editor-open-wait" ''
    exec "${editorWrapper}" --wait "$@"
  '';
  javaArgs =
    let
      inherit (pkgs.vscode-marketplace.vscjava) vscode-java-debug vscode-java-test;
      jdtls = pkgs.jdt-language-server;
    in
    {
      jdk8_path = "${pkgs.jdk8}";
      jdk11_path = "${pkgs.jdk11}";
      jdk17_path = "${pkgs.jdk17}";
      jdk21_path = "${pkgs.jdk21}";
      # JDT LS 1.63 ships Eclipse bundles requiring Java 25.
      java_path = "${pkgs.jdk25}/bin/java";
      jdtls_jar_pattern = "${jdtls}/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar";
      jdtls_config_path = "${jdtls}/share/java/jdtls/${
        if pkgs.stdenv.isDarwin then "config_mac" else "config_linux"
      }";
      java_debug_jar_pattern = "${vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar";
      java_test_jar_pattern = "${vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar";
      jol_jar_path = pkgs.javaPackages.jol;
      lombok_jar_path = "${pkgs.lombok}/share/java/lombok.jar";
      vscode_spring_boot_path = "${pkgs.vscode-marketplace.vmware.vscode-spring-boot}/share/vscode/extensions/vmware.vscode-spring-boot";
      attach_path = ./lsp-attach.lua;
    };
  files = {
    "after/ftplugin/fennel.lua" = # lua
      ''
        vim.opt_local.iskeyword:append("-")
        return vim.opt_local.iskeyword:append("?")
      '';
    "after/ftplugin/fsharp.lua" = # lua
      ''
        local function _1_()
          return vim.lsp.codelens.enable(true, {bufnr = 0})
        end
        return vim.api.nvim_create_autocmd({"BufEnter", "InsertLeave"}, {callback = _1_, buffer = 0})
      '';
    "after/ftplugin/gitcommit.lua" = # lua
      ''
        vim.opt_local.iskeyword:append("-")
        vim.bo.bufhidden = "wipe"
        local function prefill_ticket()
          local buf = vim.api.nvim_get_current_buf()
          local name = vim.api.nvim_buf_get_name(buf)
          local file = vim.uv.fs_realpath(name)
          if ((vim.bo.filetype == "gitcommit") and file and (vim.fs.basename(file) == "COMMIT_EDITMSG") and not vim.b.ticket_prefix_checked and not vim.bo.modified and vim.bo.modifiable and not vim.bo.readonly) then
            vim.b.ticket_prefix_checked = true
            local gitdir = vim.fs.dirname(file)
            local tick = vim.api.nvim_buf_get_changedtick(buf)
            local env = vim.fn.environ()
            for _, key in ipairs({"GIT_DIR", "GIT_WORK_TREE", "GIT_COMMON_DIR", "GIT_NAMESPACE"}) do
              env[key] = nil
            end
            local function git(...)
              local argv = {"git", ("--git-dir=" .. gitdir)}
              local _ = vim.list_extend(argv, {...})
              local ok, result
              local function _1_()
                return vim.system(argv, {text = true, clear_env = true, env = env}):wait(300)
              end
              ok, result = pcall(_1_)
              if ok then
                return result
              else
                return nil
              end
            end
            local function operation_3f()
              local active = false
              for _, path in ipairs({"MERGE_HEAD", "SQUASH_MSG", "CHERRY_PICK_HEAD", "REVERT_HEAD", "rebase-merge", "rebase-apply", "sequencer"}) do
                if vim.uv.fs_stat((gitdir .. "/" .. path)) then
                  active = true
                else
                end
              end
              return active
            end
            if not operation_3f() then
              local branch = git("symbolic-ref", "--quiet", "--short", "HEAD")
              local segment = (branch and (branch.code == 0) and branch.stdout:match("([^/\n]+)\n$"))
              local ticket = (segment and segment:match("^([A-Z][A-Z0-9]*%-%d+)_[A-Za-z0-9][A-Za-z0-9_-]*$"))
              if ticket then
                local comment_prefix = nil
                do
                  local comment_config = git("config", "--null", "--get-regexp", "^core\\.comment(char|string)$")
                  if comment_config then
                    if (comment_config.code == 1) then
                      comment_prefix = "#"
                    elseif (comment_config.code == 0) then
                      for entry in comment_config.stdout:gmatch("([^%z]*)%z") do
                        comment_prefix = entry:match("^[^\n]+\n(.*)$")
                      end
                    else
                    end
                  else
                  end
                end
                if (comment_prefix and (comment_prefix ~= "") and (comment_prefix ~= "auto") and vim.api.nvim_buf_is_valid(buf) and (vim.api.nvim_get_current_buf() == buf) and (vim.api.nvim_buf_get_name(buf) == name) and (vim.api.nvim_buf_get_changedtick(buf) == tick) and (vim.bo.filetype == "gitcommit") and not vim.bo.modified and vim.bo.modifiable and not vim.bo.readonly and not operation_3f()) then
                  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                  local prefix = (ticket .. " ")
                  local empty = true
                  for _, line in ipairs(lines) do
                    if (not line:match("^%s*$") and (line:sub(1, #comment_prefix) ~= comment_prefix)) then
                      empty = false
                    else
                    end
                  end
                  if empty then
                    local _7_
                    if string.match(lines[1], "^%s*$") then
                      _7_ = 1
                    else
                      _7_ = 0
                    end
                    vim.api.nvim_buf_set_lines(buf, 0, _7_, false, {prefix})
                    return vim.api.nvim_win_set_cursor(0, {1, #ticket})
                  else
                    return nil
                  end
                else
                  return nil
                end
              else
                return nil
              end
            else
              return nil
            end
          else
            return nil
          end
        end
        return vim.api.nvim_create_autocmd("BufWinEnter", {buffer = vim.api.nvim_get_current_buf(), once = true, callback = prefill_ticket})
      '';
    "after/ftplugin/java.lua" = # lua
      ''
        local args = ${pkgs.lib.generators.toLua { } javaArgs}
        local jdk8_path = args.jdk8_path
        local jdk11_path = args.jdk11_path
        local jdk17_path = args.jdk17_path
        local jdk21_path = args.jdk21_path
        local java_path = args.java_path
        local jdtls_jar_pattern = args.jdtls_jar_pattern
        local jdtls_config_path = args.jdtls_config_path
        local lombok_jar_path = args.lombok_jar_path
        local attach_path = args.attach_path
        local jdtls = require("jdtls")
        local bufnr = vim.api.nvim_get_current_buf()
        if not ((vim.bo[bufnr].buftype == "") and (vim.bo[bufnr].filetype == "java") and (vim.api.nvim_buf_get_name(bufnr) ~= "") and vim.startswith(vim.uri_from_bufnr(bufnr), "file://")) then
          return
        else
        end
        local root_dir = (vim.fs.root(bufnr, {"gradlew", "mvnw", ".git"}) or vim.fn.getcwd())
        local workspace_dir = (os.getenv("HOME") .. "/.local/share/eclipse/" .. string.gsub(vim.fn.fnamemodify(root_dir, ":p:h"), "/", "_"))
        local _2_
        do
          local tmp_3_ = vim.uv.fs_stat(workspace_dir)
          if (nil ~= tmp_3_) then
            local tmp_3_0 = tmp_3_[type]
            if (nil ~= tmp_3_0) then
              _2_ = (tmp_3_0 == "directory")
            else
              _2_ = nil
            end
          else
            _2_ = nil
          end
        end
        if not _2_ then
          vim.uv.fs_mkdir(workspace_dir, 493)
        else
        end
        local cmd = {java_path, "-Declipse.application=org.eclipse.jdt.ls.core.id1", "-Dosgi.bundles.defaultStartLevel=4", "-Declipse.product=org.eclipse.jdt.ls.core.product", ("-Dosgi.sharedConfiguration.area=" .. jdtls_config_path), "-Dosgi.sharedConfiguration.area.readOnly=true", "-Dosgi.checkConfiguration=true", "-Dosgi.configuration.cascaded=true", "-Dlog.protocol=true", "-Dlog.level=ERROR", "-Xlog:disable", "-XX:+AlwaysPreTouch", "-Xmx10g", ("-javaagent:" .. lombok_jar_path), "--add-modules=ALL-SYSTEM", "--add-opens", "java.base/java.util=ALL-UNNAMED", "--add-opens", "java.base/java.lang=ALL-UNNAMED", "-jar", vim.fn.glob(jdtls_jar_pattern), "-data", workspace_dir}
        local settings
        do
          local enabled = {enabled = true}
          local disabled = {enabled = false}
          local favoriteStaticMembers = {"io.crate.testing.Asserts.assertThat", "java.util.Objects.requireNonNull", "java.util.Objects.requireNonNullElse", "org.assertj.core.api.Assertions.*", "org.assertj.core.api.Assertions.assertThat", "org.assertj.core.api.Assertions.assertThatExceptionOfType", "org.assertj.core.api.Assertions.assertThatThrownBy", "org.assertj.core.api.Assertions.catchThrowable", "org.hamcrest.CoreMatchers.*", "org.hamcrest.MatcherAssert.assertThat", "org.hamcrest.Matchers.*", "org.junit.jupiter.api.Assertions.*", "org.junit.jupiter.api.Assumptions.*", "org.junit.jupiter.api.DynamicContainer.*", "org.junit.jupiter.api.DynamicTest.*", "org.mockito.Answers.*", "org.mockito.ArgumentMatchers.*", "org.mockito.Mockito.*"}
          local filteredTypes = {"java.awt.*", "com.sun.*", "sun.*", "jdk.*", "io.micrometer.shaded.*"}
          local completion = {favoriteStaticMembers = favoriteStaticMembers, filteredTypes = filteredTypes}
          local edit = {smartSemicolonDetection = enabled, validateAllOpenBuffersOnChanges = false}
          local sources = {organizeImports = {starThreshold = 9999, staticStarThreshold = 9999}}
          local configuration = {runtimes = {{name = "JavaSE-1.8", path = jdk8_path}, {name = "JavaSE-11", path = jdk11_path}, {name = "JavaSE-17", path = jdk17_path}, {name = "JavaSE-21", path = jdk21_path, default = true}}}
          local java = {autobuild = disabled, maxConcurrentBuilds = 8, signatureHelp = enabled, format = disabled, configuration = configuration, completion = completion, edit = edit, sources = sources, referencesCodeLens = {enabled = true}, implementationsCodeLens = {enabled = true}, inlayHints = {parameterNames = {enabled = "all"}}}
          settings = {java = java}
        end
        local bundles = {}
        local extendedClientCapabilities = vim.tbl_deep_extend("force", jdtls.extendedClientCapabilities, {resolveAdditionalTextEditsSupport = true, progressReportProvider = false})
        local init_options = {bundles = bundles, extendedClientCapabilities = extendedClientCapabilities}
        local on_attach
        local function _7_(client, bufnr0)
          return dofile(attach_path)({buf = bufnr0, client = client})
        end
        on_attach = _7_
        local flags = {allow_incremental_sync = true, debounce_text_changes = 300}
        local handlers
        local function _8_()
        end
        handlers = {["language/status"] = _8_}
        return jdtls.start_or_attach({name = "jdtls", root_dir = root_dir, cmd = cmd, settings = settings, init_options = init_options, on_attach = on_attach, flags = flags, handlers = handlers}, nil, {bufnr = bufnr})
      '';
    "after/ftplugin/jproperties.lua" = # lua
      ''
        return vim.opt_local.iskeyword:append("-")
      '';
    "after/ftplugin/json.lua" = # lua
      ''
        return vim.keymap.set("n", "<LocalLeader>E", "<CMD>Videre<CR>", {buf = 0, silent = true})
      '';
    "after/ftplugin/lua.lua" = # lua
      "";
    "after/ftplugin/make.lua" = # lua
      ''
        vim.opt_local.expandtab = false
        return vim.opt_local.iskeyword:append("-")
      '';
    "after/ftplugin/markdown.lua" = # lua
      ''
        for key, value in pairs({foldcolumn = "0", listchars = "tab:> ", virtualedit = "all", number = false}) do
          vim.opt_local[key] = value
        end
        vim.keymap.set({"n", "i"}, "<D-v>", "<Plug>(mdpaste)", {buffer = true})
        if (vim.fn.expand("%:e") == "ipynb") then
          require("quarto").activate()
          require("otter").activate()
          local runner = require("quarto.runner")
          for mode, kvp in pairs({n = {["<LocalLeader>e"] = ":MoltenEvaluateOperator<CR>", ["<localleader>rr"] = runner.run_cell, ["<localleader>ra"] = runner.run_above, ["<localleader>rA"] = runner.run_all, ["<localleader>rl"] = runner.run_line, ["<localleader>mi"] = ":MoltenInit<CR>", ["<localleader>md"] = ":MoltenDelete<CR>"}, v = {["<localleader>r"] = runner.run_range}}) do
            for k, v in pairs(kvp) do
              vim.keymap.set(mode, k, v, {buf = 0, silent = true})
            end
          end
          return nil
        else
          return nil
        end
      '';
    "after/ftplugin/nix.lua" = # lua
      ''
        return vim.opt_local.iskeyword:append("-")
      '';
    "after/ftplugin/python.lua" = # lua
      ''
        if (vim.fn.expand("%:e") == "ipynb") then
          for mode, kvp in pairs({n = {["<LocalLeader>e"] = ":MoltenEvaluateOperator<CR>", ["<localleader>rr"] = ":MoltenReevaluateCell<CR>", ["<localleader>os"] = ":noautocmd MoltenEnterOutput<CR>", ["<localleader>oh"] = ":MoltenHideOutput<CR>", ["<localleader>mi"] = ":MoltenInit<CR>", ["<localleader>md"] = ":MoltenDelete<CR>"}, v = {["<localleader>r"] = ":<C-u>MoltenEvaluateVisual<CR>gv"}}) do
            for k, v in pairs(kvp) do
              vim.keymap.set(mode, k, v, {buf = 0, silent = true})
            end
          end
          return nil
        else
          return nil
        end
      '';
    "after/ftplugin/qf.lua" = # lua
      ''
        vim.opt_local.buflisted = false
        return nil
      '';
    "after/ftplugin/qfreplace.lua" = # lua
      ''
        local tmp_9_ = vim.opt_local
        tmp_9_["buflisted"] = false
        tmp_9_["bufhidden"] = "delete"
        return tmp_9_
      '';
    "after/ftplugin/rust.lua" = # lua
      ''
        local opt = {silent = true, buf = 0}
        local function _1_()
          return vim.cmd.RustLsp({"hover", "actions"})
        end
        for k, v in pairs({K = _1_}) do
          vim.keymap.set("n", k, v, opt)
        end
        return nil
      '';
    "after/ftplugin/teal.lua" = # lua
      "";
    "after/ftplugin/toml.lua" = # lua
      ''
        return vim.keymap.set("n", "<LocalLeader>E", "<CMD>Videre<CR>", {buf = 0, silent = true})
      '';
    "after/ftplugin/translate.lua" = # lua
      ''
        vim.opt_local.wrap = true
        return nil
      '';
    "after/ftplugin/yaml.lua" = # lua
      ''
        vim.opt_local.iskeyword:append("-")
        return vim.keymap.set("n", "<LocalLeader>E", "<CMD>Videre<CR>", {buf = 0, silent = true})
      '';
    "after/lsp/denols.lua" = # lua
      ''
        return {workspace_required = true, root_markers = {"deno.json", "deno.jsonc", ".deno_project"}, init_options = {lint = true, suggest = {completeFunctionCalls = true, names = true, paths = true, autoImports = true, imports = {autoDiscover = true, hosts = vim.empty_dict()}}, unstable = false}, settings = {deno = {enable = true}}, single_file_support = false}
      '';
    "after/lsp/efm.lua" = # lua
      ''
        local languages = {}
        local init_options = {documentFormatting = true, documentRangeFormatting = true}
        return {single_file_support = true, filetypes = vim.tbl_keys(languages), settings = {rootMarkers = {".git/"}, languages = languages}, init_options = init_options}
      '';
    "after/lsp/fennel_ls.lua" = # lua
      ''
        return {settings = {["fennel-ls"] = {["extra-globals"] = "vim"}}}
      '';
    "after/lsp/eslint.lua" = # lua
      ''
        local args = ${pkgs.lib.generators.toLua { } { node_path = "${pkgs.eslint}/lib/node_modules"; }}
        return {cmd = {"vscode-eslint-language-server", "--stdio"}, cmd_env = {NODE_PATH = args.node_path}, settings = {nodePath = vim.NIL, format = false}}
      '';
    "after/lsp/jdtls.lua" = # lua
      ''
        return {filetypes = {}}
      '';
    "after/lsp/lua_ls.lua" = # lua
      ''
        return {settings = {Lua = {runtime = {version = "LuaJIT", special = {reload = "require"}}, diagnostics = {globals = {"vim"}}}, workspace = {library = {vim.fn.expand("$VIMRUNTIME/lua"), "''${3rd}/luv/library"}}, telemetry = {enable = false}}}
      '';
    "after/lsp/nil_ls.lua" = # lua
      ''
        return {settings = {["nil"] = {formatting = {command = {"nixpkgs-fmt"}}, nix = {flake = {autoArchive = false}}}}}
      '';
    "after/lsp/pyright.lua" = # lua
      ''
        return {settings = {python = {pythonPath = ".venv/bin/python", analysis = {diagnosticSeverityOverrides = {reportUnusedExpression = "none"}}}}}
      '';
    "after/lsp/typos_lsp.lua" = # lua
      ''
        return {init_options = {diagnosticSeverity = "Warning"}}
      '';
    "after/lsp/vtsls.lua" = # lua
      ''
        local function _1_(err, result, ctx, config)
          local filtered
          if (not err and result and result.diagnostics) then
            local function _2_(d)
              return ((d.code ~= 80001) and (d.code ~= "80001"))
            end
            filtered = vim.tbl_extend("force", {}, result, {diagnostics = vim.tbl_filter(_2_, result.diagnostics)})
          else
            filtered = result
          end
          return vim.lsp.handlers["textDocument/publishDiagnostics"](err, filtered, ctx, config)
        end
        return {workspace_required = true, root_markers = {"tsconfig.json", "package.json", "jsconfig.json", ".node_project"}, handlers = {["textDocument/publishDiagnostics"] = _1_}, settings = {separate_diagnostic_server = true, publish_diagnostic_on = "insert_leave", typescript = {suggest = {completeFunctionCalls = true}, preferences = {importModuleSpecifier = "relative"}}}, flags = {debounce_text_changes = 1000}, vtsls = {experimental = {completion = {enableServerSideFuzzyMatch = true}}}, single_file_support = false}
      '';
    "after/lsp/yamlls.lua" = # lua
      ''
        return {settings = {yaml = {customTags = {"!And", "!Base64", "!Cidr", "!Equals", "!FindInMap sequence", "!GetAZs", "!GetAtt", "!If", "!ImportValue", "!Join sequence", "!Not", "!Or", "!Ref Scalar", "!Ref", "!Select", "!Split", "!Sub", "!fn"}, keyOrdering = false}}}
      '';
    "after/ftdetect/nginx.vim" = ''
      source ${nginxPlugin}/ftdetect/nginx.vim
      au BufRead,BufNewFile *.nginxconf set ft=nginx
    '';
  };
  runtime = pkgs.linkFarm "nvim-v3-core-runtime" (
    pkgs.lib.mapAttrsToList (name: text: {
      inherit name;
      path = pkgs.writeText (builtins.baseNameOf name) text;
    }) files
  );
  marker = pkgs.runCommand "nvim-v3-core" { } "mkdir -p $out";
in
{
  inherit runtime;
  startupConfig = ''
    vim.g._editor_open_cmd = "${editorWrapper}"
    vim.g._editor_open_cmd_wait = "${editorWrapperWait}"
  ''
  # lua
  + ''
    vim.loader.enable()
    require("vim._core.ui2").enable()
    if (vim.v.servername and (vim.v.servername ~= "")) then
      vim.env.NVIM_EDITOR_ADDR = vim.v.servername
    else
    end
    local function configure_editor_env()
      if vim.g._editor_open_cmd then
        vim.env.EDITOR = vim.g._editor_open_cmd
        vim.env.VISUAL = vim.g._editor_open_cmd
        vim.env.TIG_EDITOR = vim.g._editor_open_cmd
      else
      end
      if vim.g._editor_open_cmd_wait then
        vim.env.GIT_EDITOR = vim.g._editor_open_cmd_wait
        return nil
      else
        return nil
      end
    end
    configure_editor_env()
    vim.cmd("language messages en_US.UTF-8")
    pcall(dofile, vim.fn.expand("$HOME/config.lua"))
    for opt, kvp in pairs({opt = {langmenu = "none", timeoutlen = 1000, shortmess = (vim.o.shortmess .. "sWcS"), cmdheight = 0, signcolumn = "yes", laststatus = 0, statusline = "%=", showtabline = 0, splitkeep = "screen", foldcolumn = "1", foldlevel = 99, foldlevelstart = 99, foldenable = true, switchbuf = "", splitbelow = true, splitright = true, winborder = "single", number = false, showmode = false, wrap = false}, g = {mapleader = " ", maplocalleader = ",", loaded_netrw = 1, loaded_netrwPlugin = 1, no_plugin_maps = true}}) do
      for k, v in pairs(kvp) do
        vim[opt][k] = v
      end
    end
  ''
  + ''
    if vim.g.neovide then
  ''
  # lua
  + ''
    for k, v in pairs({neovide_cursor_animation_length = 0.1, neovide_floating_corner_radius = 0.25, neovide_hide_mouse_when_typing = true, neovide_opacity = 0.9, neovide_padding_bottom = 5, neovide_padding_left = 5, neovide_padding_right = 5, neovide_window_blurred = true, neovide_padding_top = 10, neovide_confirm_quit = false, neovide_cursor_animate_in_insert_mode = false, neovide_cursor_antialiasing = false, neovide_floating_shadow = false, neovide_input_ime = false, neovide_macos_simple_fullscreen = false}) do
      vim.g[k] = v
    end
    local map = vim.keymap.set
    local scale = 1.1
    local change_scale
    local function _1_(delta)
      vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor * delta)
      return nil
    end
    change_scale = _1_
    local toggle_zoom
    local function _2_()
      vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
      return nil
    end
    toggle_zoom = _2_
    local toggle_blur
    local function _3_()
      vim.g.neovide_window_blurred = not vim.g.neovide_window_blurred
      return nil
    end
    toggle_blur = _3_
    local paste_from_clipboard_insert
    local function _4_()
      local lines = vim.fn.getreg("+", 1, true)
      if (#lines == 1) then
        return vim.api.nvim_paste(lines[1], true, -1)
      else
        return vim.api.nvim_put(lines, vim.fn.getregtype("+"), true, true)
      end
    end
    paste_from_clipboard_insert = _4_
    vim.o.guifont = "PlemolJP Console NF:h15"
    local function _6_()
      return change_scale(scale)
    end
    map("n", "<C-=>", _6_)
    local function _7_()
      return change_scale(scale)
    end
    map("n", "<C-+>", _7_)
    local function _8_()
      return change_scale((1 / scale))
    end
    map("n", "<C-->", _8_)
    map("n", "<A-Enter>", toggle_zoom)
    map("n", "<A-Tab>", toggle_blur)
    map("i", "<D-v>", paste_from_clipboard_insert)
    map("c", "<D-v>", "<C-r>+")
    map("t", "<D-v>", "<C-\\><C-n>\"+pi")
    vim.api.nvim_create_user_command("ToggleNeovideFullScreen", toggle_zoom, {})
    return vim.api.nvim_create_user_command("ToggleNeovideBlur", toggle_blur, {})
  ''
  + ''
    end
  '';
  definition = {
    plugin = marker;
    extraPackages = [ pkgs.jq ];
    # The default profile adds all configured plugins as explicit dependencies.
    config = # lua
      ''
        local function link_statusline_to_separator()
          vim.api.nvim_set_hl(0, "StatusLine", {link = "WinSeparator"})
          return vim.api.nvim_set_hl(0, "StatusLineNC", {link = "WinSeparator"})
        end
        link_statusline_to_separator()
        vim.api.nvim_create_autocmd("ColorScheme", {callback = link_statusline_to_separator})
        do
          local S = require("snacks")
          local opts = {noremap = true, silent = true}
          local desc
          local function _4_(d)
            return {noremap = true, silent = true, desc = d}
          end
          desc = _4_
          local lua_
          local function _5_(mod, f, opt)
            local function _6_()
              if (opt == nil) then
                return require(mod)[f]()
              else
                return require(mod)[f](opt)
              end
            end
            return _6_
          end
          lua_ = _5_
          local toggle
          local function _8_(id)
            local function _9_()
              return require("toggler").toggle(id)
            end
            return _9_
          end
          toggle = _8_
          local function _13_()
            return vim.cmd(("Track open " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")))
          end
          for m, ks in pairs({n = {{"j", "gj"}, {"k", "gk"}, {"\194\165", "\\"}, {"<C-l>", "<Cmd>nohl<CR><C-l>"}, {"*", "<Plug>(asterisk-z*)", {silent = true}}, {"#", "<Plug>(asterisk-z#)", {silent = true}}, {"g*", "<Plug>(asterisk-gz*)", {silent = true}}, {"g#", "<Plug>(asterisk-gz#)", {silent = true}}, {"<C-Space>", "<Cmd>OpenMenu<CR>"}, {"<C-o>", "<Cmd>KomadoToggle<CR>"}, {"<Leader>q", S.bufdelete.delete, desc("close buffer")}, {"<Leader>Q", S.bufdelete.all, desc("close all buffers")}, {"<Leader>A", "<Cmd>tabclose<CR>"}, {"<Leader>tq", toggle("qf"), desc("\239\136\132 quickfix")}, {"<Leader>tb", lua_("oil", "open"), desc("\239\136\132 explorer")}, {"<Leader>td", toggle("trouble-doc"), desc("\239\136\132 diagnostics (doc)")}, {"<Leader>tD", toggle("trouble-ws"), desc("\239\136\132 diagnostics (ws)")}, {"<Leader>tR", lua_("spectre", "toggle"), desc("\239\136\132 replace")}, {"<Leader>H", toggle("harpoon"), desc("\243\176\162\183 show items")}, {"<Leader>ha", "<Cmd>lua require('harpoon'):list():add()<CR>", desc("\243\176\162\183 register item")}, {"<Leader>fa", "<Cmd>Telescope worktab<CR>", desc("\238\169\173 worktab")}, {"<Leader>ff", "<Cmd>Telescope live_grep_args<CR>", desc("\238\169\173 livegrep")}, {"<Leader>fp", "<Cmd>Telescope find_files find_command=rg,--files,--hidden,-g,!.git<CR>", desc("\238\169\173 files")}, {"<Leader>Ff", "<Cmd>Telescope live_grep_args cwd=~/ghq<CR>", desc("\238\169\173 livegrep (ghq)")}, {"<Leader>Fp", "<Cmd>Telescope find_files cwd=~/ghq<CR>", desc("\238\169\173 files (ghq)")}, {"<Leader>fP", "<Cmd>Telescope ghq previewer=false<CR>", desc("\238\169\173 project files")}, {"<Leader>fb", "<Cmd>TelescopeBuffer<CR>", desc("\238\169\173 buffer")}, {"<Leader>fB", "<Cmd>TelescopeBufferName<CR>", desc("\238\169\173 buffer")}, {"<Leader>ft", "<Cmd>Telescope pterm<CR>", desc("\238\169\173 terminal")}, {"<Leader>fT", "<Cmd>Telescope sonictemplate templates<CR>", desc("\238\169\173 template")}, {"<Leader>fn", "<Cmd>NeorgFuzzySearch<CR>", desc("\238\152\179 fuzzy search")}, {"<Leader>fN", "<Cmd>NeorgFindFile<CR>", desc("\238\152\179 find file")}, {"<Leader>G", "<Cmd>Gitu<CR>", desc("\239\135\147 client")}, {"<Leader>go", "<Cmd>TracePR<CR>", desc("\239\135\147 open PR")}, {"<Leader>N", "<Cmd>Neorg<CR>", desc("\238\152\179 enter")}, {"<Leader>ny", "<Cmd>Neorg journal yesterday<CR>", desc("\238\152\179 yesterday")}, {"<Leader>nt", "<Cmd>Neorg journal today<CR>", desc("\238\152\179 today")}, {"<Leader>nT", "<Cmd>Neorg journal tomorrow<CR>", desc("\238\152\179 tomorrow")}, {"<Leader>nn", "<Cmd>NeorgScratch<CR>", desc("\238\152\179 scratch")}, {"<Leader>ngg", "<Cmd>NeorgGit<CR>", desc("\238\152\179 Git")}, {"<Leader>ngb", "<Cmd>NeorgGitBranch<CR>", desc("\238\152\179 Git (branch)")}, {"<Leader>aa", "<Cmd>AvanteAsk<CR>"}, {"<Leader>at", "<Cmd>AvanteToggle<CR>"}, {"<Leader>tt", "<Cmd>Track today<CR>", desc("\239\137\137 journal today")}, {"<Leader>tn", "<Cmd>Track open<CR>", desc("\239\137\137 open note")}, {"<Leader>tf", "<Cmd>Track search_body<CR>", desc("\239\137\137 find note (body)")}, {"<Leader>tg", _13_, desc("\239\137\137 open workdir note")}, {"<Leader>tF", "<Cmd>Track search_title<CR>", desc("\239\137\137 find note (title)")}, {"<Leader>ot", "<Cmd>Obsidian today<CR>", desc("\239\137\137 journal today")}, {"<Leader>oy", "<Cmd>Obsidian yesterday<CR>", desc("\239\137\137 journal yesterday")}, {"<Leader>oo", "<Cmd>ObsidianScratch<CR>", desc("\239\137\137 new note")}, {"<Leader>ogg", "<Cmd>ObsidianGit<CR>", desc("\239\137\137 Git")}, {"<Leader>ogb", "<Cmd>ObsidianGitBranch<CR>", desc("\239\137\137 Git branch")}, {"<Leader>on", "<Cmd>Obsidian new<CR>", desc("\239\137\137 new note")}, {"<Leader>fo", "<Cmd>Obsidian search<CR>", desc("\239\137\137 fuzzy search")}}, i = {{"\194\165", "\\"}}, c = {{"\194\165", "\\"}}, t = {{"\194\165", "\\"}, {"<S-Space>", "<Space>"}}, v = {{"\194\165", "\\"}}}) do
            for _, k in ipairs(ks) do
              vim.keymap.set(m, k[1], k[2], (k[3] or opts))
            end
          end
          for i = 0, 9 do
            vim.keymap.set({"n", "t", "i"}, ("<C-" .. i .. ">"), toggle(("term" .. i)), opts)
          end
        end
        for lhs, rhs in pairs({["<C-Space>"] = "<C-n>", ["<C-S-Space>"] = "<C-p>", ["<C-a>"] = "<Home>", ["<C-e>"] = "<End>"}) do
          vim.keymap.set("i", lhs, rhs, {noremap = true})
        end
        vim.cmd("colorscheme sorairo")
        return require("config-local").setup({silent = true})
      '';
    doc = ''
      Core owns editor options, mappings, Neovide settings, remote editor wrappers,
      and the native after/ftplugin and after/lsp runtime tree. Root startupConfig
      establishes leaders and netrw globals before any plugin executes; this
      cartridge's config runs after the default profile's plugin dependencies.
      Lua configuration is owned here; no legacy files are read at evaluation or
      runtime. Java and ESLint receive their original per-file args as local Lua
      tables, including the packaged JDK 25 launcher and owned LSP attach helper.

      EDITOR, VISUAL and TIG_EDITOR use the existing Neovim server when available;
      GIT_EDITOR waits for the buffer to close. +N and file:N positions work both
      remotely and in a new editor. Personal ~/config.lua and config-local remain
      enabled, so reproducible checks use an isolated HOME.

      Denops-dependent Telescope MR mappings are intentionally omitted. Existing
      Neorg and Avante mappings are retained for compatibility although those
      plugins were not enabled by the source profile. Eager Telescope ui-select
      registers the real handler directly, replacing the legacy lazy trampoline.
      Deno LSP is retained: it is not a Denops dependency.
    '';
    tests.core-runtime =
      {
        pkgs,
        neovim,
        bundle,
        ...
      }:
      let
        python = pkgs.python3.withPackages (ps: [ ps.pynvim ]);
        assertions = pkgs.writeText "core-runtime-check.py" ''
          """Real full-profile RPC smoke test, with no external AI/service calls."""
          import os
          import pathlib
          import json
          import signal
          import sys
          import time
          import pynvim

          # Bound hangs even when an editor callback blocks an RPC request.
          signal.alarm(120)
          nvim = pynvim.attach("child", argv=[sys.argv[1], "--embed", "--headless", "-n", "-i", "NONE"])

          def lua(code, *args):
              return nvim.exec_lua(code, *args)

          def wait(predicate, label, timeout=15):
              deadline = time.monotonic() + timeout
              while time.monotonic() < deadline:
                  if predicate():
                      return
                  time.sleep(0.025)
              raise AssertionError(label + ": " + nvim.command_output("messages"))

          def send(keys):
              nvim.input(keys)
              nvim.eval("1")

          def buffer(ft, lines=None):
              # Native FileType/ftplugin execution, but scratch buffers keep LSP
              # processes and project discovery out of this offline smoke test.
              lua('local b = vim.api.nvim_create_buf(false, true); vim.api.nvim_set_current_buf(b)')
              if lines is not None:
                  nvim.current.buffer[:] = lines
              nvim.current.buffer.options["filetype"] = ft

          try:
              assert lua('return vim.tbl_contains(vim.v.argv, vim.env.CORE_TEST_BUNDLE .. "/init.lua")')
              assert nvim.eval("v:errmsg") == "", (nvim.eval("v:errmsg"), nvim.command_output("messages"))
              assert nvim.vars["mapleader"] == " "
              assert nvim.vars["maplocalleader"] == ","
              assert nvim.vars["colors_name"] == "sorairo"
              assert nvim.options["splitbelow"] and nvim.options["splitright"]
              assert nvim.current.window.options["foldmethod"] == "expr"
              assert nvim.options["winborder"] == "single"
              assert lua('return vim.env.EDITOR == vim.g._editor_open_cmd')
              assert lua('return vim.env.GIT_EDITOR == vim.g._editor_open_cmd_wait')
              for key in ["<Leader>fru", "<Leader>frr", "<Leader>frw", "<Leader>Fru", "<Leader>Frr", "<Leader>Frw"]:
                  assert nvim.call("maparg", key, "n") == "", key
              assert nvim.call("maparg", "<Leader>fp", "n")
              for command in ["Telescope", "Track", "Gitu", "KomadoToggle", "DiffviewOpen", "Obsidian", "Videre"]:
                  assert nvim.call("exists", ":" + command) == 2, command
              for command in ["Gin", "Denops"]:
                  assert nvim.call("exists", ":" + command) == 0, command
              assert nvim.call("exists", "g:loaded_skkeleton") == 0
              assert not lua('return package.loaded["denops"] ~= nil')

              configured = lua('local t = {}; for _, s in ipairs(require("cmp").get_config().sources) do t[s.name] = true end; return t')
              for source in ["nvim_lsp", "luasnip", "buffer"]:
                  assert configured.get(source), (source, configured)
              send("i")
              wait(lambda: nvim.eval("mode()") == "i", "enter insert for cmp registration")
              registered = lua('local t = {}; for _, s in pairs(require("cmp").core.sources) do t[s.name] = true end; return t')
              for source in ["luasnip", "buffer", "path", "cmdline"]:
                  assert registered.get(source), (source, registered)
              send("<Esc>")
              wait(lambda: nvim.eval("mode()") == "n", "leave insert")

              # Run a genuine packaged language server in an isolated project.
              project = pathlib.Path(os.environ["HOME"]) / "lua-project"
              project.mkdir()
              (project / ".luarc.json").write_text(json.dumps({"diagnostics": {"enable": True, "globals": []}, "workspace": {"checkThirdParty": False}, "telemetry": {"enable": False}}))
              target = project / "main.lua"
              target.write_text("local answer = unknown_migration_global\nprint(answer)\n")
              nvim.command("edit " + nvim.call("fnameescape", str(target)))
              wait(lambda: lua('return #vim.lsp.get_clients({bufnr = 0, name = "lua_ls"}) > 0'), "Lua LSP attach", 30)
              wait(lambda: lua('for _, d in ipairs(vim.diagnostic.get(0)) do if tostring(d.code) == "undefined-global" and d.message:find("unknown_migration_global", 1, true) then return true end end; return false'), "Lua LSP diagnostic", 30)
              assert nvim.current.buffer.vars["lsp_attached"]
              assert nvim.call("maparg", "gd", "n", False, True).get("buffer") == 1
              send("i")
              wait(lambda: nvim.eval("mode()") == "i", "enter insert with LSP")
              wait(lambda: lua('for _, s in pairs(require("cmp").core.sources) do if s.name == "nvim_lsp" then return true end end; return false'), "register LSP cmp source")
              send("<Esc>")
              wait(lambda: nvim.eval("mode()") == "n", "leave LSP insert")
              lua('for _, c in ipairs(vim.lsp.get_clients({bufnr = 0})) do c:stop(true) end')
              buffer("javascript")
              gf = nvim.call("maparg", "gf", "n", False, True)
              assert gf.get("buffer") == 1 and gf.get("desc") == "SFCC cartridge gf", gf
              buffer("lua", ["local answer = 42"])
              gf = nvim.call("maparg", "gf", "n", False, True)
              assert gf.get("desc") != "SFCC cartridge gf", gf
              assert lua('local p = vim.treesitter.get_parser(0, "lua"); local trees = p:parse(); return #trees > 0 and trees[1]:root():type() == "chunk"')
              # Exercise the real core Tree-sitter highlighting compatibility
              # path, including multiline captures and rendered minimap extmarks.
              nvim.options["columns"] = 120
              nvim.options["lines"] = 40
              nvim.current.buffer[:] = ["local value = 42", "--[[ multi", "line comment", "ends here ]]", "return value", ""]
              lua('vim.treesitter.start(0, "lua"); vim.treesitter.get_parser(0):parse()')
              assert lua('return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil')
              assert lua('local h = require("codewindow.highlight").extract_highlighting(vim.api.nvim_get_current_buf(), vim.api.nvim_buf_get_lines(0, 0, -1, false)); if not h or #h ~= 2 then return false end; for _, row in ipairs(h) do for _, cell in ipairs(row) do if #cell > 0 then return true end end end; return false')
              # Codewindow intentionally ignores nofile buffers.
              nvim.current.buffer.options["buftype"] = ""
              assert lua('local n = #vim.api.nvim_list_wins(); require("codewindow").open_minimap(); return #vim.api.nvim_list_wins() == n + 1')
              assert lua('local ns = vim.api.nvim_get_namespaces()["codewindow.highlight"]; local n = 0; for _, b in ipairs(vim.api.nvim_list_bufs()) do n = n + #vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, {}) end; return n > 0')
              assert lua('local n = #vim.api.nvim_list_wins(); require("codewindow").close_minimap(); return #vim.api.nvim_list_wins() == n - 1')
              nvim.current.buffer.options["buftype"] = "nofile"
              buffer("fennel")
              assert "?" in nvim.current.buffer.options["iskeyword"]
              buffer("make")
              assert not nvim.current.buffer.options["expandtab"]
              buffer("json")
              assert "Videre" in nvim.call("maparg", "<LocalLeader>E", "n")
              buffer("markdown")
              assert nvim.current.window.options["foldcolumn"] == "0"
              assert nvim.current.window.options["virtualedit"] == "all"
              assert "mdpaste" in nvim.call("maparg", "<D-v>", "i")
              buffer("qfreplace")
              assert not nvim.current.buffer.options["buflisted"]
              assert nvim.current.buffer.options["bufhidden"] == "delete"
              assert lua('local c = dofile("${runtime}/after/lsp/eslint.lua"); return c.cmd_env.NODE_PATH == "${pkgs.eslint}/lib/node_modules"')

              # Exercise real terminal callbacks and the migrated Goda popup,
              # using only local cat. Do not launch configured AI terminals.
              nvim.command("enew")
              nvim.command("terminal " + os.environ["CORE_TEST_CAT"])
              terminal = nvim.current.buffer
              send("i")
              wait(lambda: nvim.eval("mode()") == "t", "enter terminal")
              assert nvim.call("maparg", "<C-g>", "t", False, True).get("desc") == "SKK input helper"
              send("<C-g>")
              wait(lambda: nvim.current.buffer.options["filetype"] == "skk-terminal-input", "open terminal input popup")
              wait(lambda: nvim.call("goda_skk#is_enabled"), "enable Goda in popup")
              nvim.current.buffer[:] = ["migration-terminal-ok"]
              send("<C-s>")
              assert nvim.eval("v:errmsg") == "", nvim.eval("v:errmsg")
              wait(lambda: nvim.current.buffer.number == terminal.number, "close and send popup")
              wait(lambda: "migration-terminal-ok" in "\n".join(terminal[:]), "terminal receives popup input")
              wait(lambda: nvim.eval("mode()") == "t", "restore terminal focus")
              send("<C-g>")
              wait(lambda: nvim.current.buffer.options["filetype"] == "skk-terminal-input", "reopen terminal input")
              send("<C-c>")
              assert nvim.eval("v:errmsg") == "", nvim.eval("v:errmsg")
              wait(lambda: nvim.current.buffer.number == terminal.number, "cancel terminal popup")
              send("<C-\\><C-n>")
              assert nvim.eval("v:errmsg") == "", (nvim.eval("v:errmsg"), nvim.command_output("messages"))
              print("Full profile: core, commands, cmp, Lua LSP, SFCC, parser, Codewindow, ftplugins and terminal popup passed")
          finally:
              try:
                  nvim.command("qa!")
              except EOFError:
                  pass
              nvim.close()
        '';
      in
      pkgs.runCommand "nvim-v3-core-runtime-check" { } ''
        export HOME="$TMPDIR/home"
        export XDG_CONFIG_HOME="$TMPDIR/config" XDG_DATA_HOME="$TMPDIR/data"
        export XDG_STATE_HOME="$TMPDIR/state" XDG_CACHE_HOME="$TMPDIR/cache"
        export CORE_TEST_BUNDLE=${bundle}
        export CORE_TEST_CAT=${pkgs.coreutils}/bin/cat
        mkdir -p "$HOME"
        ${python}/bin/python ${assertions} ${neovim}/bin/nvim
        touch "$out"
      '';
  };
}
