{
  pkgs,
  inputs',
  environment,
}:
let
  luaCheck = import ../packages/plugin-check.nix;
  packages = import ../packages { inherit pkgs inputs' environment; };
in
with packages;
{
  startupConfig = ''
    vim.o.termguicolors = true
    -- Fyler clears netrw's group even when netrw is disabled before startup.
    vim.api.nvim_create_augroup("FileExplorer", { clear = false })
    vim.g.python3_host_prog = "${pkgs.python3.withPackages (ps: [ ps.pynvim ])}/bin/python3"
    ${core.startupConfig}
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      desc = "Show the vNext message on empty startup",
      callback = function()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_get_current_buf()
        if vim.fn.argc(-1) > 0 or #vim.api.nvim_list_uis() == 0
          or #vim.api.nvim_list_wins() ~= 1 or #vim.fn.getbufinfo({ buflisted = 1 }) ~= 1
          or vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].buftype ~= "" or vim.bo[buf].modified
          or vim.api.nvim_buf_line_count(buf) ~= 1 or vim.api.nvim_get_current_line() ~= "" then
          return
        end

        local message = "vNext"
        local function geometry()
          local width = vim.api.nvim_win_get_width(win)
          local height = vim.api.nvim_win_get_height(win)
          local text_width = math.min(width, vim.fn.strdisplaywidth(message))
          return {
            relative = "win",
            win = win,
            row = math.floor((height - 1) / 2),
            col = math.floor((width - text_width) / 2),
            width = text_width,
            height = 1,
          }
        end

        local banner = vim.api.nvim_create_buf(false, true)
        vim.bo[banner].bufhidden = "wipe"
        vim.api.nvim_buf_set_lines(banner, 0, -1, false, { message })
        vim.opt.shortmess:append("I")
        local floating = vim.api.nvim_open_win(banner, false, vim.tbl_extend("force", geometry(), {
          border = "none",
          focusable = false,
          mouse = false,
          style = "minimal",
        }))
        vim.wo[floating].wrap = false
        vim.wo[floating].winhighlight = "NormalFloat:Normal"

        local group = vim.api.nvim_create_augroup("DotfilesStartupMessage", { clear = true })
        local function dismiss()
          vim.api.nvim_del_augroup_by_id(group)
          if vim.api.nvim_win_is_valid(floating) then
            vim.api.nvim_win_close(floating, true)
          end
        end
        -- :edit can reload the same buffer and clear its buffer-local autocmds.
        vim.api.nvim_create_autocmd({ "BufLeave", "BufReadPost", "BufNewFile", "WinLeave", "InsertEnter", "TextChanged" }, {
          group = group,
          callback = function(event)
            if event.buf == buf then dismiss() end
          end,
        })
        vim.api.nvim_create_autocmd("VimResized", {
          group = group,
          callback = function()
            if vim.api.nvim_win_is_valid(floating) and vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_set_config(floating, geometry())
            else
              dismiss()
            end
          end,
        })
      end,
    })
  '';
  extraPackages = with pkgs; [
    jq
    git
  ]
  ++ configurations.extraPackages;
  plugins = configurations.plugins ++ [
    (
      core.definition
      // {
        test = luaCheck {
          name = "environment-${environment}";
          preInit = if environment == "neovide" then "vim.g.neovide = true" else "";
          script = ''
            local gui = ${if environment == "neovide" then "true" else "false"}
            assert(vim.env.NVIM_APPNAME == "nvim-v3-${environment}")
            local image = vim.api.nvim_get_runtime_file("lua/image/init.lua", true)
            assert((#image == 0) == gui, "terminal image plugin must be absent from Neovide")
            local bg = vim.api.nvim_get_runtime_file("plugin/bg.lua", true)
            assert((#bg == 0) == gui, "terminal color plugin must be absent from Neovide")
            assert((vim.fn.exists(":ToggleNeovideBlur") == 2) == gui)
            if gui then
              assert(vim.g.neovide_padding_top == 10)
              assert(vim.o.guifont == "PlemolJP Console NF:h15")
              assert(vim.fn.maparg("<D-v>", "i") ~= "")
            else
              assert(vim.g.neovide_padding_top == nil)
            end
          '';
        };
        dependPlugins = with configurations.definitions; [
          snacks-nvim
          sorairo
          nvim-config-local
        ];
        preConfig = configurations.editorPreConfig;
        config = pkgs.lib.concatStringsSep "\n" [
          configurations.editorConfig
          core.definition.config
        ];
      }
    )
  ];
}
