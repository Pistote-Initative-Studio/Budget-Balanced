import 'package:flutter/material.dart';

import '../core/utils/currency.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.savedCents,
    required this.remainingCents,
  });

  final int savedCents;
  final int remainingCents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savedStyle = theme.textTheme.headlineMedium?.copyWith(
      color: savedCents > 0 ? theme.colorScheme.primary : null,
    );
    final hasBudget = !(savedCents == 0 && remainingCents == 0);
    final remainingColor = hasBudget && remainingCents < 0
        ? theme.colorScheme.error
        : theme.textTheme.bodyMedium?.color;
    final remainingLabel = hasBudget
        ? '${formatCents(remainingCents)} left in budget'
        : 'No budget set.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You've Saved ${formatCents(savedCents)}",
          style: savedStyle,
        ),
        Text(
          remainingLabel,
          style: theme.textTheme.bodyMedium?.copyWith(color: remainingColor),
        ),
      ],
    );
  }
}
