import 'package:flutter/material.dart';

import '../../core/constants/ui_constants.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.activeCount,
    required this.onPressed,
  });

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasFilters = activeCount > 0;

    return SizedBox(
      height: kDashboardControlHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, kDashboardControlHeight),
          maximumSize: const Size(double.infinity, kDashboardControlHeight),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(
          Icons.tune_rounded,
          size: 20,
          color: hasFilters ? colorScheme.primary : null,
        ),
        label: Text(
          hasFilters ? 'Filters ($activeCount)' : 'Filters',
          style: TextStyle(
            color: hasFilters ? colorScheme.primary : null,
            fontWeight: hasFilters ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
