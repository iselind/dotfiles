setlocal noexpandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4

" Unset did_ftplugin to enable vim-go plugin to do its magic
"unlet! b:did_ftplugin
" If the above is un-commented, then the syntax highlighting will disappear
" upon saving the file. https://github.com/fatih/vim-go/issues/2279 didn't
" recommend to unlet did_ftplugin either. Still, I need that being unlet to
" get omnifunc to be set. Vim is hopelessly old on Debian machines.

let g:go_fmt_command = 'goimports'
let g:go_list_type = 'quickfix'
let g:go_code_completion_enabled = 1
let g:go_metalinter_command='golangci-lint'
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

nmap <leader>ga <Plug>(go-alternate-edit)
nmap <leader>gah <Plug>(go-alternate-split)
nmap <leader>gav <Plug>(go-alternate-vertical)
