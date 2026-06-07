" ============================================================
" ai.vim
" Lightweight AI helpers for plain Vim
" Supports Aider and Claude CLI
" Plain Vim only, CoC-friendly, deterministic
" ------------------------------------------------------------
" Design principles
"   - Backend detection: Aider → Claude → unavailable
"   - Always non-interactive
"   - Save file before disk-based operations
"   - If buffer has no file -> fall back to stdin text mode
"   - Auto-reload file after AI makes changes
" ============================================================

if exists('g:loaded_ai_helpers')
  finish
endif
let g:loaded_ai_helpers = 1


" ============================================================
" Capability detection
" ============================================================

function! s:AiderAvailable() abort
  return executable('aider')
endfunction

function! s:ClaudeAvailable() abort
  return executable('claude')
endfunction

function! s:GetAvailableBackend() abort
  if s:AiderAvailable()
    return 'aider'
  elseif s:ClaudeAvailable()
    return 'claude'
  else
    return ''
  endif
endfunction

function! s:EchoMissing() abort
  echo "No AI backend available (install aider or claude)"
endfunction


" ============================================================
" Utilities
" ============================================================

function! s:HasFile() abort
  return &buftype ==# '' && !empty(expand('%:p'))
endfunction

function! s:CurrentFile() abort
  return expand('%:p')
endfunction

" Ensure latest contents are on disk when we rely on --file
function! s:EnsureSaved() abort
  if s:HasFile() && &modified
    silent write
  endif
endfunction

" Reload the current file after AI makes changes
function! s:ReloadFile() abort
  if s:HasFile()
    silent execute 'edit ' . fnameescape(s:CurrentFile())
  endif
endfunction


" ---------------- Diagnostics

function! s:GetDiagnostics(start, end) abort
    let diags = CocAction('diagnosticList')

    let target_file = expand('%:p')
    let filtered = filter(copy(diags), {_, d ->
      \ d.file ==# target_file &&
      \ d.end_lnum >= a:start &&
      \ d.lnum <= a:end
      \ })

  return filtered
endfunction

" ---------------- Scratch buffers

function! s:Scratch(title, content) abort
  botright new
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  execute 'file ' . a:title
  call setline(1, split(a:content, "\n"))
  normal! gg
endfunction


" ============================================================
" Context Collection
" ============================================================
function! s:CollectContext(prompt, start, end) abort
  call s:EnsureSaved()
  let file = s:CurrentFile()
  let diagnostics = s:GetDiagnostics(a:start, a:end)

  let context = {
    \ 'file': file,
    \ 'startline': a:start,
    \ 'endline': a:end,
    \ 'diagnostics': diagnostics,
    \ 'prompt': a:prompt,
    \ }

  return context
endfunction

" ============================================================
" Backend Command Builders
" ============================================================

function! s:BuildPrompt(context) abort
  let prompt = a:context.prompt

  let prompt .= ' in ' . a:context.file . ' from line ' . a:context.startline . ' to ' . a:context.endline

  if !empty(a:context.diagnostics)
    let prompt .= '. Diagnostics: ' . a:context.diagnostics
  endif

  return prompt
endfunction

function! s:BuildAiderCmd(prompt, extra_files) abort
  let model=getenv('OLLAMA_MODEL')
  let cmd = ['aider', '--model', model]

  if s:HasFile()
    let cmd += ['--file', s:CurrentFile()]
  endif

  if !empty(a:extra_files)
    for f in a:extra_files
      let cmd += ['--file', f]
    endfor
  endif

  let cmd += ['--message', a:prompt]

  return cmd
endfunction

function! s:BuildClaudeCmd(prompt, extra_files) abort
  let cmd = ['claude', '-p', a:prompt]

  if s:HasFile()
    let cmd += ['--file', s:CurrentFile()]
  endif

  if !empty(a:extra_files)
    for f in a:extra_files
      let cmd += ['--file', f]
    endfor
  endif

  return cmd
endfunction

function! s:ExecuteCmd(context, showoutput=v:true, extra_files=[]) abort
  let backend = s:GetAvailableBackend()
  if empty(backend)
    call s:EchoMissing()
    return
  endif

  let prompt = s:BuildPrompt(a:context)
  if backend ==# 'aider'
    let cmd = s:BuildAiderCmd(prompt, a:extra_files)
  elseif backend ==# 'claude'
    let cmd = s:BuildClaudeCmd(prompt, a:extra_files)
  endif
  let cmd = map(cmd, 'shellescape(v:val)')
  let cmd = join(cmd, ' ')

  echomsg 'Running command: ' . cmd
  let out = system(cmd)
  if a:showoutput
     call s:Scratch('[AI Output]', out)
  endif

  call s:ReloadFile()
endfunction


" ============================================================
" Core operations
" ============================================================

function! AIFix(...) range abort
  let context = s:CollectContext('Fix', a:firstline, a:lastline)
  call s:ExecuteCmd(context)
endfunction

function! AIAsk(...) range abort
  let instruction = input('What do you want to know? ')
  if empty(instruction)
    return
  endif

  let context = s:CollectContext(instruction, a:firstline, a:lastline)
  call s:ExecuteCmd(context)
endfunction

function! AIReview(...) range abort
  let context = s:CollectContext('Review', a:firstline, a:lastline)
  call s:ExecuteCmd(context)
endfunction

" Explain = review but supports char-precise operator motions
function! AIExplain(...) range abort
  let context = s:CollectContext('Explain', a:firstline, a:lastline)
  call s:ExecuteCmd(context)
endfunction


" ============================================================
" Commands
" ============================================================

command! -range=% AIFix     <line1>,<line2>call AIFix()
command! -range=% AIAsk     <line1>,<line2>call AIAsk()
command! -range=% AIExplain <line1>,<line2>call AIExplain()
command! -range=% AIReview  <line1>,<line2>call AIReview()


" ============================================================
" Keymaps
" ============================================================

" ---------- Commands (whole buffer)

nnoremap <leader>cf :AIFix<CR>
nnoremap <leader>ca :AIAsk<CR>
nnoremap <leader>ce :AIExplain<CR>
nnoremap <leader>cr :AIReview<CR>

" ---------- Visual (explicit selection)

vnoremap <leader>cf :AIFix<CR>
vnoremap <leader>ca :AIAsk<CR>
vnoremap <leader>ce :AIExplain<CR>
vnoremap <leader>cr :AIReview<CR>

" ============================================================
" Operator support
" ============================================================

function! s:AIFixOp(type) abort
  '[,']call AIFix()
endfunction

function! s:AIAskOp(type) abort
  '[,']call AIAsk()
endfunction

function! s:AIExplainOp(type) abort
  '[,']call AIExplain()
endfunction

function! s:AIReviewOp(type) abort
  '[,']call AIReview()
endfunction

nnoremap <silent> <leader>cf :set opfunc=<SID>AIFixOp<CR>g@
nnoremap <silent> <leader>ca :set opfunc=<SID>AIAskOp<CR>g@
nnoremap <silent> <leader>ce :set opfunc=<SID>AIExplainOp<CR>g@
nnoremap <silent> <leader>cr :set opfunc=<SID>AIReviewOp<CR>g@

" ============================================================
" Reload helpers
" ============================================================

command! -nargs=0 ReloadAI source ~/code/dotfiles/vim/plugin/ai/ai.vim
