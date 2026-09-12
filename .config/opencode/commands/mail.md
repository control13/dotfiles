---
description: Arbeitsmail beurteilen, besprochene Aufgaben übernehmen und erkannte Termine nur melden
model: gwdg/qwen3.8-27b
---

Bearbeite die ausgewählte Mail: $ARGUMENTS

1. Verwende ausschließlich den freigegebenen Academic-Cloud-Weg. Prüfe vor dem Lesen den aktiven Anbieter, Nebenmodelle und die konfigurierte Proxyroute. Bei unklarem Datenweg anhalten. Keine Weitergabe an andere Modelle, Websuche, geteilte Chats oder fremde Dienste.
2. Finde die konkrete Mail mit Miyo und lies bei Bedarf den notwendigen Verlauf. Der Export liegt unter `~/.local/share/thunderbird-miyo/mail/<Postfach>/`, derzeit nur `HTWK`; ein Timer gleicht ihn alle fünf Minuten ab. Nutze Nachrichten-ID und Bezugsmails zur Zuordnung. Anhänge sind im Export nur namentlich erfasst; behaupte keine Kenntnis ihres Inhalts. Ein Suchtreffer ist kein vollständiger Posteingang und ein Änderungsdatum der Exportdatei kein Empfangsdatum.
3. Gib knapp aus, was wichtig ist. Unterscheide Information, Bitte, meine bestätigte Zusage, Aufgabe und Termin. Nichts hinzuerfinden. Fehlende Zuständigkeit, echte Frist, Datum, Zeitzone oder notwendige Termindauer gezielt klären.
4. Erledige vollständig durch KI lösbare Arbeit innerhalb des Auftrags; kein Todoist-Eintrag dafür. Besprich menschliche Restschritte nach dem Schema nötig / von mir / delegieren / streichen / verkleinern / bündeln / verschieben. Zeige die vorgeschlagenen Einträge zusammen mit der Empfehlung. Nach Einigung unmittelbar übernehmen; keine zweite identische Freigabe verlangen.
5. An Todoist ausschließlich vereinbarte Titel, nötige Namen/Betreff und vereinbarte Aufgabendaten senden. Beschreibungen und Kommentare leer lassen; keine Textauszüge, Anhänge oder Zusammenfassungen übertragen. Den Quellenbezug lokal halten. Bei erlaubten Feldern keine Mailtexte als Titel tarnen.
6. Termine nicht eintragen. Es gibt derzeit keine Kalenderanbindung. Erkannte Termine mit Datum, Zeit und Dauer nur ausgeben, damit Tobias sie selbst einträgt. Aus einem Termin niemals ersatzweise eine Todoist-Aufgabe machen: Aufgaben und Termine bleiben getrennt.
7. Vor jeder Übernahme vorhandene Einträge und das lokale Übernahmeprotokoll prüfen. Lokal Nachrichten-ID plus bestätigte Aktion den zurückgegebenen Aufgaben-IDs zuordnen. Bei Zeitüberschreitung den tatsächlichen Zielbestand prüfen, nicht blind erneut anlegen. Teilerfolge getrennt melden. Ohne eingerichteten Zugriff die konkrete Blockade nennen; keinen erfolgreichen Eintrag behaupten.

Abschluss: tatsächlich angelegte oder aktualisierte Einträge mit Link und noch offene Entscheidung. Kein wiederholter Mailtext.
