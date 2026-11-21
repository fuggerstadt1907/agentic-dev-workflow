---
name: grill-ticket
description: Requirements-Phase für ein Ticket. Prüft es aus allen Blickwinkeln auf Readiness, fragt so lange nach, bis nichts mehr angenommen ist, und schreibt ein Requirements-Dokument (.md).
disable-model-invocation: true
argument-hint: '<#issue | Issue-URL | Datei | Ticket-Text | bestehendes Requirements-Dokument>'
---

# Grill Ticket

Du nimmst ein Ticket und löcherst den User, bis ihr ein gemeinsames Bild habt. Am Ende steht ein
Requirements-Dokument mit Anforderungen, Abhängigkeiten und Zielbild.

Grundsatz: **Fakten findest du selbst, Entscheidungen trifft der User.** Was im Code, in den Docs,
im Schema oder im Ticket steht, schlägst du nach (per Subagent) und fragst nie danach. Alles, was
eine Entscheidung ist, legst du dem User vor. Eine Lücke füllst du nie mit einer stillen Annahme:
Entweder der User entscheidet sie, oder sie wird ausdrücklich geparkt.

Sprache von Fragen und Dokument: die Sprache des Projekts (aus `AGENTS.md`/`CLAUDE.md`/`docs/`
ablesbar). Code-Bezeichner bleiben englisch.

## 1. Ticket einlesen

Eingabe: `$ARGUMENTS`

- `#123` oder GitHub-Issue-URL → `gh issue view <nr> --comments` (Body, Kommentare, Labels).
- Dateipfad → Datei lesen (Markdown, Text, PDF, Bild …). Beginnt sie mit der Statuszeile aus
  [TEMPLATE.md](TEMPLATE.md) (`> Status: ready | not ready · Ticket: …`), ist sie ein bestehendes
  Requirements-Dokument → **Wiederaufnahme**: die „Offene Punkte“ und alles mit Status
  `not ready` sind die Startfragen. Bereits Entschiedenes (Entscheidungsprotokoll) nie neu fragen.
  Danach weiter bei Schritt 3. Jede andere Datei ist Ticket-Quelle.
- Freitext → das ist das Ticket.
- Mehrere Angaben (z. B. Issue + Datei mit Notizen) → zusammen sind sie das Ticket. Widersprechen
  sich die Quellen, ist das eine Frage für Schritt 4.
- Leer → nach dem Ticket fragen.

Halte fest, woraus das Ticket stammt (Issue, Dateipfad, Freitext). Das kommt in die Statuszeile des
Dokuments.

## 2. Vorprüfung (parallel, per Subagents)

Starte in **einer** Nachricht parallel `Explore`-Subagents für:

1. **Projektkonventionen**: `AGENTS.md`/`CLAUDE.md`, Struktur von `docs/`, Projektsprache, wo
   Konzept-/Requirements-Dokumente liegen und wie sie heißen, projektspezifische Pflichtpunkte
   (z. B. Mindestversionen, i18n, Hilfeartikel, Datenschutzerklärung).
2. **Schon umgesetzt?** Nach dem _Konzept_ des Tickets suchen, nicht nur nach seinen Wörtern.
   Melden, wo gesucht wurde und was gefunden wurde.
3. **Backlog, Roadmap, bestehende Konzepte**: Gibt es das Thema schon (Feature-Backlog, Roadmap,
   Konzeptdocs, verwandte Issues)? Dann baut ihr darauf auf.
4. **Ist-Zustand**: betroffene Bereiche, Datenmodell, Schema, Schnittstellen. Hat das Projekt
   einen Schema-Zugang (z. B. Supabase-MCP), lesend nutzen.

## 3. Erstbild und Readiness

Zeige dem User kurz:

- Das Ticket in 2–3 Sätzen, so wie du es verstehst.
- Ergebnis der Vorprüfung (inkl. „schon umgesetzt in …“ oder „baut auf … auf“). Ist es schon
  umgesetzt, frag, ob ihr trotzdem weitermacht.
- Readiness je Blickwinkel aus [LENSES.md](LENSES.md): `klar` · `teilweise` · `offen` ·
  `vermutlich nicht relevant`. Plus Zähler, z. B. „6/11 offen“.

`vermutlich nicht relevant` ist eine Vermutung und muss in einer Fragerunde bestätigt werden.

