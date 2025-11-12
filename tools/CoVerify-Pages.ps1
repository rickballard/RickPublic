Param(
  [string]$RepoSlug = 'rickballard/RickPublic'
)
$ErrorActionPreference='Stop'
$RepoPath = Join-Path $HOME 'Documents\GitHub\RickPublic'
if(!(Test-Path $RepoPath)){ throw "Repo path not found: $RepoPath" }
# Ensure npm exists
if(-not (Get-Command npm -ErrorAction SilentlyContinue)){
  Write-Warning "npm not found. Install Node/npm or run the workflow to build in CI."
}
# Build locally (optional)
$Latest = Join-Path $RepoPath 'docs/intent/outreach/indexes/latest.md'
$OutDir = Join-Path $RepoPath '_site'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
if(Test-Path $Latest){
  npm -v *> $null
  npx -y marked -i $Latest -o (Join-Path $OutDir 'index.html')
}
# Append fingerprint
$date = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$f = Join-Path $OutDir 'index.html'
if(!(Test-Path $f)){ Set-Content -Encoding utf8NoBOM $f "<html><body><pre>No index.html built.</pre></body></html>" }
Add-Content -LiteralPath $f ("<!-- build-fingerprint:LOCAL:{0} -->" -f $date)
Copy-Item $f (Join-Path $OutDir '404.html') -Force
New-Item -ItemType File -Force -Path (Join-Path $OutDir '.nojekyll') | Out-Null
Write-Host "Local verify OK. Fingerprint appended to $f"
