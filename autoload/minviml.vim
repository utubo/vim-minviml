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
    i += 1
    escMark = 'QQQ' .. string(i)
  endwhile
enddef

def EscMark(index: any = ''): string
  return printf('<%s_%s>', escMark, index)
enddef

const ESC_STR_SUB = '\=EscMark(len(add(escapedStrs, submatch(0))) - 1)'
def EscapeStrings()
  escapedStrs = []
  var newLines = []
  for line in allLines
    add(newLines, substitute(line, '''\([^'']\|''''\)*''\|"\([^"\\]\|\\.\)*"', ESC_STR_SUB, 'g'))
  endfor
  allLines = newLines
enddef

def UnescapeStrings()
  var newLines = []
  const esc = EscMark('\(\d\+\)')
  for line in allLines
    add(newLines, substitute(line, esc, (m) => escapedStrs[str2nr(m[1])], 'g'))
  endfor
  allLines = newLines
enddef

# -----------------
# Utils

def Scan(expr: any, pat: string, index: number = 0): list<string>
  var scanResult = []
  substitute(expr, pat, (m) => add(scanResult, m[index])[0], 'g')
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
  'com', # command
  'au', # autocmd
]
const NO_MINIFY = '^\(' .. join(NO_MINIFY_COMMANDS, '\|') .. '\)!\?\s'

def JoinLines()
  var newLines = []
  for line in allLines
    if line =~# '^\s*\\'
      newLines[-1] ..= substitute(line, '^\s*\\', '', '')
    else
      add(newLines, line)
    endif
  endfor
  allLines = newLines
enddef

