SHELL := /bin/bash

.PHONY: help verify-subgraphs inventory-scripts fetch convert filter

help:
	@echo "Available targets:"
	@echo "  verify-subgraphs     Verify all configured subgraphs via The Graph gateway"
	@echo "  inventory-scripts    Generate scripts inventory and manifest"
	@echo "  fetch                Fetch subgraph data into data-dumps/{network}/{period}"
	@echo "  convert              Convert JSON to CSV and decode hex fields"
	@echo "  filter               Filter CSV rows with simple conditions"

verify-subgraphs:
	@echo "Verifying subgraphs..."
	@THE_GRAPH_API_KEY=$${THE_GRAPH_API_KEY} python3 scripts/verify_subgraphs.py

inventory-scripts:
	@echo "Generating scripts inventory..."
	@python3 scripts/inventory_scripts.py

fetch:
	@echo "Usage: make fetch NETWORK=<network_key> PERIOD=<period_key> [FROM=<ts>] [TO=<ts>] [FIELDS='identifier ancillaryData']"
	@test -n "$${NETWORK}" || (echo "Set NETWORK=<key>"; exit 2)
	@THE_GRAPH_API_KEY=$${THE_GRAPH_API_KEY} python3 scripts/fetch.py --network "$${NETWORK}" $$(test -n "$${PERIOD}" && echo --period "$${PERIOD}") $$(test -n "$${FROM}" && echo --from "$${FROM}") $$(test -n "$${TO}" && echo --to "$${TO}") $$(test -n "$${FIELDS}" && echo --fields $${FIELDS})

convert:
	@echo "Usage: make convert NETWORK=<network_key> PERIOD=<period_key> INPUT=<path.json> [HEX_FIELDS='identifier ancillaryData'] [STEM=<name>]"
	@test -n "$${NETWORK}" || (echo "Set NETWORK=<key>"; exit 2)
	@test -n "$${PERIOD}" || (echo "Set PERIOD=<key>"; exit 2)
	@test -n "$${INPUT}" || (echo "Set INPUT=<path.json>"; exit 2)
	@python3 scripts/convert.py --network "$${NETWORK}" --period "$${PERIOD}" --input-json "$${INPUT}" $$(test -n "$${HEX_FIELDS}" && echo --hex-fields $${HEX_FIELDS}) $$(test -n "$${STEM}" && echo --stem "$${STEM}")

filter:
	@echo "Usage: make filter NETWORK=<network_key> PERIOD=<period_key> INPUT=<path.csv> WHERE='col==val col~substr'"
	@test -n "$${NETWORK}" || (echo "Set NETWORK=<key>"; exit 2)
	@test -n "$${PERIOD}" || (echo "Set PERIOD=<key>"; exit 2)
	@test -n "$${INPUT}" || (echo "Set INPUT=<path.csv>"; exit 2)
	@test -n "$${WHERE}" || (echo "Set WHERE='conditions'"; exit 2)
	@python3 scripts/filter.py --network "$${NETWORK}" --period "$${PERIOD}" --input-csv "$${INPUT}" --where $${WHERE}


