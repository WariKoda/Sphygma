import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

/// Gemeinsame Hierarchie für Karten, auch wenn Titel oder Aktionen umbrechen.
class PanelHeader extends StatelessWidget {
  const PanelHeader({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.unit,
    this.inlineSubtitle = false,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final String? unit;
  final bool inlineSubtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final inherited = DefaultTextStyle.of(context).style;
    final titleStyle = inherited.copyWith(
      fontFamily: t.fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: t.onSurface,
    );
    final detailStyle = inherited.copyWith(
      fontFamily: t.fontFamily,
      fontSize: 13,
      color: t.muted,
    );
    final titleText = Semantics(
      header: true,
      child: Wrap(
        spacing: t.gapSmall / 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(title, style: titleStyle),
          if (unit != null) Text(unit!, style: detailStyle),
        ],
      ),
    );
    final subtitleText = subtitle == null
        ? null
        : Text(subtitle!, style: detailStyle);
    final heading = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(icon, size: 20, color: t.onSurface),
          ),
          SizedBox(width: t.gapSmall),
        ],
        Expanded(child: titleText),
      ],
    );
    return Padding(
      padding: EdgeInsets.only(
        bottom: inlineSubtitle ? t.gapSmall : t.gapLarge,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width(String text, TextStyle style) {
            final painter = TextPainter(
              text: TextSpan(text: text, style: style),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout();
            final result = painter.width;
            painter.dispose();
            return result;
          }

          final subtitleWidth = inlineSubtitle && subtitle != null
              ? width(subtitle!, detailStyle)
              : 0.0;
          final headingWidth = inlineSubtitle && subtitle != null
              ? width(title, titleStyle) +
                    (unit == null
                        ? 0
                        : t.gapSmall / 2 + width(unit!, detailStyle)) +
                    (icon == null ? 0 : 20 + t.gapSmall)
              : 0.0;
          final sideBySide =
              inlineSubtitle &&
              subtitleText != null &&
              constraints.maxWidth >= headingWidth + t.gapSmall + subtitleWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sideBySide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: heading),
                    SizedBox(width: t.gapSmall),
                    SizedBox(width: subtitleWidth, child: subtitleText),
                  ],
                )
              else ...[
                heading,
                if (subtitleText != null) ...[
                  SizedBox(height: t.gapSmall / 2),
                  subtitleText,
                ],
              ],
              if (trailing != null) ...[
                SizedBox(height: t.gapSmall),
                trailing!,
              ],
            ],
          );
        },
      ),
    );
  }
}
