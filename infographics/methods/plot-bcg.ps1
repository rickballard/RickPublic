param(
  [string]$In  = ".\infographics\matrices\scored.csv",
  [string]$Out = ".\infographics\matrices\bcg.png"
)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
$rows = Import-Csv -Path $In

# Bigger canvas
$w=2400;$h=1800
$bmp = New-Object System.Drawing.Bitmap($w,$h)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.FillRectangle([System.Drawing.Brushes]::White,0,0,$w,$h)

$pad=160
$x0=$pad;$y0=$pad;$x1=$w-$pad;$y1=$h-$pad

# Thicker axes
$pen  = New-Object System.Drawing.Pen([System.Drawing.Color]::Black,4)
$g.DrawLine($pen,$x0,$y1,$x1,$y1)
$g.DrawLine($pen,$x0,$y1,$x0,$y0)

# Larger fonts
$axis  = New-Object System.Drawing.Font("Segoe UI",28,[System.Drawing.FontStyle]::Regular)
$ticks = New-Object System.Drawing.Font("Segoe UI",22)
$label = New-Object System.Drawing.Font("Segoe UI",24,[System.Drawing.FontStyle]::Bold)
$title = New-Object System.Drawing.Font("Segoe UI",44,[System.Drawing.FontStyle]::Bold)
$brush = [System.Drawing.Brushes]::Black

$g.DrawString("Institutional Resilience (weak → strong)",$axis,$brush,($w/2-520),$h-$pad+60)
$g.DrawString("Crisis Exploitation (low → high)",       $axis,$brush,0,$y0-100)

# Ticks
for($i=0;$i -le 10;$i++){
  $t=$i/10
  $x=[int]($x0 + $t*($x1-$x0))
  $y=[int]($y1 - $t*($y1-$y0))
  $g.DrawLine($pen,$x,$y1,$x,$y1+12)
  $g.DrawString(("{0:n1}" -f $t),$ticks,$brush,$x-26,$y1+16)
  $g.DrawLine($pen,$x0-12,$y,$x0,$y)
  $g.DrawString(("{0:n1}" -f $t),$ticks,$brush,$x0-62,$y-16)
}

# Midlines
$dash = New-Object System.Drawing.Pen([System.Drawing.Color]::Gray,3)
$dash.DashStyle = 'Dash'
$midX=[int]($x0+0.5*($x1-$x0)); $midY=[int]($y1-0.5*($y1-$y0))
$g.DrawLine($dash,$midX,$y0,$midX,$y1)
$g.DrawLine($dash,$x0,$midY,$x1,$midY)

# Bigger bubbles (population)
$minSize=36;$maxSize=120
$vals = ($rows | ForEach-Object{ [double]($_.pop_or_gdp) })
$min=[math]::Max(1.0, ($vals | Measure-Object -Minimum).Minimum)
$max=[math]::Max($min+1.0, ($vals | Measure-Object -Maximum).Maximum)

foreach($r in $rows){
  $xr=[double]$r.inst_resilience
  $yr=[double]$r.crisis_exploitation
  $sz=[double]$r.pop_or_gdp
  $x=[int]($x0 + $xr*($x1-$x0))
  $y=[int]($y1 - $yr*($y1-$y0))
  $rad=[int]($minSize + ($sz-$min)/($max-$min) * ($maxSize-$minSize))
  $rect = New-Object System.Drawing.Rectangle(($x-$rad/2),($y-$rad/2),$rad,$rad)
  $fill = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(110,0,0,0))
  $g.FillEllipse($fill,$rect)
  $g.DrawEllipse($pen,$rect)
  $g.DrawString($r.country,$label,$brush,($x+$rad/2+8),($y-$rad/2-8))
}

$g.DrawString("DonDemogog — BCG-style Risk Map",$title,$brush,($w/2-560),50)

$bmp.Save($Out,[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$bmp.Dispose()
Write-Host "Wrote $Out"
