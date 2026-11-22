# SPDX-License-Identifier: GPL-3.0-or-later
#
# Stages the offline voice packs (Whisper base and small, multilingual, int8, plus Silero VAD) from the
# official sherpa-onnx release assets. Dev-time only: the app never downloads anything. OWNER: Wave 3-D.
#
#   powershell -ExecutionPolicy Bypass -File tool/packs/voice/stage_whisper.ps1 [-Models base,small]
#
# Output: build/packs/staging/voice-whisper-<model>/ with exactly these files (make_pack packs every
# file in the folder):
#   encoder.int8.onnx  decoder.int8.onnx  tokens.txt  silero_vad.onnx
# Then it prints the `dart run tool/make_pack.dart ...` command for the orchestrator to sign.
#
# Every download is checked against a pinned SHA-256 (the release assets publish no digest for the
# Whisper archives, so the hashes below were taken from the first download; re-pin only on purpose).
param(
    [string[]]$Models = @('base', 'small'),
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$ReleaseBase = 'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models'

# model -> archive, pinned archive SHA-256, names inside the archive
$Whisper = @{
    'base'  = @{ Archive = 'sherpa-onnx-whisper-base.tar.bz2';  Sha256 = '911b2083efd7c0dca2ac3b358b75222660dc09fb716d64fbfc417ba6c99ff3de';
                 Encoder = 'base-encoder.int8.onnx';  Decoder = 'base-decoder.int8.onnx';  Tokens = 'base-tokens.txt' }
    'small' = @{ Archive = 'sherpa-onnx-whisper-small.tar.bz2'; Sha256 = '486a46afbb7ba798507190ffe02fea2dd726049af212e774537efac6afb210a6';
                 Encoder = 'small-encoder.int8.onnx'; Decoder = 'small-decoder.int8.onnx'; Tokens = 'small-tokens.txt' }
}
$SileroName = 'silero_vad.onnx'
$SileroSha256 = '9e2449e1087496d8d4caba907f23e0bd3f78d91fa552479bb9c23ac09cbb1fd6'

# Myna language ids that Whisper supports (all are valid tokenizer codes; see VoiceLanguages.kt).
$Languages = 'en,es,fr,de,pt-BR,pt-PT,id,ru,uk,hi,mr,bn,ta,te,ar,ur'

$download = Join-Path $RepoRoot 'build\packs\download'
$staging = Join-Path $RepoRoot 'build\packs\staging'
New-Item -ItemType Directory -Force -Path $download, $staging | Out-Null

function Get-Sha256Hex([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-Verified([string]$Url, [string]$Name, [string]$Sha256) {
    $target = Join-Path $download $Name
    if (-not (Test-Path -LiteralPath $target)) {
        Write-Host "Downloading $Name ..."
        Invoke-WebRequest -Uri $Url -OutFile "$target.part" -UseBasicParsing
        Move-Item -LiteralPath "$target.part" -Destination $target -Force
    }
    $actual = Get-Sha256Hex $target
    if ($Sha256 -eq '') {
        Write-Host "No pinned SHA-256 for $Name. Computed: $actual" -ForegroundColor Yellow
    } elseif ($actual -ne $Sha256) {
        Remove-Item -LiteralPath $target -Force
        throw "SHA-256 mismatch for ${Name}: expected $Sha256, got $actual. Download removed."
    }
    return $target
}

$commands = @()
foreach ($m in $Models) {
    if (-not $Whisper.ContainsKey($m)) { throw "Unknown model '$m' (use base or small)." }
    $spec = $Whisper[$m]
    $archive = Get-Verified "$ReleaseBase/$($spec.Archive)" $spec.Archive $spec.Sha256

    $extract = Join-Path $download ("extract-" + $m)
    if (Test-Path -LiteralPath $extract) { Remove-Item -LiteralPath $extract -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $extract | Out-Null
    & tar -xjf $archive -C $extract
    if ($LASTEXITCODE -ne 0) { throw "tar failed for $($spec.Archive)" }

    $dir = Get-ChildItem -LiteralPath $extract -Recurse -File
    function Find-One([string]$Name) {
        $hit = $dir | Where-Object { $_.Name -eq $Name } | Select-Object -First 1
        if (-not $hit) { throw "$Name not found in $($spec.Archive)" }
        return $hit.FullName
    }

    $out = Join-Path $staging ("voice-whisper-" + $m)
    if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $out | Out-Null
    Copy-Item -LiteralPath (Find-One $spec.Encoder) -Destination (Join-Path $out 'encoder.int8.onnx')
    Copy-Item -LiteralPath (Find-One $spec.Decoder) -Destination (Join-Path $out 'decoder.int8.onnx')
    Copy-Item -LiteralPath (Find-One $spec.Tokens) -Destination (Join-Path $out 'tokens.txt')

    $silero = Get-Verified "$ReleaseBase/$SileroName" $SileroName $SileroSha256
    Copy-Item -LiteralPath $silero -Destination (Join-Path $out $SileroName)

    $files = Get-ChildItem -LiteralPath $out -File
    foreach ($f in $files) {
        "{0,-22} {1,12:N0} bytes  sha256 {2}" -f $f.Name, $f.Length, (Get-Sha256Hex $f.FullName) | Write-Host
    }
    Remove-Item -LiteralPath $extract -Recurse -Force

    $id = "voice-whisper-$m"
    $name = "Whisper $m (multilingual, offline)"
    $commands += "dart run tool/make_pack.dart --dir `"build/packs/staging/$id`" --id $id --kind voice --name `"$name`" --languages $Languages --engine sherpa-onnx-whisper --license MIT --out build/packs/$id.mynapack"
}

Write-Host ''
Write-Host 'Staged. Ask the orchestrator to sign each pack (the signing key lives outside the repo):' -ForegroundColor Green
$commands | ForEach-Object { Write-Host $_ }
