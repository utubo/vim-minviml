*⚠This has many issues and bugs !!!!*

# vim-minviml
Minify VIML.

- Before
  ```vim
  " Example
  function s:Hello(name)
    echo 'hello ' . a:name
  endfunction

  call s:Hello('minviml')
  ```
- After
  ```vim
  fu s:A(b)
  ec 'hello '.a:b
  endf
  call s:A('minviml')
  ```

# Install
```vim
dein#install('utubo/vim-minviml')
```

# Require
vim9script

# Usage
```vim
call minviml#Minify(src, dest, options)
```
- src ... The default is `%`
- dest ... The default is
  - `*vimrc.src.vim` -> `*vimrc`
  - `*vimrc` -> `*vimrc.min.vim`
  - `*.src.vim` -> `*.vim`
  - `*.vim` -> `*.min.vim`
  When write to `*.src.vim`, minify automatically.
- options ... The default is `{}`

## options
`reserved` and `fixed`

- Before
  ```vim
  let s:val1 = 1
  let s:val2 = 2
  let s:val3 = 3
  ```
- Minify with options
  ```vim
  call minviml#Minify('%','', { 'reserved': ['s:b'], 'fixed': ['.*3'] })
  ```
- After
  ```vim
  let s:a=1
  let s:c=2 " 's:b' is reserved, so names are 's:a', 's:c', 's:d' ...
  let s:val3=3 " '.*3' is fixed.
  ```

# Example
- https://github.com/utubo/vim-tabtoslash/tree/main/autoload<br>
  [tabtoslash.src.vim ](https://github.com/utubo/vim-tabtoslash/blob/main/autoload/tabtoslash.src.vim)
  ->
  [tabtoslash.vim ](https://github.com/utubo/vim-tabtoslash/blob/main/autoload/tabtoslash.vim)

