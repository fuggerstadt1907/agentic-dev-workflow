# Worklog

One entry per stage of [requirements.md](requirements.md). Each entry records which skill version
ran (R25). The entry format is published as a template in
[`templates/WORKLOG.md`](../templates/WORKLOG.md).

## 2026-11-21 · Stage 1: Repo skeleton (private)

- **Skill version:** `implement-ticket` from the installed copy in `~/.claude/skills`, identical
  (`diff -r`) to `skills/` at the initial commit `854a750`. German text, pre-1.0.
- **Branch:** `stage-01-skeleton` · Ticket: [01-repo-skeleton](tickets/01-repo-skeleton.md) ·
  Issue #1
- **Time:** ~70 min wall-clock (2026-11-20 ~10 min context and plan; 2026-11-21 ~60 min build,
  review, push, CI), estimated from file and commit timestamps

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

### Tested on GitHub

- Before the first push: `git log --format='%h %ae %ce' --all` showed only the noreply address;
  the lint with the maintainer's real private list over the tree and all branches was clean. A
  self-check (the list's patterns run against a copy of the list in a temp repo) confirmed the
  patterns fire; matching is case-insensitive (tested with upper, lower and mixed case).
- Private repo created, `main` pushed through the hook. Issues #1–#12 created, matching the ticket
  files.
- PR #13: all four checks green. The CI log shows `Skills (2)  grill-ticket, implement-ticket` and
  both strict validations.
- PR #14 (throwaway, based on `stage-01-skeleton`) planted a fake home path. The local hook blocked
  the push (pushed with `--no-verify` on purpose); CI's privacy lint failed with `planted.md:3`
  only, and the planted text does not appear anywhere in the run log. This also covers mawk on the
  Ubuntu runner. PR closed unmerged, branch deleted (D36).

### Not tested yet

- The `PRIVATE_PATTERNS` step on `main` (runs on the merge, needs the secret) and the weekly link
  job.

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

Not fixed: the external link job's red check is non-blocking by design (D35).

All tests above were rerun after the fixes, plus the review's cases (pattern in a file name,
invalid and `\b` patterns, loose noreply addresses, colon and space in file names, unknown remote
tip).

## 2026-11-21 · Stage 2: Skills in English

- **Skill version:** `implement-ticket` from the installed copy in `~/.claude/skills`, identical
  (`diff -r`) to `skills/` at `0cf58ff` (`main`). German text, pre-1.0. This is the last stage
  run with the German version.
- **Branch:** `stage-02-skills-english` · Ticket:
  [02-skills-in-english](tickets/02-skills-in-english.md) · Issue #2
- **Time:** ~60 min wall-clock, given by the maintainer

### Questions asked

1. Vocabulary: the terms of `requirements.md` (D41). The maintainer added that both skills keep
   reading the German terms of older documents, and that the skills write only English status
   markers.
2. Switch to the English skills: copy after the merge, with the German copies moved to
   `~/.claude/skills-backup-de/`, a restart and a test on a German requirements document (D43).
3. Plan confirmation: confirmed. After the first commit the maintainer asked to move the AC1 check
   into the repo with a CI step (D45).
4. During the build: reading German terms conflicts with AC1 ("no German text"). Decision: one
   exact legacy-terms block per SKILL.md, the AC1 exception covers exactly that block (D42).
5. After the review: German projects keep headings and column names in their own language
   (behaviour unchanged); only status markers are always English (D41).

### What was tested

- AC1, no German: `scripts/check-no-german.sh` blanks out the legacy block only when it matches
  the allowed text byte for byte, then greps for umlauts, ß and common German words. `skills/` is
  clean. Positive controls: the German files from `main` give 229 hits; `--self-test` plants a
  German sentence after the block and an edit inside it, and both are flagged. CI runs the
  self-test and the check on every PR (D45).
