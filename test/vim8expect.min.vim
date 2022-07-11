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
ec 1
ec \ 
ec 'Join line'
ec "split"
echo "line"
let s:f=0
const [s:g,s:h]=[1,s:f]
for [s:i,s:j] in [[1,2],[3,s:g[0]]]
endfor
fu! s:A(b,c)
let d=a:b
let l:e={
arg2: 'dict key is not renamed.'
}
let f=[s:f,0]
for l:d in range(1,s:g[1])
endfor
const l:g=1
enddef
exe 'nnoremap <SID>A()'
ec 'this is string, so be not renamed. s:scriptLocalVal'
let s:ba=0
echoe Normal
let this_is_global_val_not_renamed=0
