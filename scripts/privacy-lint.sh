#!/usr/bin/env bash
# Privacy lint for this repo. Used by CI and by the pre-push hook.
#
# Usage:
#   scripts/privacy-lint.sh [--tree] [--range <rev-range>] [--private <file>]
#
#   --tree             scan tracked files at HEAD (committed content, not the
#                      working tree): file paths and file contents
#   --range <range>    scan commits in <range> (git rev-list syntax, e.g. A..B or
#                      "B --not --remotes"): author/committer emails, commit
#                      messages, paths and added lines
#   --private <file>   also check the private pattern list in <file>: one POSIX
#                      extended regex per line (no \b, \w, \s), case-insensitive,
#                      '#' starts a comment line
#
# Generic checks always run: absolute home paths (only the placeholder user name
# "someone" is allowed) and email addresses other than GitHub noreply addresses.
# Findings print their location only, never the matched text or the pattern.
# Exit 0 clean, 1 findings, 2 usage or pattern errors.
set -euo pipefail
export LC_ALL=C

usage() { echo "privacy-lint: $1" >&2; exit 2; }

tree=0
range=""
private=""
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) tree=1 ;;
    --range) [ $# -ge 2 ] || usage "--range needs a value"; range="$2"; shift ;;
    --private) [ $# -ge 2 ] || usage "--private needs a file"; private="$2"; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) usage "unknown argument: $1" ;;
  esac
  shift
done
[ "$tree" = 1 ] || [ -n "$range" ] || usage "nothing to scan, pass --tree and/or --range"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Private patterns: strip comments and blank lines, validate each one. Patterns
# are never printed; errors name the line number only.
patterns="$tmp/patterns"
: > "$patterns"
if [ -n "$private" ]; then
  [ -r "$private" ] || usage "private pattern file not readable"
  n=0
  while IFS= read -r p || [ -n "$p" ]; do
    n=$((n + 1))
    case "$p" in ''|'#'*) continue ;; esac
    if printf '%s' "$p" | grep -q '\\[A-Za-z]'; then
      usage "private pattern on line $n uses an unsupported escape (POSIX ERE only)"
    fi
    if ! P="$p" awk 'BEGIN { if ("x" ~ ENVIRON["P"]) {} }' 2>/dev/null; then
      usage "private pattern on line $n is not a valid regular expression"
    fi
    printf '%s\n' "$p" >> "$patterns"
  done < "$private"
fi

# One awk program for every check. Modes (env MODE):
#   lines: stdin is file content; prints LOC:NR for each hit
#   one:   stdin is text; prints LOC once if any line hits
#   diff:  stdin is `git show` output of commit C; prints path:line findings
CHECK='
  BEGIN {
    n = 0
    while ((getline p < ENVIRON["PFILE"]) > 0) pats[++n] = tolower(p)
    home = "/(Users|home)/[A-Za-z0-9._-]+"
    mail = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z][A-Za-z]+"
    mode = ENVIRON["MODE"]; loc = ENVIRON["LOC"]; c = ENVIRON["C"]
  }
  function ok_mail(m) {
    m = tolower(m)
    return m ~ /@users\.noreply\.github\.com$/ || m == "noreply@github.com" || m == "noreply@anthropic.com"
  }
  function hit(s,   t, m, i, l) {
    t = s
    while (match(t, home)) {
      m = substr(t, RSTART, RLENGTH)
      if (m != "/Users/someone" && m != "/home/someone") return 1
      t = substr(t, RSTART + RLENGTH)
    }
    t = s
    while (match(t, mail)) {
      if (!ok_mail(substr(t, RSTART, RLENGTH))) return 1
      t = substr(t, RSTART + RLENGTH)
    }
    l = tolower(s)
    for (i = 1; i <= n; i++) if (l ~ pats[i]) return 1
    return 0
  }
  mode == "lines" { if (hit($0)) print loc ":" NR; next }
  mode == "one"   { if (!found && hit($0)) { print loc; found = 1 }; next }
  mode == "diff" {
    if ($0 ~ /^\+\+\+ /) {
      f = substr($0, 5); sub(/\t$/, "", f); sub(/^b\//, "", f)
      if (f != "/dev/null" && hit(f)) { print "commit:" c " a file path"; f = "a file in commit " c }
      next
    }
    if ($0 ~ /^@@ /) { split($3, a, ","); ln = substr(a[1], 2) + 0; next }
    if ($0 ~ /^\+/) { if (hit(substr($0, 2))) print f ":" ln " (commit " c ")"; ln++ }
  }
'

findings="$tmp/findings"
: > "$findings"

# run_check MODE LOC [C] < input. Fails the whole lint if awk itself fails.
run_check() {
  if ! MODE="$1" LOC="$2" C="${3:-}" PFILE="$patterns" awk "$CHECK" >> "$findings" 2>/dev/null; then
    echo "privacy-lint: internal check failed at a scanned location" >&2
    exit 2
  fi
}

git_q() { git -c core.quotePath=false "$@"; }

if [ "$tree" = 1 ]; then
  empty_tree="$(git hash-object -t tree /dev/null)"
  i=0
  # numstat: "added<TAB>deleted<TAB>path<NUL>"; binary files show "-".
  while IFS= read -r -d '' rec; do
    i=$((i + 1))
    added="${rec%%	*}"
    path="${rec#*	*	}"
    loc="$path"
    path_hit="$(printf '%s\n' "$path" | MODE=one LOC=x C= PFILE="$patterns" awk "$CHECK" 2>/dev/null)" \
      || { echo "privacy-lint: internal check failed on tracked file #$i" >&2; exit 2; }
    if [ -n "$path_hit" ]; then
      echo "tracked file #$i (git ls-files order): file path" >> "$findings"
      loc="tracked file #$i"
    fi
    [ "$added" = "-" ] && continue
    git_q show "HEAD:$path" | run_check lines "$loc"
  done < <(git_q diff --numstat -z --no-renames "$empty_tree" HEAD)
fi

if [ -n "$range" ]; then
  # shellcheck disable=SC2086  # range may hold several rev-list arguments
  commits="$(git rev-list $range)"
  for c in $commits; do
    short="$(git rev-parse --short "$c")"
    for e in "$(git show -s --format=%ae "$c")" "$(git show -s --format=%ce "$c")"; do
      case "$(printf '%s' "$e" | tr '[:upper:]' '[:lower:]')" in
        *@users.noreply.github.com|noreply@github.com) ;;
        *) echo "commit:$short author or committer email is not a GitHub noreply address" >> "$findings" ;;
      esac
    done
    git show -s --format=%B "$c" | run_check one "commit:$short message"
    git_q show --format= --no-color --no-renames --unified=0 "$c" | run_check diff "" "$short"
  done
fi

if [ -s "$findings" ]; then
  echo "privacy-lint: findings (location only):" >&2
  sort -u "$findings" >&2
  exit 1
fi
echo "privacy-lint: clean"
