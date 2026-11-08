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
        vim.opt_local.iskeyword:append({ "-", "?" })
      '';
    "after/ftplugin/fsharp.lua" = # lua
      ''
        vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
          buffer = 0,
          callback = function()
            vim.lsp.codelens.enable(true, { bufnr = 0 })
          end,
        })
      '';
    "after/ftplugin/gitcommit.lua" = # lua
      ''
        vim.opt_local.iskeyword:append("-")
        vim.bo.bufhidden = "wipe"

        local function prefill_ticket()
          local buf = vim.api.nvim_get_current_buf()
          local name = vim.api.nvim_buf_get_name(buf)
          local file = vim.uv.fs_realpath(name)
          local function editable()
            return vim.bo.filetype == "gitcommit"
              and not vim.bo.modified and vim.bo.modifiable and not vim.bo.readonly
          end
          if not editable() or not file or vim.fs.basename(file) ~= "COMMIT_EDITMSG"
            or vim.b.ticket_prefix_checked then
            return
          end
          vim.b.ticket_prefix_checked = true

          local gitdir = vim.fs.dirname(file)
          local tick = vim.api.nvim_buf_get_changedtick(buf)
          local env = vim.fn.environ()
          -- A persistent editor can belong to another repository or worktree.
          for _, key in ipairs({ "GIT_DIR", "GIT_WORK_TREE", "GIT_COMMON_DIR", "GIT_NAMESPACE" }) do
            env[key] = nil
          end
          local function git(...)
            local argv = vim.list_extend({ "git", "--git-dir=" .. gitdir }, { ... })
            local ok, result = pcall(function()
              return vim.system(argv, { text = true, clear_env = true, env = env }):wait(300)
            end)
            if ok then
              return result
            end
          end
          local function operation_in_progress()
            for _, marker in ipairs({
              "MERGE_HEAD", "SQUASH_MSG", "CHERRY_PICK_HEAD", "REVERT_HEAD",
              "rebase-merge", "rebase-apply", "sequencer",
            }) do
              if vim.uv.fs_stat(gitdir .. "/" .. marker) then
                return true
              end
            end
            return false
          end
          if operation_in_progress() then
            return
          end

          local branch = git("symbolic-ref", "--quiet", "--short", "HEAD")
          local segment = branch and branch.code == 0 and branch.stdout:match("([^/\n]+)\n$")
          local ticket = segment and segment:match("^([A-Z][A-Z0-9]*%-%d+)_[A-Za-z0-9][A-Za-z0-9_-]*$")
          if not ticket then
            return
          end
          -- commentChar and commentString share configuration order: last wins.
          local comment_prefix
          local config = git("config", "--null", "--get-regexp", "^core\\.comment(char|string)$")
          if config and config.code == 1 then
            comment_prefix = "#"
          elseif config and config.code == 0 then
            for entry in config.stdout:gmatch("([^%z]*)%z") do
              comment_prefix = entry:match("^[^\n]+\n(.*)$")
            end
          end
          if not comment_prefix or comment_prefix == "" or comment_prefix == "auto"
            or not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_get_current_buf() ~= buf
            or vim.api.nvim_buf_get_name(buf) ~= name
            or vim.api.nvim_buf_get_changedtick(buf) ~= tick
            or not editable() or operation_in_progress() then
            return
          end

          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          for _, line in ipairs(lines) do
            if not line:match("^%s*$") and line:sub(1, #comment_prefix) ~= comment_prefix then
              return
            end
          end
          -- An entirely empty amend has no reliable operation marker.
          local replace_first = lines[1]:match("^%s*$") and 1 or 0
          vim.api.nvim_buf_set_lines(buf, 0, replace_first, false, { ticket .. " " })
          vim.api.nvim_win_set_cursor(0, { 1, #ticket })
        end

        -- FileType runs during the read; BufWinEnter keeps insertion modified.
        vim.api.nvim_create_autocmd("BufWinEnter", {
          buffer = vim.api.nvim_get_current_buf(),
          once = true,
          callback = prefill_ticket,
        })
      '';
    "after/ftplugin/java.lua" = # lua
      ''
        local args = ${pkgs.lib.generators.toLua { } javaArgs}
        local jdtls = require("jdtls")
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype ~= "java"
          or vim.api.nvim_buf_get_name(bufnr) == ""
          or not vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
          return
        end

        local root_dir = vim.fs.root(bufnr, { "gradlew", "mvnw", ".git" }) or vim.fn.getcwd()
        local workspace_dir = os.getenv("HOME") .. "/.local/share/eclipse/"
          .. vim.fn.fnamemodify(root_dir, ":p:h"):gsub("/", "_")
        vim.fn.mkdir(workspace_dir, "p")

        return jdtls.start_or_attach({
          name = "jdtls",
          root_dir = root_dir,
          cmd = {
            args.java_path,
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dosgi.sharedConfiguration.area=" .. args.jdtls_config_path,
            "-Dosgi.sharedConfiguration.area.readOnly=true",
            "-Dosgi.checkConfiguration=true",
            "-Dosgi.configuration.cascaded=true",
            "-Dlog.protocol=true",
            "-Dlog.level=ERROR",
            "-Xlog:disable",
            "-XX:+AlwaysPreTouch",
            "-Xmx10g",
            "-javaagent:" .. args.lombok_jar_path,
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", vim.fn.glob(args.jdtls_jar_pattern),
            "-data", workspace_dir,
          },
          settings = {
            java = {
              autobuild = { enabled = false },
              maxConcurrentBuilds = 8,
              signatureHelp = { enabled = true },
              format = { enabled = false },
              configuration = {
                runtimes = {
                  { name = "JavaSE-1.8", path = args.jdk8_path },
                  { name = "JavaSE-11", path = args.jdk11_path },
                  { name = "JavaSE-17", path = args.jdk17_path },
                  { name = "JavaSE-21", path = args.jdk21_path, default = true },
                },
              },
              completion = {
                favoriteStaticMembers = {
                  "io.crate.testing.Asserts.assertThat",
                  "java.util.Objects.requireNonNull",
                  "java.util.Objects.requireNonNullElse",
                  "org.assertj.core.api.Assertions.*",
                  "org.assertj.core.api.Assertions.assertThat",
                  "org.assertj.core.api.Assertions.assertThatExceptionOfType",
                  "org.assertj.core.api.Assertions.assertThatThrownBy",
                  "org.assertj.core.api.Assertions.catchThrowable",
                  "org.hamcrest.CoreMatchers.*",
                  "org.hamcrest.MatcherAssert.assertThat",
                  "org.hamcrest.Matchers.*",
                  "org.junit.jupiter.api.Assertions.*",
                  "org.junit.jupiter.api.Assumptions.*",
                  "org.junit.jupiter.api.DynamicContainer.*",
                  "org.junit.jupiter.api.DynamicTest.*",
                  "org.mockito.Answers.*",
                  "org.mockito.ArgumentMatchers.*",
                  "org.mockito.Mockito.*",
                },
                filteredTypes = { "java.awt.*", "com.sun.*", "sun.*", "jdk.*", "io.micrometer.shaded.*" },
              },
              edit = {
                smartSemicolonDetection = { enabled = true },
                validateAllOpenBuffersOnChanges = false,
              },
              sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
              referencesCodeLens = { enabled = true },
              implementationsCodeLens = { enabled = true },
              inlayHints = { parameterNames = { enabled = "all" } },
            },
          },
          init_options = {
            bundles = {},
            extendedClientCapabilities = vim.tbl_deep_extend("force", jdtls.extendedClientCapabilities, {
              resolveAdditionalTextEditsSupport = true,
              progressReportProvider = false,
            }),
          },
          on_attach = function(client, buf)
            dofile(args.attach_path)({ buf = buf, client = client })
          end,
          flags = { allow_incremental_sync = true, debounce_text_changes = 300 },
          handlers = { ["language/status"] = function() end },
        }, nil, { bufnr = bufnr })
      '';
    "after/ftplugin/jproperties.lua" = # lua
      ''
        vim.opt_local.iskeyword:append("-")
      '';
    "after/ftplugin/json.lua" = # lua
      ''
        vim.keymap.set("n", "<LocalLeader>E", "<Cmd>Videre<CR>", { buffer = true, silent = true })
      '';
    "after/ftplugin/lua.lua" = "";
    "after/ftplugin/make.lua" = # lua
      ''
        vim.opt_local.expandtab = false
        vim.opt_local.iskeyword:append("-")
      '';
    "after/ftplugin/markdown.lua" = # lua
      ''
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.listchars = "tab:> "
        vim.opt_local.virtualedit = "all"
        vim.opt_local.number = false
        vim.keymap.set({ "n", "i" }, "<D-v>", "<Plug>(mdpaste)", { buffer = true })

        if vim.fn.expand("%:e") == "ipynb" then
          require("quarto").activate()
          require("otter").activate()
          local runner = require("quarto.runner")
          for key, action in pairs({
            ["<LocalLeader>e"] = ":MoltenEvaluateOperator<CR>",
            ["<LocalLeader>rr"] = runner.run_cell,
            ["<LocalLeader>ra"] = runner.run_above,
            ["<LocalLeader>rA"] = runner.run_all,
            ["<LocalLeader>rl"] = runner.run_line,
            ["<LocalLeader>mi"] = ":MoltenInit<CR>",
            ["<LocalLeader>md"] = ":MoltenDelete<CR>",
          }) do
            vim.keymap.set("n", key, action, { buffer = true, silent = true })
          end
          vim.keymap.set("v", "<LocalLeader>r", runner.run_range, { buffer = true, silent = true })
        end
      '';
    "after/ftplugin/nix.lua" = # lua
      ''
        vim.opt_local.iskeyword:append("-")
      '';
    "after/ftplugin/python.lua" = # lua
      ''
        if vim.fn.expand("%:e") == "ipynb" then
          for key, action in pairs({
            ["<LocalLeader>e"] = ":MoltenEvaluateOperator<CR>",
            ["<LocalLeader>rr"] = ":MoltenReevaluateCell<CR>",
            ["<LocalLeader>os"] = ":noautocmd MoltenEnterOutput<CR>",
            ["<LocalLeader>oh"] = ":MoltenHideOutput<CR>",
            ["<LocalLeader>mi"] = ":MoltenInit<CR>",
            ["<LocalLeader>md"] = ":MoltenDelete<CR>",
          }) do
            vim.keymap.set("n", key, action, { buffer = true, silent = true })
          end
          vim.keymap.set("v", "<LocalLeader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", {
            buffer = true,
            silent = true,
          })
        end
      '';
    "after/ftplugin/qf.lua" = # lua
      ''
        vim.opt_local.buflisted = false
      '';
    "after/ftplugin/qfreplace.lua" = # lua
      ''
        vim.opt_local.buflisted = false
        vim.opt_local.bufhidden = "delete"
      '';
    "after/ftplugin/rust.lua" = # lua
      ''
        vim.keymap.set("n", "K", function()
          vim.cmd.RustLsp({ "hover", "actions" })
        end, { buffer = true, silent = true })
      '';
    "after/ftplugin/teal.lua" = "";
    "after/ftplugin/toml.lua" = # lua
      ''
        vim.keymap.set("n", "<LocalLeader>E", "<Cmd>Videre<CR>", { buffer = true, silent = true })
      '';
    "after/ftplugin/translate.lua" = # lua
      ''
        vim.opt_local.wrap = true
      '';
    "after/ftplugin/yaml.lua" = # lua
      ''
        vim.opt_local.iskeyword:append("-")
        vim.keymap.set("n", "<LocalLeader>E", "<Cmd>Videre<CR>", { buffer = true, silent = true })
      '';
    "after/lsp/denols.lua" = # lua
      ''
        return {
          single_file_support = false,
          workspace_required = true,
          root_markers = { "deno.json", "deno.jsonc", ".deno_project" },
          init_options = {
            lint = true,
            unstable = false,
            suggest = {
              completeFunctionCalls = true,
              names = true,
              paths = true,
              autoImports = true,
              imports = { autoDiscover = true, hosts = vim.empty_dict() },
            },
          },
          settings = { deno = { enable = true } },
        }
      '';
    "after/lsp/efm.lua" = # lua
      ''
        local languages = {}
        return {
          single_file_support = true,
          filetypes = vim.tbl_keys(languages),
          settings = { rootMarkers = { ".git/" }, languages = languages },
          init_options = { documentFormatting = true, documentRangeFormatting = true },
        }
      '';
    "after/lsp/fennel_ls.lua" = # lua
      ''
        return { settings = { ["fennel-ls"] = { ["extra-globals"] = "vim" } } }
      '';
    "after/lsp/eslint.lua" = # lua
      ''
        local args = ${pkgs.lib.generators.toLua { } { node_path = "${pkgs.eslint}/lib/node_modules"; }}
        return {
          cmd = { "vscode-eslint-language-server", "--stdio" },
          -- Project-local ESLint wins over this packaged fallback.
          cmd_env = { NODE_PATH = args.node_path },
          -- Keep formatting with Prettier/Biome, while retaining code actions.
          settings = { nodePath = vim.NIL, format = false },
        }
      '';
    "after/lsp/jdtls.lua" = # lua
      ''
        -- Java's ftplugin starts JDT LS with its per-project workspace.
        return { filetypes = {} }
      '';
    "after/lsp/lua_ls.lua" = # lua
      ''
        return {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT", special = { reload = "require" } },
              diagnostics = { globals = { "vim" } },
            },
            workspace = { library = { vim.fn.expand("$VIMRUNTIME/lua"), "''${3rd}/luv/library" } },
            telemetry = { enable = false },
          },
        }
      '';
    "after/lsp/nil_ls.lua" = # lua
      ''
        return {
          settings = {
            ["nil"] = {
              formatting = { command = { "nixpkgs-fmt" } },
              nix = { flake = { autoArchive = false } },
            },
          },
        }
      '';
    "after/lsp/pyright.lua" = # lua
      ''
        return {
          settings = {
            python = {
              pythonPath = ".venv/bin/python",
              analysis = { diagnosticSeverityOverrides = { reportUnusedExpression = "none" } },
            },
          },
        }
      '';
    "after/lsp/typos_lsp.lua" = # lua
      ''
        return { init_options = { diagnosticSeverity = "Warning" } }
      '';
    "after/lsp/vtsls.lua" = # lua
      ''
        local function publish_diagnostics(err, result, ctx, config)
          -- Hide only the CommonJS-to-ES-module suggestion, without mutating the payload.
          if not err and result and result.diagnostics then
            result = vim.tbl_extend("force", {}, result, {
              diagnostics = vim.tbl_filter(function(diagnostic)
                return diagnostic.code ~= 80001 and diagnostic.code ~= "80001"
              end, result.diagnostics),
            })
          end
          -- Resolve at notification time so later global wrappers still run.
          return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
        end

        return {
          single_file_support = false,
          workspace_required = true,
          root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".node_project" },
          handlers = { ["textDocument/publishDiagnostics"] = publish_diagnostics },
          settings = {
            separate_diagnostic_server = true,
            publish_diagnostic_on = "insert_leave",
            typescript = {
              suggest = { completeFunctionCalls = true },
              preferences = { importModuleSpecifier = "relative" },
            },
          },
          flags = { debounce_text_changes = 1000 },
          vtsls = { experimental = { completion = { enableServerSideFuzzyMatch = true } } },
        }
      '';
    "after/lsp/yamlls.lua" = # lua
      ''
        return {
          settings = {
            yaml = {
              keyOrdering = false,
              customTags = {
                "!And", "!Base64", "!Cidr", "!Equals", "!FindInMap sequence",
                "!GetAZs", "!GetAtt", "!If", "!ImportValue", "!Join sequence",
                "!Not", "!Or", "!Ref Scalar", "!Ref", "!Select", "!Split", "!Sub", "!fn",
              },
            },
          },
        }
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
    if vim.v.servername and vim.v.servername ~= "" then
      vim.env.NVIM_EDITOR_ADDR = vim.v.servername
    end
    for _, name in ipairs({ "EDITOR", "VISUAL", "TIG_EDITOR" }) do
      vim.env[name] = vim.g._editor_open_cmd
    end
    vim.env.GIT_EDITOR = vim.g._editor_open_cmd_wait
    vim.cmd("language messages en_US.UTF-8")
    pcall(dofile, vim.fn.expand("$HOME/config.lua"))

    for name, value in pairs({
      langmenu = "none",
      timeoutlen = 1000,
      shortmess = vim.o.shortmess .. "sWcS",
      cmdheight = 0,
      signcolumn = "yes",
      -- Keep horizontal splits as a separator, without statusline content.
      laststatus = 0,
      statusline = "%=",
      showtabline = 0,
      splitkeep = "screen",
      foldcolumn = "1",
      foldlevel = 99,
      foldlevelstart = 99,
      foldenable = true,
      switchbuf = "",
      splitbelow = true,
      splitright = true,
      winborder = "single",
      number = false,
      showmode = false,
      wrap = false,
    }) do
      vim.opt[name] = value
    end
    vim.g.mapleader = " "
    vim.g.maplocalleader = ","
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.g.no_plugin_maps = true

    if vim.g.neovide then
      for name, value in pairs({
        neovide_confirm_quit = false,
        neovide_cursor_animate_in_insert_mode = false,
        neovide_cursor_animation_length = 0.1,
        neovide_cursor_antialiasing = false,
        neovide_floating_corner_radius = 0.25,
        neovide_floating_shadow = false,
        neovide_hide_mouse_when_typing = true,
        neovide_input_ime = false,
        neovide_macos_simple_fullscreen = false,
        neovide_opacity = 0.9,
        neovide_padding_bottom = 5,
        neovide_padding_left = 5,
        neovide_padding_right = 5,
        neovide_padding_top = 10,
        neovide_window_blurred = true,
      }) do
        vim.g[name] = value
      end
      local function change_scale(factor)
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * factor
      end
      local function toggle_fullscreen()
        vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
      end
      local function toggle_blur()
        vim.g.neovide_window_blurred = not vim.g.neovide_window_blurred
      end
      local function paste_from_clipboard()
        local lines = vim.fn.getreg("+", 1, true)
        if #lines == 1 then
          vim.api.nvim_paste(lines[1], true, -1)
        else
          vim.api.nvim_put(lines, vim.fn.getregtype("+"), true, true)
        end
      end

      vim.o.guifont = "PlemolJP Console NF:h15"
      -- Ctrl+= needs no Shift; also accept Ctrl++ for other keyboard layouts.
      for _, key in ipairs({ "<C-=>", "<C-+>" }) do
        vim.keymap.set("n", key, function() change_scale(1.1) end)
      end
      vim.keymap.set("n", "<C-->", function() change_scale(1 / 1.1) end)
      vim.keymap.set("n", "<A-Enter>", toggle_fullscreen)
      vim.keymap.set("n", "<A-Tab>", toggle_blur)
      vim.keymap.set("i", "<D-v>", paste_from_clipboard)
      vim.keymap.set("c", "<D-v>", "<C-r>+")
      -- Avoid the shell's Ctrl+r mapping in terminal mode.
      vim.keymap.set("t", "<D-v>", "<C-\\><C-n>\"+pi")
      vim.api.nvim_create_user_command("ToggleNeovideFullScreen", toggle_fullscreen, {})
      vim.api.nvim_create_user_command("ToggleNeovideBlur", toggle_blur, {})
    end
  '';
  definition = {
    plugin = runtime;
    extraPackages = [ pkgs.jq ];
    # The profile declares the plugins needed by these immediate setup calls.
    config = # lua
      ''
        local function link_statusline_to_separator()
          vim.api.nvim_set_hl(0, "StatusLine", { link = "WinSeparator" })
          vim.api.nvim_set_hl(0, "StatusLineNC", { link = "WinSeparator" })
        end
        link_statusline_to_separator()
        vim.api.nvim_create_autocmd("ColorScheme", { callback = link_statusline_to_separator })

        local snacks = require("snacks")
        local function call(module, method)
          return function() require(module)[method]() end
        end
        local function toggle(id)
          return function() require("toggler").toggle(id) end
        end
        local function open_workdir_note()
          vim.cmd("Track open " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"))
        end
        for _, mapping in ipairs({
          { "j", "gj" },
          { "k", "gk" },
          { "<C-l>", "<Cmd>nohl<CR><C-l>" },
          { "*", "<Plug>(asterisk-z*)" },
          { "#", "<Plug>(asterisk-z#)" },
          { "g*", "<Plug>(asterisk-gz*)" },
          { "g#", "<Plug>(asterisk-gz#)" },
          { "<C-Space>", "<Cmd>OpenMenu<CR>" },
          { "<C-o>", "<Cmd>KomadoToggle<CR>" },
          { "<Leader>q", snacks.bufdelete.delete, "close buffer" },
          { "<Leader>Q", snacks.bufdelete.all, "close all buffers" },
          { "<Leader>A", "<Cmd>tabclose<CR>" },
          { "<Leader>tq", toggle("qf"), " quickfix" },
          { "<Leader>tb", call("oil", "open"), " explorer" },
          { "<Leader>td", toggle("trouble-doc"), " diagnostics (doc)" },
          { "<Leader>tD", toggle("trouble-ws"), " diagnostics (ws)" },
          { "<Leader>tR", call("spectre", "toggle"), " replace" },
          { "<Leader>H", toggle("harpoon"), "󰢷 show items" },
          { "<Leader>ha", "<Cmd>lua require('harpoon'):list():add()<CR>", "󰢷 register item" },
          { "<Leader>fa", "<Cmd>Telescope worktab<CR>", " worktab" },
          { "<Leader>ff", "<Cmd>Telescope live_grep_args<CR>", " livegrep" },
          { "<Leader>fp", "<Cmd>Telescope find_files find_command=rg,--files,--hidden,-g,!.git<CR>", " files" },
          { "<Leader>Ff", "<Cmd>Telescope live_grep_args cwd=~/ghq<CR>", " livegrep (ghq)" },
          { "<Leader>Fp", "<Cmd>Telescope find_files cwd=~/ghq<CR>", " files (ghq)" },
          { "<Leader>fP", "<Cmd>Telescope ghq previewer=false<CR>", " project files" },
          { "<Leader>fb", "<Cmd>TelescopeBuffer<CR>", " buffer" },
          { "<Leader>fB", "<Cmd>TelescopeBufferName<CR>", " buffer" },
          { "<Leader>ft", "<Cmd>Telescope pterm<CR>", " terminal" },
          { "<Leader>fT", "<Cmd>Telescope sonictemplate templates<CR>", " template" },
          { "<Leader>fn", "<Cmd>NeorgFuzzySearch<CR>", " fuzzy search" },
          { "<Leader>fN", "<Cmd>NeorgFindFile<CR>", " find file" },
          { "<Leader>G", "<Cmd>Gitu<CR>", " client" },
          { "<Leader>go", "<Cmd>TracePR<CR>", " open PR" },
          { "<Leader>N", "<Cmd>Neorg<CR>", " enter" },
          { "<Leader>ny", "<Cmd>Neorg journal yesterday<CR>", " yesterday" },
          { "<Leader>nt", "<Cmd>Neorg journal today<CR>", " today" },
          { "<Leader>nT", "<Cmd>Neorg journal tomorrow<CR>", " tomorrow" },
          { "<Leader>nn", "<Cmd>NeorgScratch<CR>", " scratch" },
          { "<Leader>ngg", "<Cmd>NeorgGit<CR>", " Git" },
          { "<Leader>ngb", "<Cmd>NeorgGitBranch<CR>", " Git (branch)" },
          { "<Leader>aa", "<Cmd>AvanteAsk<CR>" },
          { "<Leader>at", "<Cmd>AvanteToggle<CR>" },
          { "<Leader>tt", "<Cmd>Track today<CR>", " journal today" },
          { "<Leader>tn", "<Cmd>Track open<CR>", " open note" },
          { "<Leader>tf", "<Cmd>Track search_body<CR>", " find note (body)" },
          { "<Leader>tg", open_workdir_note, " open workdir note" },
          { "<Leader>tF", "<Cmd>Track search_title<CR>", " find note (title)" },
          { "<Leader>ot", "<Cmd>Obsidian today<CR>", " journal today" },
          { "<Leader>oy", "<Cmd>Obsidian yesterday<CR>", " journal yesterday" },
          { "<Leader>oo", "<Cmd>ObsidianScratch<CR>", " new note" },
          { "<Leader>ogg", "<Cmd>ObsidianGit<CR>", " Git" },
          { "<Leader>ogb", "<Cmd>ObsidianGitBranch<CR>", " Git branch" },
          { "<Leader>on", "<Cmd>Obsidian new<CR>", " new note" },
          { "<Leader>fo", "<Cmd>Obsidian search<CR>", " fuzzy search" },
        }) do
          vim.keymap.set("n", mapping[1], mapping[2], {
            noremap = true,
            silent = true,
            desc = mapping[3],
          })
        end
        vim.keymap.set({ "n", "i", "c", "t", "v" }, "¥", "\\", { noremap = true, silent = true })
        vim.keymap.set("t", "<S-Space>", "<Space>", { noremap = true, silent = true })
        for i = 0, 9 do
          vim.keymap.set({ "n", "t", "i" }, "<C-" .. i .. ">", toggle("term" .. i), {
            noremap = true,
            silent = true,
          })
        end
        for lhs, rhs in pairs({
          ["<C-Space>"] = "<C-n>",
          ["<C-S-Space>"] = "<C-p>",
          ["<C-a>"] = "<Home>",
          ["<C-e>"] = "<End>",
        }) do
          vim.keymap.set("i", lhs, rhs, { noremap = true })
        end

        require("config-local").setup({ silent = true })
      '';
    doc = ''
      Core owns editor options, mappings, Neovide settings, remote editor wrappers,
      and the native after/ftplugin and after/lsp runtime tree. Root startupConfig
      establishes leaders and netrw globals before any plugin executes; this
      cartridge's config runs after its explicit setup dependencies.
      Lua configuration is handwritten from the original Fennel behavior; no
      generated Lua or legacy files are read at evaluation or runtime. Java and
      ESLint receive their original per-file args as local Lua tables, including
      the packaged JDK 25 launcher and owned LSP attach helper.

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
              # Theme-dependent plugin setup and later Meian appearance changes
              # must read the current palette, never snapshot an unset color.
              initial_background = nvim.options["background"]
              for background in ["light", "dark", initial_background]:
                  nvim.options["background"] = background
                  assert lua('return vim.api.nvim_get_hl(0, {name="HLChunk1", link=false}).fg == tonumber(vim.g.terminal_color_8:sub(2), 16)')
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

              # Attach callbacks may target a buffer that is not current.
              lua("""
                local current = vim.api.nvim_get_current_buf()
                local hidden = vim.api.nvim_create_buf(false, true)
                local attach = dofile("${./lsp-attach.lua}")
                attach({ buf = hidden })
                assert(vim.b[hidden].lsp_attached and not vim.b[current].lsp_attached)
                local count = #vim.api.nvim_buf_get_keymap(hidden, "n")
                assert(count > 0 and vim.api.nvim_get_current_buf() == current)
                attach({ buf = hidden })
                assert(#vim.api.nvim_buf_get_keymap(hidden, "n") == count)
                vim.api.nvim_buf_delete(hidden, { force = true })
              """)
              lua("""
                local method = "textDocument/publishDiagnostics"
                local handler = dofile("${runtime}/after/lsp/vtsls.lua").handlers[method]
                local native = vim.lsp.handlers[method]
                local received
                vim.lsp.handlers[method] = function(err, result)
                  received = result
                  return "forwarded"
                end
                local payload = {
                  uri = "file:///fixture.js", version = 2,
                  diagnostics = { { code = 80001 }, { code = "80001" }, { code = 6133 } },
                }
                local result = handler(nil, payload, {}, {})
                vim.lsp.handlers[method] = native
                assert(result == "forwarded" and #payload.diagnostics == 3)
                assert(received ~= payload and received.uri == payload.uri and received.version == 2)
                assert(#received.diagnostics == 1 and received.diagnostics[1].code == 6133)
              """)

              # Exercise real terminal callbacks and the migrated Goda popup.
              # Goda's silent! cleanup can leave E716 in v:errmsg even when no
              # error is shown. Check visible errors and behavior, without
              # clearing v:errmsg or weakening the strict startup check above.
              visible_messages = nvim.command_output("messages")
              lua("""
                _G.core_test_errors = {}
                _G.core_test_notify = vim.notify
                vim.notify = function(message, level, options)
                  if level == vim.log.levels.ERROR then
                    table.insert(_G.core_test_errors, tostring(message))
                  end
                  return _G.core_test_notify(message, level, options)
                end
              """)
              nvim.command("enew")
              nvim.command("terminal " + os.environ["CORE_TEST_CAT"])
              terminal = nvim.current.buffer
              send("i")
              wait(lambda: nvim.eval("mode()") == "t", "enter terminal")
              assert nvim.call("maparg", "<C-g>", "t", False, True).get("desc") == "SKK input helper"
              for action in ["send", "cancel"]:
                  send("<C-g>")
                  wait(lambda: nvim.current.buffer.options["filetype"] == "skk-terminal-input", "open terminal input popup")
                  popup = nvim.current.buffer.number
                  wait(lambda: nvim.call("goda_skk#is_enabled"), "enable Goda in popup")
                  send("kanji")
                  wait(lambda: "かんじ" in "\n".join(nvim.current.buffer[:]), "convert kana in popup")
                  payload = "migration-terminal-" + action
                  nvim.current.buffer[:] = [payload]
                  send("<C-s>" if action == "send" else "<C-c>")
                  wait(lambda: nvim.current.buffer.number == terminal.number, "close popup on " + action)
                  wait(lambda: nvim.eval("mode()") == "t", "restore terminal focus on " + action)
                  assert not lua('return vim.api.nvim_buf_is_valid(...)', popup), action
                  assert not nvim.call("goda_skk#is_enabled"), action
                  if action == "send":
                      wait(lambda: payload in "\n".join(terminal[:]), "terminal receives popup input")
                  else:
                      assert payload not in "\n".join(terminal[:]), "cancelled input was sent"
                  assert nvim.command_output("messages") == visible_messages, nvim.command_output("messages")
                  assert lua('return #_G.core_test_errors == 0'), lua('return _G.core_test_errors')
              send("<C-\\><C-n>")
              lua('vim.notify = _G.core_test_notify; _G.core_test_notify = nil; _G.core_test_errors = nil')
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
