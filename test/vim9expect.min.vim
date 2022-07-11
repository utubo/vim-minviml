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
ec 'Join line'
ec "split"
echo "line"
var p = 0
const [q, r] = [1, p]
final f = 'FINAL'
for [s, t] in [[1, 2], [3, q[0]]]
endfor
def A(a: dict<any>, b: number): string
var c = a
var d = {
arg2: 'dict key is not renamed.'
}
var e = [p, 0]
for c in range(1, q[1])
endfor
const f = 1
final g = '2'
enddef
exe 'nnoremap <SID>A()'
ec 'this is string, so be not renamed. scriptLocalVal'
var lk = 0
echoe lk
