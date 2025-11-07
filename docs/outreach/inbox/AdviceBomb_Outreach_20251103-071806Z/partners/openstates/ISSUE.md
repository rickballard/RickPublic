# Converter: Open States → CoCivium prompts + AdviceBomb

**Problem**
Downstream action and audits from deliberation/decisions are often ad‑hoc and unreproducible.

**Proposal**
CLI/JSON schema to turn bill events into prompts and bundle as AdviceBombs with traceable links.

**Minimal artifact**
- Sample AdviceBomb ZIP schema (checksums.json, INBOX_LOG row, CoSync note)
- Tiny script to export from your tool into the AdviceBomb format

**Why this helps you**
It creates a reproducible, checksumed artifact that partners (cities, NGOs) can depend on.

**Next steps (as PRs/issues)**
- [ ] Approve a minimal schema/adapter
- [ ] Pilot with 1 small dataset/thread
- [ ] Document 'Export to AdviceBomb' in your README
