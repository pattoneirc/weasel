[CmdletBinding()]
param(
  [string] $RimeDir = (Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Rime'),
  [string] $BackupBase,
  [switch] $SkipDeploy,
  [switch] $RemoveBackup
)

$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $RimeDir '.ai_creator_install.json'

function Find-WeaselDeployer {
  $registryPaths = @(
    'HKLM:\Software\WOW6432Node\Rime\Weasel',
    'HKLM:\Software\Rime\Weasel'
  )
  foreach ($registryPath in $registryPaths) {
    if (Test-Path $registryPath) {
      $root = (Get-ItemProperty $registryPath -ErrorAction SilentlyContinue).WeaselRoot
      if ($root) {
        $candidate = Join-Path $root 'WeaselDeployer.exe'
        if (Test-Path $candidate) { return $candidate }
      }
    }
  }
  $command = Get-Command 'WeaselDeployer.exe' -ErrorAction SilentlyContinue
  if ($command) { return $command.Source }
  return $null
}

if (-not (Test-Path $manifestPath)) {
  throw "Install manifest not found: $manifestPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$backupRoot = $manifest.backup_dir
if (-not (Test-Path $backupRoot)) {
  throw "Backup directory not found: $backupRoot"
}

foreach ($name in $manifest.installed_files) {
  $target = Join-Path $RimeDir $name
  $backup = Join-Path $backupRoot $name
  if (Test-Path $backup) {
    Copy-Item -LiteralPath $backup -Destination $target -Force
  } elseif (Test-Path $target) {
    Remove-Item -LiteralPath $target -Force
  }
}

$customName = 'luna_pinyin_simp.custom.yaml'
$customTarget = Join-Path $RimeDir $customName
$customBackup = Join-Path $backupRoot $customName
if (Test-Path $customBackup) {
  Copy-Item -LiteralPath $customBackup -Destination $customTarget -Force
} elseif (Test-Path $customTarget) {
  Remove-Item -LiteralPath $customTarget -Force
}

Remove-Item -LiteralPath $manifestPath -Force

if (-not $SkipDeploy) {
  $deployer = Find-WeaselDeployer
  if ($deployer) {
    & $deployer /deploy
  } else {
    Write-Warning 'WeaselDeployer.exe was not found. Use the tray menu to apply/redeploy the configuration manually.'
  }
}

if ($RemoveBackup) {
  if ([string]::IsNullOrWhiteSpace($BackupBase)) {
    throw 'BackupBase is required when RemoveBackup is enabled.'
  }
  $trimChars = [char[]]@(
    [IO.Path]::DirectorySeparatorChar,
    [IO.Path]::AltDirectorySeparatorChar
  )
  $resolvedBase = [IO.Path]::GetFullPath($BackupBase).TrimEnd($trimChars)
  $resolvedBackup = [IO.Path]::GetFullPath($backupRoot)
  if (-not $resolvedBackup.StartsWith(
      $resolvedBase + [IO.Path]::DirectorySeparatorChar,
      [StringComparison]::OrdinalIgnoreCase
    )) {
    throw "Refusing to remove backup outside BackupBase: $resolvedBackup"
  }
  Remove-Item -LiteralPath $resolvedBackup -Recurse -Force
  if ((Test-Path -LiteralPath $resolvedBase) -and
      -not (Get-ChildItem -LiteralPath $resolvedBase -Force | Select-Object -First 1)) {
    Remove-Item -LiteralPath $resolvedBase -Force
  }
}

Write-Host "AI creator dictionary removed. Original files restored from: $backupRoot"
