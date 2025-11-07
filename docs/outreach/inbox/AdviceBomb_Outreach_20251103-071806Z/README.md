# Outreach AdviceBomb (Partners) — 20251103-071806Z

This bundle contains partner dossiers and ready-to-use outreach templates (issue/email/PR). 
Intended for `CoCache/advice/inbox` ingestion. After adding, run `.CoVerify.ps1`, open a short branch, and PR.

## Contents
- `/partners/*` — per-partner profiles: why fit, contacts, leader to approach, first-touch issue, links.
- `/templates/*` — standardized ISSUE / INTRO_EMAIL / PR templates to customize.
- `_wrap.manifest.json` — metadata for AdviceBomb.
- `checksums.json` — file checksums (SHA-256).

## Next steps
1. Drop this ZIP into `CoCache/advice/inbox`, compute `.sha256`, and append a row to `INBOX_LOG.md`.
2. If targeting only a subset (e.g., Gov4Git/PolicyKit/Pol.is), open a micro PR per repo with the included issue body.
3. Write a CoSync note in `CoCivium/docs/intent/advice/notes/20251103/CoSync_20251103-071806Z.md` referencing the INBOX_LOG tail.
