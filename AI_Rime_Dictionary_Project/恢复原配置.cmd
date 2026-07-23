@echo off
setlocal
if not exist "%~dp0scripts\launch-test.ps1" (
  echo ERROR: scripts\launch-test.ps1 was not found.
  echo Run this file from the AI_Rime_Dictionary_Project directory.
  echo.
  pause
  exit /b 2
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\launch-test.ps1" -Action Restore -PackageRoot "%~dp0."
set "RESULT=%ERRORLEVEL%"
if not "%RESULT%"=="0" (
  echo.
  echo ERROR: Restore did not finish. Keep _local_test_backup.
  echo See restore-test.log for details.
  pause
)
exit /b %RESULT%
