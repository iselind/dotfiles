" ============================================================
" ai.vim
" Lightweight AI helpers for plain Vim
" Supports Claude CLI and Aider
" Plain Vim only, CoC-friendly, deterministic
" ------------------------------------------------------------
" Design principles
"   - Backend detection: Aider → Claude → unavailable
"   - Always non-interactive
"   - Save file before disk-based operations
"   - If buffer has no file -> fall back to stdin text mode
"   - Long questions use a git-commit–style editor buffer
"   - Auto-reload file after AI makes changes
"   - Verification mode: run tests, check for errors, feed failures back to LLM
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

" Run tests or check for errors after AI makes changes
" Returns: {'tests': [], 'errors': []}
function! s:RunVerification() abort
  let tests = []
  let errors = []

  " Check for common test commands
  if filereadable('Makefile')
    let tests += ['make test']
  elseif filereadable('pytest.ini') || filereadable('pyproject.toml')
    let tests += ['pytest']
  elseif filereadable('package.json')
    let tests += ['npm test']
  elseif filereadable('go.mod')
    let tests += ['go test ./...']
  elseif filereadable('Cargo.toml')
    let tests += ['cargo test']
  endif

  " Check for compilation errors
  if filereadable('Makefile')
    let errors += ['make']
  elseif filereadable('package.json')
    let errors += ['npm run build']
  elseif filereadable('go.mod')
    let errors += ['go build ./...']
  elseif filereadable('Cargo.toml')
    let errors += ['cargo build']
  endif

  " Run tests if any are found
  if !empty(tests)
    for test in tests
      echomsg 'Running: ' . test
      let out = system(test)
      if v:shell_error != 0
        echomsg 'Test failed:' . out
        let errors += ['test:' . out]
      else
        echomsg 'Tests passed'
      endif
    endfor
  endif

  " Run build check if any are found
  if !empty(errors)
    for error in errors
      echomsg 'Checking: ' . error
      let out = system(error)
      if v:shell_error != 0
        echomsg 'Build failed:' . out
        let errors += ['build:' . out]
      else
        echomsg 'Build succeeded'
      endif
    endfor
  endif

  return {'tests': tests, 'errors': errors}
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
  " Use `botright vnew` for vertical splits
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

function! s:BuildAiderCmd(prompt, extra_files) abort
  let model=getenv('OLLAMA_MODEL')
  let cmd = ['aider', '--model', model]

  " Always include current file via --file
  if s:HasFile()
    let cmd += ['--file', s:CurrentFile()]
  endif

  " Add any extra files passed as arguments
  if !empty(a:extra_files)
    for f in a:extra_files
      let cmd += ['--file', f]
    endfor
  endif

  " Add the message to send to the LLM
  let cmd += ['--message', a:prompt]

  return cmd
endfunction

function! s:BuildClaudeCmd(prompt, extra_files) abort
  let cmd = ['claude', '-p', a:prompt]

  " Add --file for each file if aider-style file passing is supported
  " Note: Claude CLI may not support --file, but we try
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

  " Auto-reload the file after AI makes changes
  call s:ReloadFile()
endfunction


" ============================================================
" Core operations
" ============================================================

" ============================================================
" FIX (file-aware, diagnostics-aware)
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

" Verify mode: run tests and check for errors after AI makes changes
" If verification fails, feed failures back to LLM for fixing
function! AIVerify(...) range abort
  let context = s:CollectContext('Verify', a:firstline, a:lastline)
  call s:ExecuteCmd(context, 0) " Don't show AI output
  let verification = s:RunVerification()
  
  " If verification failed, feed failures back to LLM
  if !empty(verification.errors)
    let error_prompt = 'Verification failed. Please fix these errors:'
    for err in verification.errors
      let error_prompt .= "\n" . err
    endfor
    let context.prompt = error_prompt
    call s:ExecuteCmd(context, 1) " Show output this time
  endif
endfunction

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
command! -range=% AIVerify  <line1>,<line2>call AIVerify()

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
nnoremap <leader>cv :AIVerify<CR>

" ---------- Visual (explicit selection)

vnoremap <leader>cf :AIFix<CR>
vnoremap <leader>ca :AIAsk<CR>
vnoremap <leader>ce :AIExplain<CR>
vnoremap <leader>cr :AIReview<CR>
vnoremap <leader>cv :AIVerify<CR>

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

function! s:AIVerifyOp(type) abort
  '[,']call AIVerify()
endfunction

nnoremap <silent> <leader>cf :set opfunc=<SID>AIFixOp<CR>g@
nnoremap <silent> <leader>ca :set opfunc=<SID>AIAskOp<CR>g@
nnoremap <silent> <leader>ce :set opfunc=<SID>AIExplainOp<CR>g@
nnoremap <silent> <leader>cr :set opfunc=<SID>AIReviewOp<CR>g@
nnoremap <silent> <leader>cv :set opfunc=<SID>AIVerifyOp<CR>g@

" ============================================================
" Reload helpers
" ============================================================

" Helper to reload AI helpers after editing the plugin file
command! -nargs=0 ReloadAI source ~/code/dotfiles/vim/plugin/ai/ai.vim
