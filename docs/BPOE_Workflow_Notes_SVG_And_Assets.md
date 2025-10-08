# BPOE_Workflow_Notes_SVG_And_Assets

## SVG Rendering (GitHub)
- Avoid rewriting structure (no root style/currentColor or aggressive shape edits).
- Sanitize once (remove `<image>`, `foreignObject`, external `href`, script/import).
- Keep **grey master**; generate color variants by **hex swap** only.

## Tools
- `tools/brand-assets.ps1`: Detect grey hex, clone & swap to produce variants. Optional PNG export via ImageMagick.
- `tools/raster-logo.ps1`: Remove white / black backgrounds to produce transparent PNGs.

## ImageMagick
- Preferred for raster operations and PNG exports.
- Standard export: `-background none -density 384 -resize 256x256`.

## Hygiene
- Ignore `*.bak` SVGs.
- Keep assets small; remove metadata if needed by saving as “Plain SVG”.

## Substack
- Prefer SVG in posts; use PNG fallback for social previews or platforms that strip SVG.
