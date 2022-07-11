let tmpfile = tempname()
try
	let srcfile = expand('<sfile>')
	let expfile = substitute(srcfile, 'test\.vim$', 'expect.min.vim', '')
	call minviml#Minify(srcfile, tmpfile)
	let expect = join(readfile(expfile), '\n')
	let actual = join(readfile(tmpfile), '\n')
	if expect ==# actual
		echo 'TEST OK !'
	else
		execute 'tabe ' . expfile
		execute 'diffs ' . tmpfile
	endif
finally
	call delete(tmpfile)
endtry

finish

" -------------------------------------
" test data
" -------------------------------------

echo 1 " remove comment
echo \ " keep escaped space
" skip empty lines
	     	

ech
	\o 'Join line'

" TODO: see issue #15
echo "split" | echo "line"

let scriptLocalVal = 0
const [const1, const2] = [1, scriptLocalVal]

for [aaa, bbb]  in [[1, 2], [3, const1[0]]]
endfor

function! ScriptLocalDef(arg1, arg2)
	let localVal = arg1
	let localVal2 = {
		arg2: 'dict key is not renamed.'
	}
	let localVal3 = [scriptLocalVal, 0]
	for localVal in range(1, const1[1])
	endfor
	const localConst = 1
enddef

execute 'nnoremap <SID>ScriptLocalDef()'
echo 'this is string, so be not renamed. scriptLocalVal'

let Normal = 0
echoe Normal " this is not renamed.

