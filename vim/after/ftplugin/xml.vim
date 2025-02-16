setl colorcolumn=100
setl tw=100

setl nosmartindent

" augroup XmlAutoFormat
"   autocmd!
"   autocmd BufWritePre,BufReadPost *.xml call FixXmlFormatting()
" augroup END
"
" function! FixXmlFormatting()
"   silent! %s/>\zs.+/\r/g
"   silent! %s/\([^\s]\+\)\s*</\1\r</g
" endfunction
