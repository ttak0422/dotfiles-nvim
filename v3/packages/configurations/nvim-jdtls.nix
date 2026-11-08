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
  plugin = sources.nvim-jdtls;
  dependPlugins = [
    definitions.nvim-dap
    definitions.nvim-dap-ui
  ];
  config = luaConfig (
    # lua
    ''
      vim.api.nvim_create_user_command("JdtDelteteWorkspaceData", function()
        local root_dir = vim.fs.root(0, { "gradlew", "mvnw", ".git" })
        local workspace_dir = os.getenv("HOME") .. "/.local/share/eclipse/"
          .. vim.fn.fnamemodify(root_dir, ":p:h"):gsub("/", "_")
        vim.notify("Starting to delete JDTLS workspace data.")
        os.execute("rm -rf " .. workspace_dir)
        vim.notify("JDTLS workspace data deleted.")
      end, {})
    ''
  );
}
