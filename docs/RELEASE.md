# Release-Anleitung (Meilenstein 7)

Stand: 2026-09-03. Ergänzt `PLAN.md` M7 und §3.3.

## 1. Vorbedingungen — einmalig

### 1.1 Stabiler Flutter-Kanal

Die Toolchain läuft auf dem **beta**-Kanal (`flutter --version`: 3.47.0-0.1.pre). Für einen
reproduzierbaren F-Droid-Build muss eine stabile, gepinnte Version verwendet werden:

```bash
flutter channel stable
flutter upgrade
flutter --version   # Version in docs/RELEASE.md und fdroid/metadata eintragen
flutter pub get
flutter test && flutter analyze
```

Danach `environment.sdk` in `pubspec.yaml` auf die stabile Dart-Version anpassen.

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

```bash
# ohne ESC-Klassifikation (Standard, siehe PLAN.md §3.2)
flutter build apk --release --split-per-abi

# mit ESC-Klassifikation - nur nach bewusster Entscheidung (Medizinprodukte-Risiko)
flutter build apk --release --split-per-abi --dart-define=SPHYGMA_ESC=true

# Play Store: App Bundle
flutter build appbundle --release
```

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
Nur mit **verifiziertem Organisationskonto** (PLAN.md §3.3). Dann:
- Health-Apps-Declaration im Play Console, je Datentyp eine Begründung
  (Blutdruck: Messgerät-Import; Herzfrequenz: Puls der Messung)
- Datenschutzerklärung (`docs/PRIVACY.md`) öffentlich erreichbar verlinken; derselbe Text
  wie in `PermissionsRationaleActivity`
- Data-Safety-Formular: Gesundheitsdaten werden **nicht** übertragen, nur lokal und in
  Health Connect gespeichert; Build-Time-Telemetrie von `flutter_blue_plus` ist keine
  Nutzerdaten-Übertragung, aber im Zweifel angeben
- Medical-Device-Labeling: siehe PLAN.md §3.2 — mit ESC-Klassifikation im Build ist die
  Einstufung anwaltlich zu prüfen

## 4. Checkliste vor dem Tag

- [ ] stabiler Flutter-Kanal, Version gepinnt
- [ ] `pubspec.yaml` Version erhöht
- [ ] `flutter test`, `flutter analyze` grün
- [ ] Release-APK auf echtem Gerät: Pairing, Sync, Export, Entfernen
- [ ] Entscheidung ESC-Flag dokumentiert (Release-Notes)
- [ ] `docs/PRIVACY.md` und Rationale-Text identisch
- [ ] Merge auf `main`, dann Tag, dann GitHub Release
