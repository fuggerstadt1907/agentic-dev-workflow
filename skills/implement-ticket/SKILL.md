---
name: implement-ticket
description: Umsetzungs-Phase nach /grill-ticket. Setzt eine Etappe eines Requirements-Dokuments um, fragt bei jeder Lücke nach statt anzunehmen, prüft gegen die Akzeptanzkriterien, reviewt und committet.
disable-model-invocation: true
argument-hint: '<pfad-zum-requirements-dokument> [Etappe <n>]'
---

# Implement Ticket

Du baust, was mit `/grill-ticket` entschieden wurde. Ein Lauf setzt **eine Etappe** um: Plan
bestätigen, bauen, gegen die Akzeptanzkriterien prüfen, reviewen, committen, Dokument
fortschreiben. Danach Kontext leeren, nächste Etappe im nächsten Lauf.

Grundsätze:

- **Das Dokument ist der Auftrag.** Was im Entscheidungsprotokoll steht, ist entschieden. Du baust
  es so und stellst es nicht neu zur Diskussion.
- **Fakten findest du selbst, Entscheidungen trifft der User.** Code, Docs und Schema schlägst du
  nach (per Subagent). Jede **Lücke**, also alles, was das Dokument nicht entscheidet und was du
  sonst raten müsstest, legst du dem User per `AskUserQuestion` vor. Das gilt auch mitten im Bauen.
- **Nur die Etappe.** Gebaut werden die R-Nummern dieser Etappe, vollständig durch alle Schichten.
  Was dir unterwegs zusätzlich auffällt, notierst du als Folgepunkt.

Sprache von Fragen, Commits und Dokument-Updates: die Sprache des Projekts. Die Regeln aus
`AGENTS.md`/`CLAUDE.md` gelten durchgehend, besonders für Migrationen, Deploys, Push und alles
nach außen: Wo das Projekt eine Rückfrage verlangt, fragst du.

## 1. Dokument und Etappe bestimmen

Eingabe: `$ARGUMENTS`

- Die Datei muss mit der Statuszeile von `/grill-ticket` beginnen
  (`> Status: ready | not ready · Ticket: …`). Ist sie ein rohes Ticket, ein Issue, Freitext oder
  leer: verweise auf `/grill-ticket <ticket>` und hör auf.
- **Etappe:** die angegebene, sonst die erste mit Status `offen` im Abschnitt „Etappen“. Hat das
  Dokument keine Etappen, ist das ganze Dokument eine Etappe. Sind alle umgesetzt, sag das und hör
  auf.
- **Status `not ready`:** Zeig die offenen Punkte und frag per `AskUserQuestion`, ob sie inzwischen
  geklärt sind. Geklärtes wandert ins Entscheidungsprotokoll. Umgesetzt wird nur eine Etappe, die
  von keinem verbleibenden offenen Punkt blockiert wird (Spalte „Blockiert“). Gibt es keine, nenne
  die blockierenden Punkte, verweise auf `/grill-ticket <pfad>` und hör auf.

Nenne dem User Titel und Umfang (R-Nummern) der Etappe, bevor es weitergeht.

## 2. Kontext holen (parallel, per Subagents)

Starte in **einer** Nachricht parallel `Explore`-Subagents für:

1. **Projektkonventionen:** Check-Befehle (Typecheck, Lint, Format, Tests), Branch- und
   Commit-Konventionen, Default-Branch, projektspezifische Pflichtpunkte (i18n, Doku, Hilfeartikel,
   Mindestversionen …) und ob das Projekt Tests hat.
2. **Ist-Zustand je Anforderung:** Für jede R-Nummer der Etappe die betroffenen Stellen im Code,
   bestehende Muster, die du wiederverwenden kannst, und Schema/Schnittstellen. Hat das Projekt
   einen Schema-Zugang, lesend nutzen.
3. **Schon erledigt?** Ist ein Teil der Etappe bereits gebaut (Code, `git log`, offene Branches)?
   Melden, wo gesucht und was gefunden wurde.

Weicht der Code von dem ab, was das Dokument als Ist-Zustand oder Zielbild annimmt, ist das eine
Frage für Schritt 3.

## 3. Plan und Prüfpunkte bestätigen

Zeig dem User kompakt:

- **Plan:** je R-Nummer, was sich in welchem Modul ändert, und die Reihenfolge (z. B. Schema vor
  Client). Gebaut wird als **Tracer Bullet**: zuerst ein dünner Durchstich durch alle Schichten,
  der die Kernanforderung sichtbar zum Laufen bringt, dann in die Breite.
- **Prüfpunkte:** je Akzeptanzkriterium der Etappe, wie es geprüft wird. Hat das Projekt Tests:
  welche Seams (öffentliche Schnittstellen) getestet werden, jeweils mit einer Zeile, was der Test
  fängt und was nicht. Ohne Tests: was automatisch geht (Typecheck, Lint, eine Abfrage gegen das
  Schema …) und welche Schritte der User manuell testet.
