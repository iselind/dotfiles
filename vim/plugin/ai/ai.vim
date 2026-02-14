" ============================================================
" ai.vim
" Lightweight AI helpers for plain Vim
" Claude CLI for intentional operations (fix/review/explain/ask)
" Plain Vim only, CoC-friendly, deterministic
" ------------------------------------------------------------
" Design principles
"   - Always non-interactive: claude -p
"   - Stateless by default (sessions only for Ask)
"   - Save file before disk-based operations
"   - If buffer has no file -> fall back to stdin text mode
"   - Long questions use a git-commit–style editor buffer
" ============================================================

if exists('g:loaded_ai_helpers')
  finish
endif
let g:loaded_ai_helpers = 1


" ============================================================
" Config
" ============================================================

" Ask session behavior: 'file' | 'global' | 'none'
if !exists('g:ai_claude_session_mode')
  let g:ai_claude_session_mode = 'file'
endif

" ============================================================
" Capability detection
" ============================================================

function! s:ClaudeAvailable() abort
  return executable('claude')
endfunction

function! s:EchoMissing() abort
  echo "Claude CLI not available on this machine"
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
  return join(getline(a:start, a:end), "
")
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
  let qf = getqflist()
  let msgs = []

  for item in qf
    if get(item, 'bufnr', -1) == bufnr('%')
      if item.lnum >= a:start && item.lnum <= a:end
        call add(msgs, printf('Line %d: %s', item.lnum, item.text))
      endif
    endif
  endfor

  return join(msgs, "\n")
endfunction


" ---------------- Scratch buffers

function! s:Scratch(title, content) abort
  botright new
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  execute 'file ' . a:title
  call setline(1, split(a:content, "\n"))
  normal! gg
endfunction


" ---------------- Claude helpers

function! s:ClaudeCmd(args) abort
  return 'claude -p ' . a:args
endfunction

function! s:AskSessionArg() abort
  if g:ai_claude_session_mode ==# 'none'
    return ''
  elseif g:ai_claude_session_mode ==# 'global'
    return '--session vim-ask'
  elseif g:ai_claude_session_mode ==# 'file'
    if !s:HasFile()
      return ''
    endif
    let id = sha256(expand('%:p'))[0:12]
    return '--session vim-ask-' . id
  endif
  return ''
endfunction


" ============================================================
" Core operations
" ============================================================

" ============================================================
" FIX  (file-aware, diagnostics-aware)
" ============================================================

function! ClaudeFix(...) range abort
  if !s:ClaudeAvailable()
    call s:EchoMissing()
    return
  endif

  let start = a:firstline
  let end   = a:lastline

  if s:HasFile()
    call s:EnsureSaved()

    let diagnostics = s:GetDiagnostics(start, end)
    let cmd = s:ClaudeCmd(printf(
          \ 'fix --file %s --range %d:%d --diagnostics %s',
          \ shellescape(s:CurrentFile()), start, end, shellescape(diagnostics)))

    execute start . ',' . end . '!' . cmd
  else
    " fallback: stdin only
    let text = s:GetRangeText(start, end)
    let cmd  = s:ClaudeCmd('fix')
    let out  = system(cmd, text)
    call setline(start, split(out, "\n"))
  endif
endfunction


" ============================================================
" REWRITE (instructional, file-aware)
" ============================================================

function! ClaudeRewrite(...) range abort
  if !s:ClaudeAvailable()
    call s:EchoMissing()
    return
  endif

  let instruction = input('Rewrite how? ')
  if empty(instruction)
    return
  endif

  let start = a:firstline
  let end   = a:lastline

  if s:HasFile()
    call s:EnsureSaved()

    let cmd = s:ClaudeCmd(printf(
          \ 'rewrite --file %s --range %d:%d --instruction %s',
          \ shellescape(s:CurrentFile()), start, end, shellescape(instruction)))

    execute start . ',' . end . '!' . cmd
  else
    let text = s:GetRangeText(start, end)
    let cmd  = s:ClaudeCmd('rewrite --instruction ' . shellescape(instruction))
    let out  = system(cmd, text)
    call setline(start, split(out, "\n"))
  endif
endfunction


" ============================================================
" REVIEW (scratch prose)
" ============================================================

function! ClaudeReview(...) range abort
  if !s:ClaudeAvailable()
    call s:EchoMissing()
    return
  endif

  let start = a:firstline
  let end   = a:lastline

  if s:HasFile()
    call s:EnsureSaved()
    let cmd = s:ClaudeCmd('review --file ' . shellescape(s:CurrentFile()))
    let out = system(cmd, s:GetRangeText(start, end))
  else
    let cmd = s:ClaudeCmd('review')
    let out = system(cmd, s:GetRangeText(start, end))
  endif

  call s:Scratch('[Claude Review]', out)
endfunction

" Explain = review but supports char-precise operator motions
function! ClaudeExplain(...) range abort
  if !s:ClaudeAvailable()
    call s:EchoMissing()
    return
  endif

  " If called via operator, use character-precise text
  let text = mode() ==# 'no' ? s:GetCharRangeText() : s:GetRangeText(a:firstline, a:lastline)

  let out = system(s:ClaudeCmd('explain'), text)
  call s:Scratch('[Claude Explain]', out)
endfunction


" ============================================================
" REVIEW -> LOC LIST (navigable)
" ============================================================

function! ClaudeReviewLoclist(...) range abort
  if !s:ClaudeAvailable()
    call s:EchoMissing()
    return
  endif

  let start = a:firstline
  let end   = a:lastline

  if s:HasFile()
    call s:EnsureSaved()
    let cmd = s:ClaudeCmd('review --file ' . shellescape(s:CurrentFile()))
    let out = system(cmd, s:GetRangeText(start, end))
  else
    let cmd = s:ClaudeCmd('review')
    let out = system(cmd, s:GetRangeText(start, end))
  endif

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
" ASK (git-commit style editor, optional sessions)
" ============================================================

function! s:OpenAskBuffer(start, end) abort
  let ctx = ''

  if s:HasFile()
    let ctx = printf('# File: %s\n# Range: %d:%d\n', s:CurrentFile(), a:start, a:end)
  else
    let ctx = printf('# Range: %d:%d (no file)\n', a:start, a:end)
  endif

  botright new
  setlocal buftype=nofile bufhidden=wipe noswapfile filetype=markdown
  execute 'file [Claude Ask]'

  call setline(1, split(ctx . '\n# Write your question below. Save and close to send.\n\n', "\n"))

  nnoremap <buffer> <silent> ZZ :call <SID>SubmitAsk()<CR>
endfunction

function! s:SubmitAsk() abort
  let lines = getline(1, '$')

  " remove comment lines
  let question = []
  for l in lines
    if l !~ '^#'
      call add(question, l)
    endif
  endfor

  let question = join(question, "\n")

  if empty(trim(question))
    bd!
    return
  endif

  let text = s:GetWholeBuffer()
  let session = s:AskSessionArg()
  let cmd = s:ClaudeCmd('ask ' . session . ' --question ' . shellescape(question))

  let out = system(cmd, text)

  bd!
  call s:Scratch('[Claude Ask]', out)
endfunction

function! ClaudeAsk(...) range abort
  if !s:ClaudeAvailable()
    call s:EchoMissing()
    return
  endif

  call s:OpenAskBuffer(a:firstline, a:lastline)
endfunction


" ============================================================
" Commands
" ============================================================

command! -range=% ClaudeFix          <line1>,<line2>call ClaudeFix()
command! -range=% ClaudeRewrite      <line1>,<line2>call ClaudeRewrite()
command! -range=% ClaudeExplain      <line1>,<line2>call ClaudeReview()
command! -range=% ClaudeReview       <line1>,<line2>call ClaudeReview()
command! -range=% ClaudeReviewLoc    <line1>,<line2>call ClaudeReviewLoclist()
command! -range=% ClaudeAsk          <line1>,<line2>call ClaudeAsk()


" ============================================================
" Keymaps
" Includes: normal (whole buffer), visual (range), operator (motion)
" ============================================================

" ---------- Commands (whole buffer)

nnoremap <leader>cf :ClaudeFix<CR>
nnoremap <leader>cr :ClaudeRewrite<CR>
nnoremap <leader>cv :ClaudeReview<CR>
nnoremap <leader>cV :ClaudeReviewLoc<CR>
nnoremap <leader>ca :ClaudeAsk<CR>

" ---------- Visual (explicit selection)

vnoremap <leader>cf :ClaudeFix<CR>
vnoremap <leader>cr :ClaudeRewrite<CR>
vnoremap <leader>cv :ClaudeReview<CR>
vnoremap <leader>cV :ClaudeReviewLoc<CR>
vnoremap <leader>ca :ClaudeAsk<CR>

" ---------- Operator support (motion/text-object)
" Makes Claude behave like native operators (gq/d/c/etc)
" Example:
"   <leader>cfap   fix paragraph
"   <leader>criw   rewrite inner word
"   <leader>cvip   review paragraph
"   <leader>caG    ask about rest of file

function! s:ClaudeFixOp(type) abort
  '[,']call ClaudeFix()
endfunction

function! s:ClaudeRewriteOp(type) abort
  '[,']call ClaudeRewrite()
endfunction

function! s:ClaudeReviewOp(type) abort
  '[,']call ClaudeReview()
endfunction

function! s:ClaudeReviewLocOp(type) abort
  '[,']call ClaudeReviewLoclist()
endfunction

function! s:ClaudeAskOp(type) abort
  " Operator-pending ask uses character-precise selection
  call s:OpenAskBuffer(line("'["), line("']"))
endfunction

nnoremap <silent> <leader>cf :set opfunc=<SID>ClaudeFixOp<CR>g@
nnoremap <silent> <leader>cr :set opfunc=<SID>ClaudeRewriteOp<CR>g@
nnoremap <silent> <leader>cv :set opfunc=<SID>ClaudeReviewOp<CR>g@
nnoremap <silent> <leader>cV :set opfunc=<SID>ClaudeReviewLocOp<CR>g@
nnoremap <silent> <leader>ca :set opfunc=<SID>ClaudeAskOp<CR>g@

" ============================================================
" End
" ============================================================

" ============================================================
