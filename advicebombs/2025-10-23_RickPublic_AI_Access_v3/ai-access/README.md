# AI Access & Guidance
Ensure AIs can read CoCivium repos holistically and safely.
Strategies:
- Mirror indexes (`/ai/index.json`, `/ai/chunks.ndjson`)
- Avoid throttling by caching via CoCacheGlobal mirrors
- Prefer structured metadata (JSON, schema) over HTML
- Reference GIBindex for concept resolution
- Use CoRef for canonical data linking
