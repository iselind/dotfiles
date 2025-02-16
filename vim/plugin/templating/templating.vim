augroup templating
  autocmd!
  autocmd BufNewFile * call TemplateFromDirectory()
augroup END

function! TemplateFromDirectory()
  " Search for .vim-template in the file's directory and upwards
  let template_file = findfile('.vim-template', expand('%:p:h') . ',;')

  " If .vim-template is found and readable
  if !empty(template_file) && filereadable(template_file)
    " Read the .vim-template content into the new file
    execute '0r ' . template_file

    " Optionally replace <FILENAME> with the file's name (without extension)
    let filename = expand('%:t:r')
    silent! %s/#FILENAME#/\=filename/g

    " Save the file to ensure the content is written
    write

    " Reload the file to trigger filetype detection and ftplugin application
    edit %
  endif
endfunction

