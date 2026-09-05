import 'package:flutter/material.dart';

import '../app/app_controller.dart';

class PairingScreen extends StatelessWidget {
  const PairingScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Mit dem Omron pairen')),
      body: ListenableBuilder(
        listenable: c,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('1. Welcher User bist du am Gerät?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('User 1')),
                ButtonSegment(value: 2, label: Text('User 2')),
              ],
              selected: {if (c.userSlot != null) c.userSlot!},
              emptySelectionAllowed: true,
              onSelectionChanged: c.busy
                  ? null
                  : (s) {
                      if (s.isNotEmpty) c.setUserSlot(s.first);
                    },
            ),
            const SizedBox(height: 4),
            const Text(
              'Nur die Messungen dieses Slots werden nach Health Connect '
              'exportiert. Der Slot-Schalter am Gerät entscheidet, wo neue '
              'Messungen landen.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 24),
            Text('2. Gerät in den Pairing-Modus bringen',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Bluetooth-Taste am Omron gedrückt halten, bis im Display "-P-" '
              'blinkt. Dann unten auf "Pairing starten" tippen. Android zeigt '
              'eine Kopplungsanfrage - meist als Benachrichtigung - die du '
              'innerhalb von 30 Sekunden bestätigen musst.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: c.busy || c.userSlot == null
                  ? null
                  : () async {
                      try {
                        await c.pair();
                        if (context.mounted) Navigator.of(context).pop();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppController.describe(e))),
                        );
                      }
                    },
              child: const Text('Pairing starten'),
            ),
            if (c.busy) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (c.status != null) ...[
              const SizedBox(height: 12),
              Text(c.status!),
            ],
            const SizedBox(height: 24),
            const Text(
              'Hinweis: Im Gerät passt immer nur ein Pairing-Key. Nach dem '
              'Pairing mit Sphygma muss die Omron-App bei Bedarf neu gepairt '
              'werden - und umgekehrt.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
