[CmdletBinding()]
param(
  [string] $Version = '1.1.0',
  [string] $OutputDir = (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'output\archives')
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$packageName = "AI_Rime_Test_Package_v$Version"
$stageDir = Join-Path $OutputDir $packageName
$archivePath = Join-Path $OutputDir "$packageName.zip"

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$resolvedOutput = [IO.Path]::GetFullPath($OutputDir)
$resolvedStage = [IO.Path]::GetFullPath($stageDir)
if (-not $resolvedStage.StartsWith($resolvedOutput + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
  throw "Unsafe staging path: $resolvedStage"
}

if (Test-Path -LiteralPath $stageDir) {
  Remove-Item -LiteralPath $stageDir -Recurse -Force
}
if (Test-Path -LiteralPath $archivePath) {
  Remove-Item -LiteralPath $archivePath -Force
}

New-Item -ItemType Directory -Path $stageDir | Out-Null
Get-ChildItem -LiteralPath $projectRoot -Force |
  Where-Object { $_.Name -notin @('_backups', '.ai_creator_install.json') } |
  Copy-Item -Destination $stageDir -Recurse -Force

Compress-Archive -Path (Join-Path $stageDir '*') -DestinationPath $archivePath -CompressionLevel Optimal
Remove-Item -LiteralPath $stageDir -Recurse -Force

$archive = Get-Item -LiteralPath $archivePath
$hash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash
Write-Host "Package: $($archive.FullName)"
Write-Host "Bytes: $($archive.Length)"
Write-Host "SHA256: $hash"
