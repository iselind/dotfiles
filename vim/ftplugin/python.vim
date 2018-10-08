setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal textwidth=79
setlocal smarttab
setlocal expandtab
setlocal nosmartindent
setlocal foldmethod=indent

" Mark how long is 79 columns
:set colorcolumn=79

"" Use autopep8 for formatting Python files
"" The hyphen '-' at the end of the command is required to make autopep8 read
"" the lines from the standard in.
"set formatprg=autopep8\ -a\ -a\ -
"
"" When we write a Python file let it pass through autopep8
"" This will fix white space issues automatically
"" Better as pre-commit hook?
":autocmd BufWritePre *.py :execute "normal mzgggqG'zzz"

":ALEDisable
let g:ale_python_flake8_executable = 'python3'
