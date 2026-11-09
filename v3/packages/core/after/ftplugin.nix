{ pkgs }:
with pkgs;
let
  javaArgs =
    let
      inherit (vscode-marketplace.vscjava) vscode-java-debug vscode-java-test;
      jdtls = jdt-language-server;
    in
    {
      jdk8_path = "${jdk8}";
      jdk11_path = "${jdk11}";
      jdk17_path = "${jdk17}";
      jdk21_path = "${jdk21}";
      # JDT LS 1.63 ships Eclipse bundles requiring Java 25.
      java_path = "${jdk25}/bin/java";
      jdtls_jar_pattern = "${jdtls}/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar";
      jdtls_config_path = "${jdtls}/share/java/jdtls/${
        if stdenv.isDarwin then "config_mac" else "config_linux"
      }";
      java_debug_jar_pattern = "${vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar";
      java_test_jar_pattern = "${vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar";
      jol_jar_path = javaPackages.jol;
      lombok_jar_path = "${lombok}/share/java/lombok.jar";
      attach_path = ../lsp-attach.lua;
    };
in
{
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
      local args = ${lib.generators.toLua { } javaArgs}
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
}
