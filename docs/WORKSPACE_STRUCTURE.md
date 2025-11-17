## Workspace Structure and Canonical Entry Points

This repository contains analysis artifacts, data dumps, and scripts. To reduce duplication and clarify “what works”, use the following canonical entry points:

- `make verify-subgraphs` — Verifies all configured subgraphs via The Graph gateway and generates:
  - `subgraphs/REGISTRY.json` (machine-readable results)
  - `subgraphs/REGISTRY.md` (human-readable summary)
- `make inventory-scripts` — Scans the repo for `.sh` and `.py` scripts and generates:
  - `scripts/SCRIPTS_MANIFEST.json` (detailed metadata per script)
  - `WORKSPACE_MANIFEST.md` (overview table with duplicates highlighted)
- `make fetch` — Fetch data for a specific network and period into the standard directory:
  - Output: `data-dumps/{network}/{period}/{network}_{period}.json`
- `make convert` — Convert a JSON dump to CSV and decode hex fields:
  - Output: `data-dumps/{network}/{period}/{stem}.csv`
- `make filter` — Filter a CSV by simple AND conditions (==, !=, ~, !~):
  - Output: `data-dumps/{network}/{period}/{stem}_filtered.csv`

### Directory overview

- `scripts/`
  - `verify_subgraphs.py`: Fetches subgraph metadata and confirms basic queryability.
  - `inventory_scripts.py`: Produces script inventory and duplicate map.
  - `fetch.py`: Unified schema-aware fetcher (V2/V3) with time-range and field selection.
  - `convert.py`: Hex→text decoding and CSV conversion.
  - `filter.py`: Simple CSV filters with AND conditions.
  - `lib/`: Shared helpers.
- `subgraphs/`
  - `REGISTRY.json`, `REGISTRY.md`: Generated verification outputs.
- `data-transformation-scripts/`
  - Legacy/working scripts used during exploration (kept intact). We will gradually consolidate these behind canonical scripts in `scripts/`.
- `data-dumps/`
  - Standardized layout:
    - `data-dumps/{network}/{period}/`
      - `..._full.json` (optional), `{network}_{period}.json` (fetch output), `{stem}.csv` (converted), `{stem}_filtered.csv` (filtered)
- `docs/`
  - Reports and analysis documentation.

### Environment configuration

Set your Graph API key:

```bash
export THE_GRAPH_API_KEY=YOUR_KEY
```

### Next consolidation steps

- Unify JSON→CSV converters into a single version-aware CLI under `scripts/`.
- Introduce shared helpers (curl/retry, IO conventions) and update legacy shell scripts progressively to use them.



