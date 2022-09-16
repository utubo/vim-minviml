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
var q = 'QQQ'
var r = 0
ec 'Join line string_is_not_changed'
var r = 0
ec "string_is_not_changed"
var s = 1
var t = 'two'
var lk = $'abc{s}{t}'
var lk = $'abc{s}xyz{t}{this is dummy}'
var ll = $"abc{s}xyz{t}{this is dummy}"
ec $'{s->substitute('.', $'{t}')}'
ec trim
ec 1
ec \ 
ec "split"|ec "line"
var a="keep 1"
var a="keep 2"
ec "keep 3" " this is error 'Missing double quote'
ec "keep 4"|ec "keep 5 | keep  6"
ec "keep 7"|ec "keep 8 | keep 9"|ino A # keep 10
ino A #|ino A "|var a='keep  11'
ino A " \| keep 12" keep 13
ino <expr> A " \| keep  14"
ino <expr> A "|" keep 15 (missing double quote error)
ino A "|ec "keep    16" " keep 17 (missing double quote error)
ino A "|var a='keep 18'
ino A \"|ino A "|ino B " keep 19
let a=1|ino A "|ino B " keep 20
let b=2|au VimEnter * inoermap A " | inoremap B "
set set1=setvalue1
set set2=# not comment
au VimEnter * var a = 1 # this is comment
au VimEnter * nmap # this is not comment
def A(a: dict<any>, b: number): string
var c = a
var d = {
arg2: 'dict key is not renamed.'
}
var e = [lm, 0]
for c in range(1, ln[1])
endfor
var [f, g] = [1, 2]
for [l:h, i] in range(1, ln[1])
endfor
const j = 1
final ba = '2'
var bb = &ff
enddef
fu! B(b, c)
let d = a:b
let l:e = {
arg2: 'dict key is not renamed.'
}
let f = [lm, 0]
for l:d in range(1, ln[1])
endfor
var [g, h] = [1, 2]
for [l:i, j] in range(1, ln[1])
endfor
const l:ba = 1
endf
var lm = 0
const [ln, lo] = [1, lm]
final f = 'FINAL'
for [lp, lq] in [[1, 2], [3, ln[0]]]
endfor
export def! This_is_exported(a: string)
var b = a
enddef
var lr = '12345'|let minifyspaces2 = 1
nn dont minify    keymap
def C()
enddef
fu D()
endf
ec "rename <SID>C() <SID>D()"
ec "ignore <SID>SidTestDef <SID>SidTestFunction"
ec "ignore SidTestDef() SidTestFunction()"
var ls = 0
echoh Normal
g:this_is_global_val_not_renamed = 0
