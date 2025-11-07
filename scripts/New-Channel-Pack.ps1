param(
  [ValidateSet('substack','linkedin','twitter-x','github-discussions','email-gmail')]
  [string]$Channel,
  [string]$RickPublic = "$HOME\Documents\GitHub\RickPublic"
)

$dir = Join-Path $RickPublic ("docs/outreach/channels/" + $Channel)
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
$utc = (Get-Date).ToUniversalTime().ToString('yyyyMMdd_HHmmssZ')
$md  = Join-Path $dir ($Channel + "_" + $utc + ".md")
"# $Channel — Draft ($utc)`n`n…" | Set-Content -Path $md -Encoding utf8
Write-Host "Created $md"
