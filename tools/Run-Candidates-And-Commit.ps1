#requires -version 7
$ErrorActionPreference='Stop'
$RepoRoot = Join-Path $HOME 'Documents\GitHub\RickPublic'
$Finder   = Join-Path $RepoRoot 'tools\Find-Candidates.ps1'
pwsh -NoProfile -ExecutionPolicy Bypass -File $Finder
git -C $RepoRoot add candidates outbox 2>$null
$st = git -C $RepoRoot status --porcelain
if ($st) { git -C $RepoRoot commit -m ("candidates/outbox: refresh ({0})" -f (Get-Date -Format yyyy-MM-dd)) | Out-Null; git -C $RepoRoot push | Out-Null; Write-Host "Committed & pushed." } else { Write-Host "No changes." }
