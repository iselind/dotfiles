setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal textwidth=79
setlocal smarttab
setlocal expandtab
setlocal nosmartindent
setlocal foldmethod=indent

" Mark how long is 79 columns
setlocal colorcolumn=79

augroup filetype_py_settings
  autocmd!
  autocmd BufWritePre *.py :silent call CocAction("format")
augroup END
