call skkeleton#config({
      \   'sources': [ 'skk_server' ],
      \   'globalDictionaries': [s:args['jisyo']],
      \   'skkServerHost': '127.0.0.1',
      \   'skkServerPort': 1178,
      \   'markerHenkan': '',
      \   'markerHenkanSelect': '',
      \ })

imap <C-j> <Plug>(skkeleton-enable)
cmap <C-j> <Plug>(skkeleton-enable)
tmap <C-j> <Plug>(skkeleton-enable)
