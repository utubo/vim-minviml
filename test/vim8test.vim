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
let default_mark_is_used = 'QQQ'

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
let s:exprstrval1 = 1
let s:exprstrval2 = 'two'
let s:expr_str1 = $'abc{s:exprstrval1}'
let s:expr_str1 = $'abc{s:exprstrval1}xyz{s:exprstrval2}{this is dummy}'
let s:expr_str2 = $"abc{s:exprstrval1}xyz{s:exprstrval2}{this is dummy}"

" ----------
" TrimAndJoinLines()
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
echo "split" | echo "line"

" ----------
" TrimTailComments()
let a="keep 1" "this is comment"
let a="keep 2" "this is comment
echo  "keep 3" " this is error 'Missing double quote'
echo  "keep 4" | " this is comment
echo  "keep 5 | keep  6"
echo  "keep 7" | " this is comment | this is comment
echo  "keep 8 | keep 9" | " this is comment " | this is comment
inoremap A " keep 10
inoremap A " | " this is comment
inoremap A " | let a='keep  11' "this is comment
inoremap A " \| keep 12" keep 13
inoremap <expr> A " \| keep  14"
inoremap <expr> A " | " keep 15 (missing double quote error)
inoremap A " | echo "keep    16" " keep 17 (missing double quote error)
inoremap A " | let a='keep 18'
inoremap A \" | "let a='this is comment'
inoremap A " | inoremap B " keep 19
let a=1 | inoremap A " | inoremap B " keep 20
let b=2 | autocmd VimEnter * inoermap A " | inoremap B "
set set1=setvalue1 " comment
set set2=" comment, so this line is error
" "this line is comment"

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
  let [val1, val2] = [1, 2]
  for [l:loop1, loop2] in range(1, const1[1])
  endfor
  const l:localConst = 1
endfunction

" ----------
" MinifyScriptLocal()
let s:scriptLocalVal = 0
const [s:const1, s:const2] = [1, s:scriptLocalVal]

for [s:aaa, s:bbb]  in [[1, 2], [3, s:const1[0]]]
endfor

function! vim8test#This_is_exported(arg1)
  let l:abc = a:arg1
endfunction

" ----------
" MinifySpaces()
let minifyspaces     =       '12345' |     let minifyspaces2   =  1
nnoremap dont minify    keymap

" ----------
" MinifyVim8Spaces()
let [s:vim8spaces, s:vim8spaces] = ['a' . 'b', 1 + 2 - 3 * 4 / 5]

" ----------
" UnescapeStrings()
" test in the test of EscapeStrings()

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

