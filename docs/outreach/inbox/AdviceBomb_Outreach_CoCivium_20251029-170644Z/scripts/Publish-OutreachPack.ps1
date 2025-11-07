param(
  [Parameter(Mandatory=$false)][string]$RepoPath = "$HOME\Documents\GitHub\CoContrib",
  [Parameter(Mandatory=$false)][string]$Branch = ("outreach/seed-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
)
$ErrorActionPreference = 'Stop'
Write-Host "Repo: $RepoPath"
if(-not (Test-Path $RepoPath)){ throw "RepoPath not found: $RepoPath" }
# Paste-safe, no AddRange, minimal args.
Push-Location $RepoPath
try{
  git switch -c $Branch
  $dest = Join-Path $RepoPath "outreach\seed"
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Copy-Item -Path "$PSScriptRoot\..\outreach" -Destination $dest -Recurse -Force
  Copy-Item -Path "$PSScriptRoot\..\OUTREACH_CHECKLIST.md" -Destination $dest -Force
  git add "outreach/seed/*"
  git commit -m "outreach: seed AdviceBomb collateral (zip-first)"
  git push -u origin $Branch
  Write-Host "Branch pushed: $Branch"
  Write-Host "Open a PR in your browser to merge to main (squash-merge)."
} finally {
  Pop-Location
}
