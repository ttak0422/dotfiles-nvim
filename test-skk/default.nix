{ pkgs, ... }:
{
  eager = with pkgs.vimPlugins; {
    denops.package = denops-vim;
    skk.package = skkeleton;
  };
  extraConfig = ''
    vim.cmd([=[
          let g:denops#deno = '${pkgs.deno}/bin/deno'
          let g:denops#server#deno_args = ['-q', '--no-lock', '-A', '--unstable-kv']

          call skkeleton#config({
                \   'sources': [ 'skk_server' ],
                \   'globalDictionaries': ['${pkgs.skk-dict}/SKK-JISYO.L'],
                \   'skkServerHost': '127.0.0.1',
                \   'skkServerPort': 1178,
                \   'markerHenkan': '',
                \   'markerHenkanSelect': '',
                \ })

          imap <C-j> <Plug>(skkeleton-enable)
          cmap <C-j> <Plug>(skkeleton-enable)
          tmap <C-j> <Plug>(skkeleton-enable)
    ]=])
  '';
}
