vim9script

var allLines = ['']
var isVim9 = false

# -----------------
# Options
var reserved = ''
var fixed = ''
def SetupOption(opt: dict<any>)
  reserved = '^\(' .. join(get(opt, 'reserved', []), '\|') .. '\)$'
  fixed = '^\(' .. join(get(opt, 'fixed', []), '\|') .. '\)$'
enddef

# -----------------
# Escape strings
var escMark = 'QQQ'
var escapedStrs = []

def SetupEscMark()
  const joined = join(allLines, '')
  var i = 0
  while true
    if match(joined, escMark) ==# -1
      break
    endif
    i = i + 1
    escMark = 'QQQ' .. string(i)
  endwhile
enddef

def EscMark(index: any = ''): string
  return printf('<%s_%s>', escMark, index)
enddef

def EscapeStrings()
  escapedStrs = []
  var newLines = []
  const esc =  '\=EscMark(len(add(escapedStrs, submatch(0))) - 1)'
  for line in allLines
    add(newLines, substitute(line, '''\([^'']\|''''\)*''\|"\([^"\\]\|\\.\)*"', esc, 'g'))
  endfor
  allLines = newLines
enddef

def UnescapeStrings()
  var newLines = []
  const esc = EscMark('\(\d\+\)')
  for line in allLines
    add(newLines, substitute(line, esc, '\=escapedStrs[str2nr(submatch(1))]', 'g'))
  endfor
  allLines = newLines
enddef

# -----------------
# Utils

def Put(expr: list<any>, item: any)
  if match(expr, item) ==# -1
    add(expr, item)
  endif
enddef

# put all submatch(<index>) from <lines> to <target> list.
def PutMatchStr(target: list<any>, lines: list<string>, pat: string, index: number)
  for line in lines
    var m = matchlist(line, pat)
    if len(m) !=# 0
      Put(target, m[index])
    endif
  endfor
enddef

var scanResult = []
def Scan(expr: any, pat: string, index: number = 0): list<string>
  scanResult = []
  substitute(expr, pat, '\=add(scanResult, submatch(' .. string(index) .. '))[0]', 'g')
  return scanResult
enddef

# -----------------
# Minify
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
    if rep =~# '^set\s\+'
      rep = substitute(rep, '^set\s\+', 'set ', '')
    else
      rep = substitute(rep, '\s\+', ' ', 'g')
    endif
    if len(rep) !=# 0
      add(newLines, rep)
    endif
  endfor
  allLines = newLines
enddef

def RemoveTailComments()
  var newLines = []
  for line in allLines
    var rep = line
    if rep !~# NO_MINIFY
      if isVim9
        rep = substitute(rep, '\s#.*$', ' ', '')
      else
        rep = substitute(rep, '\s"[^"]*$', ' ', '')
      endif
    endif
    rep = substitute(rep, '\(\\\s\)\?\s*$', '\1', '')
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
    rep = substitute(rep, '^silent\(!\?\) ', 'sil\1 ', '')
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
      rep = substitute(rep, '^\(sil!\? \)\?' .. k .. '\>', '\1' .. v, '')
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
      rep = substitute(rep, '^\(set\|setl\) \(no\)\?' .. k .. '\>', '\1 \2' .. v, '')
      rep = substitute(rep, '&' .. k .. '\>', '\&' .. v, 'g')
    endfor
    add(newLines, rep)
  endfor
  allLines = newLines
enddef

def CreateNewNamesMap(lines: list<string>, names: list<string>, opt: dict<any> = {}): dict<any>
  var joined = join(lines, ' | ')
  var vals = {}
  var nameIndex = -1
  var fmt = get(opt, 'format', '%s')
  var offset = char2nr(get(opt, 'offset', 'a')) - char2nr('0')
  for name in names
    if name =~# fixed
      continue
    endif
    while true
      nameIndex  = nameIndex + 1
      var newName = printf(
        fmt,
        substitute(string(nameIndex),
        '\(\d\)',
        '\=nr2char(char2nr(submatch(1)) + offset)', 'g')
      )
      if joined !~# '\<' .. newName .. '\>' && newName !~# reserved
        vals[name] = newName
        break
      endif
    endwhile
  endfor
  return vals
enddef

def ReplaceVals(lines: list<string>, oldToNew: dict<any>, scope: list<string> = []): list<string>
  var newLines = []
  var scopeReg = '\(' .. join(extend(['^', '[^a-zA-Z_:$]'], scope), '\|') .. '\)'
  for line in lines
    var rep = line
    if line !~# NO_MINIFY
      for [k, v] in items(oldToNew)
        rep = substitute(rep, '\<' .. k .. ' *:', EscMark(), 'g') # escape dict keys
        rep = substitute(rep, scopeReg .. k .. '\([^a-zA-Z0-9_(:]\|$\)', '\1' .. v .. '\2', 'g')
        rep = substitute(rep, EscMark(), k .. ':', 'g') # unescape dict keys
      endfor
    endif
    add(newLines, rep)
  endfor
  return newLines
enddef

