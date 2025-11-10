# RickPublic — Operations Manual

**Repo-first.** Helpers live in-repo. Local is staging only.

## Quick use
```powershell
$RP = "$HOME\Documents\GitHub\RickPublic"
# Kick scan and publish latest.md, then pull it locally
gh workflow run outreach-scan --repo rickballard/RickPublic | Out-Null
$run = (gh run list --workflow "outreach-scan.yml" --json databaseId --limit 1 --repo rickballard/RickPublic | ConvertFrom-Json)[0].databaseId
gh run watch $run --repo rickballard/RickPublic --exit-status
pwsh -NoProfile -File "$RP\scripts\Download-LatestOutreachIndex.ps1"
Receipts (optional)

Run your Rescue wave with -CommitReceipt to open a tiny PR recording the run.
