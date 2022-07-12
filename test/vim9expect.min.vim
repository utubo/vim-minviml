vim9script
var k = tempname()
try
var m = expand('<sfile>')
var n = substitute(m, 'test\.vim$', 'expect.min.vim', '')
minviml#Minify(m, k)
var o = join(readfile(n), '\n')
var p = join(readfile(k), '\n')
if o ==# p
ec 'TEST OK !'
else
exe 'tabe ' .. n
exe 'diffs ' .. k
endif
finally
delete(k)
endtry
finish
var q = 'ESCMARK'
var r = 0
ec 'Join line string_is_not_changed'
var r = 0
ec "string_is_not_changed"
ec trim
ec 1
ec \ 
ec "split"
ec "line"
ec "split"
ino <C-z> a # remove comment
var a="keep 1"
var a="keep 2"
ec "keep 3" " this is error 'Missing double quote'
ec "keep 4"
ec "keep 5 | keep  6"
ec "keep 7"
ec "keep 8 | keep 9"
ino A # keep 10
ino A #
ino A "
var a='keep  11'
ino A " \| keep 12" keep 13
ino <expr> A " \| keep  14"
ino <expr> A "
" keep 15 (missing double quote error)
ino A "
ec "keep 16" " keep 17 (missing double quote error)
ino A "
var a='keep 18'
ino A \"
ino A "
ino B " keep 19
def A(a: dict<any>, b: number): string
var c = a
var d = {
arg2: 'dict key is not renamed.'
}
var e = [s, 0]
for c in range(1, t[1])
endfor
const f = 1
final g = '2'
enddef
fu! B(b, c)
let d = a:b
let l:e = {
arg2: 'dict key is not renamed.'
}
let f = [s, 0]
for l:d in range(1, t[1])
endfor
const l:g = 1
endf
var s = 0
const [t, lk] = [1, s]
final f = 'FINAL'
for [ll, lm] in [[1, 2], [3, t[0]]]
endfor
export def! This_is_exported(a: string)
var b = a
enddef
def C()
enddef
fu D()
endf
ec "rename <SID>C() <SID>D()"
ec "ignore <SID>SidTestDef <SID>SidTestFunction"
ec "ignore SidTestDef() SidTestFunction()"
var ln = 0
echoh Normal # this is not renamed.
g:this_is_global_val_not_renamed = 0
