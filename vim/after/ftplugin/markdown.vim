" Markdown filetype-specific settings
augroup filetype_md_settings
  autocmd!

  " Insert newline before headers (#) if not already preceded by a blank line
  autocmd BufWritePre *.md :silent! %s/\([^\n]\)\n#/\1\r\r#/g

  " Remove excessive blank lines (more than 2)
  autocmd BufWritePre *.md :silent! %s/\n\n\n\+/\r\r/g

  " Optional: Keep sentences on separate lines (can be manually triggered instead)
  " Uncomment these if you want automatic sentence splitting on save
  " autocmd BufWritePre *.md :silent! %s/\.\s\+/.\r/g
  " autocmd BufWritePre *.md :silent! %s/?\s\+/?\r/g
  " autocmd BufWritePre *.md :silent! %s/!\s\+/!\r/g

augroup END

" Indentation settings for nested bullet editing
setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal expandtab

" Visual helper: show 80-character column
setlocal colorcolumn=80

" Folding: allow collapsing of deeply nested sections
setlocal foldmethod=indent
setlocal foldlevel=2

" Spellcheck
setlocal spell
setlocal spelllang=en_us

" Optional: visually wrap long lines like paragraphs
setlocal wrap
setlocal linebreak
setlocal nolist

" Optional: visualize indentation (tabs/trailing)
setlocal listchars=tab:→\ ,trail:·
setlocal list

