vim9script
if $CI ==# '1'
  execute $'set rtp^={expand('<script>:p:h:h')}'
else
  packadd vim-minviml
endif
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

