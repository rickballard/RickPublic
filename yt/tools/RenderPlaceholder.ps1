# YT_EpPlaceholder_Render.ps1
param(
  [string]$RepoRoot = "$HOME\Documents\GitHub\RickPublic",
  [string]$EpisodeId = "EP-0001",
  [int]$W = 1920,
  [int]$H = 1080
)
$ErrorActionPreference='Stop'; Set-StrictMode -Version Latest
function UTS { (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ') }

if(!(Test-Path $RepoRoot)){ try { gh repo clone rickballard/RickPublic $RepoRoot | Out-Null } catch {} }
try { git -C $RepoRoot fetch origin *> $null; try { git -C $RepoRoot switch main *> $null } catch {}; git -C $RepoRoot pull --ff-only *> $null } catch {}

$OutDir   = Join-Path $RepoRoot "yt/out";    New-Item -ItemType Directory -Force $OutDir   | Out-Null
$AssetDir = Join-Path $RepoRoot "yt/assets"; New-Item -ItemType Directory -Force $AssetDir | Out-Null
$BgDir    = Join-Path $AssetDir "bg";        New-Item -ItemType Directory -Force $BgDir    | Out-Null

$bgPng = Join-Path $BgDir "gradient.png"
Add-Type -AssemblyName System.Drawing
if(!(Test-Path $bgPng)){
  $bmp = New-Object System.Drawing.Bitmap($W,$H)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $rect = New-Object System.Drawing.Rectangle(0,0,$W,$H)
  $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect,[System.Drawing.Color]::FromArgb(18,18,28),[System.Drawing.Color]::FromArgb(34,34,64),90)
  $g.FillRectangle($grad, $rect); $g.Dispose()
  $bmp.Save($bgPng, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}

function New-Card {
  param([string]$Text,[string]$Subtitle,[string]$OutPath,[int]$PadY=0)
  Add-Type -AssemblyName System.Drawing
  $bmp = New-Object System.Drawing.Bitmap($W,$H)
  $g = [System.Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='HighQuality'; $g.TextRenderingHint='AntiAlias'
  $bg = [System.Drawing.Image]::FromFile($bgPng)
  $g.DrawImage($bg,0,0,$W,$H); $bg.Dispose()
  $white = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
  $grey  = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(210,210,220))
  $font1 = New-Object System.Drawing.Font('Segoe UI Semibold', 64,[System.Drawing.FontStyle]::Bold)
  $font2 = New-Object System.Drawing.Font('Segoe UI', 32)
  $fmt = New-Object System.Drawing.StringFormat; $fmt.Alignment='Center'; $fmt.LineAlignment='Center'
  $rect1 = New-Object System.Drawing.RectangleF(0,([float]($H/2) - 60 + $PadY),$W,120)
  $g.DrawString($Text,$font1,$white,$rect1,$fmt)
  if($Subtitle){
    $rect2 = New-Object System.Drawing.RectangleF(0,([float]($H/2) + 60 + $PadY),$W,120)
    $g.DrawString($Subtitle,$font2,$grey,$rect2,$fmt)
  }
  $g.Dispose(); $bmp.Save($OutPath,[System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}

function New-LowerThird {
  param([string]$Label,[string]$OutPath)
  Add-Type -AssemblyName System.Drawing
  $bmp = New-Object System.Drawing.Bitmap($W,$H)
  $g = [System.Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='HighQuality'; $g.TextRenderingHint='AntiAlias'
  $bg = [System.Drawing.Image]::FromFile($bgPng)
  $g.DrawImage($bg,0,0,$W,$H); $bg.Dispose()
  $bar = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(180,25,25,40))
  $g.FillRectangle($bar, 0, $H-260, $W, 220)
  $white = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
  $font = New-Object System.Drawing.Font('Segoe UI Semibold', 40,[System.Drawing.FontStyle]::Bold)
  $g.DrawString($Label,$font,$white,120,$H-215)
  $g.Dispose(); $bmp.Save($OutPath,[System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}

$epJsonPath = Join-Path $RepoRoot "yt/episodes/$EpisodeId.json"
$scriptPath = Join-Path $RepoRoot "yt/scripts/$EpisodeId.md"
if(Test-Path $epJsonPath){
  try {
    $ep = Get-Content $epJsonPath -Raw | ConvertFrom-Json
    if(Test-Path $scriptPath){
      $beats = ($ep.beats | ForEach-Object { "- $_" }) -join "`r`n"
      $cur = Get-Content $scriptPath -Raw
      if($cur -notmatch '\[AUTO-BEATS\]'){
        $cur = $cur + "`r`n`r`n[AUTO-BEATS]`r`n$beats`r`n"
        Set-Content -LiteralPath $scriptPath -Value $cur -Encoding utf8NoBOM
      }
    }
  } catch {}
}

$titlePng = Join-Path $OutDir "$EpisodeId.title.png"
$discPng  = Join-Path $OutDir "$EpisodeId.disclosure.png"
$l3Png    = Join-Path $OutDir "$EpisodeId.lowerthird.png"

New-Card -Text "AI + Markets: Fast Brief" -Subtitle "Darren-inspired synthetic presenter" -OutPath $titlePng -PadY (-60)
New-LowerThird -Label "Darren-inspired synthetic presenter" -OutPath $l3Png
New-Card -Text "Not financial advice" -Subtitle "Sources in description" -OutPath $discPng -PadY 0

$wav = Join-Path $OutDir "$EpisodeId.vo.wav"
try{
  Add-Type -AssemblyName System.Speech
  $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
  $synth.Rate = 0; $synth.Volume = 90
  $synth.SetOutputToWaveFile($wav)
  $synth.Speak("Good morning. Here is your ninety second brief. Policy. Markets. Theme. What to watch tomorrow. This channel uses a synthetic presenter inspired by Darren, used with permission. Not financial advice.")
  $synth.Dispose()
}catch{ if(Test-Path $wav){ Remove-Item $wav -Force } }

$ff = (Get-Command ffmpeg -ErrorAction SilentlyContinue)?.Source
if($ff){
  $mp4 = Join-Path $OutDir "$EpisodeId.mp4"
  $args = @(
    "-y",
    "-loop","1","-t","4","-i",$titlePng,
    "-loop","1","-t","80","-i",$l3Png,
    "-loop","1","-t","6","-i",$discPng
  )
  if(Test-Path $wav){ $args += @("-i",$wav) }
  $vf = "scale=${W}:${H}:force_original_aspect_ratio=decrease,pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2"
  $filter = "[0:v]$vf,setsar=1[v0];[1:v]$vf,setsar=1[v1];[2:v]$vf,setsar=1[v2];[v0][v1][v2]concat=n=3:v=1:a=0[v]"
  $args += @("-filter_complex", $filter, "-map","[v]")
  if(Test-Path $wav){
    $args += @("-map","3:a","-c:v","libx264","-pix_fmt","yuv420p","-r","30","-c:a","aac","-shortest",$mp4)
  } else {
    $args += @("-c:v","libx264","-pix_fmt","yuv420p","-r","30",$mp4)
  }
  & $ff @args
  Write-Host ("Rendered: {0}" -f $mp4) -ForegroundColor Green
} else {
  Write-Host "ffmpeg not found — skipped MP4 stitch. Cards + optional VO created in yt/out/." -ForegroundColor Yellow
}
Write-Host "Done." -ForegroundColor Green
