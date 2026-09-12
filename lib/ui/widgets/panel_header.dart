import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

/// Gemeinsame Hierarchie für Karten, auch wenn Titel oder Aktionen umbrechen.
class PanelHeader extends StatelessWidget {
  const PanelHeader({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: t.gapLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Icon(icon, size: 20, color: t.onSurface),
                ),
                SizedBox(width: t.gapSmall),
              ],
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: t.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: t.gapSmall / 2),
            Text(subtitle!, style: TextStyle(fontSize: 13, color: t.muted)),
          ],
          if (trailing != null) ...[SizedBox(height: t.gapSmall), trailing!],
        ],
      ),
    );
  }
}
