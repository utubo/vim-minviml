vim9script

packadd vim-minviml
g:minviml_test_faild = 0
source vim8test.vim
source vim9test.vim
if $CI ==# '1'
  if !g:minviml_test_faild
    q!
  else
    cq!
  endif
endif

