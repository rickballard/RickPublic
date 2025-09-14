# RickPublic

**Purpose:** Source-of-truth repo for Rick's public writing (Substack-first), reusable assets, presets, and backlinks into CoCivium. Keep articles **punchy, bulleted, well-cited, method-transparent**, with optional **ScripTag** hooks.

## What lives here
- `articles/` — Markdown sources mirroring or pre-staging Substack posts.
- `presets/` — Style/profile presets applied to new articles.
- `templates/` — Article skeletons (short, punchy), figure callouts, footnotes, ScripTag blocks.
- `infographics/` — Data + scripts for maps & BCG-style matrices.
- `scripts/` — Utilities to sync/import/export with Substack and manage presets.
- `links/` — Crosslinks to CoCivium-related repos and IdeaCards.
- `ScripTag/` — Temporary pointer until the ScripTag engine repo is live.

## Style Tenets (short)
- **Say less. Mean more.** Assume smart readers.
- **Bullets > paragraphs**. Each bullet earns its keep.
- **No fluff; show methods.** Link sources and formulas.
- **Conjoint terms** allowed (e.g., `DonDemogog`) with double caps when joining concepts.

## ScripTag (placeholder)
Until the engine is live, use this badge in articles:
```
[ScripTag: merit-method-v0](/ScripTag/README.md)
```
Point it at a section that documents method & assumptions.

## Suggested Workflow
1. Draft article from a template in `templates/`.
2. Add figures via `infographics/` (keep data/fig scripts versioned).
3. Publish to Substack; mirror the MD in `articles/` with a link back.
4. Create an IdeaCard in CoCivium referencing the article (future automation).

## Relevant Repos
- CoCivium — constitutional + process layer
- MeritRank — reputation & voting primitives (see below)
- (Future) ScripTag/RepTag/VoteRank — engines & badges

---

### Seed Article: The DonDemogog
**Definition (concise):**
- **Don** — gangster boss (fear, capture)
- **Demogog** — manipulative populist (crisis-for-power)
- **DonDemogog** — a political gangster who _manufactures crisis_ and _hijacks institutions_.

**Figures:**
- World map: hotspots via corruption + press freedom + populism indices.
- BCG-style matrix: X=Institutional Resilience, Y=Crisis Exploitation. Bubbles sized by population or GDP.

**Method (replicable):**
- Data: Transparency International (CPI), Freedom House (PF), V-Dem or WGI for governance.
- Normalize 0–1; composite = w1*CPI_inv + w2*PF_inv + w3*PopulismScore.
- Publish weights & code in `infographics/methods/`.
