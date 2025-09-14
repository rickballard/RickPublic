# Init-RickPublic.ps1
<#
  Creates a public GitHub repo 'RickPublic' under your account, pushes the current folder,
  and configures relaxed gating (minimal protections). Requires Git and GitHub CLI (gh).
#>
param(
  [string]$Owner = (git config user.name),
  [string]$RepoName = 'RickPublic'
)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw "GitHub CLI 'gh' not found. Install from https://cli.github.com"
}

$full = "$Owner/$RepoName"
# Create repo if missing
$exists = gh repo view $full 2>$null
if (-not $exists) {
  gh repo create $full --public --source "." --push
} else {
  git init
  git add .
  git commit -m "seed: initial content" -q
  git branch -M main
  git remote add origin "https://github.com/$full.git" 2>$null
  git push -u origin main
}

# Relaxed gating: ensure no required checks; allow squash merges by default
gh api -X PATCH "repos/$full" -f allow_squash_merge=true -f allow_merge_commit=false -f allow_rebase_merge=false

# Remove strict branch protection if present
try {
  gh api -X DELETE "repos/$full/branches/main/protection" | Out-Null
} catch {}

Write-Host "Repo ready: https://github.com/$full"
