let $PATH .= ':~/go/bin'

setlocal noexpandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4
setlocal foldmethod=syntax

" Add tags to fields
autocmd FileType go nmap gtj :CocCommand go.tags.add json<cr>
autocmd FileType go nmap gty :CocCommand go.tags.add yaml<cr>
autocmd FileType go nmap gtx :CocCommand go.tags.clear<cr>

autocmd BufWritePre *.go :silent call CocAction("format")
