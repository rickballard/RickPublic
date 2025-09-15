param(
  [Parameter(Mandatory=$true)][string]$In,
  [Parameter(Mandatory=$true)][string]$Out
)

$ErrorActionPreference = "Stop"

# Load weights
$weightsPath = Join-Path $PSScriptRoot 'weights.yml'
$w = ConvertFrom-Yaml (Get-Content $weightsPath -Raw)

# Read CSV
$rows = Import-Csv -Path $In

# Simple composite: invert resilience; combine with exploitation + (optional) populism proxy
# Here we treat crisis_exploitation as the proxy for "populism" if no explicit column exists.
$scored = foreach ($r in $rows) {
  $inst_res = [double]$r.inst_resilience
  $crx      = [double]$r.crisis_exploitation

  $cpi_inv   = (1.0 - $inst_res)              # weaker institutions → higher corruption risk proxy
  $press_inv = (1.0 - $inst_res) * 0.5        # placeholder if no press index present
  $populism  = $crx                           # use crisis_exploitation as proxy

  $dd = $w.cpi_inv * $cpi_inv + $w.press_inv * $press_inv + $w.populism * $populism

  [pscustomobject]@{
    country              = $r.country
    inst_resilience      = $inst_res
    crisis_exploitation  = $crx
    pop_or_gdp           = $r.pop_or_gdp
    dd_risk              = [math]::Round([double]$dd, 4)
  }
}

$scored | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $Out
Write-Host "Wrote $Out"
