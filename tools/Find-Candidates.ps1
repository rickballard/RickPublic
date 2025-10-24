#requires -version 7
param(
  [int]$Top = 6,
  [switch]$OpenGmail
)
$ErrorActionPreference = "Stop"

function Try-Json([string]$s){ try { $s | ConvertFrom-Json } catch { $null } }

# --- paths & config
$RepoRoot = Join-Path $HOME "Documents\GitHub\RickPublic"
$CandDir  = Join-Path $RepoRoot "candidates"
$Outbox   = Join-Path $RepoRoot "outbox"
New-Item -Force -ItemType Directory $CandDir,$Outbox | Out-Null
$CfgPath  = Join-Path $RepoRoot "tools\candidates.config.json"

# defaults
$MaxAgeDays     = 30
$MinDurationSec = 600
$MaxDurationSec = 3600
$Queries        = @(
  "AI policy talk 2025",
  "governance speech 2025",
  "economics lecture 2025",
  "institutional design seminar 2025"
)
if (Test-Path $CfgPath) {
  $cfg = Get-Content $CfgPath -Raw | ConvertFrom-Json
  if ($cfg.maxAgeDays)     {$MaxAgeDays     = [int]$cfg.maxAgeDays}
  if ($cfg.minDurationSec) {$MinDurationSec = [int]$cfg.minDurationSec}
  if ($cfg.maxDurationSec) {$MaxDurationSec = [int]$cfg.maxDurationSec}
  if ($cfg.queries)        {$Queries        = @($cfg.queries)}
}

# yt-dlp presence
& yt-dlp -U > $null 2>&1; if ($LASTEXITCODE -eq 9009) {
  throw "yt-dlp not found in PATH. Install from https://github.com/yt-dlp/yt-dlp."
}

# --- collect search hits (robust)
$raw = New-Object System.Collections.Generic.List[object]
foreach ($q in $Queries) {
  $lines = & yt-dlp -j --no-warnings --dateafter "now-$MaxAgeDays" "ytsearch15:$q" 2>$null
  foreach ($line in $lines) {
    if (-not $line) { continue }
    $j = Try-Json $line; if (-not $j) { continue }
    if ($j._type -eq 'playlist') { continue }
    $dur = [int]($j.duration ?? 0)
    if ($dur -lt $MinDurationSec -or $dur -gt $MaxDurationSec) { continue }
    $date = $null
    if ($j.upload_date) { $date = [datetime]::ParseExact($j.upload_date,'yyyyMMdd',$null) }
    $rec = if ($date) { (New-TimeSpan -Start $date -End (Get-Date)).Days } else { 999 }
    $url = $j.webpage_url; $title = $j.title
    if ([string]::IsNullOrWhiteSpace($url) -or [string]::IsNullOrWhiteSpace($title)) { continue }
    $raw.Add([pscustomobject]@{
      title        = $title
      url          = $url
      duration     = $dur
      date         = $date
      channel      = $j.channel
      view_count   = $j.view_count
      recency      = $rec
      hasTranscript= $false
      score        = 0
    })
  }
}

# bail gently if zero
if ($raw.Count -eq 0) {
  $month    = (Get-Date).ToString('yyyy-MM')
  $candFile = Join-Path $CandDir "$month.md"
  if (-not (Test-Path $candFile)) {
@"
# Candidates — $month

| Title | Link | Why it’s worth our time | Status |
|---|---|---|---|
"@ | Set-Content -Encoding UTF8 $candFile
  }
  Write-Host "No results found (queries too strict or yt-dlp blocked). Updated/ensured: $candFile"
  return
}

# dedupe by URL (lowercase)
$seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$cands = foreach ($r in $raw) { if ($seen.Add($r.url)) { $r } }

# probe transcript availability for freshest dozen
foreach ($r in ($cands | Where-Object { $_ } | Sort-Object recency | Select-Object -First 12)) {
  $info = (& yt-dlp -j --no-warnings $r.url 2>$null | Select-Object -First 1) | Try-Json
  if ($info) {
    $hasEn = $false
    if ($info.subtitles)           { $hasEn = $info.subtitles.PSObject.Properties.Name -contains 'en' }
    if (-not $hasEn -and $info.automatic_captions) {
      $hasEn = $info.automatic_captions.PSObject.Properties.Name -contains 'en'
    }
    $r.hasTranscript = [bool]$hasEn
  }
}

