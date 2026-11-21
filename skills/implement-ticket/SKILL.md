---
name: implement-ticket
description: Implementation phase after /grill-ticket. Builds one stage of a requirements document, decides implementation details itself and asks about the rest in one round, checks the result against the acceptance criteria, has it reviewed by a fresh subagent and commits.
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
- **You look up facts; you split decisions.** Code, docs and schema you check yourself (via
  subagent). Then, for each decision the document leaves open:
  - **You decide** implementation details: internal data shapes, naming, edge-case handling inside
    one module, the order of the work. Take the option you would recommend, and record it in the
    decision log with its reason. You do not ask about it.
  - **The user decides** anything that changes scope, public output (texts, UI, API, CLI output,
    files other people or tools read) or security behaviour, contradicts a doc or an ADR, or is
    hard to undo (schema, data migrations, published names). These go to the user through
    `AskUserQuestion`. You never fill them with a silent assumption.
- **One round of questions per stage.** Batch the user's decisions into the plan step (step 3).
  Step 4 says when a second round is allowed.
- **Only this stage.** You build the R-numbers of this stage, completely, through every layer.
  Anything else you notice on the way becomes a follow-up item.

Questions, commits and document updates are written in the project's language. The rules in
`AGENTS.md`/`CLAUDE.md` apply throughout, above all for migrations, deploys, pushes and anything
that goes out to other people: where the project asks for confirmation, you ask.

**Every question** you ask that rests on a technical claim ("the API returns X", "this runs on
every request") says how the claim was verified (file and line read, command run, doc checked) or
marks it as an assumption, in the project's language.

## 1. Find the document and the stage

Input: `$ARGUMENTS`

Note the current time (`date`); step 6 may show it.

- The file must start with the status line written by `/grill-ticket`
  (`> Status: ready | not ready · Ticket: …`). If it does not, refuse the input:
  - **A ticket file or an issue** (`#12`, an issue URL): look for the requirements document that
    covers it. Candidates are the project's files that start with the status line. One covers the
    ticket if a stage line or its stage-to-ticket map names the ticket (file path, file name, issue
    number or URL), if its `Ticket:` field does, or if the ticket file links to it. If you find
    one, name the document and the stage and give the command
    (`/implement-ticket <document> stage <n>`), then stop. If none covers it, point to
    `/grill-ticket <ticket>` and stop.
  - **Free text or empty:** point to `/grill-ticket <ticket>` and stop.
- **Stage:** the one given, otherwise the first with status `open` in the "Stages" section that no
  open question blocks. If the document has no stages, the whole document is one stage. If every
  stage is done, say so and stop.
- **Status `not ready`:** the document's open questions decide which stages can be built. An open
  question blocks a stage when its "Blocks" column (in the document's language) names the stage,
  one of the stage's R-numbers or one of its acceptance criteria. An empty "Blocks" entry, or one
  that names the whole document, blocks every stage. A "Blocks" entry in free text, without such an
  ID, blocks every stage whose requirements it touches; if you are unsure whether it does, treat it
  as blocking and say why.
  - The stage is not blocked: build it. The open questions stay open; do not ask about them.
  - The stage is blocked: refuse it. Name each blocking question (number and text), point to
    `/grill-ticket <path>` to settle them, and name the open stages that are not blocked, if any.
    Then stop.
  - No stage was given and every open stage is blocked: refuse the same way, naming the blocking
    questions per stage, then stop.

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
   versions …), whether the project has tests, and whether it has a `WORKLOG.md` (and its entry
   format).
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
- **Security:** whether the stage is security-relevant, and why. It is if the document marks it so,
  or if it touches authentication, authorization, secrets, untrusted input, personal data, or
  anything the document's security section names. For a security-relevant stage, add acceptance
  criteria written from an attacker's view before building: what an attacker tries and what must
  happen instead ("Given an attacker who …, when …, then …"). They get a verification like every
  other criterion and go into the document in step 6.
- **Verification:** for each acceptance criterion of the stage, how it gets verified. If the
  project has tests: which seams (public interfaces) get tested, each with one line saying which
  failures the test would reveal and which would slip past it. Without tests: what can be
  checked automatically (typecheck, lint, a query against the schema …) and which steps the user
  tests by hand.
- **Decided by you:** the implementation details you settled, each with the chosen option. They go
  into the decision log; there is no question about them.
- **Gaps:** what the document leaves open that falls to the user (see the principles), or where
  code and document disagree.
- **Git:** the current branch. If it is the default branch, propose a feature branch following the
  project's convention. If the working tree is not clean, ask what should happen to the changes.

Then **one round** of `AskUserQuestion`: the gaps first (2–4 options per question, your
recommendation first and marked "(Recommended)" in the project's language, a `description` with a
short reason, `preview` for mockups, data models, texts), and last the confirmation of plan,
verification and branch. At most 4 questions per call, the most fundamental first. If the round
needs more than 4 questions, send the next call right away; nothing gets built in between.

**This step is done when** the user has confirmed plan, verification and branch and no gap is
left open. Every answer to a gap goes into the decision log (step 6). Only then create the branch
and touch the code.

## 4. Build

- Tracer bullet first, then one requirement after another. After each step run the typecheck (and
  lint, if it is fast). If the project has tests: at every confirmed seam, first a red test, then
  only as much code as it takes to turn it green; run single test files. If the `tdd` skill is
  available, use it for this.
- **Negative checks:** every test or check that asserts something is absent ("X never appears",
  "nothing matches") gets a positive check next to it that X really is in the input it runs on.
- Reuse the project's existing patterns and helpers. The must-haves from step 2 (texts in every
  language, docs, help articles …) and the document's "Docs and help" section are part of the
  stage.
