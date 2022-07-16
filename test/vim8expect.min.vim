let s:a=tempname()
try
let s:b=expand('<sfile>')
let s:c=substitute(s:b,'test\.vim$','expect.min.vim','')
call minviml#Minify(s:b,s:a)
let s:d=join(readfile(s:c),'\n')
let s:e=join(readfile(s:a),'\n')
if s:d==# s:e
ec 'TEST OK !'
else
exe 'tabe '.s:c
exe 'diffs '.s:a
endif
finally
call delete(s:a)
endtry
finish
let default_mark_is_used='QQQ'
let string_is_not_changed=0
ec 'Join line string_is_not_changed'
let string_is_not_changed=0
ec "string_is_not_changed"
ec trim
ec 1
ec \ 
ec "split"|ec "line"
let a="keep 1" "this is comment"
let a="keep 2"
ec "keep 3"
ec "keep 4"|ec "keep 5 | keep  6"
ec "keep 7"|ec "keep 8 | keep 9"|ino A " keep 10
ino A "|ino A "|let a='keep  11'
ino A " \| keep 12" keep 13
ino <expr> A " \| keep  14"
ino <expr> A "|ino A "|ec "keep    16"
ino A "|let a='keep 18'
ino A \"|ino A "|ino B " keep 19
let a=1|ino A "|ino B " keep 20
let b=2|au VimEnter * inoermap A " | inoremap B "
set set1=setvalue1
set set2=" comment, so this line is error
fu! s:A(b,c)
let d=a:b
let l:e={
arg2: 'dict key is not renamed.'
}
let f=[s:f,0]
for l:d in range(1,const1[1])
endfo
let [g,h]=[1,2]
for [l:i,j] in range(1,const1[1])
endfo
cons l:ba=1
endf
let s:f=0
cons [s:g,s:h]=[1,s:f]
for [s:i,s:j] in [[1,2],[3,s:g[0]]]
endfo
fu! vim8test#This_is_exported(b)
let l:c=a:b
endf
let minifyspaces='12345'|let minifyspaces2=1
nn dont minify    keymap
let [s:ba,s:ba]=['a'.'b',1+2-3*4/5]
fu s:B()
endf
ec "rename <SID>SidTestDef() <SID>B()"
ec "ignore <SID>SidTestDef <SID>SidTestFunction"
ec "ignore SidTestDef() SidTestFunction()"
let Normal=0
echoh Normal
let g:this_is_global_val_not_renamed=0
