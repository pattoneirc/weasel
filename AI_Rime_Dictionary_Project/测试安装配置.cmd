@echo off
setlocal
if not exist "%~dp0scripts\launch-test.ps1" (
  echo ERROR: The ZIP package was not fully extracted.
  echo Please extract the entire ZIP to a folder on drive D: and try again.
  echo.
  pause
  exit /b 2
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\launch-test.ps1" -Action Install -PackageRoot "%~dp0"
set "RESULT=%ERRORLEVEL%"
if not "%RESULT%"=="0" (
  echo.
  echo ERROR: Installation did not finish. See install-test.log.
  pause
)
exit /b %RESULT%
