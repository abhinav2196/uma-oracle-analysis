#!/usr/bin/env python3
import argparse
import json
import os
import sys
import time
from typing import Dict, List, Optional, Tuple
import urllib.request
import urllib.error
import ssl

# Add parent directory to path for imports when run from repo root
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from scripts.lib.io_utils import ensure_dir, output_paths

# Create SSL context that doesn't verify certificates (for development)
_ssl_context = ssl._create_unverified_context()


GRAPH_GATEWAY_TEMPLATE = "https://gateway.thegraph.com/api/{api_key}/subgraphs/id/{subgraph_id}"
DEFAULT_PAGE_SIZE = 1000
DEFAULT_TIMEOUT_SECS = 40
RETRY_BACKOFF = [0, 1, 3]


def read_json(path: str) -> Dict:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def resolve_api_key(repo_root: str) -> Optional[str]:
    for env in ["THE_GRAPH_API_KEY", "GRAPH_API_KEY", "THEGRAPH_API_KEY"]:
        if os.getenv(env):
            return os.getenv(env)
    # As a last resort, look in network-config-COMPLETE.json (not recommended)
    p = os.path.join(repo_root, "network-config-COMPLETE.json")
    if os.path.exists(p):
        try:
            cfg = read_json(p)
            return cfg.get("api_config", {}).get("api_key")
        except Exception:
            return None
    return None


def load_network_config(repo_root: str) -> Dict:
    # Prefer the more complete config
    candidates = ["network-config-COMPLETE.json", "network-config.json"]
    for rel in candidates:
        p = os.path.join(repo_root, rel)
        if os.path.exists(p):
            try:
                return read_json(p)
            except Exception:
                continue
    return {}


def infer_entity_type(oracle_version: str) -> Optional[str]:
    if not oracle_version:
        return None
    ov = oracle_version.lower()
    if ov == "v3":
        return "Assertion"
    if ov in ("v2", "v1_v2", "v1"):
        return "OptimisticPriceRequest"
    return None


def infer_time_field(entity_type: Optional[str]) -> List[str]:
    # Try these fields in order for pagination
    if entity_type == "Assertion":
        return ["assertionTimestamp"]
    return ["time", "timestamp"]


def http_post_json(url: str, payload: Dict, timeout: int = DEFAULT_TIMEOUT_SECS) -> Tuple[int, str]:
    body = json.dumps(payload).encode("utf-8")
    headers = {
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }
    req = urllib.request.Request(url, data=body, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=timeout, context=_ssl_context) as resp:
            return resp.getcode(), resp.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        try:
            err = e.read().decode("utf-8", errors="replace")
        except Exception:
            err = str(e)
        return e.code, err
    except Exception as e:
        return 0, str(e)


def run_gql(url: str, query: str, variables: Optional[Dict] = None) -> Tuple[int, str]:
    payload = {"query": query}
    if variables:
        payload["variables"] = variables
    status, body = 0, ""
    for back in RETRY_BACKOFF:
        if back:
            time.sleep(back)
        status, body = http_post_json(url, payload)
        if 200 <= status < 500:
            break
    return status, body


def build_query(entity_type: str, time_field: str, fields: List[str]) -> str:
    """
    Paginates by (time_field, id) to achieve stable ordering.
    """
    collection = "assertions" if entity_type == "Assertion" else "optimisticPriceRequests"
    # Ensure required fields in selection
    selection = ["id", time_field]
    for f in fields:
        if f not in selection:
            selection.append(f)
    selection_str = " ".join(selection)
    # where: time >= from, time <= to, and (time > lastTime || (time == lastTime && id > lastId))
    # The Graph cannot express compound comparisons directly; we approximate by:
    #   where: { <time_field>_gte: $from, <time_field>_lte: $to, id_gt: $lastId }
    # and rely on strictly increasing id when within a narrow time window.
    # This is a pragmatic tradeoff for simplicity.
    q = f"""
query Page($first: Int!, $from: Int!, $to: Int!, $lastId: ID!) {{
  {collection}(
    first: $first
    orderBy: {time_field}
    orderDirection: asc
    where: {{ {time_field}_gte: $from, {time_field}_lte: $to, id_gt: $lastId }}
  ) {{
    {selection_str}
  }}
}}
""".strip()
    return q


