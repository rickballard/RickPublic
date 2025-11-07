param(
  [Parameter(Mandatory)][string]$MasterSvg,   # sanitized GREY master SVG
  [Parameter(Mandatory)][string]$OutDir,      # where to write variants
  [string[]]$Hexes = @("#08a045","#ff9f0a","#ff3b30","#ffffff","#000000"), # green, amber, red, white, black
  [string[]]$Names = @("green","amber","red","white","black"),              # matching names
  [switch]$Png,            # export 256px PNGs (requires ImageMagick)
  [string]$BaseName="icon" # output name prefix (e.g., halo -> halo-green.svg)
)

Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
if (!(Test-Path $MasterSvg)) { throw "Missing: $MasterSvg" }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Detect source grey hex from master
$svg = Get-Content $MasterSvg -Raw
$greyHex = [regex]::Match($svg,'(?i)(?<=#)[0-9a-f]{3,6}').Value
if (-not $greyHex) { throw "Could not detect a hex color in $MasterSvg" }
$srcHex = "#$greyHex"

function New-ColorVariant([string]$Source,[string]$Target,[string]$NewHex) {
  $c = Get-Content $Source -Raw
  $c = $c -replace [regex]::Escape($srcHex), $NewHex
  Set-Content -Path $Target -Value $c -Encoding UTF8
}

for ($i=0; $i -lt $Hexes.Count; $i++) {
  $name = $Names[$i]; $hex = $Hexes[$i]
  $out  = Join-Path $OutDir "$BaseName-$name.svg"
  Copy-Item $MasterSvg $out -Force
  New-ColorVariant -Source $out -Target $out -NewHex $hex
}

if ($Png) {
  $magick = Get-Command magick -ErrorAction SilentlyContinue
  if ($magick) {
    $pngDir = Join-Path $OutDir "png"; New-Item -ItemType Directory -Force -Path $pngDir | Out-Null
    Get-ChildItem $OutDir -Filter "$BaseName-*.svg" | ForEach-Object {
      & magick -background none $_.FullName -density 384 -resize 256x256 (Join-Path $pngDir ($_.BaseName + ".png"))
    }
  } else {
    Write-Warning "ImageMagick not found; skipping PNG export."
  }
}
