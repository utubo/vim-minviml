augroup minviml
  au!
  au BufWritePost *.src.vim call minviml#Minify('%')
augroup End
