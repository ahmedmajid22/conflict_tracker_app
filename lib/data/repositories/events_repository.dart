import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository(ref.watch(apiServiceProvider));
});

class EventsRepository {
  const EventsRepository(this._api);
  final ApiService _api;

  Future<List<EventModel>> getEvents({
    int     limit    = 30,
    int     offset   = 0,
    String? category,
    String? source,
    String? search,
    String? fromDate,
    String? toDate,
  }) async {
    final data = await _api.getEvents(
      limit:    limit,
      offset:   offset,
      category: category,
      source:   source,
      search:   search,
      fromDate: fromDate,
      toDate:   toDate,
    );
    final list = data['data'] as List<dynamic>? ?? [];
    return list.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<EventModel>> getMapEvents({String? category, int days = 30}) async {
    final data = await _api.getMapEvents(category: category, days: days);
    final list = data['data'] as List<dynamic>? ?? [];
    return list.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}