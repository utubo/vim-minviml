vim9script

var allLines = ['']
var isVim9 = false
var escMark = 'ESCMARK'

def SetupEscMark()
  const joined = join(allLines, '')
  var i = 0
  while true
    if match(joined, escMark) ==# -1
      break
    endif
    i = i + 1
    escMark = 'ESCMARK' .. string(i)
  endwhile
enddef

def EscMark(index: any = ''): string
  return '<' .. escMark .. ':' .. string(index) .. '>'
enddef

def Put(expr: list<any>, item: any)
  if match(expr, item) ==# -1
    add(expr, item)
  endif
enddef

const NO_MINIFY_COMMANDS = [
  'nn', # nnoremap
  'vn', # vnoremap
  'xn', # xnoremap
  'snor', # snoremap
  'ono', # onoremap
  'ino', # inoremap
  'ln', # lnoremap
  'cno', # cnoremap
  'tno', # tnoremap
  'no', # noremap
  'nm', # nmap
  'vm', # vmap
  'xm', # xmap
  'om', # omap
  'im', # imap
  'lm', # lmap
  'cm', # cmap
  'tma', # tmap
  'echoh', # echohl
  'au', # autocmd
]
const NO_MINIFY = '^\(' .. join(NO_MINIFY_COMMANDS, '\|') .. '\)\s'

var scanResult = []
def Scan(expr: any, pat: string, index: number = 0): list<string>
  scanResult = []
  substitute(expr, pat, '\=add(scanResult, submatch(' .. string(index) .. '))[0]', 'g')
  return scanResult
enddef

def RemoveComments()
  var newLines = []
  for line in allLines
    var rep = line
    rep = substitute(rep, '^\s*', '', '')
    if isVim9
      rep = substitute(rep, '^#.*', '', '')
    else
      rep = substitute(rep, '^".*', '', '')
    endif
    rep = substitute(rep, '(\\\s)\?\s*$', '\1', '')
    if len(rep) !=# 0
      add(newLines, rep)
    endif
  endfor
  allLines = newLines
enddef

def RemoveTailComments()
  var newLines = []
  var strs = []
  for line in allLines
    var rep = line
    if rep !~# NO_MINIFY
      [rep, strs] = EscapeStrings(rep)
      if isVim9
        rep = substitute(rep, '\s#.*$', ' ', '')
      else
        rep = substitute(rep, '\s"[^"]*$', ' ', '')
      endif
      rep = UnescapeStrings(rep, strs)
    endif
    rep = substitute(rep, '\([^\\]\)\s*\s$', '\1', '')
    if len(rep) !=# 0
      add(newLines, rep)
    endif
  endfor
  allLines = newLines
enddef

def MinimizeCommands()
  var newLines = []
  for line in allLines
    var rep = line
    rep = substitute(rep, '^silent\(!\?\)\s\+', 'sil\1 ', '')
    # TODO: add commands
    for [k, v] in items({
      scriptencoding: 'scripte',
      endfunction: 'endf',
      nohlsearch: 'noh',
      endwhile: 'endw',
      function: 'fu',
      setlocal: 'setl',
      tabclose: 'tabc',
      nnoremap: 'nn',
      vnoremap: 'vn',
      xnoremap: 'xn',
      snoremap: 'snor',
      onoremap: 'ono',
      inoremap: 'ino',
      lnoremap: 'ln',
      cnoremap: 'cno',
      tnoremap: 'tno',
      noremap: 'no',
      augroup: 'aug',
      autocmd: 'au',
      command: 'com',
      echomsg: 'echom',
      execute: 'exe',
      tabnext: 'tabn',
      cunmap: 'cu',
      iunmap: 'iu',
      lunmap: 'lu',
      nunmap: 'nu',
      ounmap: 'ou',
      xunmap: 'xu',
      vunmap: 'vu',
      sunmap: 'sunm',
      echohl: 'echoh',
      #endfor: 'endfo',
      #return: 'retu',
      source: 'so',
      #const: 'cons',
      unmap: 'unm',
      while: 'wh',
      echo: 'ec',
      nmap: 'nm',
      vmap: 'vm',
      xmap: 'xm',
      omap: 'om',
      imap: 'im',
      lmap: 'lm',
      cmap: 'cm',
      tmap: 'tma',
    })
      rep = substitute(rep, '^\(sil!\?\s\+\)\?' .. k .. '\>', '\1' .. v, '')
      rep = substitute(rep, '^\(sil!\?\s\+\)\?' .. v .. '\s\+', '\1' .. v .. ' ', '')
    endfor
    # TODO: add settings
    for [k, v] in items({
        fileencodings: 'fencs',
        fileencoding: 'fenc',
        breakindent: 'bri',
        smartindent: 'si',
        softtabstop: 'st',
        ttimeoutlen: 'ttm',
        virtualedit: 've',
        autoindent: 'ai',
        backupskip: 'bsk',
        laststatus: 'ls',
        ambiwidth: 'ambw',
        autochdir: 'acd',
        expandtab: 'et',
        fillchars: 'fcs',
        listchars: 'lcs',
        incsearch: 'is',
        encoding: 'enc',
        filetype: 'ft',
        hlsearch: 'hls',
        wildmenu: 'wmnu',
        belloff: 'bo',
        tabstop: 'ts',
        undodir: 'udir',
        ruler: 'ru',
    })
      rep = substitute(rep, '^\(set\|setl\)\s\+\(no\)\?' .. k .. '\>', '\1 \2' .. v, '')
      rep = substitute(rep, '&' .. k .. '\>', '\&' .. v, 'g')
    endfor
    add(newLines, rep)
  endfor
  allLines = newLines
