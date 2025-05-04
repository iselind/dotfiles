setl tabstop=4 shiftwidth=4 expandtab
setl foldmethod=syntax

" Enable line numbers and relative numbers
setl number
setl relativenumber

setl colorcolumn=100
setl tw=100

setl nosmartindent

" Buffer-local key mappings for making gf open link target in a new split
nnoremap <buffer> <leader>oh :split<CR>gf
nnoremap <buffer> <leader>ov :vsplit<CR>gf
