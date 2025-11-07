# Bridge: Pol.is exports → AdviceBomb (auditable deliberation → action)

**Problem**
Downstream action and audits from deliberation/decisions are often ad‑hoc and unreproducible.

**Proposal**
Offer a minimal script and schema mapping from Pol.is CSV/JSON exports into AdviceBomb ZIPs with CoVerify checks and CoSync notes.

**Minimal artifact**
- Sample AdviceBomb ZIP schema (checksums.json, INBOX_LOG row, CoSync note)
- Tiny script to export from your tool into the AdviceBomb format

**Why this helps you**
It creates a reproducible, checksumed artifact that partners (cities, NGOs) can depend on.

**Next steps (as PRs/issues)**
- [ ] Approve a minimal schema/adapter
- [ ] Pilot with 1 small dataset/thread
- [ ] Document 'Export to AdviceBomb' in your README
