#!/usr/bin/env bash
# AC1 check: no German text under a directory (default: skills/), apart from the
# legacy-terms block that both skills read (D42). The block must match the
# allowed text below byte for byte and may appear at most once per file.
#
# Usage:
#   scripts/check-no-german.sh [<dir>]
#   scripts/check-no-german.sh --self-test
#
#   --self-test   run the check on planted copies of skills/ and confirm it
#                 fires: a German sentence outside the block and an edit inside
#                 the block must both fail, the unchanged copy must pass
#
# German markers: umlauts, sharp s, and common German words and template terms.
# Exit 0 clean, 1 findings, 2 usage errors.
set -euo pipefail
export LC_ALL=C

read -r -d '' ALLOWED_BLOCK <<'EOF' || true
> **Legacy terms from the German version.** Status markers are machine-facing: written only in
> English, read in both languages. `Stand` = `Updated` · `Etappe` = `Stage` · `offen` = `open` ·
> `umgesetzt` = `done`. Headings, column names and criterion IDs are human-facing: written in the
> project's language, read in both. `Etappen` = `Stages` · `AK` = `AC` ·
> `Offene Punkte` = `Open questions` · `Entscheidungsprotokoll` = `Decision log` ·
> `Wer klärt` = `Owner` · `Blockiert` = `Blocks`
EOF

# Alternation instead of a bracket expression: multibyte characters match as
# exact byte sequences under LC_ALL=C on every platform.
UMLAUTS='ä|ö|ü|Ä|Ö|Ü|ß'
WORDS='der|die|das|und|nicht|ist|sind|ein|eine|einen|mit|für|auf|wird|werden|oder|auch|nur|noch'
WORDS="$WORDS|du|dem|den|des|zum|zur|bei|nach|wenn|dann|sich|wie|wer|sonst|immer|nie|kein|keine"
WORDS="$WORDS|Etappe|Etappen|offen|umgesetzt|Stand|Entscheidungsprotokoll|Blockiert|Offene"
WORDS="$WORDS|Punkte|Frage|Fragen|Lücke|Schritt|Empfohlen|Blickwinkel|Vorlage"
PATTERN="$UMLAUTS|(^|[^[:alnum:]_])($WORDS)([^[:alnum:]_]|\$)"

check() {
  local dir=$1 fail=0 f first nlines n start end
  first=$(printf '%s\n' "$ALLOWED_BLOCK" | head -1)
  nlines=$(printf '%s\n' "$ALLOWED_BLOCK" | wc -l | tr -d ' ')
  while IFS= read -r -d '' f; do
    n=$(grep -cxF -- "$first" "$f" || true)
    if [ "$n" -gt 1 ]; then
      echo "$f: legacy block appears $n times"
      fail=1
    fi
    start=0
    if [ "$n" -eq 1 ]; then
      start=$(grep -nxF -- "$first" "$f" | cut -d: -f1)
      end=$((start + nlines - 1))
      if ! sed -n "${start},${end}p" "$f" | cmp -s - <(printf '%s\n' "$ALLOWED_BLOCK"); then
        echo "$f:$start: legacy block differs from the allowed text"
        fail=1
      fi
    fi
    # Blank out exactly the allowed block (keeps line numbers), then search.
    if awk -v s="$start" -v e=$((start + nlines - 1)) \
      's > 0 && NR >= s && NR <= e { print ""; next } { print }' "$f" |
      grep -nE -- "$PATTERN" | sed "s|^|$f:|"; then
      fail=1
    fi
  done < <(find "$dir" -type f -name '*.md' -print0 | sort -z)
  return $fail
}

self_test() {
  local root ok=1
  root=$(cd "$(dirname "$0")/.." && pwd)
  # Global, not local: the EXIT trap runs after this function has returned.
  SELF_TEST_TMP=$(mktemp -d)
  trap 'rm -rf "$SELF_TEST_TMP"' EXIT
  local tmp=$SELF_TEST_TMP

  cp -R "$root/skills" "$tmp/clean"
  if check "$tmp/clean" >/dev/null; then echo "self-test: clean copy passes"; else
    echo "self-test: FAIL, clean copy was flagged"; ok=0; fi

  cp -R "$root/skills" "$tmp/outside"
  printf '\nDie Etappe ist offen.\n' >> "$tmp/outside/grill-ticket/SKILL.md"
  grep -q 'Die Etappe ist offen.' "$tmp/outside/grill-ticket/SKILL.md"
  if check "$tmp/outside" >/dev/null; then echo "self-test: FAIL, German outside the block passed"
    ok=0; else echo "self-test: German outside the block is flagged"; fi

  cp -R "$root/skills" "$tmp/inside"
  sed 's/^> `Wer klärt` = `Owner`/> `Wer klärt` = `Owner` und mehr/' \
    "$root/skills/implement-ticket/SKILL.md" > "$tmp/inside/implement-ticket/SKILL.md"
  grep -q 'und mehr' "$tmp/inside/implement-ticket/SKILL.md"
  if check "$tmp/inside" >/dev/null; then echo "self-test: FAIL, edit inside the block passed"
    ok=0; else echo "self-test: edit inside the block is flagged"; fi

  [ "$ok" -eq 1 ]
}

case "${1:-}" in
  --self-test) self_test ;;
  -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//' ;;
  -*) echo "check-no-german: unknown option $1" >&2; exit 2 ;;
  *)
    dir=${1:-skills}
    [ -d "$dir" ] || { echo "check-no-german: not a directory: $dir" >&2; exit 2; }
    if check "$dir"; then echo "check-no-german: clean"; else exit 1; fi
    ;;
esac
