import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/event_model.dart';
import '../data/repositories/events_repository.dart';
import 'filter_provider.dart';

// ── Feed events (paginated) ───────────────────────────────
final feedEventsProvider =
    FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final filter = ref.watch(filterProvider);
  final repo   = ref.watch(eventsRepositoryProvider);
  return repo.getEvents(
    category: filter.category,
    source:   filter.source,
    search:   filter.search,
  );
});

// ── Map events ────────────────────────────────────────────
final mapEventsProvider =
    FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final filter = ref.watch(filterProvider);
  final repo   = ref.watch(eventsRepositoryProvider);
  return repo.getMapEvents(
    category: filter.category,
    days:     filter.days,
  );
});

// ── Recent events for home screen (latest 10) ─────────────
final recentEventsProvider =
    FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final repo = ref.watch(eventsRepositoryProvider);
  return repo.getEvents(limit: 10);
});