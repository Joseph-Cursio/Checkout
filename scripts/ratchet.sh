#!/usr/bin/env bash
# Escape-hatch ratchet (essay §4).
#
# You can't remove every `@unchecked Sendable` today. You can refuse to add
# new ones. This script counts escape-hatch findings and fails if the count
# rose above the number committed in `.escape-hatch-baseline`.
#
#   scripts/ratchet.sh            check against the baseline
#   scripts/ratchet.sh --update   lower the baseline after removing hatches
#
# Set SWIFTPROJECTLINT to the CLI binary if it isn't on PATH as `swiftprojectlint`.
set -euo pipefail

linter="${SWIFTPROJECTLINT:-swiftprojectlint}"
root="$(cd "$(dirname "$0")/.." && pwd)"
baseline_file="$root/.escape-hatch-baseline"

hatches='["Unchecked Sendable","Nonisolated Unsafe","Preconcurrency Import","Preconcurrency Conformance"]'

# The linter exits non-zero when it finds warnings; the ratchet judges by count, not exit code.
count=$("$linter" "$root" --format json --threshold error \
    | jq --argjson hatches "$hatches" '[.issues[] | select(.ruleName as $rule | $hatches | index($rule))] | length')
baseline=$(cat "$baseline_file")

if [[ "${1:-}" == "--update" ]]; then
    if (( count > baseline )); then
        echo "Refusing to raise the baseline from $baseline to $count." >&2
        exit 1
    fi
    echo "$count" > "$baseline_file"
    echo "Baseline set to $count."
    exit 0
fi

if (( count > baseline )); then
    echo "Escape hatches rose from $baseline to $count. Remove the new one, or justify it in review." >&2
    exit 1
fi
echo "Escape hatches: $count (baseline $baseline)."
if (( count < baseline )); then
    echo "Fewer than the baseline — run 'scripts/ratchet.sh --update' to lock in the improvement."
fi