def MinimizeDefLocal(lines: list<string>): list<string>
  # find all vals
  var srcVals = []
  extend(srcVals, Scan(matchstr(lines[0], '([^)]*)'), '\<\([a-zA-Z][a-zA-Z0-9_]\+\) *:', 1))
  const escCoron = EscMark(':')
  lines[0] = substitute(lines[0], ':', escCoron, 'g')
  PutMatchStr(srcVals, lines, '^\(var\|const\|final\|for\) \([al]:\)\?\([a-zA-Z][a-zA-Z0-9_]\+\)', 3)
  # minify
  var newVals = CreateNewNamesMap(lines, srcVals)
  var newLines = ReplaceVals(lines, newVals, ['l:', 'a:'])
  newLines[0] = substitute(newLines[0], escCoron, ':', 'g')
  return newLines
enddef

def MinimizeFunctionLocal(lines: list<string>): list<string>
  # find all vals
  var srcVals = []
  extend(srcVals, Scan(matchstr(lines[0], '([^)]*)'), '\([a-zA-Z][a-zA-Z0-9_]\+\)', 1))
  PutMatchStr(srcVals, lines, '^\(let\|for\) \([al]:\)\?\([a-zA-Z][a-zA-Z0-9_]\+\)', 3)
  # minify
  var newVals = CreateNewNamesMap(lines, srcVals)
  return ReplaceVals(lines, newVals, ['l:', 'a:'])
enddef

def MinimizeAllDefsLocal()
  var newLines = []
  var defLines = []
  var isDef = false
  for line in allLines
    if line =~# '^\(def\|fu\)!\? '
      isDef = true
      defLines = []
    elseif line =~# '^enddef$\|^endf$'
      isDef = false
      if defLines[0] =~# '^def'
        extend(newLines, MinimizeDefLocal(defLines))
      else
        extend(newLines, MinimizeFunctionLocal(defLines))
      endif
    endif
    if isDef
      add(defLines, line)
    else
      add(newLines, line)
    endif
  endfor
  allLines = newLines
enddef

var scriptLocalDefs = {}
def MinimizeScriptLocal()
  var newLines = []

  # def, function
  var defNames = []
  if isVim9
    PutMatchStr(defNames, allLines, '^\(def\|fu\)!\? \([A-Z][a-zA-Z0-9_]\+(\)', 2)
  else
    PutMatchStr(defNames, allLines, '^fu!\? s:\([a-zA-Z][a-zA-Z0-9_]\+(\)', 1)
  endif
  scriptLocalDefs = CreateNewNamesMap(allLines, defNames, { offset: 'A', format: '%s(' })
  for line in allLines
    var rep = line
    for [k, v] in items(scriptLocalDefs)
      rep = substitute(rep, '\(^\|[^a-zA-Z0-9_:#]\|\<s:\)' .. k, '\1' .. v, 'g')
    endfor
    add(newLines, rep)
  endfor
  allLines = newLines

  # valiables
  if isVim9
    # without "s:"
    var sval9Names = []
    var isDef = false
    for line in allLines
      if line =~# '^\(def\|fu\)!\? '
        isDef = true
      elseif line =~# '^\(enddef\|endf\)$'
        isDef = false
      endif
      if ! isDef
        PutMatchStr(sval9Names, [line], '^\(var\|const\|final\|for\) \([a-zA-Z_][a-zA-Z_0-9]\+\)\>', 2)
      endif
    endfor
    var sval9s = CreateNewNamesMap(allLines, sval9Names, { offset: 'k' })
    allLines = ReplaceVals(allLines, sval9s, ['s:'])
  else
    # s:val
    var svalNames = []
    PutMatchStr(svalNames, allLines, '^\(let\|const\|for\) \(s:[a-zA-Z_][a-zA-Z_0-9]\+\)\>', 2)
    var svals = CreateNewNamesMap(allLines, svalNames, { format: 's:%s' })
    allLines = ReplaceVals(allLines, svals, ['s:'])
  endif
enddef

def MinimizeSIDDefs()
  var newLines = []
  for line in allLines
    var rep = line
    for [k, v] in items(scriptLocalDefs)
      rep = substitute(rep, '<SID>' .. k, '<SID>' .. v, 'g')
    endfor
    add(newLines, rep)
  endfor
  allLines = newLines
enddef

def RemoveVim8Spaces()
  if isVim9
    return
  endif
  var newLines = []
  for line in allLines
    var rep = line
    if line !~# NO_MINIFY
      rep = substitute(rep, ' *\([.,=+*/-]\) *', '\1', 'g')
    endif
    add(newLines, rep)
  endfor
  allLines = newLines
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

export def Minify(src: string = '%', dest: string = '', opt: dict<any> = {})
  var eSrc = expand(src)
  var eDest = dest != '' ? expand(dest) : CreateDestPath(eSrc)
  allLines = readfile(eSrc)
  isVim9 = allLines[0] ==# 'vim9script'
  SetupEscMark()
  EscapeStrings()
  SetupOption(opt)
  RemoveComments()
  MinimizeCommands()
  RemoveTailComments()
  MinimizeAllDefsLocal()
  MinimizeScriptLocal()
  RemoveVim8Spaces()
  UnescapeStrings()
  MinimizeSIDDefs()
  writefile(allLines, eDest)
  redraw
  echoh Delimiter
  echo 'minify to' eDest
  echoh Normal
enddef