def fetch_all(endpoint: str, entity_type: str, time_field: str, from_ts: int, to_ts: int, fields: List[str], page_size: int) -> List[Dict]:
    query = build_query(entity_type, time_field, fields)
    all_rows: List[Dict] = []
    last_id = ""
    while True:
        status, body = run_gql(
            endpoint,
            query,
            {"first": page_size, "from": int(from_ts), "to": int(to_ts), "lastId": last_id},
        )
        if status != 200:
            raise RuntimeError(f"GraphQL error status={status} body={body[:300]}")
        data = json.loads(body).get("data", {})
        collection = "assertions" if entity_type == "Assertion" else "optimisticPriceRequests"
        page = data.get(collection, [])
        if not page:
            break
        all_rows.extend(page)
        last_id = page[-1]["id"]
        if len(page) < page_size:
            break
    return all_rows


def main() -> int:
    parser = argparse.ArgumentParser(description="Fetch subgraph data into data-dumps/{network}/{period}")
    parser.add_argument("--network", required=True, help="network key from network-config(-COMPLETE).json (e.g., polygon_v2_new, ethereum_v3)")
    parser.add_argument("--period", required=False, help="time period key from config (e.g., september_2025)")
    parser.add_argument("--from", dest="from_ts", type=int, help="start timestamp (unix seconds)")
    parser.add_argument("--to", dest="to_ts", type=int, help="end timestamp (unix seconds)")
    parser.add_argument("--fields", nargs="*", default=[], help="additional fields to fetch (identifier, ancillaryData, etc.)")
    parser.add_argument("--page-size", type=int, default=DEFAULT_PAGE_SIZE)
    args = parser.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    cfg = load_network_config(repo_root)
    networks = cfg.get("networks", {})
    if args.network not in networks:
        print(f"ERROR: network '{args.network}' not found in config", file=sys.stderr)
        return 2
    ncfg = networks[args.network]
    subgraph_id = ncfg.get("subgraph_id")
    oracle_version = ncfg.get("oracle_version", "")
    entity_type = ncfg.get("entity_type") or infer_entity_type(oracle_version)
    if not subgraph_id or not entity_type:
        print("ERROR: missing subgraph_id or unknown entity_type", file=sys.stderr)
        return 3

    # Resolve period timestamps
    from_ts = args.from_ts
    to_ts = args.to_ts
    if (from_ts is None or to_ts is None) and args.period:
        periods = cfg.get("time_periods", {})
        if args.period in periods:
            from_ts = from_ts or int(periods[args.period]["from"])
            to_ts = to_ts or int(periods[args.period]["to"])
    if from_ts is None or to_ts is None:
        print("ERROR: provide --period or both --from and --to", file=sys.stderr)
        return 4

    api_key = resolve_api_key(repo_root)
    if not api_key:
        print("ERROR: THE_GRAPH_API_KEY not set and no fallback api_key found", file=sys.stderr)
        return 5

    endpoint = GRAPH_GATEWAY_TEMPLATE.format(api_key=api_key, subgraph_id=subgraph_id)

    # Select time field
    time_fields = infer_time_field(entity_type)
    chosen_time: Optional[str] = None
    # Try a probing query to pick the working time field
    for tf in time_fields:
        probe = f"query{{ {'assertions' if entity_type=='Assertion' else 'optimisticPriceRequests'}(first:1){{ id {tf} }} }}"
        st, body = run_gql(endpoint, probe)
        if st == 200 and "data" in body:
            chosen_time = tf
            break
    if not chosen_time:
        print("ERROR: Could not determine time field (tried: %s)" % ", ".join(time_fields), file=sys.stderr)
        return 6

    rows = fetch_all(endpoint, entity_type, chosen_time, int(from_ts), int(to_ts), args.fields, args.page_size)

    # Write outputs under data-dumps/{network}/{period_key or range}
    base_dir = os.path.join(repo_root, "data-dumps")
    period_key = args.period or f"{from_ts}_{to_ts}"
    stem = f"{args.network}_{period_key}"
    dir_path, json_path, _csv_path = output_paths(base_dir, args.network, period_key, stem)
    ensure_dir(dir_path)
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(rows, f, indent=2, ensure_ascii=False)
    print(f"Wrote {len(rows)} rows to {json_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


