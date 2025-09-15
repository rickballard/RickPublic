param(
  [Parameter(Mandatory=$true)][string]$In,
  [Parameter(Mandatory=$true)][string]$Out
)

$ErrorActionPreference = "Stop"

# --- Load weights (JSON or defaults) ---
$wPath = Join-Path $PSScriptRoot 'weights.json'
if (Test-Path $wPath) {
  $w = Get-Content $wPath -Raw | ConvertFrom-Json
} else {
  $w = [pscustomobject]@{ cpi_inv=0.4; press_inv=0.3; populism=0.3 }
}

# --- Read input CSV ---
$rows = Import-Csv -Path $In

# --- Score ---
$scored = foreach ($r in $rows) {
  $inst_res = [double]$r.inst_resilience
  $crx      = [double]$r.crisis_exploitation

  # Proxies (until we wire real indices):
  $cpi_inv   = (1.0 - $inst_res)        # weaker institutions → higher corruption risk proxy
  $press_inv = (1.0 - $inst_res) * 0.5  # placeholder proxy
  $populism  = $crx                      # crisis exploitation as proxy

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
