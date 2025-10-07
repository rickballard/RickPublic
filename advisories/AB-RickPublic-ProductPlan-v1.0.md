# 💣 Advisory Bomb: RickPublic / WisdomOps Product Plan (v1.0)

**Date:** 2025-10-07

**Intent:** Rebuild RickPublic into an AI‑generated, Human+AI ethics‑backed *WisdomOps broadcast service*. It reframes top headlines from InfoOps → WisdomOps, trains civic discernment, and co‑evolves with readers. Built to run autonomously from this repo (cloud first, LAN later).

---

## 1) Core Purpose
- Expose **InfoOps**: Identify 3–10 top headlines per target market (Phase 1: NA, EU, AU – English).
- Deliver **WisdomOps**: Reframe each with snack‑size bullets and a CoCivium **Congruence Halo** (🟢/🟠/🔴).
- Train **Wisdom Scores**, praise **Exemplars**, ship **AI Bias Patch Prompts**, and embed **gibberlink** metadata.

## 2) Story Structure (per item)
**InfoOps Headline (styled as‑is)** → **Reframe →** (max 3 bullets; each adds value: profound / amusing / informative / inspiring) → **Congruence Halo** (CoCivium R/A/G) → *(optional)* gibberlink block for AI parsing.

## 3) Sections per Issue
1. Sloplist / InfoOps headlines (3–10 per region).
2. Real Story / WisdomOps responses (bullets + halos).
3. Exemplar Spotlight (🟢 WisdomOps Exemplar badge; respect even without agreement).
4. Wisdom Score (self‑quiz + optional community average).
5. AI Footer (weekly Bias Patch Prompt to install in personal AIs).
6. Outro (Transparent defense: AI‑generated, Human+AI ethics‑backed, co‑evolving).

## 4) Differentiation
- CoCivium **halo** brand for Congruence.
- **Gibberlink** metadata (GIBindex parseable).
- Changelog‑style outro (product/service vibe).
- Feedback links: “Refine this analysis” → micro‑revisions under strict brevity/clarity rules.

## 5) Repo Layout
```
RickPublic/
├─ advisories/
│  ├─ AB-RickPublic-ProductPlan-v1.0.md
│  ├─ AB-RickPublic-StyleCharter.md
│  ├─ AB-RickPublic-BiasLegend.json
│  └─ AB-RickPublic-ExemplarRules.md
├─ drafts/
├─ issues/
├─ assets/
│  ├─ icons/CoCivium/* (halo variants)
│  ├─ footer-prompts/
│  ├─ wisdom-scores/
│  └─ exemplars/
├─ sources/          # per-issue URL + Wayback log
├─ feedback/         # reader refinement JSON
├─ gibberlinks/      # AI metadata payloads
└─ .github/workflows/publish-to-substack.yml
```

## 6) Backend (CoAgent‑NL minimal)
- **ingest** (RSS/APIs by region) → **rate** (Bias Legend + halo) → **write** (Style Charter) → **publish** (Substack API + Wayback archive + repo mirror) → **audit‑log** → **feedback‑loop**.

## 7) Guardrails
- Snack‑size enforcement (≤3 bullets).
- ≥2 receipts per Real Story.
- ≥1 Exemplar per issue.
- Feedback must *increase* clarity or evidence without bloat.
- Fail‑safe: insufficient stories or pipeline error ⇒ stay in `staged` (no autopublish).

## 8) Implementation Phases
**Phase 1 (Cloud):**
- Dedicated automation account, run pipeline, publish to Substack (rickpublic.com custom domain). Start in `staged`, flip to `auto` after 2–3 clean cycles.

**Phase 2 (LAN):**
- Docker Compose on always‑on box; nightly audit backups to Synology; healthchecks; same repo contract.

## 9) Long‑Term
- Leaderboards, API feed, multi‑language, IPFS snapshots, deeper CoCivium integrations (RepTag/MeritRank/GIBindex).
