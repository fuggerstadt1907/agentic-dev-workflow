# Worklog

One entry per stage of [requirements.md](requirements.md). Each entry records which skill version
ran (R25). The entry format becomes a template in stage 4.

## 2026-11-21 · Stage 1: Repo skeleton (private)

- **Skill version:** `implement-ticket` from the installed copy in `~/.claude/skills`, identical
  (`diff -r`) to `skills/` at the initial commit `854a750`. German text, pre-1.0.
- **Branch:** `stage-01-skeleton` · Ticket: [01-repo-skeleton](tickets/01-repo-skeleton.md) ·
  Issue #1
- **Time:** TODO

### Questions asked (one round)

1. GitHub actions (repo, issues, PR, planted test): allowed under conditions. Show
   `git log --format='%h %ae %ce'` before the first push; the planted test runs on a throwaway
   branch and PR that is closed unmerged; the private-pattern test stays local (D36).
2. Private pattern list: the maintainer fills it and sets the secret (D34).
3. Link check scope: split into blocking local and non-blocking external, plus a weekly run (D35).
4. Plan confirmation: confirmed, with a stop before the first push so the maintainer can fill the
   pattern list.

### What was tested

- Plugin and marketplace manifests: `claude plugin validate --strict` passes for both.
- Install check in an empty HOME, locally with Claude Code 2.1.329: marketplace add, install, and
  `details` lists both skills. The copied `skills/` validate with `--strict`.
- Privacy lint and pre-push hook in a temp repo with a fake remote: a fake private term in a file
  and in a commit message blocks the push and prints file:line or commit only. Output was grepped
  to confirm the term is absent. A missing list blocks the push. A fake home path is flagged while
  the `someone` placeholder passes, a non-noreply email in a file and as author is flagged. Each
  planted term was confirmed present in the input first.
- Lint over this repo's tree and history: clean.

### Not tested yet

- CI on GitHub (green PR, planted-violation PR), issue creation, the `PRIVATE_PATTERNS` step on
  `main` and the weekly link job: they need the remote, which comes after the maintainer's OK.

### Review findings (fresh subagent, two axes: standards and spec)

Fixed:

- An invalid private regex made awk print the pattern to stderr while the lint reported clean.
  Patterns are now validated up front (errors name the line number only), backslash escapes are
  rejected, and awk failures stop the lint.
- File paths were never checked; they are now, in tree and range mode, without printing the path.
- Any address containing "noreply" passed. Only GitHub noreply addresses pass now (plus
  `noreply@anthropic.com` as a co-author trailer in text).
- A colon in a file name broke tree mode and could print content as the location. Locations are
  now passed to awk through the environment, never parsed out of git output.
- A space in a file name dropped the line number in range mode.
- The CI install check grepped `details` for the skill names, which the description also contains.
  It now matches the inventory line.
- `include_fragments = false` is invalid lychee config (enum since 0.24); removed.
- A force-push to `main`, or a remote tip that is not local, broke the range; both fall back to the
  full history of the pushed commit.
- AC16 planted exactly the allowed placeholder and could not fail; reworded (D40).
- Doc nits: CONTRIBUTING said the private list is matched against emails; `--help` printed code
  lines; usage errors exited 1 instead of 2; ticket lines over 100 columns.

Not fixed: the external link job's red check is non-blocking by design (D35). mawk on the Ubuntu
runner is covered by the planted-violation PR, not tested locally.

All tests above were rerun after the fixes, plus the review's cases (pattern in a file name,
invalid and `\b` patterns, loose noreply addresses, colon and space in file names, unknown remote
tip).
