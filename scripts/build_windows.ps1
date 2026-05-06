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
  "--config", "Debug",
  "&&",
  "cmake",
  "--install", "`"$buildDir`""
) -join " "

cmd.exe /d /s /c $configure
cmd.exe /d /s /c $build

Write-Host ""
Write-Host "Done."
Write-Host "EXE: $(Join-Path $buildDir 'runner\vision_draft.exe')"
