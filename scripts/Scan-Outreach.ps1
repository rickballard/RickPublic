param(
  [string[]]$Targets = @(
    "$HOME\Documents\GitHub\CoCache",
    "$HOME\Documents\GitHub\RickPublic",
    "$HOME\Documents\GitHub\CoCivium",
    "$HOME\Documents\GitHub\CoPolitic"
  ),
  [string]$RickPublic = "$HOME\Documents\GitHub\RickPublic"
)

$ErrorActionPreference = 'Stop'

# Expand the concept lexicon beyond "outreach"
$Concepts = @(
  # core
  'outreach','marketing','comms','communication','campaign','promotion',
  'substack','newsletter','email','mailing list','drip','crm',
  'social','twitter','x','linkedin','youtube','podcast',
  'website','web site','landing','home page','docs site','github pages',
  'partner','sponsor','donation','funding','grant',
  'press','media','PR','public relations','announcement','launch',
  'coarena','repozipper','copilot','agent','pilot','case study',
  'guardrails','explain','undo','rollback','audit','compliance',
  # intent/ICPs
  'gov','civic','university','lab','regulator','nonprofit','philanthropy'
)

$exts = @('*.md','*.txt','*.json','*.yml','*.yaml')

$rows = @()

foreach ($t in $Targets) {
  if (-not (Test-Path $t)) { continue }
  $files = Get-ChildItem -Path $t -Recurse -File -Include $exts -ErrorAction SilentlyContinue
  foreach ($f in $files) {
    try {
      $text = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction Stop
    } catch { continue }
    $hitConcepts = @()
    foreach ($c in $Concepts) {
      if ($text -match [regex]::Escape($c)) { $hitConcepts += $c }
    }
    if ($hitConcepts.Count -gt 0) {
      $rows += [PSCustomObject]@{
        Repo   = (Split-Path $t -Leaf)
        Path   = $f.FullName
        Size   = $f.Length
        Updated= $f.LastWriteTimeUtc
        Tags   = ($hitConcepts | Sort-Object -Unique) -join ', '
      }
    }
  }
}

$rows = $rows | Sort-Object Updated -Descending

# Write index into RickPublic
$idxDir = Join-Path $RickPublic "docs/intent/outreach/indexes"
if (-not (Test-Path $idxDir)) { New-Item -ItemType Directory -Path $idxDir | Out-Null }
$stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMdd_HHmmssZ')
$md = Join-Path $idxDir ("OUTREACH_INTENT_INDEX_" + $stamp + ".md")

$header = @"
# Outreach/Marketing Intent Index — $stamp

This file is auto-generated from multiple repos using a broad lexicon (outreach, marketing, comms, social, substack, website, pilots, products, etc.).
Entries are sorted by **last updated**.

| Repo | Updated (UTC) | Tags | Path |
|------|---------------|------|------|
"@

$lines = foreach ($r in $rows) {
  $rp = $r.Path -replace [regex]::Escape("$HOME\Documents\GitHub\"), ''
  "| {0} | {1:u} | {2} | {3} |" -f $r.Repo, $r.Updated.ToUniversalTime(), $r.Tags, $rp
}

$header + ($lines -join "`n") | Set-Content -Path $md -Encoding utf8

Write-Host "Index written → $md"
