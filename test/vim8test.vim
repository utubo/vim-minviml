let s:tmpfile = tempname()
try
  let s:srcfile = expand('<sfile>')
  let s:expfile = substitute(s:srcfile, 'test\.vim$', 'expect.min.vim', '')
  call minviml#Minify(s:srcfile, s:tmpfile)
  let s:expect = join(readfile(s:expfile), '\n')
  let s:actual = join(readfile(s:tmpfile), '\n')
  if s:expect ==# s:actual
    echo 'TEST OK !'
  else
    execute 'tabe ' . s:expfile
    execute 'diffs ' . s:tmpfile
  endif
finally
  call delete(s:tmpfile)
endtry

finish

" -------------------------------------
" test data
" -------------------------------------

echo 1 " remove comment
echo \ " keep escaped space
" skip empty lines
 	 	

let s:string_is_not_changed = 0
echo
  \ 'Join
  \ line
  \ s:string_is_not_changed
  \'

" TODO: see issue #15
echo "split" | echo "line"

let s:scriptLocalVal = 0
const [s:const1, s:const2] = [1, s:scriptLocalVal]

for [s:aaa, s:bbb]  in [[1, 2], [3, s:const1[0]]]
endfor

function! s:ScriptLocalDef(arg1, arg2)
  let localVal = a:arg1
  let l:localVal2 = {
    arg2: 'dict key is not renamed.'
  }
  let localVal3 = [s:scriptLocalVal, 0]
  for l:localVal in range(1, s:const1[1])
  endfor
  const l:localConst = 1
enddef

execute 'nnoremap <SID>ScriptLocalDef()'
echo 'this is string, so be not renamed. s:scriptLocalVal'

let s:Normal = 0
echoe Normal " this is not renamed.

let this_is_global_val_not_renamed = 0

