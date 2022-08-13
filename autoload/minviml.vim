vim9script

var allLines = ['']
var isVim9 = false
var lineCommentPat = '^\s*"'

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
var escapedStrs = []
var escMark = 'QQQ'
var escStr  = '<QQQ_\d\+>'
var escVBar = '<QQQ_VB>' # `|`
var vbarPat = '^\(.\{-}\)\(<QQQ_VB>\)\?$'

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
  escVBar = EscMark('VB')
  vbarPat = '^\(.\{-}\)\(' .. escVBar .. '\)\?$'
  escStr = EscMark('\(\d\+\)')
enddef

def EscMark(index: any = ''): string
  return printf('<%s_%s>', escMark, index)
enddef

const ESC_STR_SUB = '\=EscMark(len(add(escapedStrs, submatch(0))) - 1)'
def EscapeStrings(line: string): string
  var rep = line
    ->substitute('\$''\([^'']\|''''\)*''\|\$"\([^"\\]\|\\.\)*"', (m) => {
      return m[0]->substitute('[^{}]*{\|}[^{}]*', ESC_STR_SUB, 'g')
    }, 'g')
    ->substitute('''\([^'']\|''''\)*''\|"\([^"\\]\|\\.\)*"', ESC_STR_SUB, 'g')
  return rep
enddef

def EscapeAllStrings()
  escapedStrs = []
  var newLines = []
  for line in allLines
    if line !~# lineCommentPat
      add(newLines, EscapeStrings(line))
    endif
  endfor
  allLines = newLines
enddef

def UnescapeStrings(line: string): string
  return substitute(line, escStr, (m) => escapedStrs[str2nr(m[1])], 'g')
enddef

def UnescapeAllStrings()
  var newLines = []
  for line in allLines
    add(newLines, UnescapeStrings(line))
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
const KEYMAPCMD_DICT = {
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
  cunmap: 'cu',
  iunmap: 'iu',
  lunmap: 'lu',
  nunmap: 'nu',
  ounmap: 'ou',
  xunmap: 'xu',
  vunmap: 'vu',
  sunmap: 'sunm',
  unmap: 'unm',
  nmap: 'nm',
  vmap: 'vm',
  xmap: 'xm',
  omap: 'om',
  imap: 'im',
  lmap: 'lm',
  cmap: 'cm',
  tmap: 'tma',
}
const KEYMAPCMD = printf(
  '^\(%s\|%s\)!\?\s',
  join(keys(KEYMAPCMD_DICT), '\|'),
  join(values(KEYMAPCMD_DICT), '\|')
)

var GLOBALCMD_LIST = [
  'au',
  'autocmd',
  'com',
  'command',
  'set',
]
extend(GLOBALCMD_LIST, keys(KEYMAPCMD_DICT))
extend(GLOBALCMD_LIST, values(KEYMAPCMD_DICT))
const GLOBALCMD = printf('^\(\%(%s\)!\?\)\s\+', join(GLOBALCMD_LIST, '\|'))

def SplitWithVBar(line: string): list<string>
  if line =~# lineCommentPat
    return []
  endif
  if !isVim9 && UnescapeStrings(line) =~# lineCommentPat
    return []
  endif
  var rep = line
  var isUnescaped = false
  if line =~# KEYMAPCMD
    # for `nnoremap A " | nnoreap B "`
    rep = UnescapeStrings(rep)
    isUnescaped = true
  endif
  if match(rep, '|') ==# -1
    return [line]
  endif
  const EB = EscMark('V') # escaped bar `\|`
  const OR = EscMark('OR') # `||`
  rep = rep->substitute('||', OR, 'g')->substitute('\\|', EB, 'g')
  var m = matchlist(rep, '^\(.\{-}\)|\s*\(.*\)$')
  if len(m) < 2
    return [line]
  endif
  const leftStr  = m[1]->substitute(OR, '||', 'g')->substitute(EB, '\\|', 'g') .. escVBar
  const rightStr = m[2]->substitute(OR, '||', 'g')->substitute(EB, '\\|', 'g')
  var newLines = []
  if isUnescaped
    extend(newLines, SplitWithVBar(EscapeStrings(leftStr)))
    extend(newLines, SplitWithVBar(EscapeStrings(rightStr)))
  else
    extend(newLines, SplitWithVBar(leftStr))
    extend(newLines, SplitWithVBar(rightStr))
  endif
  return newLines
enddef

def SplitAllLinesWithVBar()
  var newLines = []
  for line in allLines
    extend(newLines, SplitWithVBar(line))
  endfor
  allLines = newLines
enddef

def UnescapeVBar()
  var newLines = []
  var joinNext = false
  for line in allLines
    var m = matchlist(line, vbarPat)
    if joinNext
      newLines[-1] ..= '|' .. m[1]
    else
      add(newLines, m[1])
    endif
    joinNext = !empty(m[2])
  endfor
  allLines = newLines
enddef

def TrimAndJoinLines()
  var newLines = []
  for line in allLines
    var rep = line
    rep = substitute(rep, '^\s*', '', '')
    if empty(rep)
      continue
    endif
    if rep =~# '^\\'
      newLines[-1] ..= rep[1 : ]
    else
      add(newLines, rep)
    endif
  endfor
  allLines = newLines
enddef

def MinifySpaces()
  var newLines = []
  for line in allLines
    if line =~# KEYMAPCMD
      add(newLines, substitute(line, GLOBALCMD, '\1 ', ''))
    else
      add(newLines, substitute(line, '\s\+', ' ', 'g'))
    endif
  endfor
  allLines = newLines
enddef

def MinifyVim8Spaces()
  if isVim9
    return
  endif
  var newLines = []
  for line in allLines
    if line =~# GLOBALCMD
      add(newLines, line)
    else
      add(newLines, substitute(line, ' *\([.,=+*/-]\) *', '\1', 'g'))
    endif
  endfor
  allLines = newLines
enddef

def TrimTailComments()
  var newLines = []
  var tailCommentPat = isVim9 ? '\s#.*$' : '\s".*$'
  for line in allLines
    var m = matchlist(line, vbarPat)
    var rep = m[1]
    if rep !~# GLOBALCMD || rep =~# '^set \|setl '
      rep = substitute(rep, tailCommentPat, ' ', '')
    endif
    rep = substitute(rep, '\(\\\s\)\?\s*$', '\1', '')
    if !empty(rep)
      add(newLines, rep .. m[2])
    endif
  endfor
  allLines = newLines
enddef

def MinifyCommands()
  # TODO: add commands
  var COMMAND_DICT = {
    scriptencoding: 'scripte',
    endfunction: 'endf',
    nohlsearch: 'noh',
    function: 'fu',
    setlocal: 'setl',
    tabclose: 'tabc',
    augroup: 'aug',
    autocmd: 'au',
    command: 'com',
    echomsg: 'echom',
    execute: 'exe',
    tabnext: 'tabn',
    echohl: 'echoh',
    source: 'so',
    echo: 'ec',
  }
  if !isVim9
    extend(COMMAND_DICT, {
      endwhile: 'endw',
      endfor: 'endfo',
      return: 'retu',
      const: 'cons',
      while: 'wh',
    })
  endif
  extend(COMMAND_DICT, KEYMAPCMD_DICT)
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
      background: 'bg',
      backupskip: 'bsk',
      foldmethod: 'fdm',
      laststatus: 'ls',
      matchpairs: 'mps',
      shiftwidth: 'sw',
      splitright: 'spr',
      updatetime: 'ut',
      ambiwidth: 'ambw',
      autochdir: 'acd',
      expandtab: 'et',
      fillchars: 'fcs',
      listchars: 'lcs',
      incsearch: 'is',
      encoding: 'enc',
      filetype: 'ft',
      foldtext: 'fdt',
      hlsearch: 'hls',
      undofile: 'udf',
      wildmenu: 'wmnu',
      belloff: 'bo',
      display: 'dy',
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
      '^\(sil!\? \)\?\(' .. COMMAND_PAT .. '\)\(!\|\s\|$\)',
      (m) => m[1] .. COMMAND_DICT[m[2]] .. m[3],
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
      '^\(sil! \)\?echoh \S\+',
      ESC_STR_SUB,
      'g'
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
      if !empty(m)
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
  if empty(oldToNew)
    return lines
  endif
  const scopePat = '\(' .. join(extend(['^', '[^a-zA-Z_:$]'], scope), '\|') .. '\)'
  const namePat = '\(' .. join(keys(oldToNew), '\|') .. '\)'
  const dictKeys = '\<' .. namePat .. ':'
  const pat = scopePat .. '\@<=' .. namePat .. '\([^a-zA-Z0-9_(:]\|$\)'
  var newLines = []
  for line in lines
    var rep = line
    if line !~# GLOBALCMD
      if isVim9
        rep = substitute(rep, dictKeys, ESC_STR_SUB, 'g')
      endif
      rep = substitute(rep, pat, (m) => oldToNew[m[2]] .. m[3], 'g')
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
  ScanNames(srcVals, lines, ['^\%(var\|const\?\|final\|let\)\( [^=]\+\)', '^for\( [^=]\+\) in '], '\%(a:\|[ ,[]\|[ ,[]l:\)\([a-zA-Z_][a-zA-Z0-9_]\+\)')
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

  if !empty(scriptLocalDefs)
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
      if line =~# '^\(def\|fu\)!\? '
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
    ScanNames(svalNames, allLines, ['^\%(let\|const\?\) \([^=]\+\)', '^for \([^=]\+\) in '], '\(s:[a-zA-Z_][a-zA-Z0-9_]\+\)')
    var svals = CreateNewNamesMap(allLines, svalNames, { format: 's:%s' })
    allLines = ReplaceNames(allLines, svals, ['s:'])
  endif
enddef

def MinifySIDDefs()
  if empty(scriptLocalDefs)
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
  isVim9 = allLines[0] =~# '^vim9script'
  lineCommentPat = isVim9 ? '^\s*#' : '^\s*"'
  SetupOption(opt)
  SetupEscMark()
  TrimAndJoinLines()
  EscapeAllStrings()
  SplitAllLinesWithVBar()
  MinifySpaces()
  MinifyCommands()
  TrimTailComments()
  MinifyAllDefsLocal()
  MinifyScriptLocal()
  MinifyVim8Spaces()
  UnescapeVBar()
  UnescapeAllStrings()
  MinifySIDDefs()
  writefile(allLines, eDest)
  redraw
  echoh Delimiter
  echo 'minify to' eDest
  echoh Normal
  redraw
enddef

