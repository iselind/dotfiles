" C# specific configuration

set cindent
set formatprg=astyle\ -A10
set ai
set si

augroup filetype_cs_settings
    autocmd!
    autocmd BufWritePre *.cs :silent call CocAction("format")
augroup END