# score robustly
foreach ($r in ($cands | Where-Object { $_ })) {
  $s = 0
  if ($r.recency -lt 31) { $s += (31 - $r.recency) }
  $mid = [math]::Abs(([int]$r.duration) - 1800)
  $s += [math]::Max(0, 20 - [int]($mid/120))
  if ($r.hasTranscript) { $s += 20 }
  if ($r.view_count) { $s += [math]::Min(15, [math]::Floor([math]::Log10([double]$r.view_count + 1) * 5)) }
  $r.score = $s
}

$top = $cands | Where-Object { $_ } | Sort-Object score -Descending | Select-Object -First $Top

# write/append candidates file
$month    = (Get-Date).ToString('yyyy-MM')
$candFile = Join-Path $CandDir "$month.md"
if (-not (Test-Path $candFile)) {
@"
# Candidates — $month

| Title | Link | Why it’s worth our time | Status |
|---|---|---|---|
"@ | Set-Content -Encoding UTF8 $candFile
}
$existing = Get-Content $candFile -Raw
foreach ($r in $top) {
  if (-not $r) { continue }
  if ($existing -notmatch [regex]::Escape($r.url)) {
    $mins = [math]::Floor([int]$r.duration/60)
    $why  = "Recent; $mins min; transcript " + ($(if($r.hasTranscript){"✅"}else{"❓"}))
    Add-Content -Encoding UTF8 $candFile ("| {0} | {1} | {2} | Proposed |" -f $r.title, $r.url, $why)
  }
}

# email draft (2 repost + 1 learn) — guard for small sets
$today     = (Get-Date).ToString('yyyy-MM-dd')
$emailPath = Join-Path $Outbox "$today-repost-learn.txt"
$reposts   = $top | Sort-Object duration -Descending | Select-Object -First 2 | Where-Object { $_ }
$learn     = ($top | Sort-Object duration | Select-Object -First 1 | Where-Object { $_ })

$Lines = New-Object System.Collections.Generic.List[string]
$Lines.Add("Repost/Learn picks — $today`r`n")
$Lines.Add("Repost candidates:")
if ($reposts.Count -ge 1) {
  $Lines.Add(("1) {0} — {1} min" -f $reposts[0].title, [math]::Floor([int]$reposts[0].duration/60)))
  $Lines.Add("   " + $reposts[0].url)
  $Lines.Add("   Why: recent; transcript " + ($(if($reposts[0].hasTranscript){"available"}else{"unknown"})))
  $Lines.Add("")
}
if ($reposts.Count -ge 2) {
  $Lines.Add(("2) {0} — {1} min" -f $reposts[1].title, [math]::Floor([int]$reposts[1].duration/60)))
  $Lines.Add("   " + $reposts[1].url)
  $Lines.Add("   Why: recent; transcript " + ($(if($reposts[1].hasTranscript){"available"}else{"unknown"})))
  $Lines.Add("")
}
$Lines.Add("Learn pick:")
if ($learn) {
  $Lines.Add(("• {0} — {1} min" -f $learn.title, [math]::Floor([int]$learn.duration/60)))
  $Lines.Add("  " + $learn.url)
} else {
  $Lines.Add("• (none this run)")
}
$Lines.Add("")
$Lines.Add("(Full list: candidates/$((Get-Date).ToString('yyyy-MM')).md in RickPublic)")
$Lines -join "`r`n" | Set-Content -Encoding UTF8 $emailPath

if ($OpenGmail) {
  function UrlEncode([string]$s){ [uri]::EscapeDataString($s) }
  $su = "Repost/Learn picks — $today"
  $bo = Get-Content $emailPath -Raw
  $url = "https://mail.google.com/mail/?view=cm&fs=1&to=richardmballard@gmail.com&su=$(UrlEncode($su))&body=$(UrlEncode($bo))"
  Start-Process $url
}

Write-Host "Updated: $candFile"
Write-Host "Draft email: $emailPath"
