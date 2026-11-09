{ nginxPlugin }:
{
  "after/ftdetect/nginx.vim" = ''
    source ${nginxPlugin}/ftdetect/nginx.vim
    au BufRead,BufNewFile *.nginxconf set ft=nginx
  '';
}
