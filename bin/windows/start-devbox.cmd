@echo off
setlocal
set CONTAINER_NAME=devbox

docker compose up -d --no-recreate >nul 2>&1

if "%~1"=="" (
  docker exec -it %CONTAINER_NAME% /bin/bash
) else (
  docker exec -it %CONTAINER_NAME% %*
)
exit /b %ERRORLEVEL%
