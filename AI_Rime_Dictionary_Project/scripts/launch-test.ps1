[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [ValidateSet('Install', 'Restore')]
  [string] $Action,
  [string] $PackageRoot = (Split-Path $PSScriptRoot -Parent),
  [string] $RimeDir = (Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Rime'),
  [string] $BackupBase = (Join-Path $PackageRoot '_backups'),
  [switch] $SkipDeploy,
  [switch] $NonInteractive
)

$ErrorActionPreference = 'Stop'
$PackageRoot = [IO.Path]::GetFullPath($PackageRoot)
$logName = if ($Action -eq 'Install') { 'install-test.log' } else { 'restore-test.log' }
$logPath = Join-Path $PackageRoot $logName

function Show-Dialog {
  param(
    [string] $Text,
    [string] $Title,
    [string] $Icon = 'Information',
    [switch] $Confirm
  )

  if ($NonInteractive) {
    Write-Host $Text
    return $true
  }

  Add-Type -AssemblyName System.Windows.Forms
  $buttons = if ($Confirm) {
    [Windows.Forms.MessageBoxButtons]::YesNo
  } else {
    [Windows.Forms.MessageBoxButtons]::OK
  }
  $result = [Windows.Forms.MessageBox]::Show(
    $Text,
    $Title,
    $buttons,
    [Windows.Forms.MessageBoxIcon]::$Icon
  )
  return (-not $Confirm) -or $result -eq [Windows.Forms.DialogResult]::Yes
}

$installScript = Join-Path $PackageRoot 'scripts\install.ps1'
$uninstallScript = Join-Path $PackageRoot 'scripts\uninstall.ps1'
$englishDictionary = Join-Path $PackageRoot 'english_terms.dict.yaml'

try {
  if (-not (Test-Path -LiteralPath $installScript) -or
      -not (Test-Path -LiteralPath $uninstallScript) -or
      -not (Test-Path -LiteralPath $englishDictionary)) {
    throw 'The test package is incomplete. Extract the entire ZIP to a normal folder before running it.'
  }

  if ($Action -eq 'Install') {
    $question = @'
这会临时修改当前用户的 Rime 配置，但不会替换小狼毫程序文件。

原配置将备份到测试包旁边的 _backups 文件夹。
测试期间请保留整个测试包文件夹。

是否继续？
'@
    if (-not (Show-Dialog -Text $question -Title 'AI 创作者词库 - 测试安装' -Icon Question -Confirm)) {
      exit 0
    }

    $params = @{
      RimeDir = $RimeDir
      BackupBase = $BackupBase
      SkipDeploy = $SkipDeploy
    }
    $output = & $installScript @params 2>&1 | Out-String
    [IO.File]::WriteAllText($logPath, $output, (New-Object Text.UTF8Encoding($true)))
    Show-Dialog -Title '安装完成' -Text @'
测试配置已安装。

请依次测试：
1. Shift+2 是否直接输出 @
2. github 是否出现 GitHub
3. comfyui 是否出现 ComfyUI
4. ue5 是否出现 Unreal Engine 5

测试完成后双击“恢复原配置.cmd”。
'@ | Out-Null
  } else {
    if (-not (Show-Dialog -Text '即将删除测试词库并恢复安装前的配置。是否继续？' -Title '恢复原配置' -Icon Question -Confirm)) {
      exit 0
    }

    $params = @{
      RimeDir = $RimeDir
      SkipDeploy = $SkipDeploy
    }
    $output = & $uninstallScript @params 2>&1 | Out-String
    [IO.File]::WriteAllText($logPath, $output, (New-Object Text.UTF8Encoding($true)))
    Show-Dialog -Title '恢复完成' -Text '原配置已恢复。测试词库已经移除。' | Out-Null
  }

  exit 0
} catch {
  $details = ($_ | Format-List * -Force | Out-String)
  [IO.File]::WriteAllText($logPath, $details, (New-Object Text.UTF8Encoding($true)))
  Show-Dialog -Title '操作失败' -Icon Error -Text "操作没有完成。`r`n`r`n请保留测试包和 _backups 文件夹，并查看：`r`n$logPath" | Out-Null
  exit 1
}
