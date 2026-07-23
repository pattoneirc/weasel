@echo off
chcp 65001 >nul
setlocal
title AI 创作者词库 - 测试安装
echo.
echo 这将临时修改当前用户的 Rime 配置，但不会替换小狼毫程序文件。
echo 原配置会备份到本测试包旁边的 _backups 文件夹。
echo 测试期间请保留整个文件夹，以便一键恢复。
echo.
choice /C YN /N /M "继续安装测试配置？[Y/N] "
if errorlevel 2 exit /b 0

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install.ps1" -BackupBase "%~dp0_backups"
if errorlevel 1 (
  echo.
  echo 安装没有完成。请保留本窗口中的错误信息。
  pause
  exit /b 1
)

echo.
echo 测试配置已安装并重新部署。
echo 请测试 Shift+2、github、comfyui、ue5 等输入。
echo 测试完成后双击“恢复原配置.cmd”。
pause
