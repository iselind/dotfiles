function! s:FindTemplateFile()
  return findfile('.template', expand('%:p:h') . ',;')
endfunction

function! s:ApplyTemplatePlaceholders()
  let l:filename = expand('%:t:r')
  let l:date = strftime('%Y-%m-%d')
  silent! %s/#FILENAME#/\=l:filename/g
  silent! %s/#DATE#/\=l:date/g
endfunction

function! s:ApplyTemplate(template)
  if !empty(a:template) && filereadable(a:template)
    execute '0r ' . fnameescape(a:template)
    call s:ApplyTemplatePlaceholders()
  endif
endfunction

function! s:OnNewBufferOrFile()
  " Only apply template if buffer is truly empty (exactly one blank line)
  if line('$') == 1 && getline(1) == ''
    let l:template = s:FindTemplateFile()
    call s:ApplyTemplate(l:template)
  endif
endfunction

augroup templating
  autocmd!
  autocmd BufNewFile,BufReadPost * call s:OnNewBufferOrFile()
augroup END

" Manual new file (uses :enew so the autocommand applies)
nnoremap <leader>n :enew<CR>

" Open split according to provided command
function! s:OpenUnderCursor(splitcmd)
  let l:file = expand('<cfile>')
  if empty(l:file)
    echo 'No file under cursor'
    return
  endif
  if isdirectory(l:file)
    echo 'Path under cursor is a directory'
    return
  endif
  echo 'Opening: ' . l:file
  execute a:splitcmd . ' ' . l:file
endfunction

nnoremap <leader>oh :call <SID>OpenUnderCursor('split')<CR>
nnoremap <leader>ov :call <SID>OpenUnderCursor('vsplit')<CR>