- AC1, no behaviour change: side-by-side review of German and English by a fresh subagent (below).
- R3: the reviewer compared the diff with Matt Pocock's `grilling`, `grill-me`, `grill-with-docs`,
  `tdd` and `to-tickets` using shared 4- and 5-word runs. After the fixes only generic runs remain.
- `claude plugin validate --strict` for plugin and marketplace, the install check in an empty HOME
  for both paths (Claude Code 2.1.330 locally): both pass, `details` lists both skills.

### Not tested yet

- The link check runs in CI only (lychee is not installed locally); it passed on PR #15.

### Switch to the English skills (after the merge, D43)

- PR #15 merged as `e36a6d8`. The German copies moved to `~/.claude/skills-backup-de/`, identical
  (`diff -r`) to `skills/` at `0cf58ff`. `~/.claude/skills` now holds `skills/` from `e36a6d8`,
  checked with `diff -r`.
- German requirements document, run by the maintainer in `mcp-project-context` with the installed
  English `implement-ticket`: the document was read correctly. Stages 01–10 and 12 were recognised
  as done, ticket 11 as the only open one. The skill did not build it and pointed to
  `/grill-ticket` on the ticket file because of about ten unresolved decisions; the maintainer
  chose to leave it open. Nothing was built, and the working tree stayed clean. Result: passed.
- From stage 3 on, the skills run from the installed English copy at `e36a6d8`.

### Review findings (fresh subagent, plus a re-check of the fixes)

Fixed:

- The template kept headings in the project's language while the legacy block said "never write"
  them. Status markers and human-facing headings are now split explicitly.
- Legacy mappings were missing for `AK`, `Etappen` and `Wer klärt`.
- "Checks" meant two things in implement-ticket (per-criterion verification and the project's
  checks); the first is now "verification".
- Four passages were close to Pocock's wording (frontier definition, later-round rule, file paths
  go stale, tracer slice, one-line seam note); rephrased.
- Smaller: "clear the context" was descriptive instead of an instruction; "anything that leaves
  the machine" was narrower than the German; user-facing labels were not marked as
  project-language; "the document is the brief" clashed with `docs/brief.md`; the "Blocks"
  column is now read in the document's language.

Not fixed: none.

## 2026-11-21 · Stage 3: Skills 1.0

- **Skill version:** `implement-ticket` from the installed copy in `~/.claude/skills`, identical
  (`diff -r`) to `skills/` at `e36a6d8`. English, pre-1.0. The stage changed the skills it ran
  with; the checks below ran the new version from this branch through `--plugin-dir`.
- **Branch:** `stage-03-skills-1-0` · Ticket: [03-skills-1-0](tickets/03-skills-1-0.md) · Issue #3
- **Time:** ~50 min wall-clock, including the 15-min manual test run, given by the maintainer

### Questions asked

Round 1 (plan step):

1. R6, a decision the plan could not foresee: a second round is allowed only for the ask
   categories; the rest keeps building, and the report and worklog count extra rounds (D46).
2. R12, worklog time: the maintainer's answer replaced "proposes a time". The skill leaves `TODO`
   and asks; it shows raw timestamps at most (D47).
3. Verification: headless runs for the refusals after a load check, one manual run for the rest,
   both with the plugin from this branch (D54).
4. Plan and branch: confirmed. The stage 2 switch note went in as its own commit, with the
   German-document check marked open.

Follow-up in the same round, because answer 2 left the commit open: only the worklog entry waits
for the OK and the time; AC10 reworded (D48). The maintainer then reported the D43 check as run;
it is recorded under stage 2.

Extra round (D46), triggered by a review finding the plan had not foreseen: free-text "Blocks"
entries failed open. Decision: fail closed, and grill-ticket names IDs in "Blocks" (D55).

Decided by the agent and logged: D49–D53, D56.

### What was tested

- Load check: `claude -p --plugin-dir` runs `/agentic-dev-workflow:implement-ticket` from this
  branch (it refused a plain text file). Sonnet, about $0.10.
