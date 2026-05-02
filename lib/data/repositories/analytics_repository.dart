import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../services/api_service.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(apiServiceProvider));
});

class AnalyticsRepository {
  const AnalyticsRepository(this._api);
  final ApiService _api;

  Future<KpiModel> getKpi() async {
    final data = await _api.getKpi();
    return KpiModel.fromJson(data);
  }

  Future<List<SentimentDailyModel>> getSentimentTrend({int days = 90}) async {
    final data = await _api.getSentimentTrend(days: days);
    final list = data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => SentimentDailyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryCountModel>> getCategoryBreakdown() async {
    final data = await _api.getCategoryBreakdown();
    final list = data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => CategoryCountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SentimentDailyModel>> getEventVolume({int days = 30}) async {
    final data = await _api.getEventVolume(days: days);
    final list = data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => SentimentDailyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}