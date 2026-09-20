import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../queue_drainer.dart';
import 'feed_controller.dart';
import 'widgets/feed_detail_screen.dart';
import 'widgets/feed_filter_bar.dart';
import 'widgets/feed_list_item.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);
    final controller = ref.read(feedControllerProvider.notifier);

    final allCount = state.entries.length;
    final redCount = state.entries.where((e) => e.level == 'RED').length;
    final amberCount = state.entries.where((e) => e.level == 'AMBER').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Feed'),
        actions: [
          if (state.entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Sab Saaf Karein',
              onPressed: () => _confirmClear(context, controller),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l16,
              vertical: AppSpacing.s8,
            ),
            child: TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search pattern or alert…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          FeedFilterBar(
            selected: state.filter,
            onChanged: controller.setFilter,
            allCount: allCount,
            redCount: redCount,
            amberCount: amberCount,
          ),
          const SizedBox(height: AppSpacing.s8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(queueDrainerProvider).drainAll();
                controller.loadEntries();
              },
              child: state.isLoading
                  ? const Center(child: LoadingView())
                  : state.filteredEntries.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            EmptyStateView(
                              icon: Icons.check_circle_outline_rounded,
                              title: 'Koi dhoka nahi mila',
                              message: 'Sab surakshit hai! All clear.',
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = state.filteredEntries[index];
                            return FeedListItem(
                              entry: entry,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FeedDetailScreen(entry: entry),
                                ),
                              ),
                              onDismiss: () {
                                controller.dismissEntry(entry.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Item dismissed'),
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      onPressed: controller.undoDismiss,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, FeedController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Saari activity hatayein?'),
        content: const Text('Yeh action undo nahi ho sakta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.clearAll();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}