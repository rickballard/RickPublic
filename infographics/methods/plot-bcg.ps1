param(
  [string]$In  = ".\infographics\matrices\scored.csv",
  [string]$Out = ".\infographics\matrices\bcg.png"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
$rows = Import-Csv -Path $In

# Big canvas; extra bottom space for x-axis label
$w=3400; $h=2300
$padL=140; $padR=140; $padTop=140; $padBot=260
$x0=$padL; $y0=$padTop; $x1=$w-$padR; $y1=$h-$padBot

$bmp = New-Object System.Drawing.Bitmap($w,$h)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = 'AntiAlias'
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.FillRectangle([System.Drawing.Brushes]::White,0,0,$w,$h)

# Pens & fonts
$axisPen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black,6)
$g.DrawLine($axisPen,$x0,$y1,$x1,$y1)
$g.DrawLine($axisPen,$x0,$y1,$x0,$y0)

$axis  = New-Object System.Drawing.Font("Segoe UI",44,[System.Drawing.FontStyle]::Regular)
$ticks = New-Object System.Drawing.Font("Segoe UI",36)
$label = New-Object System.Drawing.Font("Segoe UI",40,[System.Drawing.FontStyle]::Bold)
$title = New-Object System.Drawing.Font("Segoe UI",70,[System.Drawing.FontStyle]::Bold)
$brush = [System.Drawing.Brushes]::Black
$dim   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190,0,0,0))

# Axis labels
$g.DrawString("Institutional Resilience (weak → strong)",$axis,$brush,($w/2-900),$h-$padBot+90)
$g.DrawString("Crisis Exploitation (low → high)",       $axis,$brush,0,$y0-120)

# Ticks
for($i=0;$i -le 10;$i++){
  $t=$i/10
  $x=[int]($x0 + $t*($x1-$x0))
  $y=[int]($y1 - $t*($y1-$y0))
  $g.DrawLine($axisPen,$x,$y1,$x,$y1+20)
  $g.DrawString(("{0:n1}" -f $t),$ticks,$dim,$x-34,$y1+24)
  $g.DrawLine($axisPen,$x0-20,$y,$x0,$y)
  $g.DrawString(("{0:n1}" -f $t),$ticks,$dim,$x0-82,$y-22)
}

# Midlines
$dash = New-Object System.Drawing.Pen([System.Drawing.Color]::Gray,4); $dash.DashStyle='Dash'
$midX=[int]($x0+0.5*($x1-$x0)); $midY=[int]($y1-0.5*($y1-$y0))
$g.DrawLine($dash,$midX,$y0,$midX,$y1)
$g.DrawLine($dash,$x0,$midY,$x1,$midY)

# Bubble scale (population)
$minSize=120; $maxSize=360
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

  # bubble
  $rect = New-Object System.Drawing.Rectangle(($x-$rad/2),($y-$rad/2),$rad,$rad)
  $fill = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120,0,0,0))
  $g.FillEllipse($fill,$rect); $g.DrawEllipse($bOutline,$rect)

  # dynamic label placement (left/right + leader line)
  $txt  = $r.country
  $size = $g.MeasureString($txt,$label)
  $edgeOffset = [int]($rad/2 + 26)   # push label away from bubble
  $side = if ($xr - 0.5 - ($yr-0.5)/6 - (($x1-$x)/($x1-$x0)) * 0.0 - (($x-$x0)/($x1-$x0))*0.0 - 0) { $xr -gt 0.6 } else { $false }
  # prefer left for dense cluster (xr between 0.48..0.62): alternate by name hash
  if ($xr -gt 0.48 -and $xr -lt 0.62) { if ([Math]::Abs(($txt.GetHashCode()) % 2) -eq 1) { $side = $false } }

  if ($side) {
    # place to LEFT of bubble
    $chipW=[int]($size.Width + 28); $chipH=[int]($size.Height + 18)
    $chipX=[int]($x - $rad/2 - 14 - $chipW); $chipY=[int]($y - $rad/2 - 14)
    $g.DrawLine($bOutline, $x-($rad/2), $y, $x-($rad/2)-($edgeOffset-10), $y)
  } else {
    # place to RIGHT of bubble
    $chipW=[int]($size.Width + 28); $chipH=[int]($size.Height + 18)
    $chipX=[int]($x + $rad/2 + 14); $chipY=[int]($y - $rad/2 - 14)
    $g.DrawLine($bOutline, $x+($rad/2), $y, $x+($rad/2)+($edgeOffset-10), $y)
  }

  # keep inside canvas vertically
  if ($chipY -lt ($y0+8)) { $chipY = $y0+8 }
  if ($chipY+$chipH -gt ($y1-8)) { $chipY = $y1-8-$chipH }

  # draw chip + text
  $chip   = New-Object System.Drawing.Rectangle($chipX, $chipY, $chipW, $chipH)
  $chipBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(242,255,255,255))
  $g.FillRectangle($chipBg, $chip)
  $g.DrawString($txt, $label, $brush, $chipX + 10, $chipY + 6)
}

# Title
$g.DrawString("DonDemogog — BCG-style Risk Map",$title,$brush,($w/2-920),40)

$bmp.Save($Out,[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
