// Was die Sicht ändert, nicht die Daten: Konzept und Gestaltung.
//
// Beide standen bis zuletzt im Gerätebereich, zwischen Kopplung und Health
// Connect. Dort waren sie erreichbar, aber falsch einsortiert: Gerät und
// Übertragung tun etwas mit den Messungen, diese beiden nur mit ihrer
// Darstellung. Als eigenes Blatt kann außerdem jedes Konzept sie in seiner
// eigenen Sprache aufrufen.
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/concept.dart';
import 'theme/sphygma_theme.dart';
import 'theme/variants.dart';
import 'widgets/section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Scaffold(
        backgroundColor: t.surface,
        appBar: AppBar(
          title: const Text('Konzept und Gestaltung'),
          backgroundColor: t.surface,
          foregroundColor: t.onSurface,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(t.gapLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Konzept'),
              _Erklaerung(
                text: 'Andere Konzepte ordnen denselben Bestand neu. Keine '
                    'Messung wird dabei kopiert oder entfernt.',
              ),
              RadioGroup<AppConcept>(
                groupValue: controller.concept,
                onChanged: (chosen) =>
                    chosen == null ? null : controller.setConcept(chosen),
                child: Column(
                  children: [
                    for (final k in allConcepts)
                      RadioListTile<AppConcept>(
                        value: k,
                        title: Text(
                          k.label,
                          style: TextStyle(fontSize: 14, color: t.onSurface),
                        ),
                        subtitle: Text(
                          '${k.unit} · ${k.description}',
                          style: TextStyle(fontSize: 11, color: t.muted),
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Gestaltung'),
              _Erklaerung(
                text: 'Ändert Typografie, Abstände und Tonstufen, nicht die '
                    'Messdaten.',
              ),
              RadioGroup<ThemeVariant>(
                groupValue: controller.themeVariant,
                onChanged: (chosen) =>
                    chosen == null ? null : controller.setThemeVariant(chosen),
                child: Column(
                  children: [
                    for (final v in allVariants)
                      RadioListTile<ThemeVariant>(
                        value: v,
                        title: Text(
                          themeFor(v).name,
                          style: TextStyle(fontSize: 14, color: t.onSurface),
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Öffnet die Einstellungen und nimmt die Gestaltung mit — eine geschobene
/// Route liegt außerhalb des bisherigen Baums und fände den Scope sonst nicht.
///
/// **Ein Zugang je Konzept, oben rechts, überall an derselben Stelle.**
///
/// Die fünf Konzepte schließen einander aus — wer eines sieht, sieht die
/// anderen nicht. Ein Zahnrad je Hülle sind deshalb nicht fünf konkurrierende
/// Zugänge, sondern einer. Der Umweg über den Gerätebereich wäre der falsche
/// Ort gewesen: „Gerät und Übertragung" verspricht Kopplung und Datentransport,
/// nicht Typografie. Und wer mit einem Konzept unzufrieden ist, sucht die
/// Alternative dort, wo er sie sieht — nicht hinter Bluetooth.
Future<void> showSettings(
  BuildContext context, {
  required AppController controller,
}) {
  final t = SphygmaTheme.of(context);
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SphygmaThemeScope(
        theme: t,
        child: SettingsScreen(controller: controller),
      ),
    ),
  );
}

class _Erklaerung extends StatelessWidget {
  const _Erklaerung({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: t.muted, height: 1.5),
      ),
    );
  }
}
