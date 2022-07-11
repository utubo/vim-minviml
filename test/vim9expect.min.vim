vim9script
var k = tempname()
try
var l = expand('<sfile>')
var m = substitute(l, 'test\.vim$', 'expect.min.vim', '')
minviml#Minify(l, k)
var n = join(readfile(m), '\n')
var o = join(readfile(k), '\n')
if n ==# o
ec 'TEST OK !'
else
exe 'tabe ' .. m
exe 'diffs ' .. k
endif
finally
delete(k)
endtry
finish
ec 1
ec \ " keep escaped space
var p = 0
ec 'Join line string_is_not_changed'
ec "split"
echo "line"
var q = 0
const [r, s] = [1, q]
final f = 'FINAL'
for [t, lk] in [[1, 2], [3, r[0]]]
endfor
def A(a: dict<any>, b: number): string
var c = a
var d = {
arg2: 'dict key is not renamed.'
}
var e = [q, 0]
for c in range(1, r[1])
endfor
const f = 1
final g = '2'
enddef
exe 'nnoremap <SID>A()'
ec 'this is string, so be not renamed. scriptLocalVal'
var ll = 0
echoe ll
