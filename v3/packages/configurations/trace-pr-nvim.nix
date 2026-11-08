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
  plugin = sources.trace-pr-nvim;
  extraPackages = with pkgs; [ gh ];
  config = luaConfig (
    # lua
    ''
      require("trace-pr").setup({ trace_by_commit_hash_when_pr_not_found = true })
    ''
  );
}
