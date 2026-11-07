{ pkgs, inputs }:
let
  packages = import ./packages.nix { inherit pkgs inputs; };
in
{
  # Eager editor scripts, lazy backend: the first enabled key starts Go.
  # No InsertEnter-only trigger, so first use in command/terminal mode works too.
  plugins = [
    {
      plugin = packages.skk;
      dependPlugins = [ packages.goda ];
      config = ''
        vim.env.GODA_SKK_STATE_DIR = vim.fn.stdpath("state") .. "/goda-skk"
        vim.g["goda_skk#binary"] = "${packages.binary}/bin/goda-skk"
        vim.keymap.set({ "i", "c", "t" }, "<C-j>", "<Plug>(goda-skk-enable)", {
          silent = true, desc = "Enable Goda SKK",
        })
      '';
    }
  ];
}
