{
  pkgs,
  lib,
  sources,
  definitions,
  luaConfig,
  luaCheck,
  inputs',
}:
with sources;
{
  doc = ''
    # sfcc.nvim

    ## 概要
    Salesforce B2C Commerce Cloud のカートリッジ内パスへ移動する。

    ## 主な機能
    - `*/`、`~/`、相対パス、モジュール名をカートリッジ順序に従って解決する。
    - `tsconfig.json` の `compilerOptions.paths` を優先し、JSONC・`extends`・複数候補に対応する。
    - `module.superModule` では次のカートリッジにある同じファイルへ移動する。

    ## 使い方
    `require("sfcc").gf()` をキーに割り当てる。この定義は JavaScript の `gf` に設定する。`:SfccReset` で探索・tsconfig（継承元を含む）のキャッシュを消去し、`:checkhealth sfcc` で検出内容を確認する。

    ## 要件
    カートリッジ順序は `dw.json` の `cartridgesPath` を参照する。カートリッジや tsconfig エイリアスに該当しなければ標準 `gf` へ戻る。最低 Neovim バージョンは README に未記載。

    ## 出典
    [固定バージョンの README](https://github.com/ttak0422/sfcc.nvim/blob/7814c7bee01e5f3fce745ac23e859bd8ab91b53c/README.md)
  '';

  plugin = sources.sfcc-nvim;
  config = luaConfig (''
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'javascript',
      callback = function(event)
        vim.keymap.set('n', 'gf', function() require('sfcc').gf() end,
          { buffer = event.buf, desc = 'SFCC cartridge gf' })
      end,
    })
  '');

  tests.sfcc-tsconfig-gf = luaCheck {
    name = "sfcc-tsconfig-gf";
    script = ''
      local root = vim.fn.tempname()
      vim.fn.mkdir(root, "p")
      root = assert(vim.uv.fs_realpath(root))
      local function write(path, lines)
        local target = root .. "/" .. path
        vim.fn.mkdir(vim.fs.dirname(target), "p")
        vim.fn.writefile(lines or {}, target)
        return target
      end
      write("dw.json", { '{"cartridgesPath":"custom:base"}' })
      write("tsconfig.json", { '{"extends":"./tsconfig.base.json"}' })
      local function config(directory)
        write("tsconfig.base.json", {
          "{ // JSONC inherited aliases",
          '  "compilerOptions": {"baseUrl":".", "paths": {',
          '    "@app/*": ["missing/*", "' .. directory .. '/*"],',
          '    "*/cartridge/scripts/util": ["overrides/util"],',
          "  }},",
          "}",
        })
      end
      config("src")
      local original = write("src/value.js")
      local replacement = write("replacement/value.js")
      local override = write("overrides/util.js")
      local custom = write("custom/cartridge/scripts/util.js")
      local base = write("base/cartridge/scripts/util.js")
      local entry = write("entry.js", { "const value = require('@app/value');" })
      vim.cmd.cd(root)
      vim.cmd.edit(entry)
      assert(vim.bo.filetype == "javascript")
      local mapping = vim.fn.maparg("gf", "n", false, true)
      assert(mapping.buffer == 1 and type(mapping.callback) == "function",
        "JavaScript must keep its buffer-local SFCC gf mapping")
      vim.api.nvim_win_set_cursor(0, { 1, 25 })
      mapping.callback()
      assert(vim.api.nvim_buf_get_name(0) == original, "configured gf missed inherited alias/second target")
      local sfcc = require("sfcc")
      local function resolves_to(spec, target)
        local found = sfcc.resolve(spec, entry)
        return #found == 1 and vim.uv.fs_realpath(found[1]) == target
      end
      local found, ordered = sfcc.resolve("*/cartridge/scripts/util", entry)
      assert(ordered and #found == 1 and vim.uv.fs_realpath(found[1]) == override, "explicit alias must precede cartridge lookup")
      assert(vim.deep_equal(sfcc.super(custom), { base }), "cartridge superModule behavior changed")
      config("replacement")
      assert(resolves_to("@app/value", original), "aliases should remain cached")
      assert(vim.fn.exists(":SfccReset") == 2)
      vim.cmd.SfccReset()
      assert(resolves_to("@app/value", replacement),
        "SfccReset must invalidate inherited tsconfig settings")
      local plain = write("plain/entry.js", { "./target.js" })
      local target = write("plain/target.js")
      write("plain/tsconfig.json", { '{"compilerOptions":{"paths":{}}}' })
      vim.cmd.edit(plain)
      vim.api.nvim_win_set_cursor(0, { 1, 3 })
      vim.fn.maparg("gf", "n", false, true).callback()
      assert(vim.api.nvim_buf_get_name(0) == target, "unmatched unquoted paths must retain builtin gf")
    '';
  };
}
