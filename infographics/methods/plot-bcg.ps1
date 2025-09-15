param(
  [string]$In  = ".\infographics\matrices\scored.csv",
  [string]$Out = ".\infographics\matrices\bcg.png"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
$rows = Import-Csv -Path $In

$w=1000;$h=800
$bmp = New-Object System.Drawing.Bitmap($w,$h)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.FillRectangle([System.Drawing.Brushes]::White,0,0,$w,$h)

$pad=90
$x0=$pad;$y0=$pad;$x1=$w-$pad;$y1=$h-$pad

$pen  = New-Object System.Drawing.Pen([System.Drawing.Color]::Black,2)
$g.DrawLine($pen,$x0,$y1,$x1,$y1) # X
$g.DrawLine($pen,$x0,$y1,$x0,$y0) # Y

$font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Regular)
$small= New-Object System.Drawing.Font("Segoe UI",10)
$brush= [System.Drawing.Brushes]::Black
$g.DrawString("Institutional Resilience (weak → strong)",$font,$brush,($w/2-200),$h-$pad+30)
$g.DrawString("Crisis Exploitation (low → high)", $font,$brush,0,$y0-60)

for($i=0;$i -le 10;$i++){
  $t=$i/10
  $x=[int]($x0 + $t*($x1-$x0))
  $y=[int]($y1 - $t*($y1-$y0))
  $g.DrawLine($pen,$x,$y1,$x,$y1+5)
  $g.DrawString(("{0:n1}" -f $t),$small,$brush,$x-10,$y1+8)
  $g.DrawLine($pen,$x0-5,$y,$x0,$y)
  $g.DrawString(("{0:n1}" -f $t),$small,$brush,$x0-35,$y-7)
}

$dash = New-Object System.Drawing.Pen([System.Drawing.Color]::Gray,1)
$dash.DashStyle = 'Dash'
$midX=[int]($x0+0.5*($x1-$x0)); $midY=[int]($y1-0.5*($y1-$y0))
$g.DrawLine($dash,$midX,$y0,$midX,$y1)
$g.DrawLine($dash,$x0,$midY,$x1,$midY)

$minSize=8;$maxSize=40
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
  $fill = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(64,0,0,0))
  $g.FillEllipse($fill,$rect)
  $g.DrawEllipse($pen,$rect)
  $g.DrawString($r.country,$small,$brush,($x+$rad/2+4),($y-$rad/2-4))
}

$title = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$g.DrawString("DonDemogog — BCG-style Risk Map",$title,$brush,($w/2-220),20)

$bmp.Save($Out,[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$bmp.Dispose()
Write-Host "Wrote $Out"
