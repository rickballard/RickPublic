param(
  [string]$RickPublic = "$HOME\Documents\GitHub\RickPublic",
  [string]$Downloads  = "$HOME\Downloads"
)

$ErrorActionPreference = 'Stop'

$inbox = Join-Path $RickPublic "docs/outreach/inbox"
if (-not (Test-Path $inbox)) { New-Item -ItemType Directory -Path $inbox | Out-Null }

$zips = Get-ChildItem -Path $Downloads -Filter "AdviceBomb_*Outreach*.zip" | Sort-Object LastWriteTimeUtc -Descending
if (-not $zips) { Write-Host "No AdviceBomb outreach zips found in $Downloads"; exit 0 }

foreach ($zip in $zips) {
  $name = [IO.Path]::GetFileNameWithoutExtension($zip.Name)
  $dst  = Join-Path $inbox $name
  if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst | Out-Null }
  Expand-Archive -Path $zip.FullName -DestinationPath $dst -Force

  # Surface useful docs to a dedicated subfolder, avoiding self-overwrite
  $surf = Join-Path $dst "_surfaced"
  if (-not (Test-Path $surf)) { New-Item -ItemType Directory -Path $surf | Out-Null }
  Get-ChildItem -Path $dst -Recurse -Include *.md,*.txt | ForEach-Object {
    $target = Join-Path $surf $_.Name
    if ($_.FullName -ne $target) {
      Copy-Item -LiteralPath $_.FullName -Destination $surf -Force -ErrorAction SilentlyContinue
    }
  }
}

Write-Host "Harvest complete → $inbox"
