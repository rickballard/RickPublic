param(
  [string[]]$Targets = @(
    "$HOME\Documents\GitHub\CoCache",
    "$HOME\Documents\GitHub\RickPublic",
    "$HOME\Documents\GitHub\CoCivium",
    "$HOME\Documents\GitHub\CoPolitic"
  ),
  [string]$RickPublic = "$HOME\Documents\GitHub\RickPublic",
  [string[]]$ExcludeDirs = @('.git','node_modules','dist','build','.venv','.vscode','.idea')
)

$ErrorActionPreference = 'Stop'

# --- Taxonomy (category -> synonyms/phrases) ---
$Taxonomy = @{
  "Email"            = @('email','gmail','mailing list','mailchimp','drip','newsletter','bcc','sequence')
  "Substack"         = @('substack','newsletter platform','publication','post','draft')
  "Social"           = @('social','twitter','x','linkedin','youtube','shorts','podcast','mastodon','bluesky')
  "Website"          = @('website','web site','landing','home page','docs site','github pages','jekyll','hugo','eleventy')
  "Launch/Pilot"     = @('announcement','launch','pilot','case study','press','media','PR','public relations','pressroom','press room','press kit')
  "Product"          = @('coarena','repozipper','copilot','agent','demo','readme','quickstart','walkthrough')
  "Funding/Partners" = @('partner','sponsor','donation','funding','grant','stripe','pledge','patreon')
  "Comms/Strategy"   = @('outreach','marketing','comms','campaign','promotion','positioning','messaging','content calendar')
  "Guardrails"       = @('guardrails','explain','undo','rollback','audit','compliance','objection window','evidence trail')
  "ICPs"             = @('gov','civic','university','lab','regulator','nonprofit','philanthropy','municipal',' ministry ')
}

$exts = @('*.md','*.txt','*.json','*.yml','*.yaml','*.csv')

function Should-SkipPath($path) {
  foreach ($d in $ExcludeDirs) {
    if ($path -match [regex]::Escape("\$d\")) { return $true }
    if ($path -match [regex]::Escape("/$d/")) { return $true }
  }
  return $false
}

$rows = @()

foreach ($t in $Targets) {
  if (-not (Test-Path $t)) { continue }
  $files = Get-ChildItem -Path $t -Recurse -File -Include $exts -ErrorAction SilentlyContinue
  foreach ($f in $files) {
    if (Should-SkipPath $f.FullName) { continue }
    try { $text = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction Stop } catch { continue }

    # --- Array-based collectors (no .ToArray()) ---
    $hitConcepts = @()
    $hitCats     = @()

    foreach ($cat in $Taxonomy.Keys) {
      foreach ($syn in $Taxonomy[$cat]) {
        if ($null -ne $syn -and ($text -match [regex]::Escape($syn))) {
          $hitCats     += $cat
          $hitConcepts += ($syn.Trim())
        }
      }
    }

    if ($hitCats.Count -gt 0) {
      $tags = ($hitConcepts | Where-Object { $_ -and $_.Trim() -ne '' } | Sort-Object -Unique)
      $cats = ($hitCats     | Where-Object { $_ -and $_.Trim() -ne '' } | Sort-Object -Unique)

      $rows += [PSCustomObject]@{
        Repo       = (Split-Path $t -Leaf)
        Path       = $f.FullName
        Size       = $f.Length
        Updated    = $f.LastWriteTimeUtc
        Tags       = ($tags -join ', ')
        Categories = ($cats -join ', ')
      }
    }
  }
}

$rows = $rows | Sort-Object Updated -Descending

# Write index
$idxDir = Join-Path $RickPublic "docs/intent/outreach/indexes"
if (-not (Test-Path $idxDir)) { New-Item -ItemType Directory -Path $idxDir | Out-Null }
$stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMdd_HHmmssZ')
$md = Join-Path $idxDir ("OUTREACH_INTENT_INDEX_" + $stamp + ".md")

$header = @"
# Outreach/Marketing Intent Index — $stamp

Sorted by **last updated**. Auto-categorized via taxonomy.

| Repo | Updated (UTC) | Categories | Tags | Path |
|------|---------------|-----------|------|------|
"@

$lines = foreach ($r in $rows) {
  $rp = $r.Path -replace [regex]::Escape("$HOME\Documents\GitHub\"), ''
  "| {0} | {1:u} | {2} | {3} | {4} |" -f $r.Repo, $r.Updated.ToUniversalTime(), $r.Categories, $r.Tags, $rp
}

$header + ($lines -join "`n") | Set-Content -Path $md -Encoding utf8
Write-Host "Index written → $md"
