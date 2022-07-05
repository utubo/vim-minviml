if exists('g:minviml')
  finish
endif
let g:minviml = 1

augroup minviml
  au!
  au BufWritePost *.src.vim call minviml#Minify('%')
augroup End
