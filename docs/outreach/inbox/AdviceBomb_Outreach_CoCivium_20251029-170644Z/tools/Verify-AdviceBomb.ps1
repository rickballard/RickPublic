# Lightweight shape + checksum verifier for AdviceBomb zip folders
param(
  [Parameter(Mandatory=$false)][string]$Path = "."
)
$ErrorActionPreference='Stop'
function Get-FileHashHex([string]$p){
  if(!(Test-Path $p)){ return "" }
  $h = Get-FileHash -Algorithm SHA256 -Path $p
  return $h.Hash.ToLowerInvariant()
}
$expected = @(
  "outreach\README.md",
  "outreach\email_templates\Outreach_Intro_Email_Long.md",
  "outreach\email_templates\Outreach_Intro_Email_Short.md",
  "outreach\snippets\whatsapp.txt",
  "scripts\Publish-OutreachPack.ps1",
  "_copayload.meta.json",
  "_wrap.manifest.json"
)
$missing = @()
foreach($rel in $expected){
  if(!(Test-Path (Join-Path $Path $rel))){ $missing += $rel }
}
if($missing.Count -gt 0){
  Write-Error ("Missing required files:`n - " + ($missing -join "`n - "))
}
else {
  Write-Host "Shape OK."
}
# Compute top-level file checksums (non-recursive listing for audit)
Get-ChildItem -Path $Path -File | ForEach-Object {
  $h = Get-FileHash -Path $_.FullName -Algorithm SHA256
  "{0}  {1}" -f $h.Hash.ToLowerInvariant(), $_.Name
}
