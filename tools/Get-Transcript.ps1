#requires -version 7
param(
  [Parameter(Mandatory)][string]$Url,    # YouTube URL OR bare ID
  [Parameter(Mandatory)][string]$Slug,   # e.g. 0002
  [string]$Lang = 'en'
)
$ErrorActionPreference = 'Stop'

if     ($Url -match 'v=([^&]+)')         { $vid = $Matches[1] }
elseif ($Url -match 'youtu\.be/([^?]+)') { $vid = $Matches[1] }
elseif ($Url -match '^[A-Za-z0-9_-]{10,}$') { $vid = $Url }
else { throw "Unrecognized YouTube URL/ID: $Url" }

$RepoRoot = Join-Path $HOME 'Documents\GitHub\RickPublic'
$assets   = Join-Path $RepoRoot "sotw\$Slug\assets"
New-Item -Force -ItemType Directory $assets | Out-Null

$tmp = Join-Path $env:TEMP ("yt-" + [guid]::NewGuid().Guid)
New-Item -Force -ItemType Directory $tmp | Out-Null
Push-Location $tmp

$extra = @("--extractor-args","youtube:player_client=android")
$cmd = @("yt-dlp","--skip-download","--write-sub","--write-auto-sub","--sub-lang",$Lang,
         "--convert-subs","srt","--output","%(title)s [%(id)s].%(ext)s") + $extra + @("https://www.youtube.com/watch?v=$vid")
& $cmd 2>$null | Out-Null
Pop-Location

$srt = Get-ChildItem -Recurse -File $tmp -Filter "*[$vid]*.$Lang.srt" | Sort-Object LastWriteTime -Desc | Select-Object -First 1
if (-not $srt) {
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
  throw "No .$Lang .srt found for id $vid (video may not have captions yet)."
}

$destSrt = Join-Path $assets ("{0}.{1}.srt" -f $Slug,$Lang)
Copy-Item $srt.FullName $destSrt -Force
(Get-Content $destSrt -Raw) -replace "`r","" | Set-Content -Encoding UTF8 (Join-Path $assets ("{0}.{1}.txt" -f $Slug,$Lang))

Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
Write-Host "Saved SRT:" (Resolve-Path $destSrt)
