let tmpfile=tempname()
try
let srcfile=expand('<sfile>')
let expfile=substitute(srcfile,'test\.vim$','expect.min.vim','')
call minviml#Minify(srcfile,tmpfile)
let expect=join(readfile(expfile),'\n')
let actual=join(readfile(tmpfile),'\n')
if expect==# actual
ec 'TEST OK !'
else
exe 'tabe '.expfile
exe 'diffs '.tmpfile
endif
finally
call delete(tmpfile)
endtry
finish
ec 1
ec \ 
ec 'Join line'
ec "split"
echo "line"
let scriptLocalVal=0
const [const1,const2]=[1,scriptLocalVal]
for [aaa,bbb] in [[1,2],[3,const1[0]]]
endfor
fu! ScriptLocalDef(a,b)
let c=a
let d={
arg2: 'dict key is not renamed.'
}
let e=[scriptLocalVal,0]
for c in range(1,const1[1])
endfor
const f=1
enddef
exe 'nnoremap <SID>ScriptLocalDef()'
ec 'this is string, so be not renamed. scriptLocalVal'
let Normal=0
echoe Normal
