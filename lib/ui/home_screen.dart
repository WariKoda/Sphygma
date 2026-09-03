import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import 'pairing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  Future<void> _guard(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppController.describe(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final slotChosen = c.userSlot != null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Icon(c.paired ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
            title: Text(c.paired ? 'Gepairt' : 'Nicht gepairt'),
            subtitle: Text(
              slotChosen ? 'Am Geraet: User ${c.userSlot}' : 'User-Slot noch nicht gewaehlt',
            ),
            trailing: TextButton(
              onPressed: c.busy
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PairingScreen(controller: c),
                        ),
                      ),
              child: Text(c.paired ? 'Neu pairen' : 'Pairen'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: c.busy || !c.paired || !slotChosen
              ? null
              : () => _guard(context, c.sync),
          icon: const Icon(Icons.sync),
          label: const Text('Jetzt synchronisieren'),
        ),
        const SizedBox(height: 4),
        const Text(
          'Vorher die Bluetooth-Taste am Omron kurz druecken.',
          style: TextStyle(fontSize: 12),
        ),
        if (c.busy) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ],
        if (c.status != null) ...[
          const SizedBox(height: 12),
          Text(c.status!),
        ],
        if (c.clockLooksWrong) ...[
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Geraeteuhr pruefen'),
              subtitle: Text(
                'Die neueste Messung traegt ein unplausibles Datum. Bitte Datum '
                'und Uhrzeit am Omron stellen - Sphygma kann die Uhr nicht setzen.',
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Health Connect',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text('${c.pendingExport} Messungen noch nicht exportiert.'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: c.busy || !slotChosen || c.pendingExport == 0
                  ? null
                  : () => _guard(context, c.exportAll),
              child: const Text('Alle exportieren'),
            ),
            OutlinedButton(
              onPressed: c.busy || !slotChosen
                  ? null
                  : () => _guard(context, c.retractAll),
              child: const Text('Alle aus Health Connect entfernen'),
            ),
          ],
        ),
      ],
    );
  }
}
