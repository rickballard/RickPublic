param(
  [string]$RickPublic = "$HOME\Documents\GitHub\RickPublic"
)
$ErrorActionPreference = 'Stop'
$utc = (Get-Date).ToUniversalTime().ToString('yyyyMMdd_HHmmssZ')
$notesDir = Join-Path $RickPublic "docs/intent/outreach/notes"
if (-not (Test-Path $notesDir)) { New-Item -ItemType Directory -Path $notesDir | Out-Null }
$note = Join-Path $notesDir ("Outreach_Note_" + $utc + ".md")

$tpl = @"
# Outreach Note — $utc

## Today’s targets
- [ ]

## Assets touched
- 

## Decisions & next
- 

## Checklist (paste-friendly)
- [ ] Define target(s) + why now
- [ ] Map pillar → ask
- [ ] Draft copy
- [ ] Attach asset
- [ ] Open tracking issue
- [ ] Record outcomes

"@

$tpl | Set-Content -Path $note -Encoding utf8
Write-Host "Created $note"
