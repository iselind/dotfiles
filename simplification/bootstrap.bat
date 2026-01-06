@echo off
setlocal

REM ---- Config -------------------------------------------------
set GIT_VERSION=2.44.0
set GIT_INSTALLER=Git-%GIT_VERSION%-64-bit.exe
set GIT_URL=https://github.com/git-for-windows/git/releases/download/v%GIT_VERSION%.windows.1/%GIT_INSTALLER%

set VIM_VERSION=9.0.2167
set VIM_INSTALLER=gvim_%VIM_VERSION%_x64.exe
set VIM_URL=https://github.com/vim/vim-win32-installer/releases/download/v9.0.2167/%VIM_INSTALLER%
REM ------------------------------------------------------------

set DOWNLOADS=%USERPROFILE%\Downloads
set GIT_BASH="C:\Program Files\Git\bin\bash.exe"

if not exist "%DOWNLOADS%" mkdir "%DOWNLOADS%"

REM ---- Install Git for Windows -------------------------------
if not exist %GIT_BASH% (
  echo Installing Git for Windows...
  if not exist "%DOWNLOADS%\%GIT_INSTALLER%" (
    curl -L -o "%DOWNLOADS%\%GIT_INSTALLER%" "%GIT_URL%"
  )
  "%DOWNLOADS%\%GIT_INSTALLER%" /VERYSILENT /NORESTART
)

REM ---- Install Vim for Windows -------------------------------
if not exist "%ProgramFiles%\Vim\vim90\vim.exe" (
  echo Installing Vim...
  if not exist "%DOWNLOADS%\%VIM_INSTALLER%" (
    curl -L -o "%DOWNLOADS%\%VIM_INSTALLER%" "%VIM_URL%"
  )
  "%DOWNLOADS%\%VIM_INSTALLER%" /S
)

REM ---- Launch Git Bash ---------------------------------------
echo Launching Git Bash provisioning shell...
%GIT_BASH% --login -i "%~dp0install.sh"

endlocal
