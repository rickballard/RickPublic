param()
$ErrorActionPreference='Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Resolve-Path (Join-Path $root '..') | % Path

# a) git cleanliness
$dirty = git -C $repo status --porcelain
if($dirty){ Write-Error "Repo has uncommitted changes. Commit or stash first."; exit 2 }

# b) line endings setup (informational)
git -C $repo config core.autocrlf true | Out-Null
git -C $repo config core.eol lf | Out-Null

# c) source exists
$src = Join-Path $repo 'docs\intent\outreach\indexes\latest.md'
if(-not (Test-Path $src)){ throw "Missing: $src" }

# d) quick local build using marked
$tmp = Join-Path $env:TEMP "rp_pages_check_$([DateTime]::UtcNow.ToString('yyyyMMdd_HHmmss'))"
New-Item -ItemType Directory -Force $tmp | Out-Null
$dst = Join-Path $tmp 'index.html'
# Ensure npm/marked available
if(-not (Get-Command npm -ErrorAction SilentlyContinue)){ throw "npm missing on PATH" }
& npx -y marked -i $src -o $dst | Out-Null

# e) inject fingerprint (same as CI will do)
$stamp = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
$sha   = (git -C $repo rev-parse --short=8 HEAD).Trim()
$fpr   = "<!-- build-fingerprint:$sha:$stamp -->"
(Add-Content -LiteralPath $dst "`n$fpr")

# f) assert fingerprint present
$html = Get-Content -Raw $dst
if($html -notmatch [regex]::Escape($fpr)){ throw "Fingerprint not present in local build." }

Write-Host "✓ CoVerify ok — fingerprint: $fpr"
