#!/usr/bin/env python3
import json
import os
import sys
import time
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional, Tuple

import urllib.request
import urllib.error


GRAPH_GATEWAY_TEMPLATE = "https://gateway.thegraph.com/api/{api_key}/subgraphs/id/{subgraph_id}"
DEFAULT_TIMEOUT_SECS = 30
RETRY_BACKOFF_SECS = [0, 1, 3]


@dataclass
class SubgraphSpec:
    key: str
    name: str
    subgraph_id: str
    oracle_version: str
    entity_type: Optional[str]  # e.g., "OptimisticPriceRequest" or "Assertion"
    source_file: str


@dataclass
class SubgraphCheckResult:
    key: str
    name: str
    subgraph_id: str
    oracle_version: str
    entity_type: Optional[str]
    endpoint: str
    status: str  # "ok" | "error"
    http_status: Optional[int]
    error: Optional[str]
    fields: List[str]
    sample_count: Optional[int]
    checked_at: str
    used_api_key_source: str  # "env" | "config" | "unknown"


def read_json(path: str) -> Dict:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def load_subgraph_specs(repo_root: str) -> List[SubgraphSpec]:
    specs: List[SubgraphSpec] = []

    # Primary configs
    candidates: List[Tuple[str, Dict]] = []
    for rel in ["network-config-COMPLETE.json", "network-config.json"]:
        path = os.path.join(repo_root, rel)
        if os.path.exists(path):
            try:
                candidates.append((rel, read_json(path)))
            except Exception:
                # Skip malformed files gracefully
                continue

    def maybe_entity_type(oracle_version: str) -> Optional[str]:
        if oracle_version is None:
            return None
        ov = str(oracle_version).lower()
        if ov == "v3":
            return "Assertion"
        if ov in ("v2", "v1_v2", "v1", "v1v2"):
            return "OptimisticPriceRequest"
        return None

    for rel, cfg in candidates:
        networks = cfg.get("networks", {})
        for key, value in networks.items():
            subgraph_id = value.get("subgraph_id")
            name = value.get("name", key)
            oracle_version = value.get("oracle_version", "")
            entity_type = value.get("entity_type", None) or maybe_entity_type(oracle_version)
            if not subgraph_id:
                continue
            specs.append(
                SubgraphSpec(
                    key=key,
                    name=name,
                    subgraph_id=subgraph_id,
                    oracle_version=oracle_version,
                    entity_type=entity_type,
                    source_file=rel,
                )
            )
    return specs


def resolve_api_key(repo_root: str) -> Tuple[Optional[str], str]:
    # Prefer environment variable
    env_name = None
    # Try common env var names
    for candidate in ["THE_GRAPH_API_KEY", "GRAPH_API_KEY", "THEGRAPH_API_KEY"]:
        if os.getenv(candidate):
            env_name = candidate
            break
    if env_name:
        return os.getenv(env_name), "env"

    # Fallback to network-config-COMPLETE.json if present (not recommended to commit keys)
    complete_path = os.path.join(repo_root, "network-config-COMPLETE.json")
    if os.path.exists(complete_path):
        try:
            cfg = read_json(complete_path)
            api_key = cfg.get("api_config", {}).get("api_key")
            if api_key:
                return api_key, "config"
        except Exception:
            pass
    return None, "unknown"


def http_post_json(url: str, payload: Dict, timeout: int = DEFAULT_TIMEOUT_SECS) -> Tuple[int, str]:
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            status = resp.getcode()
            data = resp.read().decode("utf-8", errors="replace")
            return status, data
    except urllib.error.HTTPError as e:
        try:
            err_body = e.read().decode("utf-8", errors="replace")
        except Exception:
            err_body = str(e)
        return e.code, err_body
    except Exception as e:
        return 0, str(e)


def run_graphql_with_retries(url: str, query: str, variables: Optional[Dict] = None) -> Tuple[int, str]:
    payload = {"query": query}
    if variables:
        payload["variables"] = variables
    last_status = 0
    last_body = ""
    for backoff in RETRY_BACKOFF_SECS:
        if backoff:
            time.sleep(backoff)
        status, body = http_post_json(url, payload)
        last_status, last_body = status, body
        if status and 200 <= status < 500:
            break
    return last_status, last_body


def build_min_query(entity_type: Optional[str]) -> Optional[str]:
    # Minimal safe query by entity type
    if entity_type == "Assertion":
        # V3
        return "query Q{ assertions(first: 1) { id } }"
    if entity_type == "OptimisticPriceRequest":
        # V2
        return "query Q{ optimisticPriceRequests(first: 1) { id } }"
    return None


def build_introspection_query(entity_type: Optional[str]) -> Optional[str]:
    # Try to introspect fields if allowed
    if not entity_type:
        return None
    return (
        "query Introspect($name: String!){ "
        "__type(name: $name) { fields { name } }"
        "}"
    )


