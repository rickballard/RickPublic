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
  # Copy any obvious outreach docs to top-level for quick scanning
  Get-ChildItem -Path $dst -Recurse -Include *.md,*.txt | Copy-Item -Destination $dst -Force
}

Write-Host "Harvest complete → $inbox"
