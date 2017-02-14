set nocompatible

set backspace=indent,eol

syntax enable

set expandtab

set ignorecase
set smartcase
set incsearch

set ai
set si

set sts=4
set ts=4
set sw=4

set foldmethod=syntax

set laststatus=2

set hls

set scrolloff=5

if has("gui_running")
        set background=light
else
        set background=dark
endif

set modeline

" Make Vim automatically refresh any files that haven't been edited by Vim
set autoread

" Highlight space error
:highlight ExtraWhitespace term=inverse gui=inverse cterm=inverse
" Show trailing whitespace and when tabs and space are mixed, also highlight
" when we have more than one white space between non-whitespace characters
:match ExtraWhitespace /^\s\+$\|\s\+$\|S\s\{2,\}\S\|\t\+ \+/

:set cursorline

" How indentation looks like
set listchars=tab:▷⋅

filetype plugin indent on

set statusline=%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%y%r%m%=L%l,C%c\ %P

" Git convenience commands, % is the current file name with folder relative to
" where vim was started
command Gadd !git add %
command Gdiff !git diff %
command Gstatus !git status

" Set tabstop, softtabstop and shiftwidth to the same value
command! -nargs=* Stab call Stab()
function! Stab()
    let l:tabstop = 1 * input('set tabstop = softtabstop = shiftwidth = ')
    if l:tabstop > 0
        let &l:sts = l:tabstop
        let &l:ts = l:tabstop
        let &l:sw = l:tabstop
    endif
    call SummarizeTabs()
endfunction

function! SummarizeTabs()
    try
        echohl ModeMsg
        echon 'tabstop='.&l:ts
        echon ' shiftwidth='.&l:sw
        echon ' softtabstop='.&l:sts
        if &l:et
            echon ' expandtab'
        else
            echon ' noexpandtab'
        endif
    finally
        echohl None
    endtry
endfunction

execute pathogen#infect()
"Syntastic config
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers = ['pylint', 'pycodestyle']
let g:syntastic_javascript_checkers = ['jsl']
let g:syntastic_c_checkers = []
" let g:syntastic_c_remove_include_errors = 1
"let g:syntastic_c_include_dirs = split(system("find_include_folders"), "\n")
"let g:syntastic_c_remove_include_errors = 1
"let g:syntastic_c_no_default_include_dirs = 1
