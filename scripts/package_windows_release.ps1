param(
  [switch]$SkipSetup
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $repoRoot "dist"
$windowsDistDir = Join-Path $distDir "windows"
$pubspecPath = Join-Path $repoRoot "pubspec.yaml"
$setupScriptPath = Join-Path $repoRoot "scripts\visiondraft_setup.iss"
$portableZipPath = $null
$singleFilePath = Join-Path $distDir "VisionDraft-portable.exe"
$sourceZipPath = $null
$setupExePath = $null

function Get-AppVersion {
  param([Parameter(Mandatory = $true)][string]$PubspecPath)

  $versionLine = Get-Content $PubspecPath | Where-Object { $_ -match '^version:\s*(.+)$' } | Select-Object -First 1
  if (-not $versionLine) {
    throw "Could not find version in $PubspecPath"
  }

  $appVersion = ($versionLine -replace '^version:\s*', '').Trim()
  if ($appVersion -match '^(?<version>[^+]+)') {
    return $Matches.version
  }

  return $appVersion
}

function Resolve-IsccPath {
  $candidates = @((
    (Join-Path $env:LOCALAPPDATA "Programs\Inno Setup 6\ISCC.exe"),
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe"
  ) | Where-Object { $_ -and (Test-Path $_) })

  if ($candidates.Count -gt 0) {
    return (Resolve-Path $candidates[0]).ProviderPath
  }

  $uninstallRoots = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
  )

  foreach ($root in $uninstallRoots) {
    if (-not (Test-Path $root)) {
      continue
    }

    $match = Get-ChildItem $root -ErrorAction SilentlyContinue |
      Get-ItemProperty -ErrorAction SilentlyContinue |
      Where-Object { $_.DisplayName -like 'Inno Setup*' -and $_.InstallLocation } |
      Select-Object -First 1

    if ($match) {
      $candidate = Join-Path $match.InstallLocation "ISCC.exe"
      if (Test-Path $candidate) {
        return (Resolve-Path $candidate).ProviderPath
      }
    }
  }

  return $null
}

if (-not (Test-Path $windowsDistDir)) {
  throw "Missing dist\windows. Run scripts\build_windows.ps1 first."
}

$version = Get-AppVersion -PubspecPath $pubspecPath
$portableZipPath = Join-Path $distDir "VisionDraft-v$version-portable-windows-x64.zip"
$sourceZipPath = Join-Path $distDir "VisionDraft-source-v$version.zip"
$setupExePath = Join-Path $distDir "VisionDraft-Setup-v$version.exe"

if (Test-Path $portableZipPath) {
  Remove-Item $portableZipPath -Force
}

Compress-Archive -Path (Join-Path $windowsDistDir '*') -DestinationPath $portableZipPath -Force

if (Test-Path $sourceZipPath) {
  Remove-Item $sourceZipPath -Force
}

git archive --format=zip -o $sourceZipPath HEAD
if ($LASTEXITCODE -ne 0) {
  throw "git archive failed with exit code $LASTEXITCODE"
}

& (Join-Path $repoRoot "scripts\package_windows_single_file.ps1")
if ($LASTEXITCODE -ne 0) {
  throw "package_windows_single_file.ps1 failed with exit code $LASTEXITCODE"
}

$isccPath = [string](Resolve-IsccPath)
if (-not $isccPath) {
  if ($SkipSetup) {
    Write-Warning "ISCC.exe not found. Setup installer was skipped because -SkipSetup was used."
  } else {
    throw "ISCC.exe not found. Install Inno Setup or rerun with -SkipSetup."
  }
} else {
  Write-Host "Using ISCC: $isccPath"
  if (Test-Path $setupExePath) {
    Remove-Item $setupExePath -Force
  }

  $process = Start-Process -FilePath $isccPath -ArgumentList @(
    "/DMyAppVersion=$version",
    "/DMyOutputBaseFilename=VisionDraft-Setup-v$version",
    $setupScriptPath
  ) -Wait -PassThru -NoNewWindow
  if ($process.ExitCode -ne 0) {
    throw "ISCC failed with exit code $($process.ExitCode)"
  }
}

Write-Host ""
Write-Host "Release packaging complete."
Write-Host "Portable zip: $portableZipPath"
Write-Host "Portable exe: $singleFilePath"
Write-Host "Source zip:   $sourceZipPath"
if (Test-Path $setupExePath) {
  Write-Host "Setup exe:    $setupExePath"
} else {
  Write-Host "Setup exe:    skipped"
}
