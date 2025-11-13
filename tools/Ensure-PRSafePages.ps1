\
param(
  [Parameter(Mandatory=$false)][string]$RepoPath = (Join-Path $HOME 'Documents\GitHub\RickPublic')
)
$ErrorActionPreference='Stop'
$wf = Join-Path $RepoPath '.github/workflows/outreach-pages.yml'
if(-not (Test-Path $wf)){ throw "Missing workflow: $wf" }
$y = Get-Content -Raw $wf

# Ensure triggers (push + pull_request + dispatch)
if($y -notmatch '(?ms)^\s*on:\s*[\s\S]*?pull_request:'){
  $y = $y -replace '(?ms)^on:\s*\r?\n',
    "on:`n  workflow_dispatch:`n  push:`n    branches: [ main ]`n    paths:`n      - docs/intent/outreach/indexes/latest.md`n      - .github/workflows/outreach-pages.yml`n  pull_request:`n    paths:`n      - docs/intent/outreach/indexes/latest.md`n      - .github/workflows/outreach-pages.yml`n"
}

# Skip Pages-specific steps on PRs; keep 'deploy' job green
$y = $y -replace 'uses:\s*actions/configure-pages@v\d+', "if: `${{ github.event_name != 'pull_request' }}``n        uses: actions/configure-pages@v5"
$y = $y -replace 'uses:\s*actions/upload-pages-artifact@v\d+', "if: `${{ github.event_name != 'pull_request' }}``n        uses: actions/upload-pages-artifact@v3"
$y = $y -replace '(?ms)(- name:\s*Deploy to GitHub Pages\s*\r?\n\s*id:\s*deployment\s*\r?\n\s*uses:\s*actions/deploy-pages@v\d+)', '$1' + "`n        if: `${{ github.event_name != 'pull_request' }}"
$y = $y -replace '(?ms)(- name:\s*Verify live page \(fingerprint\)\s*\r?\n\s*shell:\s*bash)', '$1' + "`n        if: `${{ github.event_name != 'pull_request' }}"

# Ensure a PR-only simulated deploy step after the real one
if($y -notmatch '(?ms)- name:\s*Simulated deploy \(PR\)'){
  $sim = @"
      - name: Simulated deploy (PR)
        if: `${{ github.event_name == 'pull_request' }}
        run: echo "Simulated deploy for PR — skipping real Pages publish."
"@
  $y = $y -replace '(?ms)(- name:\s*Deploy to GitHub Pages[\s\S]*?actions/deploy-pages@v\d+[^\r\n]*\r?\n)', "`$1$sim"
}

Set-Content -LiteralPath $wf -Encoding utf8NoBOM $y
Write-Host "Patched PR-safe workflow: $wf"
