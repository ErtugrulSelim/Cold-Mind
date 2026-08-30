# Turns the generated art into square, full-bleed icon tiles.
#
#   powershell -ExecutionPolicy Bypass -File tools/normalize_icons.ps1
#
# The image model draws a rounded tile floating on white, and it picks a
# different corner radius every time — measured across one batch the white
# inset ranged from 0% (art running off the edge) to 25.6%. Left alone that
# gives a home screen of 23 icons with 23 different silhouettes, and white
# corners showing against the wallpaper.
#
# So each tile is cropped twice: first to the bounding box of its own
# non-white content, then inward by the smallest amount that removes the
# rounded corner arcs. The result is a square that is opaque to all four
# corners, and `AppIcon` gives every one of them the same radius in Flutter.
#
# Originals are kept in assets/icons/raw/ so this is re-runnable and a bad
# crop can be undone without spending another API call.

# -Size is the edge of the shipped PNG. The generator returns 1024, which is
# five times what the phone ever draws: `AppIcon` renders at 66pt, so even a
# 3x screen only asks for about 200 physical pixels. Shipping the 1024s cost
# 28 MB for twenty-three icons; 256 costs a fraction of that and is still
# above what any device requests. The originals stay in raw/ at full size.
param([switch]$Force, [int]$Size = 0, [string]$Set = 'icons')

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot

# The desk badges are circles that get clipped to an oval at draw time, so
# they skip the corner crop entirely — cutting corners off a circle would
# only eat the brass rim. They ship smaller too: `_DeskButton` draws at 52pt
# against the app icons' 66pt.
$isDesk = ($Set -eq 'desk')
$dir    = if ($isDesk) { Join-Path $root 'assets/desk' } else { Join-Path $root 'assets/icons' }
$rawDir = Join-Path $dir 'raw'
if ($Size -le 0) { $Size = if ($isDesk) { 192 } else { 256 } }
if (-not (Test-Path $rawDir)) { New-Item -ItemType Directory -Path $rawDir -Force | Out-Null }

# Anything this pale counts as the surrounding paper rather than artwork.
#
# The desk badges are rendered with a soft drop shadow outside the rim, and at
# the app-icon threshold that grey counted as content: the bounding box grew
# down and to the right, the circle came out off-centre, and clipping it to an
# oval left a pale crescent along one edge. Treating light grey as background
# too puts the box back on the badge itself.
$White = if ($isDesk) { 214 } else { 242 }

function Test-Pale {
  param($Pixel)
  return ($Pixel.R -ge $White -and $Pixel.G -ge $White -and $Pixel.B -ge $White)
}

if (-not (Get-ChildItem $rawDir -Filter *.png -ErrorAction SilentlyContinue)) {
  throw "no source art in $rawDir - run tools/gen_icons.ps1 first"
}

# Reads the untouched download, writes the shipped tile beside it. Always
# derived, never edited in place, so this can be re-run as often as you like
# and a bad crop is one re-run away from being undone.
foreach ($f in Get-ChildItem $rawDir -Filter *.png) {
  $dest = Join-Path $dir $f.Name
  $src = New-Object System.Drawing.Bitmap($f.FullName)
  $w = $src.Width; $h = $src.Height

  # -- 1. bounding box of non-pale content ----------------------------------
  $left = $w; $right = -1; $top = $h; $bottom = -1
  for ($y = 0; $y -lt $h; $y += 2) {
    for ($x = 0; $x -lt $w; $x += 2) {
      if (-not (Test-Pale $src.GetPixel($x, $y))) {
        if ($x -lt $left) { $left = $x }
        if ($x -gt $right) { $right = $x }
        if ($y -lt $top) { $top = $y }
        if ($y -gt $bottom) { $bottom = $y }
      }
    }
  }
  if ($right -lt 0) { Write-Host "SKIP  $($f.BaseName): all pale"; $src.Dispose(); continue }

  # Square it off around the centre of the content, so nothing is stretched.
  $cx = ($left + $right) / 2
  $cy = ($top + $bottom) / 2
  $side = [math]::Max($right - $left, $bottom - $top) + 1
  $side = [math]::Min($side, [math]::Min($w, $h))

  # -- 2. shrink until the four corners are opaque artwork ------------------
  # Steps inward 1% at a time rather than using one fixed number: a tile that
  # already bleeds off the edge needs no crop at all, and over-cropping it
  # would eat the design.
  $crop = 0
  for ($step = 0; ($step -le 30) -and (-not $isDesk); $step++) {
    $s = [int]($side * (1 - $step / 100.0))
    $x0 = [int]($cx - $s / 2); $y0 = [int]($cy - $s / 2)
    $x0 = [math]::Max(0, [math]::Min($x0, $w - $s))
    $y0 = [math]::Max(0, [math]::Min($y0, $h - $s))

    $inset = [math]::Max(1, [int]($s * 0.02))
    $corners = @(
      $src.GetPixel($x0 + $inset,          $y0 + $inset),
      $src.GetPixel($x0 + $s - 1 - $inset, $y0 + $inset),
      $src.GetPixel($x0 + $inset,          $y0 + $s - 1 - $inset),
      $src.GetPixel($x0 + $s - 1 - $inset, $y0 + $s - 1 - $inset)
    )
    $anyPale = $false
    foreach ($c in $corners) { if (Test-Pale $c) { $anyPale = $true } }
    if (-not $anyPale) { $crop = $step; break }
    $crop = $step
  }

  # Two steps past the minimum. Bicubic resampling overshoots towards white
  # along a hard edge, so a crop that measures clean in source pixels can
  # still land a pale pixel in the corner of the 1024 output — dial and lookup
  # both did. Tiles that need no crop at all stay untouched.
  if ($crop -gt 0) { $crop = [math]::Min(30, $crop + 2) }

  $s = [int]($side * (1 - $crop / 100.0))
  $x0 = [int]($cx - $s / 2); $y0 = [int]($cy - $s / 2)
  $x0 = [math]::Max(0, [math]::Min($x0, $w - $s))
  $y0 = [math]::Max(0, [math]::Min($y0, $h - $s))

  # -- 3. write a clean square at the shipping size -------------------------
  $out = New-Object System.Drawing.Bitmap($Size, $Size)
  $g = [System.Drawing.Graphics]::FromImage($out)
  $g.InterpolationMode = 'HighQualityBicubic'
  $g.PixelOffsetMode = 'HighQuality'
  $rect = New-Object System.Drawing.Rectangle($x0, $y0, $s, $s)
  $g.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $Size, $Size)), $rect, 'Pixel')
  $g.Dispose()
  $src.Dispose()

  $out.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
  $out.Dispose()

  Write-Host ("{0,-10} bbox {1}px -> crop {2}%" -f $f.BaseName, $side, $crop)
}

Write-Host 'normalize complete'
