import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants.dart';
import '../../../data/models/analytics_model.dart';
import '../../../state/analytics_provider.dart';
import '../../../state/events_provider.dart';
import '../../widgets/event_card.dart';
import '../../widgets/error_view.dart';
import '../../widgets/kpi_tile.dart';
import '../../widgets/loading_shimmer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiAsync     = ref.watch(kpiProvider);
    final recentAsync  = ref.watch(recentEventsProvider);
    final theme        = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConstants.appName, style: theme.textTheme.headlineSmall),
            Text(
              AppConstants.appTagline,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        toolbarHeight: 64,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(kpiProvider);
              ref.invalidate(recentEventsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(kpiProvider);
          ref.invalidate(recentEventsProvider);
        },
        child: ListView(
          children: [
            // ── KPI section ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Overview', style: theme.textTheme.titleLarge),
            ),

            kpiAsync.when(
              loading: () => const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(kpiProvider),
              ),
              data: (kpi) => _KpiGrid(kpi: kpi),
            ),

            // ── Live feed section ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Row(
                children: [
                  Text('Latest Events', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  _PipelineStatusDot(ref: ref),
                ],
              ),
            ),

            recentAsync.when(
              loading: () => const EventCardShimmer(),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(recentEventsProvider),
              ),
              data: (events) => events.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No events yet — pipeline is running')),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < events.length; i++)
                          EventCard(event: events[i], index: i),
                        const SizedBox(height: 16),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── KPI grid (2 × 2) ─────────────────────────────────────
class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.kpi});
  final KpiModel kpi;

  String _sentimentLabel(double score) {
    if (score < -0.3) return 'Negative';
    if (score >  0.3) return 'Positive';
    return 'Neutral';
  }

  @override
  Widget build(BuildContext context) {
    final tiles = [
      KpiTile(
        label:    'Total Events',
        value:    kpi.totalEvents.toString(),
        icon:     Icons.article,
        color:    const Color(0xFF1E88E5),
        subtitle: '${kpi.todayEvents} today',
      ),
      KpiTile(
        label:    '7-Day Sentiment',
        value:    _sentimentLabel(kpi.avgSentiment7d),
        icon:     Icons.sentiment_very_dissatisfied,
        color:    const Color(0xFFE53935),
        subtitle: 'Score: ${kpi.avgSentiment7d.toStringAsFixed(2)}',
      ),
      KpiTile(
        label:    'Top Source',
        value:    kpi.topSource.toUpperCase(),
        icon:     Icons.newspaper,
        color:    const Color(0xFF6A1B9A),
      ),
      KpiTile(
        label:    'Top Category',
        value:    kpi.topCategory,
        icon:     Icons.category,
        color:    const Color(0xFF00897B),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        crossAxisCount:    2,
        shrinkWrap:        true,
        physics:           const NeverScrollableScrollPhysics(),
        childAspectRatio:  1.2,
        children: tiles,
      ),
    );
  }
}

// ── Pipeline status dot ───────────────────────────────────
class _PipelineStatusDot extends ConsumerWidget {
  const _PipelineStatusDot({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF43A047),
            shape: BoxShape.circle,
          ),
        ).animate(onPlay: (c) => c.repeat())
         .fadeOut(duration: 1000.ms)
         .then()
         .fadeIn(duration: 1000.ms),
        const SizedBox(width: 6),
        Text('Live', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}