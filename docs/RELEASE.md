# Release-Anleitung (Meilenstein 7)

Stand: 2026-09-03. Ergänzt `PLAN.md` M7 und §3.3.

## 1. Vorbedingungen — einmalig

### 1.1 Stabiler Flutter-Kanal

**Gepinnte Release-Toolchain (seit 2026-09-04): Flutter 3.47.2 (stable), Dart 3.13.2.**
Dieselbe Version steht in `fdroid/metadata` (`srclibs: flutter@3.47.2`); beim Wechsel beides
zusammen anpassen. Der Wechsel vom beta-Kanal lief so (falls er wiederholt werden muss):

```bash
flutter channel stable
flutter upgrade
flutter --version   # Version hier und in fdroid/metadata eintragen
flutter pub get
flutter test && flutter analyze
```

Scheitert `flutter channel` an einer lokal geänderten `pubspec.lock` **im Flutter-SDK**,
ist das ein Artefakt des Tools: `git -C <flutter-root> checkout -- pubspec.lock`.

### 1.2 Signierschlüssel — nur auf deinem Rechner

Der Schlüssel wird **nie** ins Repo gelegt; `key.properties`, `*.jks`, `*.keystore` sind in
`.gitignore`. Erzeugen (Quelle: docs.flutter.dev/deployment/android):

```bash
keytool -genkey -v -keystore ~/sphygma-upload-keystore.jks -keyalg RSA \
        -storetype JKS -keysize 2048 -validity 10000 -alias upload
```

Dann `android/key.properties` anlegen (nicht committen):

```properties
storePassword=<Passwort>
keyPassword=<Passwort>
keyAlias=upload
storeFile=/home/<user>/sphygma-upload-keystore.jks
```

`android/app/build.gradle.kts` liest die Datei, wenn sie existiert; fehlt sie, wird mit dem
Debug-Key signiert und eine Warnung ausgegeben. **Keystore und Passwort sichern** — ein
verlorener Upload-Key macht Updates im Play Store unmöglich (Play App Signing hilft nur, wenn
es vor dem ersten Upload aktiviert war).

## 2. Build

**Entscheidung 2026-09-04: Der veröffentlichte Build enthält die ESC-Klassifikation**
(`--dart-define=SPHYGMA_ESC=true`). Das MDR-Risiko aus PLAN.md §3.2 bleibt damit bestehen und
ist vor dem Play-Release anwaltlich zu prüfen; die Release-Notes und die Store-Beschreibung
tragen den Hinweis „kein Medizinprodukt, ersetzt keine ärztliche Bewertung".

```bash
# GitHub / F-Droid: signierte Split-APKs
flutter build apk --release --split-per-abi --dart-define=SPHYGMA_ESC=true

# Play Store: App Bundle
flutter build appbundle --release --dart-define=SPHYGMA_ESC=true

# Variante ohne Klassifikation (nur falls die Entscheidung revidiert wird)
flutter build apk --release --split-per-abi
```

Das Flag muss bei **jedem** Build-Aufruf mitgegeben werden — es ist kein Projekt-Default.

Artefakte unter `build/app/outputs/`. R8-Shrinking ist im Release-Build immer aktiv.

Vor jedem Release: `version:` in `pubspec.yaml` erhöhen (`x.y.z+N`, N streng monoton),
`flutter test`, `flutter analyze`, Tag erst **nach** dem Merge auf `main` setzen
(`v<x.y.z>`), Release-Notes aus den PR-Beschreibungen.

## 3. Kanäle

### GitHub Releases
Signierte APKs (per ABI) an das Tag hängen. Hinweis in den Release-Notes: Pairing überschreibt
den Key im Gerät; die Omron-App muss danach neu gepairt werden.

### F-Droid
- FOSS-Lizenz: MIT ✓ (`LICENSE`)
- Entwurf der Metadaten: `fdroid/metadata/de.bdgraue.sphygma.yml` — wird als Merge-Request in
  [fdroiddata](https://gitlab.com/fdroid/fdroiddata) eingereicht, nicht hier gebaut.
- F-Droid signiert selbst; der Build muss ohne `key.properties` durchlaufen (tut er).
- **Prüfen:** `flutter_blue_plus` steht unter der FlutterBluePlus License (nicht OSI-gelistet,
  Section 1.4 Build-Time-Telemetrie). F-Droid prüft Abhängigkeitslizenzen und Telemetrie
  („Anti-Features"). Vor dem Einreichen im F-Droid-Forum klären, ob die Lizenz akzeptiert wird
  und ob die Telemetrie als Anti-Feature zu deklarieren ist.

### Google Play
Organisationskonto liegt vor (Stand 2026-09-04). Anforderungen:

- **Target-API-Level:** Seit dem 31.08.2026 müssen neue Apps und Updates **Android 16 (API 36)**
  oder höher als Ziel haben (Quelle: developer.android.com/google/play/requirements/target-sdk,
  abgerufen 2026-09-04). `targetSdk`/`compileSdk` in `android/app/build.gradle.kts` sind
  entsprechend gesetzt; Plattform `android-36` ist im SDK installiert.
- **Health-Apps-Declaration** im Play Console: Erklärungsformular mit Begründung je Datentyp,
  nur die minimal nötigen Typen (Quelle: support.google.com/googleplay/android-developer/
  answer/9888170). Sphygma: `WRITE_BLOOD_PRESSURE` (Import der Messwerte des Geräts),
  `WRITE_HEART_RATE` (Puls derselben Messung). Kein Lesezugriff.
- **Datenschutzerklärung** (`docs/PRIVACY.md`) öffentlich erreichbar verlinken; die Policy
  verlangt: App benennen, Datentypen und ihre Funktion, Nutzung/Weitergabe (hier: keine),
  Anleitung zum Verwalten und Löschen, Angaben zur sicheren Verarbeitung. Derselbe Text wie
  in `PermissionsRationaleActivity`.
- **Data-Safety-Formular:** Gesundheitsdaten werden **nicht** übertragen, nur lokal und in
  Health Connect gespeichert; Build-Time-Telemetrie von `flutter_blue_plus` ist keine
  Nutzerdaten-Übertragung, aber im Zweifel angeben.
- **Medical-Device-Labeling / MDR:** ESC-Klassifikation ist im Build (§2) — Einstufung nach
  PLAN.md §3.2 anwaltlich prüfen lassen, bevor der Play-Release live geht.
- Upload als App Bundle (`flutter build appbundle`), Play App Signing beim ersten Upload
  aktivieren.

## 4. Checkliste vor dem Tag

- [ ] stabiler Flutter-Kanal, Version gepinnt
- [ ] `pubspec.yaml` Version erhöht
- [ ] `flutter test`, `flutter analyze` grün
- [ ] Release-APK auf echtem Gerät: Pairing, Sync, Export, Entfernen
- [ ] Entscheidung ESC-Flag dokumentiert (Release-Notes)
- [ ] `docs/PRIVACY.md` und Rationale-Text identisch
- [ ] Merge auf `main`, dann Tag, dann GitHub Release
