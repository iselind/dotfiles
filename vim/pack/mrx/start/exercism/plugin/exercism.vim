" exercism.vim - Functions and mappings for Exercism
" This plugin is based on functions provided by exercism.io
" Maintainer: Patrik Iselind
" Version 0.1

if exists('g:loaded_exercism')
    finish
endif
let g:loaded_exercism = 1

" Exercism stuff
function! s:exercism_tests()
  if expand('%:e') ==# 'vim'
    let testfile = printf('%s/%s.vader', expand('%:p:h'),
          \ tr(expand('%:p:h:t'), '-', '_'))
    if !filereadable(testfile)
      echoerr 'File does not exist: '. testfile
      return
    endif
    source %
    execute 'Vader' testfile
  else
    let sourcefile = printf('%s/%s.vim', expand('%:p:h'),
          \ tr(expand('%:p:h:t'), '-', '_'))
    if !filereadable(sourcefile)
      echoerr 'File does not exist: '. sourcefile
      return
    endif
    execute 'source' sourcefile
    Vader
  endif
endfunction

augroup exercism
    autocmd!
    autocmd BufRead *.{vader,vim} command! -buffer Test call s:exercism_tests()
augroup END
