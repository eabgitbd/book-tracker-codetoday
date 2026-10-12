import 'package:flutter/material.dart';

class ReadingProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final double height;
  final bool showLabel;

  const ReadingProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 6.0,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = progress.clamp(0.0, 1.0);
    final barColor = color ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            height: height,
            color: theme.dividerColor.withOpacity(0.4),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: Container(
                color: barColor,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            '${(clamped * 100).toInt()}%',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: barColor,
            ),
          ),
        ],
      ],
    );
  }
}
