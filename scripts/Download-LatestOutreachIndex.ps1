Param(
  [string]$Repo   = "rickballard/RickPublic",
  [string]$Branch = "main",
  [string]$OutDir = "$HOME\Downloads\outreach-index"
)
$ErrorActionPreference='Stop'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$raw = "https://raw.githubusercontent.com/$Repo/$Branch/docs/intent/outreach/indexes/latest.md"
$dst = Join-Path $OutDir "latest.md"
Invoke-WebRequest -UseBasicParsing -Uri $raw -OutFile $dst
Write-Host "Downloaded → $dst"
# Try to open in default viewer/editor
try { Start-Process $dst } catch { }
