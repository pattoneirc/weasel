@echo off
chcp 65001 >nul
setlocal
title AI 创作者词库 - 恢复原配置
echo.
echo 即将删除测试词库，并恢复安装测试配置前的 Rime 配置。
echo.
choice /C YN /N /M "确认恢复？[Y/N] "
if errorlevel 2 exit /b 0

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\uninstall.ps1"
if errorlevel 1 (
  echo.
  echo 恢复没有完成。请保留本文件夹和 _backups，不要手动删除备份。
  pause
  exit /b 1
)

echo.
echo 原配置已恢复并重新部署。
pause
