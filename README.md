# RickPublic Pages Guardrails  -  MegaWave AdviceBomb

This bundle contains a hardened Pages workflow, local verify tools, and protection scripts.

## Files
- `.github/workflows/outreach-pages.yml`  -  PR-safe deploy with live fingerprint verify
- `tools/CoVerify-Pages.ps1`  -  local build + fingerprint append (optional)
- `tools/Set-PagesProtections.ps1`  -  set branch protection & env policy via `gh api`
- `docs/intent/advice/notes/20251112/CoSync_TEMPLATE.md`  -  session plan & sweep template
- `checks/*.example.json`  -  expected snapshots

## Quick use (on your repo clone)
```powershell
$RepoPath = "$HOME\Documents\GitHub\RickPublic"
Expand-Archive -Path .\AdviceBomb_RickPublic_PagesGuard_20251112_145129Z.zip -DestinationPath $RepoPath -Force

# Commit the workflow (adjust branch as needed)
git -C $RepoPath add .github/workflows/outreach-pages.yml
git -C $RepoPath commit -m "ci(pages): hardened workflow (PR-safe deploy + fingerprint verify)"
git -C $RepoPath push -u origin <your-branch>

# Set protections (requires gh with 'repo' scope; 'workflow' scope not needed for API)
pwsh -File "$RepoPath\tools\Set-PagesProtections.ps1" -RepoSlug 'rickballard/RickPublic'
```

## Status

- Nightly status: [docs/status/Nightly.md](docs/status/Nightly.md)
- CoSync receipts (latest): see docs/intent/advice/notes/


## Status
[![nightly-costatus](https://github.com/rickballard/RickPublic/actions/workflows/nightly-costatus.yml/badge.svg)](https://github.com/rickballard/RickPublic/actions/workflows/nightly-costatus.yml)



## YouTube placeholder CI
[![yt-placeholder](https://github.com/rickballard/RickPublic/actions/workflows/yt-placeholder.yml/badge.svg)](https://github.com/rickballard/RickPublic/actions/workflows/yt-placeholder.yml)
- Tool: yt/tools/RenderPlaceholder.ps1 (local)
- CI: .github/workflows/yt-placeholder.yml (dispatch with pisode)

