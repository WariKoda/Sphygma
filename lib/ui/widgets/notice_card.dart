// Hinweisfeld auf "Heute". Erscheint nur, wenn es etwas zu sagen gibt -
// nie als dauerhafte Verzierung.
import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';
import 'panel_header.dart';
import 'surface_panel.dart';

class NoticeCard extends StatefulWidget {
  const NoticeCard({
    super.key,
    required this.title,
    required this.message,
    this.details,
  });

  final String title;
  final String message;

  /// Laengerer Text, der erst auf Tippen erscheint - etwa die Anleitung
  /// zum Stellen der Geraeteuhr.
  final String? details;

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return SurfacePanel(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanelHeader(title: widget.title, icon: Icons.info_outline),
          Text(
            widget.message,
            style: TextStyle(fontSize: 14, color: t.onSurface),
          ),
          if (widget.details != null) ...[
            SizedBox(height: t.gapSmall / 2),
            TextButton(
              onPressed: () => setState(() => _open = !_open),
              child: Text(
                _open ? 'Anleitung ausblenden' : 'Anleitung anzeigen',
                style: TextStyle(
                  fontSize: 14,
                  color: t.accent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            if (_open) ...[
              SizedBox(height: t.gapSmall),
              Text(
                widget.details!,
                style: TextStyle(fontSize: 14, color: t.muted, height: 1.5),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
