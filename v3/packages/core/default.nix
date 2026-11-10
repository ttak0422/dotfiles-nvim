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
  files =
    import ./after/ftplugin.nix { inherit pkgs; }
    // import ./after/lsp.nix { inherit pkgs; }
    // import ./after/ftdetect.nix { inherit nginxPlugin; };
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
    -- Match v2: the first UI selection activates the configured Telescope picker.
    local function lazy_ui_select(...)
      require("telescope")
      assert(vim.ui.select ~= lazy_ui_select, "Telescope ui-select did not install its handler")
      return vim.ui.select(...)
    end
    vim.ui.select = lazy_ui_select
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
        for key, kind in pairs({ u = "mru", r = "mrr", w = "mrw" }) do
          vim.keymap.set("n", "<Leader>fr" .. key, function()
            require("telescope").extensions.mr[kind]({ cwd = vim.fn.getcwd() })
          end, { silent = true, desc = " " .. kind:upper() })
          vim.keymap.set("n", "<Leader>Fr" .. key, function()
            require("telescope").extensions.mr[kind]()
          end, { silent = true, desc = " " .. kind:upper() })
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

      Telescope MR uses vim-mr’s Vimscript API without Denops. Existing
      Neorg and Avante mappings are retained for compatibility although those
      plugins were not enabled by the source profile. The first vim.ui.select
      loads Telescope and delegates to its installed ui-select handler.
      Deno LSP is retained: it is not a Denops dependency.
    '';
  };
}
