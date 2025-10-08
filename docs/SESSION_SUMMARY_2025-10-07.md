# Session Summary — RickPublic / WisdomOps — 2025-10-07

This document captures everything from the session so nothing is lost outside chat history.

---

## 1) Newsletter / “Reframe” Product Plan (RickPublic)

**Goal:** Expose info-ops and bias by reframing the top stories per market (initially EN: NA/EU/AUS).  
**North Star:** Prioritize wisdom over reprogramming; readers leave more informed, less manipulated.

### Format
- **Story Block = Original → Reframe → Bullets**
  - **Original (clickbait)**: one line (no quotes).
  - **Reframe**: one line, truthful/neutral/precise alternative headline.
  - **Bullets (3–5)**: plain‑English, snack‑size; either profound, amusing, highly informative, inspiring, or entertaining.
- **Congruence strip** with CoCivium halo (R/A/G/grey) and a small legend link.
- **“The Real Story”** short paragraph when needed; link to sources.
- **Footer**: “Make your AI reasonable”: link to a prompt/preset page (CoEvolve / CoCivium compatible).

### Ratings (iconic, not numeric)
- **Truth** (how fact‑aligned) → halo color mapping.
- **Source bias** (declared vs inferred).
- **Intent type** (inform, sell, outrage, op‑ed, tribal, astroturf).
- **Ethics** (fairness, privacy, manipulation level).

### Exemplars (praise references)
- Promote media exemplars that model good practice—even if we disagree with conclusions.
- Exemplar callouts are brief, with links and a one‑line “why respected”.

### Reader co‑evolution
- **Feedback micro‑form** per story: asks targeted questions; updates article in real‑time if revision improves clarity without bloat.
- “Snack‑size” preserved by editing for brevity; long material links out.

### Delivery cadence
- 5–10 minute read per issue, 3–10 stories per locale.
- Start weekly; move to 3×/week when pipeline is stable.

### Initial scope
- English regions first (NA/EU/AUS). Add locales later with local editors/curators.

---

## 2) Implementation Plan

### Repo structure (already aligned)
```
assets/
  branding/                 # RP logo (JPG + transparent PNGs)
  icons/CoCivium/           # halo-*.svg (+ png/)
docs/
  SESSION_SUMMARY_2025-10-07.md
  Newsletter_Reframe_ProductPlan_v1.0.md
  BPOE_Workflow_Notes_SVG_And_Assets.md
tools/
  brand-assets.ps1          # SVG hex-swap + PNG export
  raster-logo.ps1           # JPG -> transparent PNGs
advisories/
  AB-RickPublic-ProductPlan-v1.0.md         # existing
  AB-RickPublic-StyleCharter.md             # existing
  AB-RickPublic-ExemplarRules.md            # existing
  AB-RickPublic-BiasLegend.json             # existing
drafts/
feedback/
gibberlinks/
sources/
```

### Content pipeline (AI‑first, human‑backed ethics)
1) **Fetch & cluster** top stories by locale; dedupe near‑duplicates; compute stance/bias fingerprints.  
2) **Reframe agent** drafts “Original → Reframe → Bullets” + “Real Story” paragraph.  
3) **Ethics engine** (human+AI rules): truth/bias/intent/ethics icons; block low‑confidence narratives.  
4) **Editor pass** (style charter): correctness > zing; brevity; no hedging language.  
5) **Publish** to Substack; auto‑tweet/thread optional; archive sources.  
6) **Feedback** collected and applied with throttled live updates.  

### Telemetry & traction
- Track opens/CTRs on “Reframe vs Original” lines.
- A/B test number of bullets and tone.
- “Wisdom score” per reader (private): reading depth, diversity of sources engaged, constructive feedback ratio.

### Backend (stripped CoAgent)
- Dedicated process to run fetch → reframe → ethics → publish.
- Start cloud‑hosted; later move to LAN box.
- No “Humangate” necessary for routine runs; alerts when ethics confidence < threshold.

---

## 3) BPOE / Workflow Lessons (What we learned)

- **GitHub SVG Preview Pitfall**: Colored variants failed to render because structure was modified (styles/currentColor).  
  **Fix**: Sanitize once, then **clone via hex‑swap** of the grey color (#666666). GitHub‑safe.  
- **Inkscape not required**: ImageMagick good enough for PNG exports.  
- **Idempotent tools**: Added `brand-assets.ps1` and `raster-logo.ps1`; safe to re‑run anytime.  
- **.gitignore**: Ignore `*.bak` in halo folder.  
- **Substack**: Prefer SVG; fallback to PNG where SVG is stripped.

---

## 4) Asset & Tool Inventory (as of this session)

**Assets**
- `assets/icons/CoCivium/halo-{grey,green,amber,red,white,black}.svg`
- `assets/icons/CoCivium/png/halo-{grey,green,amber,red,white,black}.png`
- `assets/branding/RickPublic_Logo_Black_On_White.jpg`
- `assets/branding/RickPublic_Logo_{Black,White}_On_Transparent.png`

**Tools**
- `tools/brand-assets.ps1` (SVG color variants + optional PNGs)
- `tools/raster-logo.ps1` (transparent PNGs from JPG)

---

## 5) Usage (tested commands)

```pwsh
# Rebuild icons from grey master + PNGs
.	oolsrand-assets.ps1 -MasterSvg assets\icons\CoCivium\halo-grey.svg -OutDir assets\icons\CoCivium -BaseName halo -Png

# Rebuild transparent RP logo PNGs
.	oolsaster-logo.ps1 -InputJpg assetsranding\RickPublic_Logo_Black_On_White.jpg -OutDir assetsranding -BaseName RickPublic_Logo
```

---

## 6) Next Steps

- Add Substack publish wiring to `.github/workflows/publish-to-substack.yml` (secrets required).
- Add wisdom score telemetry (private) and reader feedback micro‑form.
- Extend exemplar rules and bias legend as JSON schemas.
- Consider white/dark site themes and automatic halo selection.
