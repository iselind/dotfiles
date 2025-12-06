@echo off
setlocal
rem Delegate to devbox shim; ensure container is up and running
if "%~1"=="" (
  call start-devbox.cmd git --help
  exit /b %ERRORLEVEL%
) else (
  set IS_CLONE_OR_INIT=0
  for %%I in (%*) do (
    if /I "%%I"=="clone" set IS_CLONE_OR_INIT=1
    if /I "%%I"=="init"  set IS_CLONE_OR_INIT=1
  )
  if "%IS_CLONE_OR_INIT%"=="1" (
    call start-devbox.cmd /bin/bash -lc "mkdir -p \$HOME/code; cd \$HOME/code; git %*"
  ) else (
    call start-devbox.cmd git %*
  )
  exit /b %ERRORLEVEL%
)
