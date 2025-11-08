# RickPublic Outreach Staging

This folder set is the **personal outreach hub** for Rick. It is **vendor-neutral** and **future-facing** (months ahead of active campaigns).

- `docs/intent/outreach/` — strategy, plans, playbooks.
- `docs/outreach/` — channel-ready copy and assets (public-facing drafts).
- `docs/intent/outreach/products/` — product-specific staging (CoArena, RepoZipper).
- `docs/intent/outreach/inseed/` & `copolitic/` — *staging only* for those orgs; final integration happens in their repos later.
- `docs/outreach/inbox/` — harvested AdviceBomb outreach payloads.

**Outreach hub:** docs/intent/outreach/OUTREACH_STRATEGY.md
### Outreach fast-path
```powershell
$RP = "$HOME\Documents\GitHub\RickPublic"
pwsh -NoProfile -File "$RP\scripts\Quick-Outreach-Sweep.ps1"   # Harvest → Scan → open latest index
![outreach-scan](https://github.com/rickballard/RickPublic/actions/workflows/outreach-scan.yml/badge.svg)
