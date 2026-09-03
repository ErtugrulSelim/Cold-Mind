# Generates the Reels clips through the Freepik image-to-video API.
#
#   powershell -ExecutionPolicy Bypass -File tools/gen_videos.ps1
#   powershell -ExecutionPolicy Bypass -File tools/gen_videos.ps1 -Only reel_02
#   powershell -ExecutionPolicy Bypass -File tools/gen_videos.ps1 -Missing
#   powershell -ExecutionPolicy Bypass -File tools/gen_videos.ps1 -WhatIf
#
# Reads MAGNIFIC_API_KEY from .env (gitignored). The key is never printed.
#
# ── What is different from the stills ───────────────────────────────────────
#
# **There is no text-to-video on this key.** `text-to-video/*` answers 404 and
# only `image-to-video/kling-v2` takes a job, so every clip starts from a
# frame — `from` in the manifest — which is why each one grows out of a
# photograph that is already in the Explore grid. That is the better shape
# anyway: the still and the clip are the same place, one swipe apart.
#
# **The image goes up as base64 in the JSON body**, not as a URL, so a 1600px
# JPEG becomes about 270 KB of body. That is fine; a 2k PNG would not be.
#
# **It is slow.** A clip takes ten to thirty minutes against seconds for a
# still, so the poll budget here is forty minutes rather than the stills'
# nine, and the loop reports only every other minute so the log stays short.
param(
  [string[]]$Only = @(),
  [switch]$Missing,
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$api = 'https://api.freepik.com/v1/ai/image-to-video/kling-v2'

# PS 5.1 negotiates TLS 1.0/1.1 by default, which the CDN refuses.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$manifestPath = Join-Path $root 'tools/prompts/videos.json'
if (-not (Test-Path $manifestPath)) { throw 'tools/prompts/videos.json not found' }
# Assign before wrapping: in PS 5.1 `@(... | ConvertFrom-Json)` collapses the
# whole JSON array into a single element.
$manifest = Get-Content $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$jobs = @($manifest)

if ($Only.Count -eq 1 -and $Only[0] -like '*,*') {
  $Only = @($Only[0] -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}
if ($Only.Count) { $jobs = @($jobs | Where-Object { $Only -contains $_.name }) }
if ($Missing) {
  $jobs = @($jobs | Where-Object { -not (Test-Path (Join-Path $root $_.asset)) })
}

if (-not $jobs.Count) { Write-Host 'no matching jobs in manifest'; exit 0 }
Write-Host "$($jobs.Count) clip(s): $(($jobs | ForEach-Object { $_.name }) -join ', ')"
if ($WhatIf) { Write-Host '-WhatIf: nothing submitted.'; exit 0 }

$envPath = Join-Path $root '.env'
if (-not (Test-Path $envPath)) { throw '.env not found' }
$keyLine = (Get-Content $envPath) | Where-Object { $_ -like 'MAGNIFIC_API_KEY=*' } | Select-Object -First 1
if (-not $keyLine) { throw 'MAGNIFIC_API_KEY missing from .env' }
$key = $keyLine.Substring('MAGNIFIC_API_KEY='.Length).Trim()
if (-not $key -or $key -like 'your_*') { throw 'MAGNIFIC_API_KEY is still the placeholder' }
$headers = @{ 'x-freepik-api-key' = $key }

# -- submit ------------------------------------------------------------------
$pending = @()
foreach ($job in $jobs) {
  $seed = Join-Path $root $job.from
  if (-not (Test-Path $seed)) {
    Write-Host "NO-SEED     $($job.name): $($job.from) is not on disk"
    continue
  }

  $payload = @{
    image    = [Convert]::ToBase64String([IO.File]::ReadAllBytes($seed))
    prompt   = $job.prompt
    duration = if ($job.duration) { $job.duration } else { '5' }
  }
  $body = $payload | ConvertTo-Json -Depth 4 -Compress

  try {
    $res = Invoke-RestMethod -Uri $api -Method Post -Headers $headers `
             -ContentType 'application/json' -Body ([Text.Encoding]::UTF8.GetBytes($body))
    if (-not $res.data.task_id) { throw 'no task_id in response' }
    $pending += [pscustomobject]@{ Job = $job; TaskId = $res.data.task_id }
    Write-Host "submitted   $($job.name)  from $($job.from)"
  } catch {
    # The message alone is "(400) Bad Request" and says nothing about which
    # field was refused. The body does, when there is one.
    $detail = ''
    try {
      $detail = (New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd()
    } catch { }
    Write-Host "SUBMIT-FAIL $($job.name): $($_.Exception.Message) $detail"
  }
  Start-Sleep -Seconds 2
}

# -- poll + download ---------------------------------------------------------
$remaining = @($pending)
for ($round = 0; $round -lt 240 -and $remaining.Count; $round++) {
  Start-Sleep -Seconds 10
  $still = @()
  foreach ($item in $remaining) {
    try {
      $data = (Invoke-RestMethod -Uri "$api/$($item.TaskId)" -Headers $headers).data
    } catch {
      $still += $item
      continue
    }

    if ($data.status -eq 'COMPLETED' -and $data.generated -and $data.generated.Count) {
      $out = Join-Path $root $item.Job.asset
      $parent = Split-Path -Parent $out
      if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
      }
      # A download failure must not abandon the rest of the batch — the result
      # URL stays valid for a while, so put the job back and retry next round.
      try {
        Invoke-WebRequest -Uri $data.generated[0] -OutFile $out -UseBasicParsing
      } catch {
        Write-Host "DL-RETRY    $($item.Job.name): $($_.Exception.Message)"
        $still += $item
        continue
      }
      Write-Host ("DONE        {0} -> {1}  ({2:N1} MB)" -f `
        $item.Job.name, $item.Job.asset, ((Get-Item $out).Length / 1MB))
    } elseif ($data.status -eq 'FAILED') {
      Write-Host "FAILED      $($item.Job.name): $($data | ConvertTo-Json -Compress -Depth 4)"
    } else {
      $still += $item
    }
  }
  if ($still.Count -and $round % 12 -eq 0) {
    Write-Host ("  still running: {0}  ({1} min)" -f `
      (($still | ForEach-Object { $_.Job.name }) -join ', '), [int]($round / 6))
  }
  $remaining = $still
}

if ($remaining.Count) {
  Write-Host "TIMED OUT: $(($remaining | ForEach-Object { $_.Job.name }) -join ', ')"
}
Write-Host 'video pass complete'
