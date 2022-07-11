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
let default_mark_is_used='ESCMARK'
let string_is_not_changed=0
ec 'Join line string_is_not_changed'
let string_is_not_changed=0
ec "string_is_not_changed"
ec trim
ec 1
ec \ 
" TODO: see issue "15
ec "split"
echo "line"
" TODO: see issue "17
ec "split"
ino <C-z> a " remove comment
fu! s:A(b,c)
let d=a:b
let l:e={
arg2: 'dict key is not renamed.'
}
let f=[s:f,0]
for l:d in range(1,const1[1])
endfor
const l:g=1
endf
let s:f=0
const [s:g,s:h]=[1,s:f]
for [s:i,s:j] in [[1,2],[3,s:g[0]]]
endfor
fu! vim8test#This_is_exported(b)
let l:c=a:b
endf
let [s:ba,s:ba]=['a'.'b',1+2-3*4/5]
fu s:B()
endf
ec "rename <SID>SidTestDef() <SID>B()"
ec "ignore <SID>SidTestDef <SID>SidTestFunction"
ec "ignore SidTestDef() SidTestFunction()"
let Normal=0
echoh Normal " this is not renamed.
let g:this_is_global_val_not_renamed=0
