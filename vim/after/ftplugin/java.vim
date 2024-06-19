" autocmd BufWritePre *.java :silent call CocAction("format")

augroup ProjectDrawer
  autocmd!
  autocmd VimEnter * :Vexplore
augroup END

setl cursorcolumn
