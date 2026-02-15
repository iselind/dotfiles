" ============================================================
" ai.vim
" Lightweight AI helpers for plain Vim
" Supports Claude CLI and Copilot CLI with fallback
" Plain Vim only, CoC-friendly, deterministic
" ------------------------------------------------------------
" Design principles
"   - Backend detection: Claude → Copilot → unavailable
"   - Always non-interactive
"   - Save file before disk-based operations
"   - If buffer has no file -> fall back to stdin text mode
"   - Long questions use a git-commit–style editor buffer
" ============================================================

if exists('g:loaded_ai_helpers')
  finish
endif
let g:loaded_ai_helpers = 1


" ============================================================
" Capability detection
" ============================================================

function! s:ClaudeAvailable() abort
  return executable('claude')
endfunction

function! s:CopilotAvailable() abort
  return executable('copilot')
endfunction

function! s:GetAvailableBackend() abort
  if s:ClaudeAvailable()
    return 'claude'
  elseif s:CopilotAvailable()
    return 'copilot'
  else
    return ''
  endif
endfunction

function! s:EchoMissing() abort
  echo "No AI CLI available (install claude or copilot)"
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

function! s:GetRangeText(start, end) abort
    echomsg printf('Getting text from lines %d to %d', a:start, a:end)
  return join(getline(a:start, a:end), "\n")
endfunction

" Character-precise extraction using '[ and '] marks
function! s:GetCharRangeText() abort
  let sp = getpos("'[")
  let ep = getpos("']")

  let sline = sp[1]
  let scol  = sp[2]
  let eline = ep[1]
  let ecol  = ep[2]

  if sline == eline
    let line = getline(sline)
    return strpart(line, scol - 1, ecol - scol + 1)
  endif

  let lines = getline(sline, eline)
  let lines[0] = strpart(lines[0], scol - 1)
  let lines[-1] = strpart(lines[-1], 0, ecol)

  return join(lines, "
")
endfunction

function! s:GetWholeBuffer() abort
  return join(getline(1, '$'), "\n")
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
    \ 'prompt': prompt,
    \ }

  "" Print context for debugging
  "echo 'Collected context:'
  "for [key, value] in items(context)
  "  echo printf('  %s: %s', key, json_encode(value))
  "endfor

  return context
endfunction

" To test CollectContext in isolation:
function! TestCollectContext(...) range abort
  " Get range from selection
  " If no selection, then start and end will be equal.
  let start = a:firstline
  let end = a:lastline

  let context = s:CollectContext('Make this code more efficient', start, end)
  let context = s:CollectContext('explain', start, end)

endfunction

" ============================================================
" Backend Command Builders
" ============================================================

function! s:BuildClaudeCmd(context) abort
  let parts = ['claude', '-p', a:context.operation]

  if a:context.operation ==# 'ask'
    let question = a:context.question
    if !empty(a:context.file)
      let question .= ' (in ' . a:context.file . ' lines ' . a:context.start . '-' . a:context.end . ')'
    endif
    call extend(parts, ['--question', shellescape(question)])
  else
    if !empty(a:context.file)
      call extend(parts, ['--file', shellescape(a:context.file)])
      call extend(parts, ['--range', a:context.start . ':' . a:context.end])
    endif

    if !empty(a:context.diagnostics)
      call extend(parts, ['--diagnostics', shellescape(a:context.diagnostics)])
    endif

    if !empty(a:context.instruction)
      call extend(parts, ['--instruction', shellescape(a:context.instruction)])
    endif
  endif

  return join(parts, ' ')
endfunction

function! s:BuildCopilotCmd(context) abort
  if a:context.operation ==# 'ask'
    let prompt = a:context.question
    if !empty(a:context.file)
      let prompt .= ' (in ' . a:context.file . ' lines ' . a:context.start . '-' . a:context.end . ')'
    endif
    return 'copilot -sp ' . shellescape(prompt)
  endif

  let prompt = a:context.operation . ' the code'

  if !empty(a:context.file)
    let prompt .= ' in ' . a:context.file . ' from line ' . a:context.start . ' to ' . a:context.end
  endif

  if !empty(a:context.diagnostics)
    let prompt .= '. Diagnostics: ' . a:context.diagnostics
  endif

  if !empty(a:context.instruction)
    let prompt .= '. Instruction: ' . a:context.instruction
  endif

  return 'copilot -sp ' . shellescape(prompt)
endfunction

function! s:BuildCmd(backend, context) abort
  if a:backend ==# 'claude'
    return s:BuildClaudeCmd(a:context)
  else
    return s:BuildCopilotCmd(a:context)
  endif
endfunction


" ============================================================
" Core operations
" ============================================================

" ============================================================
" FIX  (file-aware, diagnostics-aware)
" ============================================================