def ExpandVirticalBar()
  var newLines = []
  const escB = EscMark('B')
  const escV = EscMark('V')
  const escOR = EscMark('OR')
  for line in allLines
    if match(line, '|') !=# -1 && line !~# NO_MINIFY
      var rep = line
      rep = substitute(rep, '\\\\', escB, 'g')
      rep = substitute(rep, '\\|', escV, 'g')
      rep = substitute(rep, '||', escOR, 'g')
      for l in split(rep, '\s*|\s*')
        var r = l
        r = substitute(r, escOR, '||', 'g')
        r = substitute(r, escV, '\\|', 'g')
        r = substitute(r, escB, '\', 'g')
        add(newLines, r)
      endfor
    else
      add(newLines, line)
    endif
  endfor
  allLines = newLines
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
    if rep =~# '^set\s\+'
      rep = substitute(rep, '^set\s\+', 'set ', '')
    else
      rep = substitute(rep, '\s\+', ' ', 'g')
    endif
    if len(rep) ==# 0
      continue
    endif
    add(newLines, rep)
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

def MinifyCommands()
  # TODO: add commands
  const COMMAND_DICT = {
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
  }
  # TODO: add settings
  const SETTING_DICT = {
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
  }
  const COMMAND_PAT = join(keys(COMMAND_DICT), '\|')
  const SETTING_PAT = join(keys(SETTING_DICT), '\|')
  var newLines = []
  for line in allLines
    var rep = line
    rep = substitute(rep, '^silent\(!\?\) ', 'sil\1 ', '')
    rep = substitute(
      rep,
      '^\(sil!\? \)\?\(' .. COMMAND_PAT .. '\)\>',
      (m) => m[1] .. COMMAND_DICT[m[2]],
      ''
    )
    rep = substitute(
      rep,
      '^\(set\|setl\) \(no\)\?\(' .. SETTING_PAT .. '\)\>',
      (m) => m[1] .. ' ' .. m[2] .. SETTING_DICT[m[3]],
      ''
    )
    rep = substitute(
      rep,
      '&\(' .. SETTING_PAT .. '\)\>',
      (m) => '&' .. SETTING_DICT[m[1]],
      'g'
    )
    add(newLines, rep)
  endfor
  allLines = newLines
enddef

def ScanNames(names: list<any>, lines: list<string>, pat1: list<string>, pat2: string)
  for line in lines
    for pat in pat1
      var m = matchlist(line, pat)
      if len(m) !=# 0
        for n in Scan(m[1], pat2, 1)
          if index(names, n) ==# -1
            add(names, n)
          endif
        endfor
      endif
    endfor
  endfor
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

def ReplaceNames(lines: list<string>, oldToNew: dict<any>, scope: list<string> = []): list<string>
  if len(oldToNew) ==# 0
    return lines
  endif
  const scopePat = '\(' .. join(extend(['^', '[^a-zA-Z_:$]'], scope), '\|') .. '\)'
  const namePat = '\(' .. join(keys(oldToNew), '\|') .. '\)'
  const dictKeys = '\<' .. namePat .. ' *:'
  const pat = scopePat .. namePat .. '\([^a-zA-Z0-9_(:]\|$\)'
  var newLines = []
  for line in lines
    var rep = line
    if line !~# NO_MINIFY
      rep = substitute(rep, dictKeys, ESC_STR_SUB, 'g')
      rep = substitute(rep, pat, (m) => m[1] .. oldToNew[m[2]] .. m[3], 'g')
    endif
    add(newLines, rep)
  endfor
  return newLines
enddef

def MinifyDefLocal(lines: list<string>): list<string>
  # a:val
  const escCoron = EscMark(':')
  var srcVals = []
  if lines[0] =~# '^\(export \)\?def!\? '
    extend(srcVals, Scan(matchstr(lines[0], '([^)]*)'), '\<\([a-zA-Z][a-zA-Z0-9_]\+\) *:', 1))
    lines[0] = substitute(lines[0], ':', escCoron, 'g')
  else
    extend(srcVals, Scan(matchstr(lines[0], '([^)]*)'), '\([a-zA-Z_][a-zA-Z0-9_]\+\)', 1))
  endif
  # l:val
  ScanNames(srcVals, lines, ['^\%(var\|const\|final\|let\)\( [^=]\+\)', '^for\( [^=]\+\) in '], '\%(a:\|[ ,]\|[ ,]l:\)\([a-zA-Z_][a-zA-Z0-9_]\+\)')
  # minify
  var newVals = CreateNewNamesMap(lines, srcVals)
  var newLines = ReplaceNames(lines, newVals, ['l:', 'a:'])
  newLines[0] = substitute(newLines[0], escCoron, ':', 'g')
  return newLines
enddef

def MinifyAllDefsLocal()
  var newLines = []
  var defLines = []
  var isDef = false
  for line in allLines
    if line =~# '^\(export \)\?\(def\|fu\)!\? '
      isDef = true
      defLines = []
    elseif line =~# '^enddef$\|^endf$'
      isDef = false
      extend(newLines, MinifyDefLocal(defLines))
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
def MinifyScriptLocal()
  # def, function
  var defNames = []
  var defPat =
    isVim9 ? '^\%(def\|fu\)!\? \([A-Z][a-zA-z0-9_]\+\)('
    :        '^fu!\? s:\([a-zA-Z][a-zA-Z0-9_]\+\)('
  for line in allLines
    substitute(line, defPat, (m) => string(add(defNames, m[1])), '')
  endfor
  scriptLocalDefs = CreateNewNamesMap(allLines, defNames, { offset: 'A', format: '%s(' })

  if len(scriptLocalDefs) > 0
    var pat = printf('[a-zA-Z0-9_:#]\@<!\(s:\)\?\(%s\)\@>(', join(keys(scriptLocalDefs), '\|'))
    var newLines = []
    for line in allLines
      add(newLines, substitute(line, pat, (m) => m[1] .. scriptLocalDefs[m[2]], 'g'))
    endfor
    allLines = newLines
  endif

  # valiables
  if isVim9
    # without "s:"
    var sval9Names = []
    var isDef = false
    for line in allLines
      if line =~# '^\((export )\?def\|fu\)!\? '
        isDef = true
      elseif line =~# '^\(enddef\|endf\)$'
        isDef = false
      endif
      if ! isDef
        ScanNames(sval9Names, [line], ['^\%(var\|const\|final\) \([^=]\+\)', '^for \([^=]\+\) in '], '\([a-zA-Z_][a-zA-Z0-9_]\+\)')
      endif
    endfor
    var sval9s = CreateNewNamesMap(allLines, sval9Names, { offset: 'k' })
    allLines = ReplaceNames(allLines, sval9s, ['s:'])
  else
    # s:val
    var svalNames = []
    ScanNames(svalNames, allLines, ['^\%(let\|const\) \([^=]\+\)', '^for \([^=]\+\) in '], '\(s:[a-zA-Z_][a-zA-Z0-9_]\+\)')
    var svals = CreateNewNamesMap(allLines, svalNames, { format: 's:%s' })
    allLines = ReplaceNames(allLines, svals, ['s:'])
  endif
enddef

def MinifySIDDefs()
  if len(scriptLocalDefs) ==# 0
    return
  endif
  var pat = '<SID>\(' .. join(keys(scriptLocalDefs), '\|') .. '\)\@>('
  var newLines = []
  for line in allLines
    var rep = line
    rep = substitute(rep, pat, (m) => '<SID>' .. scriptLocalDefs[m[1]], 'g')
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
  redraw
  echoh Delimiter
  echo 'minifing to' eDest '...'
  echoh Normal
  redraw
  allLines = readfile(eSrc)
  isVim9 = allLines[0] ==# 'vim9script'
  SetupOption(opt)
  SetupEscMark()
  JoinLines()
  EscapeStrings()
  RemoveComments()
  MinifyCommands()
  ExpandVirticalBar()
  RemoveTailComments()
  MinifyAllDefsLocal()
  MinifyScriptLocal()
  RemoveVim8Spaces()
  UnescapeStrings()
  MinifySIDDefs()
  writefile(allLines, eDest)
  redraw
  echoh Delimiter
  echo 'minify to' eDest
  echoh Normal
enddef

