# Claude Code Skills

Meine Skills für [Claude Code](https://claude.com/claude-code). Die Skills sind auf Deutsch
geschrieben, arbeiten aber in der Sprache des jeweiligen Projekts.

## Skills

| Skill | Wofür |
| --- | --- |
| [`grill-ticket`](skills/grill-ticket/SKILL.md) | Requirements-Phase: prüft ein Ticket aus elf Blickwinkeln auf Readiness, fragt nach, bis nichts mehr angenommen ist, und schreibt ein Requirements-Dokument. |
| [`implement-ticket`](skills/implement-ticket/SKILL.md) | Umsetzungs-Phase: setzt eine Etappe aus diesem Dokument um, fragt bei Lücken nach, prüft gegen die Akzeptanzkriterien, lässt reviewen und committet. |

Die beiden gehören zusammen:

```
/grill-ticket #123                    → docs/…/requirements.md (Status: ready)
/implement-ticket docs/…/requirements.md   → Etappe 1 umgesetzt und committet
/clear
/implement-ticket docs/…/requirements.md   → Etappe 2 …
```

Beide Skills starten nur per Slash-Befehl (`disable-model-invocation: true`). Optional nutzen sie
die Skills `humanizer`, `code-review` und `tdd`, wenn sie installiert sind.

## Installation

Einzelnen Skill für alle Projekte installieren:

```bash
git clone https://github.com/<user>/claude-skills.git
cp -R claude-skills/skills/grill-ticket ~/.claude/skills/
```

Oder nur für ein Projekt: in dessen `.claude/skills/` kopieren.

## Lizenz

[MIT](LICENSE)
