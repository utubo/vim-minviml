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

" ----------
" SetupOption(opt)
" test is vim9test.vim

" ----------
" SetupEscMark()
let default_mark_is_used = 'ESCMARK'

" ----------
" JoinLines()
let string_is_not_changed = 0
echo
  \ 'Join
  \ line
  \ string_is_not_changed
  \'

" EscapeStrings()
let string_is_not_changed = 0
echo "string_is_not_changed"

" ----------
" RemoveComments()
" comment
  echo trim
echo 1 " remove comment
echo \ " keep escaped space
" skip empty lines
 	 	

" ----------
" MinifyCommands()
" test in vim9test.vim

" ----------
" ExpandVirticalBar()
" TODO: see issue "15
echo "split" | echo "line"

" ----------
" RemoveTailComments()
" TODO: see issue "17
echo "split" " remove comment
inoremap <C-z> a  " remove comment

" ----------
" MinifyAllDefsLocal()
function! s:ScriptLocalFunction(arg1, arg2)
  let localVal = a:arg1
  let l:localVal2 = {
    arg2: 'dict key is not renamed.'
  }
  let localVal3 = [s:scriptLocalVal, 0]
  for l:localVal in range(1, const1[1])
  endfor
  const l:localConst = 1
endfunction

" ----------
" MinifyScriptLocal()
let s:scriptLocalVal = 0
const [s:const1, s:const2] = [1, s:scriptLocalVal]

for [s:aaa, s:bbb]  in [[1, 2], [3, s:const1[0]]]
endfor

function! vim8test#This_is_expoeted(arg1)
  let l:abc = a:arg1
endfunction

" ----------
" RemoveVim8Spaces()
let [s:vim8spaces, s:vim8spaces] = ['a' . 'b', 1 + 2 - 3 * 4 / 5]

" ----------
" UnescapeStrings()
" test in the test of EscapeString()

" ----------
" MinifySIDDefs()
function s:SidTestFunction()
endfunction
echo "rename <SID>SidTestDef() <SID>SidTestFunction()"
echo "ignore <SID>SidTestDef <SID>SidTestFunction"
echo "ignore SidTestDef() SidTestFunction()"

" ----------
" Others
let Normal = 0
echohl Normal " this is not renamed.

let g:this_is_global_val_not_renamed = 0


