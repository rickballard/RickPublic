# Methods (BCG-style DonDemogog scoring)

Files:
- `weights.yml`  -  weights for CPI_inv, Press_inv, PopulismScore
- `schema.md`  -  column definitions and valid ranges
- `score.ps1`  -  reference scorer (reads CSV, writes scored CSV)

Repro:
1) Edit `weights.yml` if needed.
2) Run: `pwsh -File .\infographics\methods\score.ps1 -In .\infographics\matrices\data.csv -Out .\infographics\matrices\scored.csv`

