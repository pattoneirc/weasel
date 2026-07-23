[CmdletBinding()]
param(
  [string] $RimeDir = (Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Rime'),
  [string] $BackupBase = (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'RimeBackups\AI_Rime_Dictionary_Project'),
  [switch] $SkipDeploy
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$manifestPath = Join-Path $RimeDir '.ai_creator_install.json'
$utf8 = New-Object Text.UTF8Encoding($false)

if (Test-Path $manifestPath) {
  throw 'AI creator test configuration is already installed. Run uninstall.ps1 (or double-click 恢复原配置.cmd) before installing again.'
}

$files = @(
  'ai_creator.dict.yaml',
  'ai_creator.schema.yaml',
  'ai_creator.yaml',
  'ai_punctuation.yaml',
  'ai_shortcuts.dict.yaml',
  'ai_shortcuts.yaml',
  'ai_models.dict.yaml',
  'ai_nodes.dict.yaml',
  'english_terms.dict.yaml',
  'image_prompt.dict.yaml',
  'video_prompt.dict.yaml',
  'storyboard.dict.yaml',
  'writing.dict.yaml'
)

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

function Convert-ToPatchList {
  param([string] $Content)

  if ($Content -match '(?m)^__patch:\s*$') {
    return $Content.TrimEnd()
  }

  $match = [regex]::Match($Content, '(?ms)^(?<prefix>.*?)(?m:^patch:\s*$\r?\n)(?<body>.*)$')
  if (-not $match.Success) {
    throw 'Unsupported luna_pinyin_simp.custom.yaml structure. Restore the backup and merge luna_pinyin_simp.custom.template.yaml manually.'
  }

  $prefix = $match.Groups['prefix'].Value.TrimEnd()
  $bodyLines = $match.Groups['body'].Value.TrimEnd() -split '\r?\n'
  $indentedBody = $bodyLines | ForEach-Object {
    if ($_.Length -eq 0) { '' } else { '    ' + $_ }
  }
  $result = @()
  if ($prefix) { $result += $prefix; $result += '' }
  $result += '__patch:'
  $result += '  - patch/+:'
  $result += $indentedBody
  return ($result -join "`r`n").TrimEnd()
}

$aiPatch = @'
  # AI Creator Dictionary BEGIN
  - patch/+:
      schema/dependencies:
        - stroke
        - ai_creator
      engine/translators:
        - punct_translator
        - table_translator@custom_phrase
        - reverse_lookup_translator
        - script_translator
        - table_translator@ai_creator
        - table_translator@ai_shortcuts
      ai_creator:
        dictionary: ai_creator
        enable_completion: false
        enable_sentence: false
        enable_user_dict: true
        initial_quality: -2.0
        comment_format:
          - xform/.+//
      ai_shortcuts:
        __include: ai_shortcuts:/translator
      "recognizer/patterns/ai_shortcut":
        __include: ai_shortcuts:/pattern
      "punctuator/import_preset": ai_punctuation
  # AI Creator Dictionary END
'@

New-Item -ItemType Directory -Force -Path $RimeDir | Out-Null

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $BackupBase $timestamp
New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null

$backedUp = @()
$absentBeforeInstall = @()
$targets = $files + 'luna_pinyin_simp.custom.yaml'
foreach ($name in $targets) {
  $target = Join-Path $RimeDir $name
  if (Test-Path $target) {
    Copy-Item -LiteralPath $target -Destination (Join-Path $backupRoot $name) -Force
    $backedUp += $name
  } else {
    $absentBeforeInstall += $name
  }
}

foreach ($name in $files) {
  Copy-Item -LiteralPath (Join-Path $projectRoot $name) -Destination (Join-Path $RimeDir $name) -Force
}

$customPath = Join-Path $RimeDir 'luna_pinyin_simp.custom.yaml'
if (Test-Path $customPath) {
  $custom = [IO.File]::ReadAllText($customPath, $utf8)
  if ($custom -notmatch 'AI Creator Dictionary BEGIN') {
    $custom = Convert-ToPatchList $custom
    $custom = $custom + "`r`n" + $aiPatch.TrimEnd() + "`r`n"
    [IO.File]::WriteAllText($customPath, $custom, $utf8)
  }
} else {
  $custom = "__patch:`r`n" + $aiPatch.TrimEnd() + "`r`n"
  [IO.File]::WriteAllText($customPath, $custom, $utf8)
}

$manifest = [ordered]@{
  version = '1.1.0'
  installed_at = (Get-Date).ToString('o')
  rime_dir = $RimeDir
  backup_dir = $backupRoot
  installed_files = $files
  backed_up_files = $backedUp
  absent_before_install = $absentBeforeInstall
}
$manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

if (-not $SkipDeploy) {
  $deployer = Find-WeaselDeployer
  if ($deployer) {
    & $deployer /deploy
  } else {
    Write-Warning 'WeaselDeployer.exe was not found. Use the tray menu to apply/redeploy the configuration manually.'
  }
}

Write-Host "AI creator dictionary installed. Backup: $backupRoot"
