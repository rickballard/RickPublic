param(
  [Parameter(Mandatory)][string]$InputJpg,
  [Parameter(Mandatory)][string]$OutDir,
  [string]$BaseName = "RickPublic_Logo"
)
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
if (!(Test-Path $InputJpg)) { throw "Missing: $InputJpg" }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$magick = Get-Command magick -ErrorAction SilentlyContinue
if (-not $magick) { throw "ImageMagick (magick) not found on PATH" }

$blackT = Join-Path $OutDir ($BaseName + "_Black_On_Transparent.png")
$whiteT = Join-Path $OutDir ($BaseName + "_White_On_Transparent.png")

# Black on transparent (remove white)
& magick $InputJpg -alpha off -fuzz 10% -transparent white $blackT
# White on transparent (invert then remove black)
& magick $InputJpg -alpha off -colorspace sRGB -negate -fuzz 10% -transparent black $whiteT

Write-Host "Wrote:" $blackT
Write-Host "Wrote:" $whiteT
