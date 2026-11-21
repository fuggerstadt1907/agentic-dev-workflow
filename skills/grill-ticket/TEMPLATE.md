# Vorlage Requirements-Dokument

Überschriften in der Projektsprache. Abschnitte, deren Blickwinkel bestätigt nicht relevant ist,
bleiben mit einem Satz stehen („Keine Schemaänderung.“), damit sichtbar ist, dass sie geprüft
wurden.

```markdown
# <Titel>

> Status: ready | not ready · Ticket: <#123 / Link / Dateipfad / „Freitext“> · Stand: <YYYY-MM-DD>

## Zusammenfassung

2–3 Sätze: was, für wen, warum.

## Problem & Ziel

Problem aus Sicht der Betroffenen. Erfolgskriterium.

## Akteure & Rollen

Wer was darf, als Liste oder Tabelle.

## Anforderungen

- **R1** – …
- **R2** – …

### Akzeptanzkriterien

- **AK1 (R1)** – Given … When … Then …

## Edge Cases & Fehlerfälle

## UX/UI & Texte

## Daten & Schema

## Sicherheit & Datenschutz

## Abhängigkeiten

## Zielbild (Lösung)

Betroffene Bereiche, Datenmodell, Schnittstellen. Jede Entscheidung mit kurzer Begründung und der
verworfenen Alternative.

### Etappen

Nur wenn sinnvoll. Pro Etappe: Umfang (R-Nummern), warum sie für sich lieferbar und testbar ist,
und ein Status (`offen`, später von `/implement-ticket` gesetzt: `umgesetzt · <Datum> · <Branch>`).

- **Etappe 1 – <Titel>** · offen · R1, R2 – …

## Rollout & Release

## Nicht-Ziele

## Doku & Hilfe

## Entscheidungsprotokoll

| #   | Frage | Entscheidung | Begründung |
| --- | ----- | ------------ | ---------- |

## Offene Punkte

| #   | Frage | Wer klärt | Blockiert |
| --- | ----- | --------- | --------- |
```
