#requires -version 7
param(
  [Parameter(Mandatory)][string]$PostMd,
  [Parameter(Mandatory)][string]$SrtPath,
  [int]$Top = 6,
  [int]$MinChars = 30,
  [switch]$Dedupe,
  [int]$MergeGapSec = 2
)
$ErrorActionPreference = "Stop"

function Get-FirstWords {
  param([string]$Text,[int]$N = 3)
  if (-not $Text) { return "" }
  $parts = $Text -split '\s+'
  $take  = [Math]::Min($N, $parts.Count)
  return ($parts[0..($take-1)] -join ' ')
}

$srtText = Get-Content -LiteralPath $SrtPath -Raw

$blocks = $srtText -split "(?ms)^\s*\d+\s*\r?\n" |
          Where-Object { $_ -match "^\d{2}:\d{2}:\d{2},\d{3}\s-->\s" }

$rows = foreach($b in $blocks){
  $lines = $b -split "\r?\n" | Where-Object { $_.Trim() -ne "" }
  if ($lines[0] -match "^(?<h>\d{2}):(?<m>\d{2}):(?<s>\d{2}),(?<ms>\d{3})") {
    $mm   = [int]$Matches['m']
    $ss   = [int]$Matches['s']
    $stamp= "{0:00}:{1:00}" -f $mm,$ss
    $text = ($lines[1..($lines.Count-1)] -join " ") -replace "\s+", " "
    [pscustomobject]@{ t=$stamp; s=[int]($mm*60+$ss); text=$text.Trim() }
  }
}

$rows = $rows | Where-Object { $_.text.Length -ge $MinChars }

if ($Dedupe) {
  $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
  $rows = foreach($r in $rows){ if ($seen.Add(($r.text -replace '\W',''))) { $r } }
}

if ($MergeGapSec -gt 0) {
  $merged = New-Object System.Collections.Generic.List[object]
  foreach($r in ($rows | Sort-Object s)) {
    if ($merged.Count -gt 0) {
      $last = $merged[$merged.Count-1]
      $samePrefix = (Get-FirstWords $r.text 3) -eq (Get-FirstWords $last.text 3)
      if ( ($r.s - $last.s) -le $MergeGapSec -and $samePrefix ) {
        $last.text += " " + $r.text
        continue
      }
    }
    $merged.Add([pscustomobject]@{ t=$r.t; s=$r.s; text=$r.text })
  }
  $rows = $merged
}

$newBul   = $rows | Select-Object -First $Top | ForEach-Object { "- **[$($_.t)]** $($_.text)" }
$bulBlock = ($newBul -join "`r`n")

$md  = Get-Content -LiteralPath $PostMd -Raw
$md2 = [regex]::Replace($md, '(?ms)(^##\s*2\)\s*What we heard.*?\r?\n)(?:- .+?\r?\n)+', "`$1" + $bulBlock + "`r`n")
if ($md2 -eq $md) {
  $md2 = [regex]::Replace($md, '(^##\s*2\)\s*What we heard[^\r\n]*\r?\n)', "`$1" + $bulBlock + "`r`n")
}
Set-Content -Encoding UTF8 -Path $PostMd -Value $md2
Write-Host ("Inserted {0} bullets into {1}" -f $newBul.Count, $PostMd)
