# agentic-dev-workflow

Two Claude Code skills for agentic development. `grill-ticket` turns a ticket into a requirements
document with decisions and stages. `implement-ticket` builds one stage at a time, with a review
by a fresh subagent and one commit per stage.

> Work in progress. This README is a stub; the full version with the workflow diagram follows in
> stage 4 of [the requirements](docs/requirements.md#stages). The skills are written in English and
> work in the language of the project they run in.

## Install

As a plugin (recommended), inside Claude Code:

```text
/plugin marketplace add fuggerstadt1907/agentic-dev-workflow
/plugin install agentic-dev-workflow@agentic-dev-workflow
```

Fallback: copy the skills, for all projects or for one project.

```bash
git clone https://github.com/fuggerstadt1907/agentic-dev-workflow.git
cp -R agentic-dev-workflow/skills/grill-ticket agentic-dev-workflow/skills/implement-ticket ~/.claude/skills/
# or, for one project only: copy them into <project>/.claude/skills/
```

## Usage

```text
/grill-ticket #123                          → docs/…/requirements.md (Status: ready)
/implement-ticket docs/…/requirements.md    → stage 1 built, reviewed, committed
/clear
/implement-ticket docs/…/requirements.md    → stage 2 …
```

The short form (`/implement-ticket`) works as long as no other installed skill has the same name.
The namespaced form always works: `/agentic-dev-workflow:grill-ticket`,
`/agentic-dev-workflow:implement-ticket`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Licence

[MIT](LICENSE)