- AC3, refusal (headless, Sonnet): `stage 2` of a `not ready` scratch document is refused, and the
  run names Q1 and offers stage 1 as unblocked. Re-run after the review fixes: same result. A
  variant with a free-text "Blocks" entry (`Export format`) is refused too (D55). The planted entry
  was confirmed present in the copy before the run.
- AC8 (headless, Sonnet): `docs/tickets/02-export.md` as input is refused and names
  `docs/requirements.md` and stage 2.
- Five headless runs, including the load check, at $0.10 to $0.12 each, about $0.58 in total. None
  changed a file in its copy.
- Manual run by the maintainer on stage 1 of the scratch project, with the skills from this branch
  through `--plugin-dir`, on the version before the review fixes. Results as reported by the
  maintainer, the file-based ones also checked by the agent:
  - AC3: passed. Stage 1 was picked from the `not ready` document without a question about Q1,
    which the run said blocks only stage 2. Stage 2 was refused afterwards and pointed to
    `/grill-ticket`.
  - AC4: passed. No `code-review` call in the transcripts. A grep over the scratch transcripts
    finds "# Review instructions" and "Two axes, reported separately" in the main session and in
    the review subagent.
  - AC5: passed. A "Decided by me" section (D5–D9); questions only on public output, in one round,
    no extra round.
  - AC6: passed. Stage commit `a36e597` has 6 files, `notes.txt` is not among them and stayed
    untracked.
  - AC7: passed. A question named its source ("Verified: docs/requirements.md, Edge cases").
  - AC9: passed. The plan marked the stage security-relevant and added AC-S1 to AC-S3 ("Given an
    attacker who …"); every "no `<script>`" assertion has a positive check of the payload.
  - AC10: passed. `Time: TODO`, only raw start and end times labelled "not an estimate"; the
    worklog entry was committed on its own (`c3b9a23`, only `WORKLOG.md`) after the maintainer's
    OK.
- AC11: `scripts/check-changelog.sh` passes; its self-test flags an entry without a link and a
  case-study link without a SHA. CI runs both. The reviewer checked all seven permalinks against
  `127aae8`.
- AC1 still holds: `scripts/check-no-german.sh` and its self-test pass.
- `claude plugin validate --strict` for plugin, marketplace and copied skills; the install check in
  an empty HOME lists both skills (Claude Code 2.1.330 locally). Privacy lint over the branch is
  clean.

### Not tested yet

- Not run end to end after the review fixes: D56 (user edits in touched files) and the refusal
  when no stage is given and every open stage is blocked. D55 ran headless for a given stage.
- The link check with fragments runs in CI only; the CHANGELOG anchors to this entry resolve only
  once this entry is committed.

### Review findings (fresh subagent with REVIEW.md, two axes)

The review ran on the new REVIEW.md rather than `code-review`, which the installed skill still
named, following D5.

Fixed:

- No behaviour when no stage is given and every open stage is blocked; the old text had one.
- Free-text "Blocks" entries blocked nothing (D55, decided by the maintainer).
- The worklog commit could sweep the user's own uncommitted edits in `WORKLOG.md`, the same case
  that caused R7 (D56).
- `check-changelog.sh` ignored `*`, `+` and numbered list items, and accepted short hex names as
  SHAs. It now needs a full 40-character SHA.

Not fixed: `](` inside a code span still counts as a link in `check-changelog.sh` (nit; the
CHANGELOG has no such case).

### Switch to the 1.0 skills (after the merge, as in D43)

- PR #16 merged as `e79f19c`. `~/.claude/skills/grill-ticket` and `implement-ticket` now hold
  `skills/` from `e79f19c` (taken with `git archive`), checked with `diff -r`; `implement-ticket`
  now includes `REVIEW.md`. The German backup in `~/.claude/skills-backup-de/` was not touched
  (same checksum over all its files before and after).
- From stage 4 on, the skills run from the installed copy at `e79f19c`. Claude Code has to be
  restarted to load them.
