highlight LocalScopeWarning term=inverse gui=inverse cterm=inverse

function! s:HighlightSuspiciousSet()
  call matchadd('LocalScopeWarning', '^\s*\(:\s*\)\?set\>')
endfunction

augroup scope_hinting
  autocmd!
  autocmd FileType vim call s:HighlightSuspiciousSet()
augroup END

if &filetype ==# 'vim'
  call s:HighlightSuspiciousSet()
endif

set background=dark
