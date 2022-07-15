vim9script

var tmpfile = tempname()
try
  var srcfile = expand('<sfile>')
  var expfile = substitute(srcfile, 'test\.vim$', 'expect.min.vim', '')
  minviml#Minify(srcfile, tmpfile)
  var expect = join(readfile(expfile), '\n')
  var actual = join(readfile(tmpfile), '\n')
  if expect ==# actual
    echo 'TEST OK !'
  else
    execute 'tabe ' .. expfile
    execute 'diffs ' .. tmpfile
  endif
finally
  delete(tmpfile)
endtry

finish

# -------------------------------------
# test data
# -------------------------------------

# ----------
# SetupOption(opt)
# TODO

# ----------
# SetupEscMark()
var default_mark_is_used = 'ESCMARK'

# ----------
# JoinLines()
var string_is_not_changed = 0
echo
  \ 'Join
  \ line
  \ string_is_not_changed
  \'

# EscapeStrings()
var string_is_not_changed = 0
echo "string_is_not_changed"

# ----------
# TrimAndJoinLines()
# comment
  echo trim
echo 1 # remove comment
echo \ # keep escaped space
# skip empty lines
 	 	

# ----------
# MinifyCommands()
# TODO

# ----------
# ExpandVirticalBar()
echo "split" | echo "line"

# ----------
# TrimTailComments()
var a="keep 1" #this is comment"
var a="keep 2" #this is comment
echo  "keep 3" " this is error 'Missing double quote'
echo  "keep 4" | # this is comment
echo  "keep 5 | keep  6"
echo  "keep 7" | # this is comment | this is comment
echo  "keep 8 | keep 9" | # this is comment " | this is comment
inoremap A # keep 10
inoremap A # | # this is comment
inoremap A " | var a='keep  11' #this is comment
inoremap A " \| keep 12" keep 13
inoremap <expr> A " \| keep  14"
inoremap <expr> A " | " keep 15 (missing double quote error)
inoremap A " | echo "keep    16" " keep 17 (missing double quote error)
inoremap A " | var a='keep 18'
inoremap A \" | #var a='this is comment'
inoremap A " | inoremap B " keep 19
let a=1 | inoremap A " | inoremap B " keep 20
let b=2 | autocmd VimEnter * inoermap A " | inoremap B "
set set1=setvalue1 # comment
set set2=# not comment
# "this line is comment"


# ----------
# MinifyAllDefsLocal()
def ScriptLocalDef(arg1: dict<any>, arg2: number): string
  var localVal = arg1
  var localVal2 = {
    arg2: 'dict key is not renamed.'
  }
  var localVal3 = [scriptLocalVal, 0]
  for localVal in range(1, const1[1])
  endfor
  var [val1, val2] = [1, 2]
  for [l:loop1, loop2] in range(1, const1[1])
  endfor
  const localConst = 1
  final localFinal = '2'
enddef

function! ScriptLocalFunction(arg1, arg2)
  let localVal = a:arg1
  let l:localVal2 = {
    arg2: 'dict key is not renamed.'
  }
  let localVal3 = [scriptLocalVal, 0]
  for l:localVal in range(1, const1[1])
  endfor
  var [val1, val2] = [1, 2]
  for [l:loop1, loop2] in range(1, const1[1])
  endfor
  const l:localConst = 1
endfunction

# ----------
# MinifyScriptLocal()
var scriptLocalVal = 0
const [const1, const2] = [1, scriptLocalVal]
final f = 'FINAL'

for [aaa, bbb]  in [[1, 2], [3, const1[0]]]
endfor

export def! This_is_exported(arg1: string)
  var abc = arg1
enddef

# ----------
# MinifySpaces()
var minifyspaces     =       '12345' |     let minifyspaces2   =  1
nnoremap dont minify    keymap

# ----------
# MinifyVim8Spaces()
# test in vim8test.vim

# ----------
# UnescapeStrings()
# test in the test of EscapeString()

# ----------
# MinifySIDDefs()
def SidTestDef()
enddef
function SidTestFunction()
endfunction
echo "rename <SID>SidTestDef() <SID>SidTestFunction()"
echo "ignore <SID>SidTestDef <SID>SidTestFunction"
echo "ignore SidTestDef() SidTestFunction()"

# ----------
# Others
var Normal = 0
echohl Normal # this is not renamed.

g:this_is_global_val_not_renamed = 0

