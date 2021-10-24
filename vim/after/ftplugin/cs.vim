" C# specific configuration

set cindent
set formatprg=astyle\ -A10
set ai
set si

autocmd BufWritePre *.cs :silent call CocAction("format")
