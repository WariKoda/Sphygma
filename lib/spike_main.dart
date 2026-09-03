// Eigener Einstiegspunkt fuer den M1-Protokoll-Spike, getrennt von
// lib/main.dart (das M6 gehoert). Start: flutter run -t lib/spike_main.dart
import 'package:flutter/material.dart';

import 'spike/protocol_spike_screen.dart';

void main() {
  runApp(const _SpikeApp());
}

class _SpikeApp extends StatelessWidget {
  const _SpikeApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sphygma Spike',
      home: ProtocolSpikeScreen(),
    );
  }
}
