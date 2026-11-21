# Blickwinkel (Definition of Ready)

Jedes Ticket wird durch alle elf Blickwinkel geprüft. Die Prüffragen sind Anregungen zum Löchern,
keine Liste zum Abhaken. Projektspezifische Pflichtpunkte aus der Vorprüfung (Schritt 2) hängst du
an den passenden Blickwinkel an.

Ein Blickwinkel ist `klar`, wenn du ihn ohne eigene Annahme ins Dokument schreiben kannst.

## 1. Problem & Ziel

- Wessen Problem ist das, und wie löst die Person es heute?
- Woran merken wir, dass es gelöst ist (Erfolgskriterium, beobachtbar)?
- Warum jetzt? Was passiert, wenn wir es nicht bauen?

## 2. Akteure & Rollen

- Wer nutzt es, wer ist betroffen, ohne es zu nutzen?
- Wer darf was sehen, anlegen, ändern, löschen? Was passiert bei Rollenwechsel oder Austritt?

## 3. Verhalten & Akzeptanzkriterien

- Was genau passiert Schritt für Schritt? Als nummerierte Anforderungen (R1, R2 …).
- Jede Anforderung bekommt mindestens ein prüfbares Akzeptanzkriterium (Given/When/Then).
- Gibt es Zahlen, Grenzen, Reihenfolgen, Standardwerte?

## 4. Edge Cases & Fehlerfälle

- Leer, sehr viel, doppelt, gleichzeitig, rückwirkend, Zeitzonen/Datumsgrenzen.
- Offline, Abbruch mittendrin, fehlende Rechte, gelöschtes Gegenstück.
- Was sieht die Person, wenn etwas schiefgeht, und kann sie es beheben?

## 5. UX/UI & Texte

- Wo im Produkt lebt das? Neuer Screen oder Erweiterung eines bestehenden?
- Leere Zustände, Ladezustände, Bestätigungen, Rückmeldungen.
- Texte und Mehrsprachigkeit; projektspezifische UI-Vorgaben.

## 6. Daten & Schema

- Neue oder geänderte Entitäten, Felder, Beziehungen.
- Was passiert mit Bestandsdaten (Migration, Defaults, Backfill)?
- Lebensdauer: wann wird etwas gelöscht oder archiviert?

## 7. Sicherheit & Datenschutz

- Wer darf die Daten lesen und schreiben, und wo wird das durchgesetzt (Server, nicht nur Client)?
- Personenbezogene Daten? Muss die Datenschutzerklärung angepasst werden?
- Missbrauch: Spam, Rate Limits, Ausspähen fremder Daten.

## 8. Abhängigkeiten

- Andere Features, Tickets oder Entscheidungen, die vorher stehen müssen.
- Backend, externe Dienste, Drittanbieter, Konten, Kosten.
- Braucht das Gegenüber eine neue App-/Client-Version, damit es funktioniert?

## 9. Rollout & Release

- Reicht ein reines Code-Update, oder braucht es einen neuen nativen Build / Deploy / Migration?
- Reihenfolge der Auslieferung (Schema vor Client?), Feature-Flag, Mindestversion.
- Was sehen bestehende User beim ersten Start danach?

## 10. Nicht-Ziele

- Was gehört ausdrücklich nicht dazu, obwohl man es erwarten könnte?
- Was kommt vielleicht später (als Ausblick, nicht als Anforderung)?

## 11. Doku & Hilfe

- Welche Projekt-Docs, Hilfeartikel, Touren, Release Notes, Website-Texte ändern sich?
