param(
  [string]$In  = ".\infographics\matrices\scored.csv",
  [string]$Out = ".\infographics\matrices\bcg.png"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
$rows = Import-Csv -Path $In

# Big canvas; tighter padding to reduce whitespace
$w=3200; $h=2200
$pad=110
$bmp = New-Object System.Drawing.Bitmap($w,$h)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = 'AntiAlias'
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.FillRectangle([System.Drawing.Brushes]::White,0,0,$w,$h)

$x0=$pad; $y0=$pad; $x1=$w-$pad; $y1=$h-$pad

# Axes
$axisPen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black,6)
$g.DrawLine($axisPen,$x0,$y1,$x1,$y1)
$g.DrawLine($axisPen,$x0,$y1,$x0,$y0)

# Fonts (big)
$axis  = New-Object System.Drawing.Font("Segoe UI",42,[System.Drawing.FontStyle]::Regular)
$ticks = New-Object System.Drawing.Font("Segoe UI",34)
$label = New-Object System.Drawing.Font("Segoe UI",38,[System.Drawing.FontStyle]::Bold)
$title = New-Object System.Drawing.Font("Segoe UI",66,[System.Drawing.FontStyle]::Bold)
$brush = [System.Drawing.Brushes]::Black
$dim   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190,0,0,0))

# Axis labels
$g.DrawString("Institutional Resilience (weak → strong)",$axis,$brush,($w/2-850),$h-$pad+70)
$g.DrawString("Crisis Exploitation (low → high)",       $axis,$brush,0,$y0-120)

# Ticks
for($i=0;$i -le 10;$i++){
  $t=$i/10
  $x=[int]($x0 + $t*($x1-$x0))
  $y=[int]($y1 - $t*($y1-$y0))
  $g.DrawLine($axisPen,$x,$y1,$x,$y1+18)
  $g.DrawString(("{0:n1}" -f $t),$ticks,$dim,$x-34,$y1+24)
  $g.DrawLine($axisPen,$x0-18,$y,$x0,$y)
  $g.DrawString(("{0:n1}" -f $t),$ticks,$dim,$x0-80,$y-22)
}

# Midlines
$dash = New-Object System.Drawing.Pen([System.Drawing.Color]::Gray,4)
$dash.DashStyle='Dash'
$midX=[int]($x0+0.5*($x1-$x0)); $midY=[int]($y1-0.5*($y1-$y0))
$g.DrawLine($dash,$midX,$y0,$midX,$y1)
$g.DrawLine($dash,$x0,$midY,$x1,$midY)

# Bubbles: scale UP (relative preserved)
$minSize=110; $maxSize=340
$vals = ($rows | ForEach-Object{ [double]($_.pop_or_gdp) })
$min=[math]::Max(1.0, ($vals | Measure-Object -Minimum).Minimum)
$max=[math]::Max($min+1.0, ($vals | Measure-Object -Maximum).Maximum)
$bOutline = New-Object System.Drawing.Pen([System.Drawing.Color]::Black,6)

foreach($r in $rows){
  $xr=[double]$r.inst_resilience
  $yr=[double]$r.crisis_exploitation
  $sz=[double]$r.pop_or_gdp
  $x=[int]($x0 + $xr*($x1-$x0))
  $y=[int]($y1 - $yr*($y1-$y0))
  $rad=[int]($minSize + ($sz-$min)/($max-$min) * ($maxSize-$minSize))
  $rect = New-Object System.Drawing.Rectangle(($x-$rad/2),($y-$rad/2),$rad,$rad)
  $fill = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120,0,0,0))
  $g.FillEllipse($fill,$rect)
  $g.DrawEllipse($bOutline,$rect)

  # White label chip (int rectangle)
  $txt  = $r.country
  $size = $g.MeasureString($txt,$label)
  $chipX = [int]($x + $rad/2 + 14)
  $chipY = [int]($y - $rad/2 - 14)
  $chipW = [int]($size.Width + 26)
  $chipH = [int]($size.Height + 16)
  $chip   = New-Object System.Drawing.Rectangle($chipX, $chipY, $chipW, $chipH)
  $chipBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(242,255,255,255))
  $g.FillRectangle($chipBg, $chip)
  $g.DrawString($txt, $label, $brush, $chipX + 10, $chipY + 6)
}

# Title
$g.DrawString("DonDemogog — BCG-style Risk Map",$title,$brush,($w/2-900),70)

$bmp.Save($Out,[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
