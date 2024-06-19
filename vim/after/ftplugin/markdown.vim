" Links on new line
autocmd BufWritePre *.md :silent! %s/\s\+\[/\r\[/g
" All lines should end with period. Remove whitespace after dot
autocmd BufWritePre *.md :silent! %s/\.\s\+/.\r/g
