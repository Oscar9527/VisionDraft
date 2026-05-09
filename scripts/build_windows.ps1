$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$flutterRoot = if ($env:FLUTTER_ROOT) {
  $env:FLUTTER_ROOT
} else {
  "C:\tools\flutter"
}
$vsDevCmd = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat"
$pluginRoot = Join-Path $repoRoot "windows\flutter\ephemeral\.plugin_symlinks"
$buildDir = Join-Path $repoRoot "tmp_build\cmake_nmake"
$distDir = Join-Path $repoRoot "dist\windows"
$stagingDistDir = Join-Path $repoRoot "dist\windows_next"
$windowsDir = Join-Path $repoRoot "windows"
$dependenciesFile = Join-Path $repoRoot ".flutter-plugins-dependencies"

if (-not (Test-Path $flutterRoot)) {
  throw "Flutter SDK not found at $flutterRoot. Set FLUTTER_ROOT or install Flutter there."
}

if (-not (Test-Path $vsDevCmd)) {
  throw "VsDevCmd.bat not found at $vsDevCmd."
}

if (-not (Test-Path $dependenciesFile)) {
  throw "Missing .flutter-plugins-dependencies. Run 'flutter pub get' first."
}

New-Item -ItemType Directory -Force -Path $pluginRoot | Out-Null
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
New-Item -ItemType Directory -Force -Path $distDir | Out-Null
if (Test-Path $stagingDistDir) {
  Remove-Item $stagingDistDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $stagingDistDir | Out-Null

Get-Process vision_draft -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 800

$cacheFile = Join-Path $buildDir "CMakeCache.txt"
if (Test-Path $cacheFile) {
  Remove-Item $cacheFile -Force
}

$deps = Get-Content $dependenciesFile -Raw | ConvertFrom-Json
$windowsPlugins = @($deps.plugins.windows)

foreach ($plugin in $windowsPlugins) {
  $name = $plugin.name
  $target = $plugin.path.TrimEnd("\")
  $linkPath = Join-Path $pluginRoot $name

  if (Test-Path $linkPath) {
    $item = Get-Item $linkPath -Force
    if ($item.LinkType -eq "Junction") {
      cmd /c rmdir "$linkPath" | Out-Null
    } elseif ($item.PSIsContainer -or $item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
      Remove-Item $linkPath -Recurse -Force
    } else {
      throw "Existing non-link path blocks plugin junction: $linkPath"
    }
  }

  cmd /c mklink /J "$linkPath" "$target" | Out-Null
}

$configure = @(
  "`"$vsDevCmd`"",
  "-arch=x64",
  "-host_arch=x64",
  ">nul",
  "&&",
  "cmake",
  "-S", "`"$windowsDir`"",
  "-B", "`"$buildDir`"",
  "-G", "`"NMake Makefiles`"",
  "-DCMAKE_BUILD_TYPE=Release",
  "-DFLUTTER_TARGET_PLATFORM=windows-x64",
  "-DFLUTTER_ROOT=`"$flutterRoot`""
) -join " "

$build = @(
  "`"$vsDevCmd`"",
  "-arch=x64",
  "-host_arch=x64",
  ">nul",
  "&&",
  "cmake",
  "--build", "`"$buildDir`"",
  "--config", "Release",
  "&&",
  "cmake",
  "--install", "`"$buildDir`"",
  "--config", "Release"
) -join " "

cmd.exe /d /s /c $configure
cmd.exe /d /s /c $build

$runnerDir = Join-Path $buildDir "runner"

$runtimeEntries = @(
  "vision_draft.exe",
  "flutter_windows.dll",
  "pdfium.dll",
  "file_selector_windows_plugin.dll",
  "printing_plugin.dll",
  "sqlite3_flutter_libs_plugin.dll",
  "sqlite3.dll",
  "native_assets.json",
  "data"
)

foreach ($entry in $runtimeEntries) {
  $source = Join-Path $runnerDir $entry
  if (-not (Test-Path $source)) {
    throw "Missing runtime artifact: $source"
  }
  Copy-Item -Path $source -Destination $stagingDistDir -Recurse -Force
}

$backupDistDir = Join-Path $repoRoot "dist\windows_prev"
if (Test-Path $backupDistDir) {
  Remove-Item $backupDistDir -Recurse -Force
}
if (Test-Path $distDir) {
  Move-Item -Path $distDir -Destination $backupDistDir -Force
}
Move-Item -Path $stagingDistDir -Destination $distDir -Force
if (Test-Path $backupDistDir) {
  for ($attempt = 0; $attempt -lt 6; $attempt++) {
    try {
      Remove-Item $backupDistDir -Recurse -Force
      break
    } catch {
      if ($attempt -eq 5) {
        Write-Warning "Could not remove previous dist directory: $backupDistDir"
      } else {
        Start-Sleep -Milliseconds (500 * ($attempt + 1))
      }
    }
  }
}

Write-Host ""
Write-Host "Done."
Write-Host "EXE: $(Join-Path $buildDir 'runner\vision_draft.exe')"
Write-Host "DIST: $distDir"
