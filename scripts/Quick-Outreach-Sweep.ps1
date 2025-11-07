param(
  [string]$RickPublic = "$HOME\Documents\GitHub\RickPublic",
  [string]$Downloads  = "$HOME\Downloads"
)
$ErrorActionPreference = 'Stop'

& "$RickPublic\scripts\Harvest-Outreach.ps1" -RickPublic $RickPublic -Downloads $Downloads
& "$RickPublic\scripts\Scan-Outreach.ps1" -RickPublic $RickPublic

$idxDir = Join-Path $RickPublic "docs/intent/outreach/indexes"
$latest = Get-ChildItem $idxDir -Filter "OUTREACH_INTENT_INDEX_*.md" | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
if ($latest) {
  Write-Host "Opening $($latest.FullName)"
  Start-Process $latest.FullName
} else {
  Write-Host "No index file found in $idxDir"
}
