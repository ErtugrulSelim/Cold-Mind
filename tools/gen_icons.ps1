# Generates the phone's app icons through the Freepik Mystic API.
#
#   powershell -ExecutionPolicy Bypass -File tools/gen_icons.ps1
#   powershell -ExecutionPolicy Bypass -File tools/gen_icons.ps1 -Only dial,texts
#   powershell -ExecutionPolicy Bypass -File tools/gen_icons.ps1 -Missing
#   powershell -ExecutionPolicy Bypass -File tools/gen_icons.ps1 -WhatIf
#
# -Missing   only generates icons whose .png is not already on disk, which is
#            the safe way to resume after a partial or failed batch
# -WhatIf    lists what would be generated and exits without calling the API
#
# Reads MAGNIFIC_API_KEY from .env (gitignored). The key is never printed.
#
# Icons stay PNG rather than being converted to JPG like the case photographs:
# an icon is flat colour with hard edges, which is exactly what JPEG's chroma
# subsampling smears, and at 1024px the file is small either way.

param(
  [string[]]$Only = @(),
  [switch]$Missing,
  [switch]$WhatIf,
  # Which set to build. `icons` is the phone's app icons; `desk` is the
  # player's own controls, which belong to the warm register and live in
  # their own folder so the two never get mixed.
  [string]$Set = 'icons'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$api  = 'https://api.freepik.com/v1/ai/mystic'
# Gemini 2.5 Flash Image. Mystic is the better photographic renderer and the
# wrong tool here: it composes an icon the way it composes a photograph, with
# the subject centred small and margin all round, and it invents a different
# house style on every call — which is fatal for a set of 23 that has to read
# as one family. This one follows the instruction instead.
$nanoApi = 'https://api.freepik.com/v1/ai/gemini-2-5-flash-image-preview'
# Downloads land in raw/, never beside the shipped PNGs.
#
# They used to land on top of them, and `normalize_icons.ps1` — which always
# re-derives from raw/ so it can be run twice safely — would then overwrite
# the fresh art with the stash from the first batch. Regenerating a single
# icon looked like it worked and silently changed nothing.
$setDir = if ($Set -eq 'desk') {
  Join-Path $root 'assets/desk'
} else {
  Join-Path $root 'assets/icons'
}
$outDir = Join-Path $setDir 'raw'

# PS 5.1 negotiates TLS 1.0/1.1 by default, which the image CDN refuses.
# Without this the API calls succeed and only the download fails, which looks
# like a random mid-batch crash.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# -- manifest ----------------------------------------------------------------
$manifestPath = Join-Path $root "tools/prompts/$Set.json"
if (-not (Test-Path $manifestPath)) { throw "manifest not found: tools/prompts/$Set.json" }
# Assign before wrapping: in PS 5.1 `@(... | ConvertFrom-Json)` collapses the
# whole JSON array into a single element.
$manifest = Get-Content $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$jobs = @($manifest)

# `powershell -File script.ps1 -Only a,b` hands the whole thing over as one
# string rather than an array, so a two-name filter silently matched nothing.
if ($Only.Count -eq 1 -and $Only[0] -like '*,*') {
  $Only = @($Only[0] -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}
if ($Only.Count) { $jobs = @($jobs | Where-Object { $Only -contains $_.name }) }
if ($Missing) {
  $jobs = @($jobs | Where-Object { -not (Test-Path (Join-Path $outDir "$($_.name).png")) })
}

if (-not $jobs.Count) { Write-Host 'no matching jobs in manifest'; exit 0 }

Write-Host "$($jobs.Count) icon(s): $(($jobs | ForEach-Object { $_.name }) -join ', ')"
if ($WhatIf) { Write-Host '-WhatIf: nothing submitted.'; exit 0 }

# -- key ---------------------------------------------------------------------
# Read only after -WhatIf has had its chance, so a dry run needs no secret.
$envPath = Join-Path $root '.env'
if (-not (Test-Path $envPath)) {
  throw ".env not found. Copy .env.example to .env and set MAGNIFIC_API_KEY."
}
$keyLine = (Get-Content $envPath) | Where-Object { $_ -like 'MAGNIFIC_API_KEY=*' } | Select-Object -First 1
if (-not $keyLine) { throw 'MAGNIFIC_API_KEY missing from .env' }
$key = $keyLine.Substring('MAGNIFIC_API_KEY='.Length).Trim()
if (-not $key -or $key -like 'your_*') {
  throw 'MAGNIFIC_API_KEY is still the placeholder value in .env'
}
$headers = @{ 'x-freepik-api-key' = $key }

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

# -- submit ------------------------------------------------------------------
$pending = @()
foreach ($job in $jobs) {
  # Nano is the default for icons; a job can opt back into Mystic with
  # "model": "mystic" if one tile turns out to want a painterly treatment.
  $useMystic = ($job.model -eq 'mystic')
  $endpoint = if ($useMystic) { $api } else { $nanoApi }

  if ($useMystic) {
    $payload = @{
      prompt             = $job.prompt
      resolution         = '2k'
      aspect_ratio       = if ($job.aspect) { $job.aspect } else { 'square_1_1' }
      realism            = $false
      engine             = 'automatic'
      creative_detailing = 12
      filter_nsfw        = $true
    }
  } else {
    # Nano takes no aspect_ratio — the square has to be said in the prompt.
    $payload = @{ prompt = $job.prompt }
  }
  $body = $payload | ConvertTo-Json -Depth 5 -Compress

  try {
    $res = Invoke-RestMethod -Uri $endpoint -Method Post -Headers $headers `
             -ContentType 'application/json' -Body ([Text.Encoding]::UTF8.GetBytes($body))
    if (-not $res.data.task_id) { throw 'no task_id in response' }
    $pending += [pscustomobject]@{ Job = $job; TaskId = $res.data.task_id; Endpoint = $endpoint }
    Write-Host "submitted   $($job.name)$(if (-not $useMystic) { '  [nano]' })"
  } catch {
    Write-Host "SUBMIT-FAIL $($job.name): $($_.Exception.Message)"
  }
  Start-Sleep -Milliseconds 1200
}

# -- poll + download ---------------------------------------------------------
$remaining = @($pending)
for ($round = 0; $round -lt 70 -and $remaining.Count; $round++) {
  Start-Sleep -Seconds 8
  $still = @()
  foreach ($item in $remaining) {
    try {
      $data = (Invoke-RestMethod -Uri "$($item.Endpoint)/$($item.TaskId)" -Headers $headers).data
    } catch {
      Write-Host "POLL-FAIL   $($item.Job.name): $($_.Exception.Message)"
      $still += $item
      continue
    }

    if ($data.status -eq 'COMPLETED' -and $data.generated -and $data.generated.Count) {
      $png = Join-Path $outDir "$($item.Job.name).png"
      # A download failure must not abandon the rest of the batch — the result
      # URL stays valid for a while, so put the job back and retry next round.
      try {
        Invoke-WebRequest -Uri $data.generated[0] -OutFile $png -UseBasicParsing
      } catch {
        Write-Host "DL-RETRY    $($item.Job.name): $($_.Exception.Message)"
        $still += $item
        continue
      }
      Write-Host "DONE        $($item.Job.name) -> $($png.Substring($root.Length + 1))"
    } elseif ($data.status -eq 'FAILED') {
      Write-Host "FAILED      $($item.Job.name): $($data.error | ConvertTo-Json -Compress)"
    } else {
      $still += $item
    }
  }
  $remaining = $still
}

if ($remaining.Count) {
  Write-Host "TIMED OUT: $(($remaining | ForEach-Object { $_.Job.name }) -join ', ')"
}
Write-Host 'icon pass complete'
