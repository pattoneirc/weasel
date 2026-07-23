@echo off
setlocal
if not exist "%~dp0scripts\launch-test.ps1" (
  echo ERROR: scripts\launch-test.ps1 was not found.
  echo Run this file from the AI_Rime_Dictionary_Project directory.
  echo.
  pause
  exit /b 2
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\launch-test.ps1" -Action Install -PackageRoot "%~dp0."
set "RESULT=%ERRORLEVEL%"
if not "%RESULT%"=="0" (
  echo.
  echo ERROR: Installation did not finish. See install-test.log.
  pause
)
exit /b %RESULT%