def parse_fields_from_introspection(body: str) -> List[str]:
    try:
        data = json.loads(body)
        fields = data.get("data", {}).get("__type", {}).get("fields", [])
        return [f.get("name") for f in fields if "name" in f]
    except Exception:
        return []


def parse_sample_count_from_response(body: str, entity_type: Optional[str]) -> Optional[int]:
    try:
        data = json.loads(body)
        d = data.get("data", {})
        if entity_type == "Assertion":
            arr = d.get("assertions", [])
        else:
            arr = d.get("optimisticPriceRequests", [])
        if isinstance(arr, list):
            return len(arr)
    except Exception:
        pass
    return None


def verify_subgraph(api_key: str, spec: SubgraphSpec) -> SubgraphCheckResult:
    endpoint = GRAPH_GATEWAY_TEMPLATE.format(api_key=api_key, subgraph_id=spec.subgraph_id)
    min_query = build_min_query(spec.entity_type)
    http_status = None
    error = None
    fields: List[str] = []
    sample_count: Optional[int] = None

    if not min_query:
        return SubgraphCheckResult(
            key=spec.key,
            name=spec.name,
            subgraph_id=spec.subgraph_id,
            oracle_version=spec.oracle_version,
            entity_type=spec.entity_type,
            endpoint=endpoint,
            status="error",
            http_status=None,
            error="Unknown entity_type, cannot build query",
            fields=[],
            sample_count=None,
            checked_at=time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            used_api_key_source="env" if os.getenv("THE_GRAPH_API_KEY") else "config" if os.path.exists("network-config-COMPLETE.json") else "unknown",
        )

    status, body = run_graphql_with_retries(endpoint, min_query)
    http_status = status
    if status != 200:
        error = f"GraphQL request failed: status={status}, body={body[:300]}"
    else:
        # Try to get a tiny sample count
        sample_count = parse_sample_count_from_response(body, spec.entity_type)
        # Try to introspect available fields
        introspect = build_introspection_query(spec.entity_type)
        if introspect:
            istatus, ibody = run_graphql_with_retries(endpoint, introspect, {"name": spec.entity_type})
            if istatus == 200:
                fields = parse_fields_from_introspection(ibody)
            else:
                # Introspection disabled or failed; not a hard failure
                fields = []

    return SubgraphCheckResult(
        key=spec.key,
        name=spec.name,
        subgraph_id=spec.subgraph_id,
        oracle_version=spec.oracle_version,
        entity_type=spec.entity_type,
        endpoint=endpoint,
        status="ok" if (http_status == 200 and not error) else "error",
        http_status=http_status,
        error=error,
        fields=fields,
        sample_count=sample_count,
        checked_at=time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        used_api_key_source="env" if os.getenv("THE_GRAPH_API_KEY") else "config" if os.path.exists("network-config-COMPLETE.json") else "unknown",
    )


def write_registry(out_json_path: str, out_md_path: str, results: List[SubgraphCheckResult]) -> None:
    os.makedirs(os.path.dirname(out_json_path), exist_ok=True)

    registry = {
        "generatedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "total": len(results),
        "ok": sum(1 for r in results if r.status == "ok"),
        "error": sum(1 for r in results if r.status == "error"),
        "subgraphs": [asdict(r) for r in results],
    }
    with open(out_json_path, "w", encoding="utf-8") as f:
        json.dump(registry, f, indent=2, ensure_ascii=False)

    # Minimal markdown overview
    lines: List[str] = []
    lines.append(f"# Subgraph Registry (verified)")
    lines.append("")
    lines.append(f"- Generated: {registry['generatedAt']}")
    lines.append(f"- Total: {registry['total']} | OK: {registry['ok']} | Error: {registry['error']}")
    lines.append("")
    lines.append("| Key | Name | Version | Status | Sample | Endpoint |")
    lines.append("|---|---|---|---|---:|---|")
    for r in results:
        sample = r.sample_count if r.sample_count is not None else "-"
        lines.append(f"| `{r.key}` | {r.name} | {r.oracle_version} | {r.status} | {sample} | `{r.endpoint}` |")
    with open(out_md_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def main(argv: List[str]) -> int:
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    api_key, key_source = resolve_api_key(repo_root)
    if not api_key:
        print("ERROR: No Graph API key found. Set THE_GRAPH_API_KEY or provide api_config.api_key in network-config-COMPLETE.json", file=sys.stderr)
        return 2

    specs = load_subgraph_specs(repo_root)
    if not specs:
        print("ERROR: No subgraphs found in configs.", file=sys.stderr)
        return 3

    results: List[SubgraphCheckResult] = []
    for spec in specs:
        res = verify_subgraph(api_key, spec)
        results.append(res)

    out_json = os.path.join(repo_root, "subgraphs", "REGISTRY.json")
    out_md = os.path.join(repo_root, "subgraphs", "REGISTRY.md")
    write_registry(out_json, out_md, results)

    # Exit non-zero if any error to ensure CI visibility
    has_error = any(r.status != "ok" for r in results)
    return 1 if has_error else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))


