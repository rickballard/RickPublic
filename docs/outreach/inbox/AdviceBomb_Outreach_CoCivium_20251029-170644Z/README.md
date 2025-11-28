# CoCivium Outreach AdviceBomb
**Package:** AdviceBomb_Outreach_CoCivium_20251029-170644Z  
**Purpose:** Zip-first collateral to kick off contributor outreach for CoCivium / CoSuite.  
**Author:** <your-name>  
**Created (UTC):** 20251029-170644Z

## How to use (BPOE / CoSync quick path)
1) **Repo-first.** Open a *fresh* CoPrime session. Run:
   ```pwsh
   git switch main && git pull --ff-only
   ```
2) **Unzip** this package into a *working area* (`CoTemp` locally or a branch folder in a repo PR).
3) **Run verification** (optional) if you have the CoCache helpers checked out:
   ```pwsh
   # In the folder containing this AdviceBomb
   .\tools\Verify-AdviceBomb.ps1
   ```
4) **Pick a repo landing** (recommendations below) and commit via a short branch → PR → squash-merge:
   - `rickballard/CoContrib/outreach/`  -  **primary** for contributor-facing collateral
   - `rickballard/CoCache/advice/seeds/`  -  if publishing as a seed AdviceBomb for broader reuse
   - `rickballard/CoAgent/docs/outreach/`  -  if aligning with CoAgent guardrailer demos
5) **Open a tiny docs PR** and include the **Outreach_Intro_Email.md** as the email body template.  
6) **(Optional)** Wrap as a formal inbox AdviceBomb for CoCache’s `advice/inbox` using the manifest + checksum.

## Contents
- `outreach/README.md`  -  outreach flow + roles
- `outreach/email_templates/`  -  ready-to-send emails (short/long; sector variants)
- `outreach/snippets/`  -  WhatsApp / DM / PR body snippets
- `outreach/targets/outreach_targets.csv`  -  simple target list
- `scripts/Publish-OutreachPack.ps1`  -  paste-safe PR helper (no AddRange, minimal args)
- `tools/Verify-AdviceBomb.ps1`  -  lightweight checksum & shape check
- `_copayload.meta.json`  -  machine-readable manifest (topic, shas, pointers)
- `_wrap.manifest.json`  -  zip-first wrapper manifest
- `INBOX_LOG_row_template.md`  -  one-line append template when logging into CoCache
- `OUTREACH_CHECKLIST.md`  -  step-by-step “5 minute” path and beyond

## Suggested landing path (repo-first)
- **Preferred:** `rickballard/CoContrib/outreach/20251029-170644Z/...` (then refactor to stable paths on merge)
- PR title: `outreach: seed AdviceBomb + email template (zip-first)`
- Labels: `first-build`, `good first issue`

## Pointers
- Onboarding checklist (Elias path):  
  https://github.com/rickballard/CoContrib/blob/main/contributors/elias/ONBOARDING_CHECKLIST.md
- CoContrib home:  
  https://github.com/rickballard/CoContrib
- Zip-first pattern:  
  https://github.com/rickballard/CoContrib/blob/main/training/README.md
- CoCache inbox guard:  
  https://github.com/rickballard/CoCache/blob/main/advice/inbox/README.md

## Trail
Always leave one: add a CoSync note under `docs/intent/advice/notes/YYYYMMDD/CoSync_<UTCSTAMP>.md` in a relevant repo with: pointers, landing paths, INBOX_LOG tail, open PRs, next steps.