## 4. Fragerunden

Lies [LENSES.md](LENSES.md), falls noch nicht geschehen. Führe einen **Entscheidungsbaum**: Jede
Entscheidung hat Folgeentscheidungen. Die **Frontier** sind alle Fragen, deren Voraussetzungen schon
geklärt sind. Eine Frage, die von einer noch offenen Frage derselben Runde abhängt, gehört in eine
spätere Runde.

Pro Runde fragst du die Frontier mit dem Tool `AskUserQuestion`:

- Max. 4 Fragen pro Aufruf. Ist die Frontier größer, zuerst die grundlegendsten (die mit den
  meisten Folgefragen), dann der nächste Aufruf.
- Jede Frage hat 2–4 Optionen. Deine Empfehlung steht zuerst und trägt „(Empfohlen)“; die
  `description` begründet sie kurz. Offene Fragen (Namen, Zahlen, Texte) bekommen Vorschläge als
  Optionen, freie Antwort geht über „Other“.
- Für Mockups, Datenmodelle, Abläufe oder Textvarianten: `preview` nutzen.
- `header` nennt den Blickwinkel (z. B. „Edge Case“, „Rollen“, „Schema“).

Zwischen den Runden:

- Jede Antwort verändert den Baum: Status der Blickwinkel aktualisieren, neue Frontier berechnen.
- Braucht eine neue Frage einen Fakt, schick einen Subagent los. Stell solange die Fragen, die
  nicht davon abhängen.
- Widerspricht eine Antwort dem Code oder den Docs, sag es sofort: „Im Code passiert X, du
  beschreibst Y. Was gilt?“
- Unscharfe Begriffe schärfen („Meinst du mit ‚Mitglied‘ Rolle A oder Rolle B?“). Erfinde konkrete
  Szenarien, die Grenzfälle erzwingen.
- Antwortet der User „weiß nicht“ oder „muss ich klären“: Frage **parken**, mit Verantwortlichem
  und dem, was sie blockiert. Geparkte Fragen machen den Status `not ready`.

**Fertig ist dieser Schritt erst, wenn** jeder Blickwinkel `klar`, bestätigt `nicht relevant` oder
geparkt ist und die Frontier leer ist. Zähle nach, bevor du weitergehst.

## 5. Gemeinsames Bild bestätigen

Fasse kompakt zusammen: Ziel, wichtigste Anforderungen, Zielbild, Etappenschnitt (falls das
Ticket mehr als eine lieferbare Einheit enthält; jede Etappe einzeln lieferbar und testbar),
geparkte Punkte, Status. Frag per `AskUserQuestion`, ob das das gemeinsame Bild ist. Korrekturen
führen zurück zu Schritt 4. Ohne Bestätigung wird nichts geschrieben.

## 6. Dokument schreiben

- **Ort und Name** nach der Projektkonvention aus Schritt 2 (z. B. neben bestehenden
  Konzeptdocs). Gibt es keine eindeutige Konvention, frag per `AskUserQuestion` mit Vorschlag.
  Bei Wiederaufnahme: das bestehende Dokument aktualisieren.
- **Aufbau** nach [TEMPLATE.md](TEMPLATE.md).
- Zielbild auf Ebene von Modulen, Datenmodell, Schnittstellen und Entscheidungen. Keine Dateipfade
  und kein Code: das veraltet schnell. Ausnahme: ein Schema oder Typ, der eine Entscheidung
  genauer festhält als Prosa.
- Ist der Skill `humanizer` verfügbar, lass den Fließtext des Dokuments durch ihn laufen
  (Struktur, IDs und Fachbegriffe bleiben).

## 7. Ticket aktualisieren (nur bei GitHub-Issue)

Entwirf einen Kommentar: Status (`ready`/`not ready`), Zusammenfassung in 2–3 Sätzen, geparkte
Punkte mit Verantwortlichen, Pfad zum Dokument. Zeig ihn dem User und poste erst nach dessen OK
(`gh issue comment`). Labels nur setzen, wenn der User es sagt.

Zum Schluss: Pfad zum Dokument, Status und (falls `not ready`) was als Nächstes geklärt werden
muss. Wiederaufnahme später mit `/grill-ticket <pfad-zum-dokument>`, Umsetzung bei `ready`
(oder unblockierten Etappen) mit `/implement-ticket <pfad-zum-dokument>`.
