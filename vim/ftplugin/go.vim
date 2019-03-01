setlocal noexpandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4

let g:go_fmt_command = 'goimports'
let g:go_list_type = 'quickfix'
let g:go_auto_sameids = 1
let g:go_auto_type_info = 1

nmap <leader>ga <Plug>(go-alternate-edit)
nmap <leader>gah <Plug>(go-alternate-split)
nmap <leader>gav <Plug>(go-alternate-vertical)
nmap <F10> :GoTest -short<cr>
