import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/event_model.dart';
import 'category_chip.dart';
import 'sentiment_badge.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.index = 0,
  });

  final EventModel event;
  final int        index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ─────────────────────────────
              Row(
                children: [
                  _SourceBadge(source: event.source),
                  const SizedBox(width: 8),
                  if (event.category != null)
                    CategoryChip(category: event.category!, small: true),
                  const Spacer(),
                  SentimentBadge(sentiment: event.sentiment, compact: true),
                  const SizedBox(width: 8),
                  Text(
                    event.timeAgo,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Title ──────────────────────────────────
              Text(
                event.title,
                style: theme.textTheme.titleMedium?.copyWith(height: 1.35),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // ── Description ────────────────────────────
              if (event.description != null && event.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  event.description!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 10),

              // ── Footer row ─────────────────────────────
              Row(
                children: [
                  if (event.locationName != null) ...[
                    Icon(Icons.location_on, size: 12,
                        color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        event.locationName!,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (event.hasUrl)
                    InkWell(
                      onTap: () => _launchUrl(event.url!),
                      child: Icon(Icons.open_in_new,
                          size: 14,
                          color: theme.colorScheme.primary),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 50))
     .fadeIn(duration: 300.ms)
     .slideY(begin: 0.05, end: 0);
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context:      context,
      isScrollControlled: true,
      useSafeArea:  true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EventDetailSheet(event: event),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ── Source badge ─────────────────────────────────────────
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});
  final String source;

  static const _colors = <String, Color>{
    'bbc':        Color(0xFFCC0000),
    'bbc_world':  Color(0xFFCC0000),
    'reuters':    Color(0xFFFF6600),
    'al_jazeera': Color(0xFF009933),
    'newsapi':    Color(0xFF1565C0),
    'gdelt':      Color(0xFF6A1B9A),
    'france24':   Color(0xFF003399),
    'guardian':   Color(0xFF005789),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[source] ?? const Color(0xFF607D8B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        source.toUpperCase().replaceAll('_', ' '),
        style: const TextStyle(
          color:      Colors.white,
          fontSize:   9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Event detail bottom sheet ─────────────────────────────
class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize:     0.4,
      maxChildSize:     0.95,
      expand:           false,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color:        theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category + sentiment
            if (event.category != null || event.sentiment != null)
              Row(
                children: [
                  if (event.category != null)
                    CategoryChip(category: event.category!),
                  const SizedBox(width: 8),
                  SentimentBadge(sentiment: event.sentiment),
                ],
              ),

            const SizedBox(height: 12),

            // Title
            Text(event.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),

            // Date + source
            Row(
              children: [
                _SourceBadge(source: event.source),
                const SizedBox(width: 8),
                Text(event.formattedDate, style: theme.textTheme.bodySmall),
              ],
            ),

            // Location
            if (event.locationName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(event.locationName!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ],

            const Divider(height: 24),

            // Description
            if (event.description != null)
              Text(event.description!, style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                if (event.hasUrl)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(event.url!);
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      },
                      icon:  const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Read full article'),
                    ),
                  ),
                if (event.hasUrl) const SizedBox(width: 12),
                IconButton.outlined(
                  onPressed: () => Share.share('${event.title}\n\n${event.url ?? ""}'),
                  icon: const Icon(Icons.share),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}