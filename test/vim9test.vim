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

echo 1 # remove comment
echo \ " keep escaped space
# skip empty lines
	     	

ech
	\o 'Join line'

# TODO: see issue #15
echo "split" | echo "line"

var scriptLocalVal = 0
const [const1, const2] = [1, scriptLocalVal]
final f = 'FINAL'

for [aaa, bbb]  in [[1, 2], [3, const1[0]]]
endfor

def ScriptLocalDef(arg1: dict<any>, arg2: number): string
	var localVal = arg1
	var localVal2 = {
		arg2: 'dict key is not renamed.'
	}
	var localVal3 = [scriptLocalVal, 0]
	for localVal in range(1, const1[1])
	endfor
	const localConst = 1
	final localFinal = '2'
enddef

execute 'nnoremap <SID>ScriptLocalDef()'
echo 'this is string, so be not renamed. scriptLocalVal'

var Normal = 0
echoe Normal # this is not renamed.

