---
name: grill-ticket
description: Requirements phase for a ticket. Checks it from every angle for readiness, keeps asking until nothing rests on an assumption, and writes a requirements document (.md).
disable-model-invocation: true
argument-hint: '<#issue | issue URL | file | ticket text | existing requirements document>'
---

# Grill Ticket

You take a ticket and keep questioning the user until the two of you see the same picture. The
result is a requirements document with requirements, dependencies and a target picture.

Principle: **You look up facts; the user makes decisions.** Whatever the code, the docs, the
schema or the ticket already says, you check yourself (via subagent) and never ask about. Anything
that is a decision goes to the user. You never fill a gap with a silent assumption: either the
user decides it, or it is explicitly parked.

Questions and document are written in the project's language (as shown by
`AGENTS.md`/`CLAUDE.md`/`docs/`). Code identifiers stay in English.

## 1. Read the ticket

Input: `$ARGUMENTS`

- `#123` or a GitHub issue URL → `gh issue view <nr> --comments` (body, comments, labels).
- File path → read the file (Markdown, text, PDF, image …). If it starts with the status line from
  [TEMPLATE.md](TEMPLATE.md) (`> Status: ready | not ready · Ticket: …`), it is an existing
  requirements document → **resume**: the open questions and everything with status `not ready`
  are the starting questions. Never ask again about anything already decided (decision log). Then
  continue with step 3. Any other file is a ticket source.
- Free text → that is the ticket.
- Several inputs (for example an issue plus a file with notes) → together they are the ticket. If
  the sources contradict each other, that is a question for step 4.
- Empty → ask for the ticket.

Note where the ticket comes from (issue, file path, free text). It goes into the document's
status line.

Documents from the German version of the skills use the legacy terms below. Read them as their
English equivalents; write as the block says.

> **Legacy terms from the German version.** Status markers are machine-facing: written only in
> English, read in both languages. `Stand` = `Updated` · `Etappe` = `Stage` · `offen` = `open` ·
> `umgesetzt` = `done`. Headings, column names and criterion IDs are human-facing: written in the
> project's language, read in both. `Etappen` = `Stages` · `AK` = `AC` ·
> `Offene Punkte` = `Open questions` · `Entscheidungsprotokoll` = `Decision log` ·
> `Wer klärt` = `Owner` · `Blockiert` = `Blocks`

## 2. Pre-check (in parallel, via subagents)

In **one** message, start `Explore` subagents in parallel for:

1. **Project conventions**: `AGENTS.md`/`CLAUDE.md`, structure of `docs/`, project language, where
   concept and requirements documents live and how they are named, project-specific must-haves
   (for example minimum versions, i18n, help articles, privacy policy).
2. **Already built?** Search for the ticket's _concept_, not just its words. Report where you
   searched and what you found.
3. **Backlog, roadmap, existing concepts**: Does the topic exist already (feature backlog, roadmap,
   concept docs, related issues)? Then you build on it.
4. **Current state**: affected areas, data model, schema, interfaces. If the project has schema
   access (for example a Supabase MCP), use it read-only.

## 3. First picture and readiness

Show the user briefly:

- The ticket in 2–3 sentences, as you understand it.
- The result of the pre-check (including "already built in …" or "builds on …"). If it is already
  built, ask whether to continue anyway.
- Readiness per lens from [LENSES.md](LENSES.md): `clear` · `partial` · `open` ·
  `probably not relevant` (in the project's language). Plus a count, for example "6/11 open".

`probably not relevant` is a guess and has to be confirmed in a question round.

## 4. Question rounds

Read [LENSES.md](LENSES.md) if you have not yet. Keep a **decision tree**: every decision has
follow-up decisions. Questions whose preconditions have all been answered form the **frontier**.
If a question can only be asked once another question of the current round is answered, hold it
back for the next round.

In each round you ask the frontier with the `AskUserQuestion` tool:

- At most 4 questions per call. If the frontier is larger, the most fundamental first (those with
  the most follow-up questions), then the next call.
- Every question has 2–4 options. Your recommendation comes first and is marked "(Recommended)"
  in the project's language; its `description` gives a short reason. Open questions (names,
  numbers, texts) get suggestions as options; a free answer goes through "Other".
- For mockups, data models, flows or text variants: use `preview`.
- A question that rests on a technical claim ("the API returns X", "this table has no index")
  says how the claim was verified (file and line read, command run, doc checked) or marks it as
  an assumption, in the project's language.
- `header` names the lens (for example "Edge case", "Roles", "Schema").

Between rounds:

- Every answer changes the tree: update the status of the lenses, work out the new frontier.
- If a new question needs a fact, send a subagent. Meanwhile, ask the questions that do not depend
  on it.
- If an answer contradicts the code or the docs, say so at once: "The code does X, you describe Y.
  Which one holds?"
- Sharpen vague terms ("By 'member', do you mean role A or role B?"). Invent concrete scenarios
  that force edge cases into the open.
- If the user answers "don't know" or "need to check": **park** the question, with an owner and
  what it blocks, named by stage, R-number or AC ID (`/implement-ticket` reads these to decide
  which stages it can build). Parked questions make the status `not ready`.

**This step is only done when** every lens is `clear`, confirmed `not relevant` or parked, and the
frontier is empty. Count again before you move on.

## 5. Confirm the shared picture

Sum up briefly: goal, key requirements, target picture, stage split (if the ticket holds more than
one deliverable unit; each stage deliverable and testable on its own), parked questions, status.
Ask via `AskUserQuestion` whether this is the picture you both share. Corrections lead back to
step 4. Nothing gets written without confirmation.

## 6. Write the document

- **Location and name** follow the project convention from step 2 (for example next to existing
  concept docs). If there is no clear convention, ask via `AskUserQuestion` with a proposal. When
  resuming: update the existing document.
- **Structure** follows [TEMPLATE.md](TEMPLATE.md). Map every stage to the ticket it is tracked
  in (ticket file or issue), so `/implement-ticket` can point from a ticket to its stage.
- Target picture at the level of modules, data model, interfaces and decisions. Leave out file paths
  and code, since both age fast, unless a schema or type states a decision more exactly than
  words could.
- If the `humanizer` skill is available, run the document's prose through it (structure, IDs and
  domain terms stay).

## 7. Update the ticket (GitHub issue only)

Draft a comment: status (`ready`/`not ready`), a 2–3 sentence summary, parked questions with
owners, path to the document. Show it to the user and post only after their OK
(`gh issue comment`). Set labels only if the user says so.

Finally: path to the document, status, and (if `not ready`) what needs settling next. Resume later
with `/grill-ticket <path-to-document>`; implement when `ready` (or for unblocked stages) with
`/implement-ticket <path-to-document>`.
