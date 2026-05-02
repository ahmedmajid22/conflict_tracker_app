import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/analytics_model.dart';
import '../data/repositories/analytics_repository.dart';

final kpiProvider =
    FutureProvider.autoDispose<KpiModel>((ref) async {
  return ref.watch(analyticsRepositoryProvider).getKpi();
});

final sentimentTrendProvider =
    FutureProvider.autoDispose<List<SentimentDailyModel>>((ref) async {
  return ref.watch(analyticsRepositoryProvider).getSentimentTrend(days: 90);
});

final categoryBreakdownProvider =
    FutureProvider.autoDispose<List<CategoryCountModel>>((ref) async {
  return ref.watch(analyticsRepositoryProvider).getCategoryBreakdown();
});

final eventVolumeProvider =
    FutureProvider.autoDispose<List<SentimentDailyModel>>((ref) async {
  return ref.watch(analyticsRepositoryProvider).getEventVolume(days: 30);
});