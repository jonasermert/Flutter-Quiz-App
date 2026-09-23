# Flutter Quiz App

Eine Flutter Quiz App mit Fragen aus `assets/questions.json`. Das Design orientiert sich an der [Bibliothek App](https://github.com/jonasermert/Bibliothek): Türkis als Akzentfarbe, ruhige Oberflächen und abgerundete Karten.

## Funktionen

- Fragen und Antworten werden pro Runde gemischt.
- Einzel- und Mehrfachantworten werden unterstützt.
- Nach jeder Frage werden die richtigen Antworten angezeigt.
- Am Ende erscheint das Ergebnis; bei voller Punktzahl gibt es Konfetti.
- Hell, Dunkel oder Systemeinstellung können über das Symbol oben rechts gewählt werden.
- Mit „Erneut spielen“ startet eine neue Runde.

## Starten

```bash
flutter pub get
flutter run
```

## Fragen bearbeiten

Die Fragen stehen in `assets/questions.json`. Das Feld `correct` enthält die Nummern der richtigen Antworten, beginnend bei **1**. Mehrere Nummern ergeben eine Frage mit Mehrfachauswahl.
