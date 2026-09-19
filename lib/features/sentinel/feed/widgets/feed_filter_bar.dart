import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../feed_controller.dart';

class FeedFilterBar extends StatelessWidget {
  const FeedFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.allCount,
    required this.redCount,
    required this.amberCount,
  });

  final FeedFilter selected;
  final ValueChanged<FeedFilter> onChanged;
  final int allCount;
  final int redCount;
  final int amberCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l16),
      child: Row(
        children: [
          FilterChip(
            label: Text('Sabhi ($allCount)'),
            selected: selected == FeedFilter.all,
            onSelected: (_) => onChanged(FeedFilter.all),
          ),
          const SizedBox(width: AppSpacing.s8),
          FilterChip(
            label: Text('🔴 Khatra ($redCount)'),
            selected: selected == FeedFilter.red,
            selectedColor: AppColors.dangerContainer,
            onSelected: (_) => onChanged(FeedFilter.red),
          ),
          const SizedBox(width: AppSpacing.s8),
          FilterChip(
            label: Text('🟡 Shak ($amberCount)'),
            selected: selected == FeedFilter.amber,
            selectedColor: AppColors.warningContainer,
            onSelected: (_) => onChanged(FeedFilter.amber),
          ),
        ],
      ),
    );
  }
}