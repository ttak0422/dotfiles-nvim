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
  doc = ''
    # project.nvim

    ## 概要
    LSP またはルートを示すパターンからプロジェクトを検出し、作業ディレクトリを切り替える。

    ## 主な機能
    - 検出方法とディレクトリ変更のスコープを設定。
    - 任意の Telescope 連携で最近のプロジェクトを表示。

    ## 使い方
    `require("project_nvim").setup(...)` で設定する。`:ProjectRoot` で手動検出できる。この定義は `.git` パターンで検出し、タブ単位でディレクトリを変更する。Telescope 連携には別途 extension 設定が必要。

    ## 要件
    Neovim 0.5.0 以上。LSP による検出に lspconfig は不要。

    ## 出典
    [固定リビジョンの README](https://github.com/ahmedkhalf/project.nvim/blob/8c6bad7d22eef1b71144b401c9f74ed01526a4fb/README.md)
  '';
  # Telescope owns its command; this genuine prerequisite loads with its group.
  lazy = true;
  onCommands = [
    "ProjectRoot"
    "AddProject"
  ];
  onModules = [ "project_nvim" ];
  plugin = sources.project-nvim;
  config = luaConfig (
    # lua
    ''
      require("project_nvim").setup({
        scope_chdir = "tab",
        detection_methods = { "pattern" },
        patterns = { ".git" },
        manual_mode = false,
      })
      local group = vim.api.nvim_create_augroup("ProjectSubmoduleGuard", { clear = true })
      local adjusting = false
      local function superproject_root(dir)
        local output = vim.fn.system({ "git", "-C", dir, "rev-parse", "--show-superproject-working-tree" })
        local root = vim.trim(output)
        if vim.v.shell_error == 0 and root ~= "" then
          return root
        end
      end
      -- Keep project.nvim from moving into a submodule instead of its superproject.
      vim.api.nvim_create_autocmd("DirChanged", {
        group = group,
        pattern = { "global", "tabpage" },
        callback = function()
          if adjusting then
            return
          end
          local root = superproject_root(vim.fn.getcwd())
          if root then
            adjusting = true
            pcall(vim.cmd.tcd, vim.fn.fnameescape(root))
            adjusting = false
          end
        end,
      })
    ''
  );
}
