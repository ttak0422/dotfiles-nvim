{
  pkgs,
  definitions,
  luaCheck,
}:
{
  plugin = import ../../plugins/nix-inline { inherit pkgs; };
  lazy = true;
  onFiletypes = [ "nix" ];
  dependPlugins = [ definitions.nvim-treesitter ];
  config = # lua
    ''
      require("nix_inline").setup()
    '';
  doc = ''
    # Nix inline code

    ## Usage
    Put `# lua`, `# vim`, `# bash`, or `# python` immediately before a Nix
    string. `# vimscript` and `# sh` are also accepted. The matching parser
    must be installed. Nix interpolation remains outside the injected ranges.

    ## Implementation
    A repository-local plugin loads on the first Nix FileType event and
    attaches to existing and later Nix buffers. It uses the pinned Nix
    injection queries, retaining built-in shell helper and comment support.
    No separately maintained query copy or parser download is needed.
  '';
  test = luaCheck {
    name = "nix-inline";
    ui = true;
    script = # lua
      ''
        assert(package.loaded.nix_inline == nil, "loaded before Nix FileType")
        local path = vim.fn.tempname() .. ".nix"
        vim.fn.writefile({ "{", "  code = # lua", "    \"local answer = 42\";", "}" }, path)
        vim.cmd.edit(vim.fn.fnameescape(path))
        assert(vim.bo.filetype == "nix")
        assert(package.loaded.nix_inline, "first Nix buffer did not load the plugin")
        local function language_at(buf, row, col)
          local parser = vim.treesitter.get_parser(buf, "nix")
          parser:parse(true)
          return parser:language_for_range({ row, col, row, col + 1 }):lang()
        end
        assert(language_at(0, 2, 6) == "lua", "first buffer has no Lua injection")
        for _, case in ipairs({
          { "lua", "local answer = 42", "lua" },
          { "vim", "let g:answer = 42", "vim" },
          { "vimscript", "let g:answer = 42", "vim" },
          { "bash", "echo answer", "bash" },
          { "sh", "echo answer", "bash" },
          { "python", "answer = 42", "python" },
        }) do
          local buf = vim.api.nvim_create_buf(true, false)
          vim.api.nvim_set_current_buf(buf)
          local quote = string.rep("'", 2)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
            "{ value = # " .. case[1], quote, case[2], quote .. "; }",
          })
          vim.bo[buf].filetype = "nix"
          assert(language_at(buf, 2, 1) == case[3], case[1] .. " injection missing")
          assert(vim.treesitter.highlighter.active[buf], "highlighter not attached")
          local highlighted = false
          for _, capture in ipairs(vim.treesitter.get_captures_at_pos(buf, 2, 1)) do
            if capture.lang == case[3] then highlighted = true end
          end
          assert(highlighted, case[1] .. " has no highlight capture")
          vim.api.nvim_buf_delete(buf, { force = true })
        end
        -- Marker edits must re-parse without reloading the plugin.
        local buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_set_current_buf(buf)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
          "{ value = # lua", '"local x = 1";', "}",
        })
        vim.bo[buf].filetype = "nix"
        assert(language_at(buf, 1, 2) == "lua")
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
          "{ value = # python", '"x = 1";', "}",
        })
        assert(language_at(buf, 1, 1) == "python", "edited marker was not re-parsed")
        local dollar = string.char(36)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
          "{ value = # lua", '"local x = ' .. dollar .. '{value}; print(x)";', "}",
        })
        assert(language_at(buf, 1, 13) == "nix", "interpolation leaked into Lua")
        vim.treesitter.language.register("nix_inline_missing_parser", "vimscript")
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
          "{ value = # vimscript", '"let g:answer = 42";', "}",
        })
        assert(language_at(buf, 1, 1) == "nix")
        require("nix_inline").setup()
        assert(language_at(buf, 1, 1) == "vim", "existing parser missed the alias")
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '{ value = "plain text"; }' })
        assert(language_at(buf, 0, 12) == "nix", "injected an unmarked string")
        local before = #vim.api.nvim_get_autocmds({ group = "NixInline" })
        require("nix_inline").setup()
        assert(#vim.api.nvim_get_autocmds({ group = "NixInline" }) == before)
        vim.api.nvim_buf_delete(buf, { force = true })
        local text = vim.api.nvim_create_buf(true, false)
        vim.bo[text].filetype = "text"
        require("nix_inline").attach(text)
        assert(not vim.treesitter.highlighter.active[text], "attached to a non-Nix buffer")
        vim.api.nvim_buf_delete(text, { force = true })
        vim.fn.delete(path)
      '';
  };
}
