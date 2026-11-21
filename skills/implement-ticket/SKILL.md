---
name: implement-ticket
description: Implementation phase after /grill-ticket. Builds one stage of a requirements document, asks about every gap instead of assuming, checks the result against the acceptance criteria, reviews it and commits.
disable-model-invocation: true
argument-hint: '<path-to-requirements-document> [stage <n>]'
---

# Implement Ticket

You build what was decided with `/grill-ticket`. One run delivers **one stage**: confirm the plan,
build, check against the acceptance criteria, review, commit, update the document. Then clear
the context; the next stage gets its own run.

Principles:

- **The document is the mandate.** Whatever the decision log records is settled. You build it that
  way and do not reopen it.
- **You look up facts; the user makes decisions.** Code, docs and schema you check yourself (via
  subagent). Every **gap**, meaning anything the document leaves undecided that you would
  otherwise have to guess, goes to the user through `AskUserQuestion`. That holds in the middle of
  the build as well.
- **Only this stage.** You build the R-numbers of this stage, completely, through every layer.
  Anything else you notice on the way becomes a follow-up item.

Questions, commits and document updates are written in the project's language. The rules in
`AGENTS.md`/`CLAUDE.md` apply throughout, above all for migrations, deploys, pushes and anything
that goes out to other people: where the project asks for confirmation, you ask.

## 1. Find the document and the stage

Input: `$ARGUMENTS`

- The file must start with the status line written by `/grill-ticket`
  (`> Status: ready | not ready · Ticket: …`). If it is a raw ticket, an issue, free text or
  empty, point to `/grill-ticket <ticket>` and stop.
- **Stage:** the one given, otherwise the first with status `open` in the "Stages" section. If the
  document has no stages, the whole document is one stage. If every stage is done, say so and
  stop.
- **Status `not ready`:** Show the open questions and ask via `AskUserQuestion` whether they have
  been settled in the meantime. Settled answers move into the decision log. Only a stage that no
  remaining open question blocks (the "Blocks" column, in the document's language) gets built.
  If there is none, name the blocking questions, point to `/grill-ticket <path>` and stop.

Documents from the German version of the skills use the legacy terms below. Read them as their
English equivalents; write as the block says.

> **Legacy terms from the German version.** Status markers are machine-facing: written only in
> English, read in both languages. `Stand` = `Updated` · `Etappe` = `Stage` · `offen` = `open` ·
> `umgesetzt` = `done`. Headings, column names and criterion IDs are human-facing: written in the
> project's language, read in both. `Etappen` = `Stages` · `AK` = `AC` ·
> `Offene Punkte` = `Open questions` · `Entscheidungsprotokoll` = `Decision log` ·
> `Wer klärt` = `Owner` · `Blockiert` = `Blocks`

Tell the user the title and scope (R-numbers) of the stage before you go on.

## 2. Gather context (in parallel, via subagents)

In **one** message, start `Explore` subagents in parallel for:

1. **Project conventions:** check commands (typecheck, lint, format, tests), branch and commit
   conventions, default branch, project-specific must-haves (i18n, docs, help articles, minimum
   versions …) and whether the project has tests.
2. **Current state per requirement:** for each R-number of the stage, the affected places in the
   code, existing patterns you can reuse, and schema/interfaces. If the project has schema access,
   use it read-only.
3. **Already done?** Is part of the stage built already (code, `git log`, open branches)? Report
   where you searched and what you found.

If the code differs from what the document assumes as current state or target picture, that is a
question for step 3.

## 3. Confirm plan and verification

Show the user, briefly:

- **Plan:** per R-number, what changes in which module, and the order (for example schema before
  client). The build follows the **tracer bullet** idea: first a narrow slice that runs end to
  end, touches all layers and visibly makes the core requirement work; then the breadth.
- **Verification:** for each acceptance criterion of the stage, how it gets verified. If the
  project has tests: which seams (public interfaces) get tested, each with one line saying which
  failures the test would reveal and which would slip past it. Without tests: what can be
  checked automatically (typecheck, lint, a query against the schema …) and which steps the user
  tests by hand.
- **Gaps:** everything the document leaves open, or where code and document disagree.
- **Git:** the current branch. If it is the default branch, propose a feature branch following the
  project's convention. If the working tree is not clean, ask what should happen to the changes.

Then `AskUserQuestion`: the gaps first (2–4 options per question, your recommendation first and
marked "(Recommended)" in the project's language, a `description` with a short reason, `preview`
for mockups, data models, texts), and last the confirmation of plan, verification and branch. At
most 4 questions per call, the most fundamental first.

**This step is done when** the user has confirmed plan, verification and branch and no gap is
left open. Every answer to a gap goes into the decision log (step 6). Only then create the branch
and touch the code.

## 4. Build

- Tracer bullet first, then one requirement after another. After each step run the typecheck (and
  lint, if it is fast). If the project has tests: at every confirmed seam, first a red test, then
  only as much code as it takes to turn it green; run single test files. If the `tdd` skill is
  available, use it for this.
- Reuse the project's existing patterns and helpers. The must-haves from step 2 (texts in every
  language, docs, help articles …) and the document's "Docs and help" section are part of the
  stage.
- **A gap during the build:** stop right at that point and ask via `AskUserQuestion`. Meanwhile,
  keep building the parts that do not depend on the answer. If an answer contradicts an earlier
  decision, name the contradiction explicitly.
- **Follow-up items:** bugs, clean-up needs or ideas outside the stage go into a list for step 6.

At the end, run all of the project's checks once (typecheck, lint, format, full test suite).

**This step is done when** all checks are green and every R-number of the stage is built. Fix red
checks; if one cannot be fixed, show the user the output and ask.

## 5. Review

For the review, start a **fresh subagent** that did not write the code. If the `code-review`
skill is available, use it. Give it pointers to the context, not summaries: path to the document,
the stage, the diff since the branch point. Two separate axes:

- **Standards:** Does the diff follow the project's documented conventions?
- **Spec:** Is every R-number of the stage fully implemented, is every acceptance criterion met,
  and does the diff contain anything the stage does not ask for?

Fix real defects and run the checks again. If a finding is a decision (for example "intended like
this?"), ask the user. Findings that are not fixed go into the final report.

## 6. Close

1. **Update the document:**
   - Set the stage to `done · <YYYY-MM-DD> · <branch>`.
   - New decisions from steps 3 and 4 go into the decision log (with reason).
   - New questions go under open questions; follow-up items go where the project keeps its backlog
     and bugs (for example a roadmap or feature backlog). If there is no such place, under open
     questions.
   - Change the target picture only if a decision changed it.
2. **Report to the user:**
   - per acceptance criterion: `checked automatically` (how) or `test manually` (concrete
     steps), both labels in the project's language,
   - deviations from the plan and why,
   - review findings that were not fixed,
   - follow-up items.
3. **Commit:** one commit for the stage (code and document update), following the project's
   convention. If the `humanizer` skill is available, run the commit message and new prose in the
   document through it.
4. **Push, PR, issue comment** only after the user's OK. If the ticket came from a GitHub issue and
   the last stage is done, propose a comment or "Closes #…" in the PR and show the draft first.

Finally: branch, commit, next open stage. Continue with `/clear` and
`/implement-ticket <path-to-document>`.
