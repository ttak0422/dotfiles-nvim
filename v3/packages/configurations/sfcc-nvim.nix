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
}