function! AIFix(...) range abort
  let backend = s:GetAvailableBackend()
  if empty(backend)
    call s:EchoMissing()
    return
  endif

  let start = a:firstline
  let end = a:lastline

  let context = s:CollectContext('fix', start, end)
  let cmd = s:BuildCmd(backend, context)

  let out = system(cmd, text)
  call setline(start, split(out, "\n"))
endfunction


" ============================================================
" REWRITE (instructional, file-aware)
" ============================================================

function! AIRewrite(...) range abort
  let backend = s:GetAvailableBackend()
  if empty(backend)
    call s:EchoMissing()
    return
  endif

  let instruction = input('Rewrite how? ')
  if empty(instruction)
    return
  endif

  let start = a:firstline
  let end = a:lastline
  let context = s:CollectContext(instruction, start, end)
  let cmd = s:BuildCmd(backend, context)

  let out = system(cmd, text)
  call setline(start, split(out, "\n"))
endfunction


" ============================================================
" REVIEW (scratch prose)
" ============================================================

function! AIReview(...) range abort
  let backend = s:GetAvailableBackend()
  if empty(backend)
    call s:EchoMissing()
    return
  endif

  let start = a:firstline
  let end = a:lastline
  let context = s:CollectContext('review', start, end)
  let cmd = s:BuildCmd(backend, context)

  let out = system(cmd, text)
  call s:Scratch('[AI Review]', out)
endfunction

" Explain = review but supports char-precise operator motions
function! AIExplain(...) range abort
  let backend = s:GetAvailableBackend()
  if empty(backend)
    call s:EchoMissing()
    return
  endif

  let start = a:firstline
  let end = a:lastline
  let context = s:CollectContext('explain', start, end)
  let cmd = s:BuildCmd(backend, context)
  let out = system(cmd, text)
  call s:Scratch('[AI Explain]', out)
endfunction


" ============================================================
" REVIEW -> LOC LIST (navigable)
" ============================================================

function! AIReviewLoclist(...) range abort
  let backend = s:GetAvailableBackend()
  if empty(backend)
    call s:EchoMissing()
    return
  endif

  let start = a:firstline
  let end = a:lastline
  let context = s:CollectContext('review', start, end)
  let cmd = s:BuildCmd(backend, context)

  let out = system(cmd, text)

  let items = []
  for l in split(out, "\n")
    let m = matchlist(l, '^Line \(\d\+\): \(.*\)')
    if len(m) == 3
      call add(items, {'lnum': str2nr(m[1]), 'text': m[2]})
    endif
  endfor

  call setloclist(0, items, 'r')
  lopen
endfunction

" ============================================================
" Commands
" ============================================================

command! -range=% AIFix             <line1>,<line2>call AIFix()
command! -range=% AIRewrite         <line1>,<line2>call AIRewrite()
command! -range=% AIExplain         <line1>,<line2>call AIExplain()
command! -range=% AIReview          <line1>,<line2>call AIReview()
command! -range=% AIReviewLoc       <line1>,<line2>call AIReviewLoclist()

" ============================================================
" Keymaps
" Includes: normal (whole buffer), visual (range), operator (motion)
" ============================================================

" ---------- Commands (whole buffer)

nnoremap <leader>cf :AIFix<CR>
nnoremap <leader>cr :AIRewrite<CR>
nnoremap <leader>cv :AIReview<CR>
nnoremap <leader>cV :AIReviewLoc<CR>

" ---------- Visual (explicit selection)

vnoremap <leader>cf :AIFix<CR>
vnoremap <leader>cr :AIRewrite<CR>
vnoremap <leader>cv :AIReview<CR>
vnoremap <leader>cV :AIReviewLoc<CR>

" ============================================================
" Operator support (motion/text-object)
" Makes AI behave like native operators (gq/d/c/etc)
" Example:
"   <leader>cfap   fix paragraph
"   <leader>criw   rewrite inner word
"   <leader>cvip   review paragraph
"   <leader>caG    ask about rest of file

function! s:AIFixOp(type) abort
  '[,']call AIFix()
endfunction

function! s:AIRewriteOp(type) abort
  '[,']call AIRewrite()
endfunction

function! s:AIReviewOp(type) abort
  '[,']call AIReview()
endfunction

function! s:AIReviewLocOp(type) abort
  '[,']call AIReviewLoclist()
endfunction

nnoremap <silent> <leader>cf :set opfunc=<SID>AIFixOp<CR>g@
nnoremap <silent> <leader>cr :set opfunc=<SID>AIRewriteOp<CR>g@
nnoremap <silent> <leader>cv :set opfunc=<SID>AIReviewOp<CR>g@
nnoremap <silent> <leader>cV :set opfunc=<SID>AIReviewLocOp<CR>g@

" ============================================================
" End
" ============================================================

" ============================================================
