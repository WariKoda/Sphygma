// Hinweisfeld auf "Heute". Erscheint nur, wenn es etwas zu sagen gibt -
// nie als dauerhafte Verzierung.
import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

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

    return Container(
      margin: EdgeInsets.symmetric(vertical: t.gapSmall),
      padding: EdgeInsets.all(t.gapSmall + 4),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: t.categoryColors.values.last,
            width: 3,
          ),
        ),
        borderRadius: widget.details == null && !t.useRoundedCards
            ? null
            : BorderRadius.circular(t.radius),
        color: t.line.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: t.onSurface,
            ),
          ),
          SizedBox(height: t.gapSmall / 2),
          Text(
            widget.message,
            style: TextStyle(fontSize: 12, color: t.onSurface),
          ),
          if (widget.details != null) ...[
            SizedBox(height: t.gapSmall / 2),
            GestureDetector(
              onTap: () => setState(() => _open = !_open),
              child: Text(
                _open ? 'Anleitung ausblenden' : 'Anleitung anzeigen',
                style: TextStyle(
                  fontSize: 12,
                  color: t.accent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            if (_open) ...[
              SizedBox(height: t.gapSmall),
              Text(
                widget.details!,
                style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