- **Decisions during the build:** implementation details you decide and record, as in the plan
  step. A decision that falls to the user and that the plan could not have foreseen is the only
  reason for a second round: stop the part that depends on it, ask in one batched
  `AskUserQuestion` call, and keep building everything else. The report names what triggered the
  extra round and why the plan missed it. If an answer contradicts an earlier decision, name the
  contradiction explicitly.
- **Follow-up items:** bugs, clean-up needs or ideas outside the stage go into a list for step 6.

At the end, run all of the project's checks once (typecheck, lint, format, full test suite).

**This step is done when** all checks are green and every R-number of the stage is built. Fix red
checks; if one cannot be fixed, show the user the output and ask.

## 5. Review

Read [REVIEW.md](REVIEW.md) and start a **fresh subagent** that did not write the code. Its prompt
is the full text of REVIEW.md, followed by the pointers it asks for: path to the document, the
stage, and the base commit (`git merge-base HEAD <default-branch>`). Give pointers, not summaries.
Never delegate the review to another review skill (such as `code-review`), and do not tell the
subagent to use one.

Fix real defects and run the checks again. A finding marked "decision needed" follows the rules
for decisions during the build: implementation details you settle; anything that falls to the user
you ask. Findings that are not fixed go into the final report.

## 6. Close

1. **Update the document:**
   - Set the stage to `done · <YYYY-MM-DD> · <branch>`.
   - New decisions from steps 3 to 5 go into the decision log (with reason), including the ones
     you decided yourself.
   - Attacker-view acceptance criteria from step 3 go into the acceptance criteria.
   - New questions go under open questions; follow-up items go where the project keeps its backlog
     and bugs (for example a roadmap or feature backlog). If there is no such place, under open
     questions.
   - Change the target picture only if a decision changed it.
2. **Worklog** (only if the project has a `WORKLOG.md`; otherwise skip this and create no worklog
   file): draft the stage's entry in the file, in the format its existing entries use. First
   check `git diff -- <worklog>`: if the file already has uncommitted changes, they are the
   user's, not part of the entry. It records
   the questions asked (number of rounds, and the trigger of any extra round), the review findings
   (fixed and not fixed), and what was and was not tested. Leave the time as `TODO`. Do not
   estimate or propose a time; you may show the start time from step 1 and the current time,
   labelled as raw timestamps, not as time worked.
3. **Report to the user:**
   - per acceptance criterion: `checked automatically` (how) or `test manually` (concrete
     steps), both labels in the project's language,
   - deviations from the plan and why,
   - extra question rounds, their trigger and why the plan missed it,
   - review findings that were not fixed,
   - follow-up items.
4. **Commit:** one commit for the stage (code and document update, not the worklog entry),
   following the project's convention. Stage explicit paths only (`git add -- <path> …`), the
   files you changed for this stage; never `git add -A`, `git add .`, `git add -u` or
   `git commit -a`. Before committing, compare `git diff --cached --name-only` with
   `git status --short`: anything staged that is not part of this stage gets unstaged, and
   unrelated changes in the working tree are named in the report. If a file you changed already
   had uncommitted changes of the user's before this stage, stage only your own hunks (for example
   a patch applied with `git apply --cached`), or ask. If the `humanizer` skill is
   available, run the commit message and new prose in the document through it.
5. **Worklog commit:** ask the user to check the draft and give the time. Only after their OK,
   write the time into the entry and commit the worklog file alone, by its path. If the file had
   uncommitted changes of the user's before the draft, name them in the same question; commit
   them only if the user says so, otherwise stage only the entry. This
   confirmation does not count as a question round.
6. **Push, PR, issue comment** only after the user's OK. If the ticket came from a GitHub issue and
   the last stage is done, propose a comment or "Closes #…" in the PR and show the draft first.

Finally: branch, commit, next open stage. Continue with `/clear` and
`/implement-ticket <path-to-document>`.
