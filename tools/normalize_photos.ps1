# Turns generated artwork into files an app can actually ship.
#
#   powershell -ExecutionPolicy Bypass -File tools/normalize_photos.ps1
#   powershell -ExecutionPolicy Bypass -File tools/normalize_photos.ps1 -Dir assets/stock/photos
#   powershell -ExecutionPolicy Bypass -File tools/normalize_photos.ps1 -WhatIf
#
# With no -Dir it does every case's endings folder and the shared stock feed.
#
# Re-running is safe: a file that is already JPEG is left alone. That is the
# whole idempotency strategy here, and it is why there is no raw/ folder beside
# these the way there is beside the icons — 30 photographs at 2k is 123 MB of
# PNG, which is more than the rest of the case assets put together and not
# something to keep a second copy of. The manifest is the source; the API is
# the way back.
#
# ── Why this exists ─────────────────────────────────────────────────────────
#
# Mystic returns PNG, and `gen_icons.ps1` writes whatever comes down the wire
# to the path the manifest names. So `assets/cases/sNN/endings/<branch>.jpg`
# arrived as a 2048-wide PNG with a .jpg on the end of it. Flutter sniffs the
# header and draws it perfectly, which is exactly what makes this invisible:
# nothing looks wrong, the bundle is just four times the size it should be.
#
# An ending card draws at the width of a phone and a feed tile at a third of
# it, so 1600px is generous for both at 3x and lands each file well under a
# quarter of a megabyte.
param(
  [string[]]$Dir = @(),
  [int]$MaxWidth = 1600,
  [int]$Quality = 82,
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Add-Type -AssemblyName System.Drawing

$jpeg = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
  Where-Object { $_.MimeType -eq 'image/jpeg' }
$params = New-Object System.Drawing.Imaging.EncoderParameters(1)
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
  [System.Drawing.Imaging.Encoder]::Quality, [long]$Quality)

if ($Dir.Count) {
  $dirs = @($Dir | ForEach-Object { Join-Path $root $_ })
} else {
  $dirs = @(
    Get-ChildItem (Join-Path $root 'assets/cases') -Directory |
      ForEach-Object { Join-Path $_.FullName 'endings' }
  ) + @(Join-Path $root 'assets/stock/photos')
}

$cards = @($dirs | Where-Object { Test-Path $_ } |
  ForEach-Object { Get-ChildItem $_ -Filter *.jpg -File })

if (-not $cards.Count) { Write-Host 'no images found'; exit 0 }

$before = 0
$after = 0
$converted = 0

foreach ($card in $cards) {
  $before += $card.Length

  # Two bytes are enough to tell them apart: JPEG starts FF D8, PNG 89 50.
  $head = [byte[]]::new(2)
  $fs = [IO.File]::OpenRead($card.FullName)
  try { $null = $fs.Read($head, 0, 2) } finally { $fs.Dispose() }

  if ($head[0] -eq 0xFF -and $head[1] -eq 0xD8) {
    $after += $card.Length
    continue
  }

  if ($WhatIf) {
    Write-Host ("would convert {0}  {1:N0} KB" -f $card.Name, ($card.Length / 1KB))
    $after += $card.Length
    continue
  }

  # The source bitmap keeps a handle on the file it was loaded from, so it has
  # to be let go before anything can be written over that path — otherwise the
  # swap below fails with "cannot create a file that already exists", which is
  # not what the problem is.
  $out = $null
  $w = 0
  $h = 0
  $src = New-Object System.Drawing.Bitmap($card.FullName)
  try {
    $w = $src.Width
    $h = $src.Height
    if ($w -gt $MaxWidth) {
      $h = [int][Math]::Round($h * ($MaxWidth / $w))
      $w = $MaxWidth
    }

    $out = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($out)
    try {
      $g.InterpolationMode = 'HighQualityBicubic'
      $g.PixelOffsetMode = 'HighQuality'
      $g.SmoothingMode = 'HighQuality'
      $g.DrawImage($src, 0, 0, $w, $h)
    } finally { $g.Dispose() }
  } finally { $src.Dispose() }

  try {
    # Write beside it and swap, so a failure halfway leaves the original.
    $tmp = "$($card.FullName).tmp"
    $out.Save($tmp, $jpeg, $params)
    Move-Item $tmp $card.FullName -Force
  } finally { $out.Dispose() }

  $now = (Get-Item $card.FullName).Length
  $after += $now
  $converted++
  Write-Host ("converted   {0}  {1:N0} KB -> {2:N0} KB  ({3}x{4})" -f `
    $card.Name, ($card.Length / 1KB), ($now / 1KB), $w, $h)
}

Write-Host ''
Write-Host ("{0} of {1} image(s) converted. {2:N1} MB -> {3:N1} MB" -f `
  $converted, $cards.Count, ($before / 1MB), ($after / 1MB))
