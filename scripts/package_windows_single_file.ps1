$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $repoRoot "dist\windows"
$bundleDir = Join-Path $repoRoot "dist\single_file_bundle"
$outputExe = Join-Path $repoRoot "dist\VisionDraft-portable.exe"
$stubSource = Join-Path $repoRoot "dist\single_file_stub.ps1"
$sfxSource = Join-Path $repoRoot "dist\single_file_payload.7z"

if (-not (Test-Path $distDir)) {
  throw "Missing dist\windows. Run scripts\build_windows.ps1 first."
}

if (Test-Path $bundleDir) {
  Remove-Item $bundleDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $bundleDir | Out-Null

$launcherPath = Join-Path $bundleDir "launch_visiondraft.ps1"
$launcherContent = @'
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$exe = Join-Path $root "vision_draft.exe"
if (-not (Test-Path $exe)) {
  throw "vision_draft.exe not found at $exe"
}
Start-Process -FilePath $exe -WorkingDirectory $root
'@
Set-Content -Path $launcherPath -Value $launcherContent -Encoding UTF8

Copy-Item -Path (Join-Path $distDir "*") -Destination $bundleDir -Recurse -Force

$sevenZip = @(
  "$env:ProgramFiles\7-Zip\7z.exe",
  "${env:ProgramFiles(x86)}\7-Zip\7z.exe",
  "$env:ChocolateyInstall\bin\7z.exe"
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

if (-not $sevenZip) {
  throw "7-Zip not found. Install 7-Zip to build single-file package."
}

$sfxModule = @(
  "$env:ProgramFiles\7-Zip\7z.sfx",
  "${env:ProgramFiles(x86)}\7-Zip\7z.sfx"
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

if (-not $sfxModule) {
  throw "7z.sfx not found next to 7-Zip installation."
}

if (Test-Path $sfxSource) {
  Remove-Item $sfxSource -Force
}
if (Test-Path $stubSource) {
  Remove-Item $stubSource -Force
}
if (Test-Path $outputExe) {
  Remove-Item $outputExe -Force
}

& $sevenZip a -t7z $sfxSource (Join-Path $bundleDir "*") | Out-Null
if ($LASTEXITCODE -ne 0) {
  throw "7-Zip archive creation failed with exit code $LASTEXITCODE"
}

$escapedBundleDir = $bundleDir.Replace('\', '\\')
$stubContent = @"
;!@Install@!UTF-8!
Title="VisionDraft Portable"
BeginPrompt="VisionDraft 将解压到本机后运行。"
RunProgram="powershell.exe -ExecutionPolicy Bypass -File launch_visiondraft.ps1"
InstallPath="%LOCALAPPDATA%\\VisionDraftPortable\\ba31844"
OverwriteMode="2"
GUIMode="1"
;!@InstallEnd@!
"@
Set-Content -Path $stubSource -Value $stubContent -Encoding ASCII

$outStream = [System.IO.File]::Create($outputExe)
try {
  foreach ($part in @($sfxModule, $stubSource, $sfxSource)) {
    $bytes = [System.IO.File]::ReadAllBytes($part)
    $outStream.Write($bytes, 0, $bytes.Length)
  }
} finally {
  $outStream.Dispose()
}

Write-Host ""
Write-Host "Single-file package created:"
Write-Host $outputExe
