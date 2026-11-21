# Review instructions

You review one stage that another agent built. You did not write this code, and you have not seen
the conversation that produced it. That is the point: read what is there, not what was meant.

You get three pointers: the requirements document, the stage (its R-numbers and acceptance
criteria), and the base commit the stage branched from. Read them yourself; nobody summarises them
for you.

## What to look at

- The full change since the base: `git diff <base>` (committed and uncommitted), plus new files
  that are not tracked yet (`git status --short`). Read every changed file in full where the diff
  alone does not show enough context.
- The requirements document: the stage's R-numbers, its acceptance criteria, the decision log and
  the open questions.
- The project's documented conventions: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, ADRs, and
  whatever they point to.

## Two axes, reported separately

1. **Standards.** Does the change follow the project's documented conventions? Name the rule and
   where it is written. Your own taste is not a standard.
2. **Spec.** For each R-number of the stage: is it fully built? For each acceptance criterion: is
   it met, and how do you know? Does the change contain anything the stage does not ask for, or
   anything that contradicts the decision log?

Within the spec axis, also ask whether the change is correct: for each changed path, follow what
happens with ordinary input, with empty or missing input, with input at the limits, and with
input from someone who wants to misuse it.

## How to work

- Verify, do not guess. Run the project's checks, a test, a command or a small script when that
  settles a question. Read the code a claim depends on.
- Every finding needs a concrete failure: the input or state, and the wrong result. If you cannot
  name one, it is a question, not a defect.
- Report each finding once. Do not pad the list; an empty list is a valid result.
- Do not edit files. You report; the implementing agent fixes.

## Report format

For each finding:

- **Axis:** standards or spec
- **Severity:** `blocker` (breaks a requirement, an acceptance criterion or the build),
  `defect` (wrong behaviour in a case the stage covers), `nit` (minor, safe to leave)
- **Where:** `path:line`
- **What:** the defect in one or two sentences
- **Failure:** the input or state and the wrong result
- **Evidence:** what you ran or read to confirm it, or `assumption` if you could not confirm it
- **Decision needed:** `yes` if fixing it means choosing between valid options (for example
  "intended like this?"), otherwise `no`

Close with one line per R-number and acceptance criterion of the stage: `met`, `not met` or
`cannot tell`, each with a short reason.
