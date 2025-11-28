# 02  -  Operations Runbook

Refresh candidates + write outbox draft:
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\Run-Candidates-And-Commit.ps1

Manual Substack paste helper (SOTW #2):
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\Publish-Helper.ps1 -Slug 0002

Pull transcript into sotw\<slug>\assets:
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\Get-Transcript.ps1 -Url <YOUTUBE_URL> -Slug 0002

Tune search config:
edit .\tools\candidates.config.json

