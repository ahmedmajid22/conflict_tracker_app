import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../data/models/analytics_model.dart';
import '../../../state/analytics_provider.dart';
import '../../widgets/error_view.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(sentimentTrendProvider);
              ref.invalidate(categoryBreakdownProvider);
              ref.invalidate(eventVolumeProvider);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ── Sentiment trend line chart ─────────────────
          _SectionHeader('Sentiment Trend — 90 Days'),
          ref.watch(sentimentTrendProvider).when(
            loading: () => _LoadingCard(height: 220),
            error:   (e, _) => ErrorView(message: e.toString(),
                onRetry: () => ref.invalidate(sentimentTrendProvider)),
            data:    (data) => _SentimentLineChart(data: data),
          ),

          // ── Category breakdown pie chart ───────────────
          _SectionHeader('Category Breakdown — Last 30 Days'),
          ref.watch(categoryBreakdownProvider).when(
            loading: () => _LoadingCard(height: 220),
            error:   (e, _) => ErrorView(message: e.toString(),
                onRetry: () => ref.invalidate(categoryBreakdownProvider)),
            data:    (data) => _CategoryPieChart(data: data),
          ),

          // ── Event volume bar chart ─────────────────────
          _SectionHeader('Event Volume — Last 30 Days'),
          ref.watch(eventVolumeProvider).when(
            loading: () => _LoadingCard(height: 200),
            error:   (e, _) => ErrorView(message: e.toString(),
                onRetry: () => ref.invalidate(eventVolumeProvider)),
            data:    (data) => _VolumeBarChart(data: data),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: SizedBox(height: height,
        child: const Center(child: CircularProgressIndicator())),
  );
}

// ── Sentiment line chart ──────────────────────────────────
class _SentimentLineChart extends StatelessWidget {
  const _SentimentLineChart({required this.data});
  final List<SentimentDailyModel> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    final spots = data.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), e.value.avgScore)
    ).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine:   false,
                horizontalInterval: 0.5,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.dividerColor,
                  strokeWidth: 0.5,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles:   AxisTitles(sideTitles: SideTitles(
                  showTitles:    true,
                  interval:      0.5,
                  reservedSize:  32,
                  getTitlesWidget: (v, _) => Text(
                    v.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 9),
                  ),
                )),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles:    true,
                  interval:      (data.length / 5).roundToDouble(),
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= data.length) return const SizedBox.shrink();
                    final date = DateTime.tryParse(data[i].date);
                    if (date == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('MMM d').format(date),
                        style: const TextStyle(fontSize: 9),
                      ),
                    );
                  },
                )),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              minY: -1.0,
              maxY:  1.0,
              lineBarsData: [
                LineChartBarData(
                  spots:   spots,
                  isCurved: true,
                  color:   const Color(0xFFE53935),
                  barWidth: 2.5,
                  dotData:  const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show:  true,
                    color: const Color(0xFFE53935).withValues(alpha: 0.12),
                  ),
                ),
              ],
              // Zero line
              extraLinesData: ExtraLinesData(horizontalLines: [
                HorizontalLine(
                  y:           0,
                  color:       theme.dividerColor,
                  strokeWidth: 1,
                  dashArray:   [6, 4],
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Category pie chart ────────────────────────────────────
class _CategoryPieChart extends StatefulWidget {
  const _CategoryPieChart({required this.data});
  final List<CategoryCountModel> data;

  @override
  State<_CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<_CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final total = widget.data.fold<int>(0, (s, e) => s + e.count);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Pie chart
            SizedBox(
              height: 180,
              width:  180,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (_, r) {
                      setState(() {
                        _touchedIndex = r?.touchedSection?.touchedSectionIndex ?? -1;
                      });
                    },
                  ),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: widget.data.asMap().entries.map((e) {
                    final pct   = e.value.count / total * 100;
                    final hex   = AppConstants.categoryColors[e.value.category] ?? 0xFF757575;
                    final color = Color(hex);
                    final isTouched = _touchedIndex == e.key;
                    return PieChartSectionData(
                      value:  e.value.count.toDouble(),
                      color:  color,
                      radius: isTouched ? 70 : 60,
                      title:  isTouched ? '${pct.toStringAsFixed(0)}%' : '',
                      titleStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Legend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.data.map((item) {
                  final hex   = AppConstants.categoryColors[item.category] ?? 0xFF757575;
                  final color = Color(hex);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(width: 10, height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.category,
                              style: theme.textTheme.bodySmall),
                        ),
                        Text(item.count.toString(),
                            style: theme.textTheme.labelLarge?.copyWith(color: color)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Event volume bar chart ────────────────────────────────
class _VolumeBarChart extends StatelessWidget {
  const _VolumeBarChart({required this.data});
  final List<SentimentDailyModel> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxY = data
        .map((e) => e.eventCount.toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
        child: SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY:       maxY * 1.2,
              borderData: FlBorderData(show: false),
              gridData:   FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color:       Theme.of(context).dividerColor,
                  strokeWidth: 0.5,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles:   AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (v, _) => Text(
                    v.toInt().toString(),
                    style: const TextStyle(fontSize: 9),
                  ),
                )),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles:  true,
                  interval:    5,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= data.length) return const SizedBox.shrink();
                    final date = DateTime.tryParse(data[i].date);
                    if (date == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('d').format(date),
                        style: const TextStyle(fontSize: 9),
                      ),
                    );
                  },
                )),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: data.asMap().entries.map((e) {
                final sentimentColor = e.value.avgScore < -0.3
                    ? const Color(0xFFE53935)
                    : e.value.avgScore > 0.3
                        ? const Color(0xFF43A047)
                        : const Color(0xFF757575);
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY:   e.value.eventCount.toDouble(),
                      color: sentimentColor.withOpacity(0.8),
                      width: data.length > 20 ? 6 : 10,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}