enddef

var escapedStrs = []
def EscapeStrings(line: string): list<any>
  var rep = line
  escapedStrs = []
  const esc =  '\=EscMark(len(add(escapedStrs, submatch(0))) - 1)'
  rep = substitute(rep, '''\([^'']\|''''\)*''', esc, 'g')
  rep = substitute(rep, '"\([^"\\]\|\\.\)*"', esc, 'g')
  var strs = extend([], escapedStrs)
  return [rep, strs]
enddef

def UnescapeStrings(line: string, strs: list<string>): string
  var rep = line
  for i in reverse(range(0, len(strs) - 1))
    #rep = substitute(rep, EscMark(i), strs[i], '') TODO bug ?
    rep = substitute(rep, EscMark(i), escape(strs[i], '&\'), 'g')
  endfor
  return rep
enddef

def CreateNewNamesMap(joined: string, names: list<string>, opt: dict<any> = {}): dict<any>
  var vals = {}
  var nameIndex = -1
  var fmt = get(opt, 'format', '%s')
  var offset = char2nr(get(opt, 'offset', 'a')) - char2nr('0')
  for name in names
    while true
      nameIndex  = nameIndex + 1
      var newName = printf(
        fmt,
        substitute(string(nameIndex),
        '\(\d\)',
        '\=nr2char(char2nr(submatch(1)) + offset)', 'g')
      )
      if joined !~# '\<' .. newName .. '\>'
        vals[name] = newName
        break
      endif
    endwhile
  endfor
  return vals
enddef

def ReplaceVals(lines: list<string>, oldToNew: dict<any>, scope: list<string> = []): list<string>
  var newLines = []
  var strs = []
  var scopeReg = '\(' .. join(extend(['^', '[^a-zA-Z_:$]'], scope), '\|') .. '\)'
  for line in lines
    var rep = line
    if line !~# NO_MINIFY
      [rep, strs] = EscapeStrings(rep)
      for [k, v] in items(oldToNew)
        rep = substitute(rep, '\<' .. k .. '\s*:', EscMark(), 'g') # escape dict keys
        rep = substitute(rep, scopeReg .. k .. '\([^a-zA-Z0-9_(:]\|$\)', '\1' .. v .. '\2', 'g')
        rep = substitute(rep, EscMark(), k .. ':', 'g') # unescape dict keys
      endfor
      rep = UnescapeStrings(rep, strs)
    endif
    add(newLines, rep)
  endfor
  return newLines
enddef

def MinimizeDefLocal(lines: list<string>): list<string>
  var joined = join(lines, ' | ')
  # find all vals
  var srcVals = []
  extend(srcVals, Scan(matchstr(lines[0], '([^)]*)'), '\<\([a-zA-Z][a-zA-Z0-9_]\+\)\s*:', 1))
  const escCoron = EscMark(':')
  lines[0] = substitute(lines[0], ':', escCoron, 'g')
  for line in lines
    var m = matchlist(line, '^\(var\|const\|final\|for\)\s\+\([al]:\)\?\([a-zA-Z][a-zA-Z0-9_]\+\)')
    if len(m) !=# 0
      Put(srcVals, m[3])
    endif
  endfor
  # new names
  var vals = CreateNewNamesMap(joined, srcVals)
  # minify
  var newLines = ReplaceVals(lines, vals, ['l:', 'a:'])
  newLines[0] = substitute(newLines[0], escCoron, ':', 'g')
  return newLines
enddef

def MinimizeFunctionLocal(lines: list<string>): list<string>
  var joined = join(lines, ' | ')
  # find all vals
  var srcVals = []
  extend(srcVals, Scan(matchstr(lines[0], '([^)]*)'), '\([a-zA-Z][a-zA-Z0-9_]\+\)', 1))
  for line in lines
    var m = matchlist(line, '^\(let\|for\)\s\+\([al]:\)\?\([a-zA-Z][a-zA-Z0-9_]\+\)')
    if len(m) !=# 0
      Put(srcVals, m[3])
    endif
  endfor
  # new names
  var vals = CreateNewNamesMap(joined, srcVals)
  # minify
  return ReplaceVals(lines, vals, ['l:', 'a:'])
enddef

def MinimizeAllDefsLocal()
  var newLines = []
  var defLines = []
  var isDef = false
  for line in allLines
    if line =~# '^enddef$\|^endf$'
      isDef = false
      if defLines[0] =~# '^def'
        extend(newLines, MinimizeDefLocal(defLines))
      else
        extend(newLines, MinimizeFunctionLocal(defLines))
      endif
    elseif line =~# '^\(def\|fu\)!\?\s'
      isDef = true
      defLines = []
    endif
    if isDef
      add(defLines, line)
    else
      add(newLines, line)
    endif
  endfor
  allLines = newLines
enddef

def MinimizeScriptLocal()
  var newLines = []
  # def, function
  var defNames = []
  for line in allLines
    var m = matchlist(line, '^\(def\|fu\)!\?\s\+\(\([A-Z]\|s:[a-zA-Z]\)[a-zA-Z0-9_]\+(\)')
    if len(m) !=# 0
      Put(defNames, substitute(m[2], '^s:', '', ''))
    endif
  endfor
  var defs = CreateNewNamesMap(join(allLines, ' | '), defNames, { offset: 'A', format: '%s(' })
  var strs = []
  for line in allLines
    var rep = line
    [rep, strs] = EscapeStrings(rep)
    for [k, v] in items(defs)
      rep = substitute(rep, '\(^\|[^a-zA-Z0-9_:#]\|\<s:\)' .. k, '\1' .. v, 'g')
    endfor
    rep = UnescapeStrings(rep, strs)
    for [k, v] in items(defs)
      rep = substitute(rep, '<SID>' .. k, '<SID>' .. v, 'g')
    endfor
    add(newLines, rep)
  endfor
  allLines = newLines

  # s:val
  var svalNames = []
  for line in allLines
    var m = matchlist(line, '^\(let\|const\)\s\+\(s:[a-zA-Z_][a-zA-Z_0-9]\+\)\>')
    if len(m) !=# 0
      Put(svalNames, m[2])
    endif
  endfor
  var svals = CreateNewNamesMap(join(allLines, ' | '), svalNames, { format: 's:%s' })
  allLines = ReplaceVals(allLines, svals, ['s:'])

  # without "s:" for vim9script
  if isVim9
    var sval9Names = []
    var isDef = false
    for line in allLines
      if line =~# '^\(def\|fu\)!\?\s'
        isDef = true
      elseif line =~# '^\(enddef\|endf\)$'
        isDef = false
      endif
      if ! isDef
        var m = matchlist(line, '^\(var\|const\|final\)\s\+\([a-zA-Z_][a-zA-Z_0-9]\+\)\>')
        if len(m) !=# 0
          Put(sval9Names, m[2])
        endif
      endif
    endfor
    var sval9s = CreateNewNamesMap(join(allLines, ' | '), sval9Names, { offset: 'k' })
    allLines = ReplaceVals(allLines, sval9s, ['s:'])
  endif
enddef

def CreateDestPath(src: string): string
  if src =~# 'vimrc\.src\.vim$'
    return substitute(src, '\.src\.vim$', '', '')
  elseif src =~# '\.src\.vim$'
    return substitute(src, '\.src\.vim$', '.vim', '')
  elseif src =~# '\.vim$'
    return substitute(src, '\.vim$', '.min.vim', '')
  else
    return src .. '.min.vim'
  endif
enddef

export def Minify(src: string = '%', dest: string = '')
  var eSrc = expand(src)
  var eDest = dest != '' ? expand(dest) : CreateDestPath(eSrc)
  allLines = readfile(eSrc)
  isVim9 = allLines[0] ==# 'vim9script'
  SetupEscMark()
  RemoveComments()
  MinimizeCommands()
  RemoveTailComments()
  MinimizeAllDefsLocal()
  MinimizeScriptLocal()
  writefile(allLines, eDest)
  redraw
  echo ''
  echoh Delimiter
  echo 'minify to' eDest
  echoh Normal
enddef

