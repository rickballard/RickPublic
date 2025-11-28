
# ♦ CoBlock — CoEndorse_Seed_v1 (no personal contact info)
$ErrorActionPreference='Stop'; Set-StrictMode -Version Latest
function UTS { (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ') }

param(
  [string]$RepoSlug = 'rickballard/RickPublic',
  [string]$RepoRoot = (Join-Path $HOME 'Documents\GitHub\RickPublic')
)

# 0) Ensure repo is ready
if(!(Test-Path $RepoRoot)){ gh repo clone $RepoSlug $RepoRoot | Out-Null }
git -C $RepoRoot fetch origin *> $null
try{ git -C $RepoRoot switch main *> $null }catch{}
git -C $RepoRoot pull --ff-only *> $null

# 1) Write files
$base = Join-Path $RepoRoot 'outreach\endorse'
New-Item -ItemType Directory -Force $base | Out-Null
New-Item -ItemType Directory -Force (Join-Path $base 'consent') | Out-Null

$files = @{
  'CONSENT_TEMPLATE.md'        = @'
# CoEndorse Micro‑Consent (Revocable)

**Parties**  
Endorser: _________________________________  
Project: CoCivium / CoSuite (open, repo‑first initiative)

**1) Scope**  
Permission to publish the selected sentence(s) verbatim, attributed to the Endorser by name and role/title.
Publication surfaces limited to CoCivium/CoSuite owned web pages, documents, decks, and repositories.
No paid advertising use without renewed consent.

**2) No Affiliation / No Advice**  
Publication does not imply affiliation, governance role, investment advice, or endorsement beyond the literal quoted text.

**3) Edits**  
Only spelling, spacing, or punctuation corrections may be made without re‑approval.

**4) Revocation**  
Endorser may revoke permission at any time via written notice (email acceptable). Project will remove the quote from live surfaces within 72 hours. 
Historical commits may persist in public version history, but the quote will be excised from all active surfaces and indexes.

**5) Jurisdiction**  
Governed by the Endorser’s home jurisdiction; informal resolution preferred.

---
Selected Quote ID:  __Q#__  
Selected Quote Text (verbatim):  
"""
____________________________________________
"""

Signed (Endorser):  _________________________   Date: _____________
Name (print):      _________________________   Role/Title: ________

'@
  'ENDORSE_MENU.md'            = @'
# CoEndorse — Quote Menu (pick one; verbatim or light edit)

Each option avoids affiliation, advice, or governance claims. Quotes are revocable on notice.

**Q1.** “Open, repo‑first guardrails for AI are overdue. CoCivium is a useful push in that direction.”  
**Q2.** “I support experiments in edge‑owned governance where interfaces matter more than titles.”  
**Q3.** “Shipping transparent artifacts beats promises. Judge projects like CoCivium by what’s in the repo.”  
**Q4.** “Keep governance simple, auditable, and reversible. If CoCivium holds to that, it’s worth watching.”  
**Q5.** “Good interfaces constrain power. If CoCivium prioritizes interfaces, that’s the right instinct.”

**Attribution format (we add this footer):**  
— Full Name, role/title (for identification only), date (YYYY‑MM‑DD)  
_Shared with permission. No affiliation implied. Quote may be revoked on notice._

'@
  'ENDORSE_INDEX.yml'          = @'
# Pipeline index for quotes and consents (revocable)
# status: draft | asked | approved | published | revoked

- id: sample-anchor
  name: "Full Name"
  role: "Title, Organization"
  email: "assistant_or_alias@domain.tld"
  status: draft
  quote_id: Q1
  quote_verbatim: "Open, repo‑first guardrails for AI are overdue. CoCivium is a useful push in that direction."
  consent_file: "consent/2025-12-03_FullName.pdf"
  publication_urls: []
  revocation_ts: null

'@
  'EMAIL_TEMPLATE_Principal.md'= @'
Subject: One sentence you control (revocable) for an open guardrails project

Hi {{principal_name}} —

Could we attribute **one sentence** to you (verbatim, revocable) that signals support for transparent, interface‑centric governance? 
No affiliation implied; no meetings required.

Please pick **one** (or lightly edit a word or two):

- Q1: “Open, repo‑first guardrails for AI are overdue. CoCivium is a useful push in that direction.”
- Q2: “I support experiments in edge‑owned governance where interfaces matter more than titles.”
- Q3: “Shipping transparent artifacts beats promises. Judge projects like CoCivium by what’s in the repo.”

If you reply “OK with Q# as written,” we’ll send a 1‑page micro‑consent (revocable anytime; removal within 72 hours on notice).

— {{sender_name}}

'@
  'EMAIL_TEMPLATE_Assistant.md'= @'
Subject: Revocable one‑liner attribution request (no meeting needed)

Hi {{assistant_name}} —

Request for a **single sentence** (revocable) attribution from {{principal_name}} for CoCivium, an open, repo‑first AI guardrails project. 
No affiliation implied. If preferred, reply “OK with Q#,” and we’ll return a 1‑page micro‑consent for e‑signature. 
Publishing begins in ~2–3 weeks.

Menu attached (PDF or link).

{{sender_name}}

'@
  'PRESS_STRIP.md'             = @'
_Shared with permission. No affiliation implied. Quote may be revoked on notice._

'@
}

foreach($name in $files.Keys){
  $p = Join-Path $base $name
  Set-Content -LiteralPath $p -Value $files[$name] -Encoding utf8NoBOM
}

# 2) Commit on short branch
$br = 'docs/coendorse-seed-' + (UTS)
git -C $RepoRoot switch -c $br *> $null
git -C $RepoRoot add 'outreach/endorse' 
git -C $RepoRoot commit -m "docs(coendorse): seed assets (consent, menu, templates, index)" | Out-Null
git -C $RepoRoot push -u origin HEAD | Out-Null

# 3) Open PR
$pr = gh pr create -R $RepoSlug --base main --head $br `
      --title "docs(coendorse): seed endorsement assets" `
      --body  "Adds revocable CoEndorse kit (no personal contact info): consent template, quote menu, email templates, press strip, and YAML pipeline index."
"PR: $pr"
