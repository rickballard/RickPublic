# Hook: PolicyKit → CoSuite (repo‑first audit chain)

**Problem**
Downstream action and audits from deliberation/decisions are often ad‑hoc and unreproducible.

**Proposal**
Add a 'Repo‑first Governance Pack' that posts PolicyKit decisions/events to AdviceBomb ZIPs + opens traceable CoSync notes.

**Minimal artifact**
- Sample AdviceBomb ZIP schema (checksums.json, INBOX_LOG row, CoSync note)
- Tiny script to export from your tool into the AdviceBomb format

**Why this helps you**
It creates a reproducible, checksumed artifact that partners (cities, NGOs) can depend on.

**Next steps (as PRs/issues)**
- [ ] Approve a minimal schema/adapter
- [ ] Pilot with 1 small dataset/thread
- [ ] Document 'Export to AdviceBomb' in your README
