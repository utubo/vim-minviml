*⚠This has many issues and bugs !!!!*

# vim-minviml
Minify VIML.

- Before
  ```vim
  " Example
  function s:Hello(name)
    echo 'hello ' . a:name
  endfunction

  call s:Hello('viminim')
  ```
- After
  ```vim
  fu s:A(b)
  ec 'hello '.a:b
  endf
  call s:A('viminim')
  ```

# Install
```vim
dein#install('utubo/vim-minviml')
```

# Require
vim9script

# Usage
```vim
call minviml#Minify(src, dest)
```
- src ... The default is `%`
- dest ... The default is
  - `*vimrc.src.vim` -> `*vimrc`
  - `*vimrc` -> `*vimrc.min.vim`
  - `*.src.vim` -> `*.vim`
  - `*.vim` -> `*.min.vim`

When write to `*.src.vim`, minify automatically.

# Example
- https://github.com/utubo/vim-tabtoslash/tree/main/autoload<br>
  [tabtoslash.src.vim ](https://github.com/utubo/vim-tabtoslash/blob/main/autoload/tabtoslash.src.vim)
  ->
  [tabtoslash.vim ](https://github.com/utubo/vim-tabtoslash/blob/main/autoload/tabtoslash.vim)
