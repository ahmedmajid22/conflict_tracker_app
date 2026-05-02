import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/events_provider.dart';
import '../../../state/filter_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/event_card.dart';
import '../../widgets/loading_shimmer.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(feedEventsProvider);
    final filter      = ref.watch(filterProvider);
    final notifier    = ref.read(filterProvider.notifier);
    final theme       = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
        actions: [
          if (filter.hasActiveFilters)
            TextButton(
              onPressed: () {
                notifier.clearAll();
                _searchController.clear();
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:      'Search events...',
                prefixIcon:    const Icon(Icons.search, size: 20),
                border:        OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:   BorderSide.none,
                ),
                filled:        true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: filter.search != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearch(null);
                        },
                      )
                    : null,
              ),
              onChanged: (v) => notifier.setSearch(v.isEmpty ? null : v),
            ),
          ),

          // ── Category filter bar ─────────────────────────
          _CategoryFilterBar(
            selected: filter.category,
            onSelect: notifier.setCategory,
          ),

          // ── Events list ────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(feedEventsProvider),
              child: eventsAsync.when(
                loading: () => const EventCardShimmer(),
                error: (e, _) => ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(feedEventsProvider),
                ),
                data: (events) => events.isEmpty
                    ? const EmptyView(
                        message: 'No events match your filters',
                        subtitle: 'Try adjusting the category or search terms',
                        icon: Icons.search_off,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: events.length,
                        itemBuilder: (_, i) =>
                            EventCard(event: events[i], index: i),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({required this.selected, required this.onSelect});

  final String?               selected;
  final ValueChanged<String?> onSelect;

  static const _categories = [
    'military', 'diplomatic', 'economic', 'humanitarian', 'social'
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onSelect(null),
              child: Chip(
                label: const Text('All'),
                backgroundColor: selected == null
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                    : null,
              ),
            ),
          ),
          for (final cat in _categories)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CategoryChip(
                category: cat,
                selected: selected == cat,
                onTap:    () => onSelect(selected == cat ? null : cat),
              ),
            ),
        ],
      ),
    );
  }
}