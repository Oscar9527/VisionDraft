param(
  [switch]$SkipBuild,
  [switch]$SkipPackage
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$pubspecPath = Join-Path $repoRoot "pubspec.yaml"
$releaseNotesPath = $null

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

function Get-RepoSlug {
  $remoteUrl = (git config --get remote.origin.url).Trim()
  if (-not $remoteUrl) {
    throw "Could not resolve remote.origin.url."
  }

  if ($remoteUrl -match 'github\.com[:/](?<slug>.+?)(\.git)?$') {
    return $Matches.slug
  }

  throw "Only GitHub remotes are supported. Found: $remoteUrl"
}

if ((git status --porcelain).Trim()) {
  throw "Working tree is not clean. Commit or stash changes before publishing a release."
}

$version = Get-AppVersion -PubspecPath $pubspecPath
$tag = "v$version"
$repoSlug = Get-RepoSlug
$releaseNotesPath = Join-Path $repoRoot "docs\release-notes-v$version.md"

if (-not (Test-Path $releaseNotesPath)) {
  throw "Missing release notes file: $releaseNotesPath"
}

if (-not $SkipBuild) {
  & (Join-Path $repoRoot "scripts\build_windows.ps1")
  if ($LASTEXITCODE -ne 0) {
    throw "build_windows.ps1 failed with exit code $LASTEXITCODE"
  }
}

if (-not $SkipPackage) {
  & (Join-Path $repoRoot "scripts\package_windows_release.ps1")
  if ($LASTEXITCODE -ne 0) {
    throw "package_windows_release.ps1 failed with exit code $LASTEXITCODE"
  }
}

$assets = @(
  (Join-Path $repoRoot "dist\VisionDraft-Setup-v$version.exe"),
  (Join-Path $repoRoot "dist\VisionDraft-v$version-portable-windows-x64.zip"),
  (Join-Path $repoRoot "dist\VisionDraft-portable.exe"),
  (Join-Path $repoRoot "dist\VisionDraft-source-v$version.zip")
)

foreach ($asset in $assets) {
  if (-not (Test-Path $asset)) {
    throw "Missing release asset: $asset"
  }
}

git push origin main
if ($LASTEXITCODE -ne 0) {
  throw "Failed to push origin/main."
}

$tagCommit = (git rev-list -n 1 $tag 2>$null)
$headCommit = (git rev-parse HEAD).Trim()
if (-not $tagCommit) {
  git tag -a $tag -m "VisionDraft $tag"
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to create tag $tag"
  }
  $tagCommit = (git rev-list -n 1 $tag).Trim()
}

if ($tagCommit.Trim() -ne $headCommit) {
  throw "Tag $tag does not point to HEAD. Bump version before publishing a new release."
}

git push origin "refs/tags/$tag"
if ($LASTEXITCODE -ne 0) {
  throw "Failed to push tag $tag"
}

$releaseExists = $false
gh release view $tag --repo $repoSlug *> $null
if ($LASTEXITCODE -eq 0) {
  $releaseExists = $true
}

if ($releaseExists) {
  gh release edit $tag --repo $repoSlug --title "VisionDraft $tag" --notes-file $releaseNotesPath
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to edit GitHub release $tag"
  }

  gh release upload $tag $assets --repo $repoSlug --clobber
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to upload assets to GitHub release $tag"
  }
} else {
  gh release create $tag $assets --repo $repoSlug --title "VisionDraft $tag" --notes-file $releaseNotesPath
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to create GitHub release $tag"
  }
}

Write-Host ""
Write-Host "GitHub release published:"
Write-Host "https://github.com/$repoSlug/releases/tag/$tag"
