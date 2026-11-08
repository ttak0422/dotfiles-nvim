{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  inputs',
}:
with sources;
{
  plugin = sources.obsidian-nvim;
  dependPlugins = [
    definitions.nvim-cmp
    definitions.plenary-nvim
    definitions.telescope-nvim
    definitions.image-nvim
  ];
  extraPackages = with pkgs; [
    pngpaste
    ripgrep
  ];
  config = luaConfig (
    # lua
    ''
      local default_vault = vim.fn.fnamemodify(os.getenv("HOME") .. "/vaults/default/", ":p:h")
      local stat = vim.uv.fs_stat(default_vault)
      if not stat or stat.type ~= "directory" then
        vim.fn.mkdir(default_vault, "p")
      end
      local api = require("obsidian.api")
      local Path = require("obsidian.path")
      local Note = require("obsidian.note")
      require("obsidian").setup({
        workspaces = { { name = "default", path = default_vault } },
        daily_notes = {
          folder = "journal",
          date_format = "%Y-%m-%d",
          default_tags = { "journal" },
        },
        completion = { nvim_cmp = true, min_chars = 1, create_new = true, blink = false },
        ui = { enable = false },
        checkbox = { enabled = false },
        callbacks = {
          enter_note = function(note)
            vim.keymap.set("n", "<CR>", function()
              if api.cursor_link(nil, nil, true) then
                vim.cmd("Obsidian follow_link")
              elseif api.cursor_tag() then
                vim.cmd("Obsidian tags")
              end
            end, { buffer = note.bufnr, desc = "Obsidian Smart Action" })
            vim.keymap.set("x", "<LocalLeader>l", "<Cmd>Obsidian link<CR>", {
              buffer = note.bufnr,
              desc = "Obsidian Link",
            })
          end,
        },
        statusline = { enabled = false },
        footer = { enabled = false },
        log_level = vim.log.levels.WARN,
        legacy_commands = false,
      })
      local directory = _G.Obsidian.workspace.path
      local options = _G.Obsidian.opts
      local function get_branch(default)
        local command = default
          and { "git", "symbolic-ref", "refs/remotes/origin/HEAD" }
          or { "git", "rev-parse", "--abbrev-ref", "HEAD" }
        local result = vim.system(command):wait()
        if result.code ~= 0 then
          error("branch not found")
        end
        if default then
          return result.stdout:gsub("^refs/remotes/origin/", ""):gsub("%s+$", "")
        end
        return result.stdout:gsub("%s+", "")
      end
      local function open_note(path, tags)
        local note
        if path:exists() then
          note = Note.from_file(path, options.load)
        else
          note = Note.create({ id = path.stem, aliases = {}, tags = tags, dir = path:parent() }):write({})
        end
        note:open()
      end
      local function open_git_note(default)
        local branch = get_branch(default)
        local cwd = vim.fn.getcwd()
        local relative = vim.fs.relpath(vim.fn.expand("~"), cwd)
        open_note(Path.new(directory / relative / branch), { vim.fn.fnamemodify(cwd, ":t"), branch })
      end
      vim.api.nvim_create_user_command("ObsidianScratch", function()
        open_note(Path.new(directory) / "scratch.md", {})
      end, {})
      vim.api.nvim_create_user_command("ObsidianGit", function()
        open_git_note(true)
      end, {})
      vim.api.nvim_create_user_command("ObsidianGitBranch", function()
        open_git_note(false)
      end, {})
    ''
  );
}
