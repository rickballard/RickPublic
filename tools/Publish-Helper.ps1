#requires -version 7
param([Parameter(Mandatory=$true)][string]$Slug)
$RepoRoot = Join-Path $HOME "Documents\GitHub\RickPublic"
$PostMd   = Join-Path $RepoRoot ("sotw\{0}\post.md" -f $Slug)
if (!(Test-Path -LiteralPath $PostMd)) { Write-Error "Not found: $PostMd"; exit 1 }
Get-Content -LiteralPath $PostMd -Raw | Set-Clipboard
$md = Get-Content -LiteralPath $PostMd -Raw
$h1 = ($md -split "`r?`n") | Where-Object { $_ -match '^\s*#\s+(.+)$' } | Select-Object -First 1
if ($h1) { $title = ($h1 -replace '^\s*#\s+','').Trim(); $titlePath = Join-Path $env:TEMP "substack_title.txt"; Set-Content -Encoding UTF8 -Path $titlePath -Value $title; Write-Host "Title hint saved to: $titlePath" }
Write-Host "✅ post.md copied to clipboard."; Write-Host "➡ Opening Substack drafts..."; Start-Process "https://rickpublic.substack.com/publish/posts/drafts"
