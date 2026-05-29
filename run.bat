@echo off
setlocal

cd /d "%~dp0"
set "ROOT=%CD%"
set "APP_DIR=%ROOT%\apps\codex-plus-manager"

if not exist "%APP_DIR%\package.json" (
  echo Cannot find manager app at:
  echo %APP_DIR%
  exit /b 1
)

call :check_command node "Node.js"
if errorlevel 1 exit /b 1

call :check_command npm "npm"
if errorlevel 1 exit /b 1

call :check_command cargo "Rust Cargo"
if errorlevel 1 exit /b 1

:menu
echo.
echo Codex++ project runner
echo ======================
echo 1. Dev - run Tauri manager
echo 2. Build - build release package
echo 3. Check - TypeScript check and Rust tests
echo 4. Exit
echo.
choice /C 1234 /N /M "Choose an option [1-4]: "

if errorlevel 4 exit /b 0
if errorlevel 3 goto check
if errorlevel 2 goto build
if errorlevel 1 goto dev

:dev
call :ensure_node_modules
if errorlevel 1 exit /b 1
cd /d "%APP_DIR%"
call npm run dev
exit /b %ERRORLEVEL%

:build
call :ensure_node_modules
if errorlevel 1 exit /b 1
cd /d "%APP_DIR%"
call npm run build
exit /b %ERRORLEVEL%

:check
call :ensure_node_modules
if errorlevel 1 exit /b 1
cd /d "%APP_DIR%"
call npm run check
if errorlevel 1 exit /b %ERRORLEVEL%
cd /d "%ROOT%"
where sh >nul 2>nul
if errorlevel 1 (
  echo.
  echo Warning: sh was not found in PATH.
  echo Some Rust tests require a POSIX shell. Install Git Bash or WSL if cargo test fails.
  echo.
)
call cargo test
exit /b %ERRORLEVEL%

:ensure_node_modules
if exist "%APP_DIR%\node_modules" exit /b 0
echo.
echo node_modules not found. Installing dependencies...
cd /d "%APP_DIR%"
call npm install
exit /b %ERRORLEVEL%

:check_command
where %~1 >nul 2>nul
if errorlevel 1 (
  echo Missing required command: %~2
  echo Please install %~2 and try again.
  exit /b 1
)
exit /b 0
