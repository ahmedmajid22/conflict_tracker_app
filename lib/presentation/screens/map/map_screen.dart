import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants.dart';
import '../../../data/models/event_model.dart';
import '../../../state/events_provider.dart';
import '../../../state/filter_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/error_view.dart';
import '../../widgets/event_card.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  EventModel? _selectedEvent;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(mapEventsProvider);
    final filter      = ref.watch(filterProvider);
    final theme       = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Map'),
        actions: [
          if (filter.hasActiveFilters)
            TextButton(
              onPressed: () => ref.read(filterProvider.notifier).clearAll(),
              child: const Text('Clear filters'),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Category filter bar ────────────────────────
          _CategoryFilterBar(
            selected: filter.category,
            onSelect: (c) =>
                ref.read(filterProvider.notifier).setCategory(c),
          ),

          // ── Map ───────────────────────────────────────
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(mapEventsProvider),
              ),
              data: (events) => Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(
                          AppConstants.defaultLat, AppConstants.defaultLon),
                      initialZoom: AppConstants.defaultZoom,
                      onTap: (_, __) =>
                          setState(() => _selectedEvent = null),
                    ),
                    children: [
                      // ── Tile layer (OpenStreetMap, free) ───
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.conflicttracker',
                      ),

                      // ── Event markers ──────────────────────
                      MarkerLayer(
                        markers: events
                            .where((e) => e.hasCoordinates)
                            .map((e) => _buildMarker(e))
                            .toList(),
                      ),
                    ],
                  ),

                  // ── Event count badge ──────────────────────
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:        theme.colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow:    [BoxShadow(
                            color: Colors.black26, blurRadius: 8)],
                      ),
                      child: Text(
                        '${events.where((e) => e.hasCoordinates).length} events',
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Selected event card ────────────────────────
          if (_selectedEvent != null)
            Container(
              height: 150,
              color: theme.colorScheme.surface,
              child: EventCard(event: _selectedEvent!),
            ),
        ],
      ),
    );
  }

  Marker _buildMarker(EventModel event) {
    final hex   = AppConstants.categoryColors[event.category ?? 'other'] ?? 0xFF757575;
    final color = Color(hex);
    final sentimentScore = event.sentiment?.score ?? 0.0;

    // Pulse size based on sentiment negativity
    final size = 24.0 + (sentimentScore.abs() * 10);

    return Marker(
      point: LatLng(event.lat!, event.lon!),
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () => setState(() => _selectedEvent = event),
        child: Container(
          decoration: BoxDecoration(
            color:       color.withValues(alpha: 0.85),
            shape:       BoxShape.circle,
            border:      Border.all(color: Colors.white, width: 1.5),
            boxShadow:   [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
          ),
          child: Icon(
            _categoryIcon(event.category),
            color: Colors.white,
            size:  size * 0.5,
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String? category) {
    switch (category) {
      case 'military':     return Icons.military_tech;
      case 'diplomatic':   return Icons.handshake;
      case 'economic':     return Icons.trending_up;
      case 'humanitarian': return Icons.volunteer_activism;
      case 'social':       return Icons.people;
      default:             return Icons.circle;
    }
  }
}

// ── Category filter bar ───────────────────────────────────
class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({required this.selected, required this.onSelect});

  final String?               selected;
  final ValueChanged<String?> onSelect;

  static const _categories = [
    'military', 'diplomatic', 'economic', 'humanitarian', 'social', 'other'
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