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

function! s:BuildPrompt(context) abort
  let prompt = a:context.prompt

  let prompt .= ' in ' . a:context.file . ' from line ' . a:context.startline . ' to ' . a:context.endline

  if !empty(a:context.diagnostics)
    let prompt .= '. Diagnostics: ' . a:context.diagnostics
  endif

  return prompt
endfunction

function! s:BuildClaudeCmd(prompt) abort
   return ['claude', '-p', a:prompt]
endfunction

function! s:BuildCopilotCmd(prompt) abort
  return ['copilot', '-s', '-p', a:prompt]
endfunction

function! s:ExecuteCmd(context, showoutput=v:true) abort
  let backend = s:GetAvailableBackend()
  if empty(backend)
    call s:EchoMissing()
    return
  endif

  let prompt = s:BuildPrompt(a:context)
  if backend ==# 'claude'
    let cmd = s:BuildClaudeCmd(prompt)
  else
    let cmd = s:BuildCopilotCmd(prompt)
  endif
  let cmd = map(cmd, 'shellescape(v:val)')
  let cmd = join(cmd, ' ')

  echomsg 'Running command: ' . cmd
  let out = system(cmd)
  if a:showoutput
     call s:Scratch('[AI Output]', out)
  endif
endfunction


" ============================================================
" Core operations
" ============================================================

" ============================================================
" FIX  (file-aware, diagnostics-aware)
" ============================================================

function! AIFix(...) range abort
  let context = s:CollectContext('Fix', a:firstline, a:lastline)
  call s:ExecuteCmd(context)
endfunction

function! AIAsk(...) range abort
  let instruction = input('Rewrite how? ')
  if empty(instruction)
    return
  endif

  let context = s:CollectContext(instruction, a:firstline, a:lastline)
  call s:ExecuteCmd(context)
endfunction

function! AIReview(...) range abort
  let context = s:collectcontext('Review', a:firstline, a:lastline)
  call s:ExecuteCmd(context)
endfunction

" Explain = review but supports char-precise operator motions
function! AIExplain(...) range abort
  let context = s:CollectContext('Explain', a:firstline, a:lastline)
  call s:ExecuteCmd(context)
endfunction

" Future extensions:
" - Review produce a loclist with line-specific feedback instead of a prose
"   summary

" ============================================================
" Commands
"
" These are used when users want to explicitly select a range and then run a
" command on it.
" ============================================================

command! -range=% AIFix     <line1>,<line2>call AIFix()
command! -range=% AIAsk     <line1>,<line2>call AIAsk()
command! -range=% AIExplain <line1>,<line2>call AIExplain()
command! -range=% AIReview  <line1>,<line2>call AIReview()

" ============================================================
" Keymaps
"
" These are used for quick access and support different selection modes.
"
" Includes: normal (whole buffer), visual (range), operator (motion)
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
" Operator support (motion/text-object)
" Makes AI behave like native operators (gq/d/c/etc)
" Example:
"   <leader>cfap   fix paragraph
"   <leader>criw   rewrite inner word
"   <leader>cvip   review paragraph
"   <leader>caG    ask about rest of file
"
" These are used when users want to quickly apply an AI operation to a
" specific text object or motion

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
