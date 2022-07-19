vim9script

if exists('g:minviml')
  finish
endif
g:minviml = 1

augroup minviml
  au!
  au BufWritePost *.src.vim call minviml#Minify('%')
augroup End