- **Lücken:** alles, was das Dokument offen lässt oder wo Code und Dokument sich widersprechen.
- **Git:** aktueller Branch. Steht er auf dem Default-Branch, schlag einen Feature-Branch nach
  Projektkonvention vor. Ist der Working Tree nicht sauber, frag, was mit den Änderungen passiert.

Dann `AskUserQuestion`: erst die Lücken (je Frage 2–4 Optionen, Empfehlung zuerst mit
„(Empfohlen)“, `description` mit kurzer Begründung, `preview` für Mockups, Datenmodelle, Texte),
zuletzt die Bestätigung von Plan, Prüfpunkten und Branch. Max. 4 Fragen pro Aufruf, die
grundlegendsten zuerst.

**Fertig ist dieser Schritt, wenn** der User Plan, Prüfpunkte und Branch bestätigt hat und keine
Lücke mehr offen ist. Jede Antwort auf eine Lücke kommt ins Entscheidungsprotokoll (Schritt 6).
Erst danach Branch anlegen und Code anfassen.

## 4. Bauen

- Zuerst der Tracer Bullet, dann Anforderung für Anforderung. Nach jedem Schritt Typecheck (und
  Lint, wenn schnell). Hat das Projekt Tests: an jedem bestätigten Seam erst ein roter Test, dann
  nur so viel Code, dass er grün wird, einzelne Testdateien laufen lassen. Ist der Skill `tdd`
  verfügbar, nutze ihn dafür.
- Bestehende Muster und Helfer des Projekts wiederverwenden. Pflichtpunkte aus Schritt 2 (Texte in
  allen Sprachen, Doku, Hilfeartikel …) und der Abschnitt „Doku & Hilfe“ des Dokuments gehören zur
  Etappe.
- **Lücke unterwegs:** Halte genau an dieser Stelle an und frag per `AskUserQuestion`. Bau
  solange an Teilen weiter, die nicht von der Antwort abhängen. Widerspricht eine Antwort einer
  früheren Entscheidung, nenn den Widerspruch ausdrücklich.
- **Folgepunkte:** Bugs, Aufräumbedarf oder Ideen außerhalb der Etappe sammelst du in einer Liste
  für Schritt 6.

Am Ende einmal alle Checks des Projekts (Typecheck, Lint, Format, komplette Testsuite).

**Fertig ist dieser Schritt, wenn** alle Checks grün sind und jede R-Nummer der Etappe gebaut ist.
Rote Checks behebst du; lässt sich einer nicht beheben, zeig dem User die Ausgabe und frag.

## 5. Review

Starte für das Review einen **frischen Subagent**, der den Code nicht geschrieben hat. Ist der
Skill `code-review` verfügbar, nutze ihn. Gib ihm Kontext-Pointer statt Zusammenfassungen: Pfad
zum Dokument, die Etappe, den Diff seit dem Abzweig. Zwei getrennte Achsen:

- **Standards:** Hält sich der Diff an die dokumentierten Konventionen des Projekts?
- **Spec:** Ist jede R-Nummer der Etappe vollständig umgesetzt, ist jedes Akzeptanzkriterium
  erfüllt, und steckt im Diff etwas, das die Etappe nicht verlangt?

Echte Fehler behebst du und lässt die Checks erneut laufen. Ist ein Fund eine Entscheidung (z. B.
„so gewollt?“), frag den User. Nicht behobene Funde kommen in den Abschlussbericht.

## 6. Abschluss

1. **Dokument fortschreiben:**
   - Etappe auf `umgesetzt · <YYYY-MM-DD> · <branch>` setzen.
   - Neue Entscheidungen aus Schritt 3 und 4 ins Entscheidungsprotokoll (mit Begründung).
   - Neu aufgetauchte Fragen unter „Offene Punkte“, Folgepunkte dorthin, wo das Projekt Backlog
     und Bugs führt (z. B. Roadmap, Feature-Backlog). Gibt es keinen solchen Ort, unter „Offene
     Punkte“.
   - Zielbild nur anpassen, wenn eine Entscheidung es geändert hat.
2. **Bericht an den User:**
   - je Akzeptanzkriterium: `automatisch geprüft` (wie) oder `manuell testen` (konkrete Schritte),
   - Abweichungen vom Plan und ihr Grund,
   - nicht behobene Review-Funde,
   - Folgepunkte.
3. **Commit:** ein Commit für die Etappe (Code und Dokument-Update) nach Projektkonvention. Ist der
   Skill `humanizer` verfügbar, lass Commit-Message und neue Fließtexte im Dokument durch ihn
   laufen.
4. **Push, PR, Issue-Kommentar** nur nach OK des User. Stammt das Ticket aus einem GitHub-Issue
   und ist die letzte Etappe umgesetzt, schlag einen Kommentar bzw. „Closes #…“ im PR vor und zeig
   den Entwurf vorher.

Zum Schluss: Branch, Commit, nächste offene Etappe. Weiter mit `/clear` und
`/implement-ticket <pfad-zum-dokument>`.
