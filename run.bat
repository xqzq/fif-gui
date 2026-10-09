@echo off
cd /d "%~dp0"
set PYTHONUTF8=1
if not exist ".venv\Scripts\python.exe" (
  echo Run setup.ps1 first. See README.md.
  pause
  exit /b 1
)
".venv\Scripts\python.exe" src\main.py
set "RESULT=%ERRORLEVEL%"
if not "%RESULT%"=="0" pause
exit /b %RESULT%
