" Links on new line
autocmd BufWritePre *.md :silent! %s/\s\+\[/\r\[/g
" All lines should end with period. Remove whitespace after it
autocmd BufWritePre *.md :silent! %s/\.\s\+/.\r/g
" All lines should end with question mark. Remove whitespace after it
autocmd BufWritePre *.md :silent! %s/?\s\+/?\r/g
" All lines should end with question mark. Remove whitespace after it
autocmd BufWritePre *.md :silent! %s/!\s\+/!\r/g
" Remove extra line breaks
autocmd BufWritePre *.md :silent! %s/\n\n\n\+/\r\r/g
" Ensure empty row before section head, regardless of level
autocmd BufWritePre *.md :silent! %s/\([^\n]\)\n#/\1\r\r#/g

" The following breaks lists that start with more than one bullet on the first
" level
"
" " Ensure empty row before unnumbered list
" autocmd BufWritePre *.md :silent! %s/\([^\n]\)\n-/\1\r\r-/g
    " " Ensure empty row before numbered list
" autocmd BufWritePre *.md :silent! %s/\([^\n]\)\n1/\1\r\r1/g
