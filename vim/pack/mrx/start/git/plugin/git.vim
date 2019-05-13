" git.vim - Git related stuff
" This plugin is based on functions provided by exercism.io
" Maintainer: Patrik Iselind
" Version 0.1

if exists('g:loaded_git')
    finish
endif
let g:loaded_git = 1

" Git convenience commands, % is the current file name with folder relative to
" where vim was started
command Gadd !git add %
command Gdiff !git diff %
command Gstatus !git status
command Gcommit !git commit
command Gpush !git push
