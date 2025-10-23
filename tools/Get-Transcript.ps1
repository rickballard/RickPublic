#requires -version 7
param(
  [Parameter(Mandatory)][string]$Url,
  [string]$Lang = "en",
  [string]$OutDir = "."
)
$ErrorActionPreference = "Stop"

if     ($Url -match 'v=([^&]+)')         { $vid = $Matches[1] }
elseif ($Url -match 'youtu\.be/([^?]+)') { $vid = $Matches[1] }
else { throw "Unrecognized YouTube URL: $Url" }

$tmp = Join-Path $env:TEMP ("yt-"+[guid]::NewGuid().Guid)
New-Item -Force -ItemType Directory $tmp | Out-Null

Push-Location $tmp
yt-dlp --skip-download --write-sub --write-auto-sub --sub-lang $Lang --convert-subs srt `
  --output "%(title)s [%(id)s].%(ext)s" $Url | Out-Null
Pop-Location

$srt = Get-ChildItem -Recurse -File -Path $tmp -Filter "*[$vid]*.$Lang.srt" |
       Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $srt) { throw "No .$Lang .srt found for id $vid" }

New-Item -Force -ItemType Directory $OutDir | Out-Null
$dest = Join-Path $OutDir ("{0}.{1}.srt" -f $vid, $Lang)
Copy-Item -LiteralPath $srt.FullName -Destination $dest -Force

Remove-Item -Recurse -Force $tmp
Write-Output (Resolve-Path $dest)
