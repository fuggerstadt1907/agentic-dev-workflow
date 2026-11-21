#!/usr/bin/env bash
# AC11 check (R13): every CHANGELOG entry has at least one link, and every link
# into the case study repo mcp-project-context is pinned to a commit SHA.
#
# Usage:
#   scripts/check-changelog.sh [<file>]
#   scripts/check-changelog.sh --self-test
#
#   --self-test   run the check on planted copies of CHANGELOG.md and confirm it
#                 fires: an entry without a link and a case-study link without a
#                 SHA must both fail, the unchanged copy must pass
#
# An entry is a list item ("- ", "* ", "+ " or "1. ") below the first "## "
# heading, with its indented continuation lines. A link is "](" followed by a
# non-empty target. Exit 0 clean, 1 findings, 2 usage errors.
set -euo pipefail
export LC_ALL=C

# A permalink names the full commit SHA: /blob/<sha>/, /tree/<sha>/, /raw/<sha>/ or /commit/<sha>.
PINNED='/(blob|tree|raw|commit)/[0-9a-f]{40}([/#?]|$)'

check() {
  local file=$1 fail=0
  # Entries without a link, as file:line of the entry's first line.
  if awk -v f="$file" '
    /^## / { inside = 1 }
    function flush() { if (start && !link) { print f ":" start ": entry has no link"; bad = 1 } start = 0 }
    function item() { return $0 ~ /^([-*+]|[0-9]+\.) / }
    item() { flush(); if (inside) { start = NR; link = 0 } }
    !item() && (/^[^ ]/ || /^$/) { flush() }
    start && /\]\([^) ]/ { link = 1 }
    END { flush(); exit bad }
  ' "$file"; then :; else fail=1; fi
  # Links into the case study without a SHA.
  local n url
  while IFS=: read -r n url; do
    if ! printf '%s\n' "$url" | grep -Eq -- "$PINNED"; then
      echo "$file:$n: case-study link without a commit SHA"
      fail=1
    fi
  done < <(grep -noE 'https?://[^ )>]*mcp-project-context[^ )>]*' "$file" || true)
  return $fail
}

self_test() {
  local root ok=1
  root=$(cd "$(dirname "$0")/.." && pwd)
  # Global, not local: the EXIT trap runs after this function has returned.
  SELF_TEST_TMP=$(mktemp -d)
  trap 'rm -rf "$SELF_TEST_TMP"' EXIT
  local tmp=$SELF_TEST_TMP

  cp "$root/CHANGELOG.md" "$tmp/clean.md"
  if check "$tmp/clean.md" >/dev/null; then echo "self-test: clean copy passes"; else
    echo "self-test: FAIL, clean copy was flagged"; ok=0; fi

  cp "$root/CHANGELOG.md" "$tmp/nolink.md"
  printf '\n- Planted entry without a link,\n  over two lines.\n' >> "$tmp/nolink.md"
  grep -q 'Planted entry without a link' "$tmp/nolink.md"
  if check "$tmp/nolink.md" >/dev/null; then echo "self-test: FAIL, entry without a link passed"
    ok=0; else echo "self-test: entry without a link is flagged"; fi

  cp "$root/CHANGELOG.md" "$tmp/nosha.md"
  printf '\n- Planted ([case study](https://github.com/x/mcp-project-context/blob/main/README.md#L1))\n' \
    >> "$tmp/nosha.md"
  grep -q 'mcp-project-context/blob/main/' "$tmp/nosha.md"
  if check "$tmp/nosha.md" >/dev/null; then echo "self-test: FAIL, link without a SHA passed"
    ok=0; else echo "self-test: case-study link without a SHA is flagged"; fi

  [ "$ok" -eq 1 ]
}

case "${1:-}" in
  --self-test) self_test ;;
  -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//' ;;
  -*) echo "check-changelog: unknown option $1" >&2; exit 2 ;;
  *)
    file=${1:-CHANGELOG.md}
    [ -f "$file" ] || { echo "check-changelog: not a file: $file" >&2; exit 2; }
    if check "$file"; then echo "check-changelog: clean"; else exit 1; fi
    ;;
esac
