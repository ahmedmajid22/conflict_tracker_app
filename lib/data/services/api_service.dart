import 'package:conflict_tracker_app/core/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Singleton Dio client shared across the app.
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl:        AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 90),
        headers:        {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody:  false,
        responseBody: false,
        logPrint: (o) => debugPrint('[API] $o'),
      ),
    );
  }

  late final Dio _dio;

  Future<void> wakeUp() async {
    const maxAttempts  = 3;
    const delayBetween = Duration(seconds: 5);
    Exception? lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await _dio.get(
          '/health/ping',
          options: Options(
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout:    const Duration(seconds: 15),
          ),
        );
        debugPrint('[API] Server awake after attempt $attempt');
        return;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint('[API] Wake-up attempt $attempt/$maxAttempts failed: $e');
        if (attempt < maxAttempts) {
          await Future.delayed(delayBetween);
        }
      }
    }
    throw lastError ?? Exception('Server did not respond after $maxAttempts attempts');
  }

  // ── Events ───────────────────────────────────────────────

  Future<Map<String, dynamic>> getEvents({
    int     limit      = AppConstants.defaultPageSize,
    int     offset     = 0,
    String? category,
    String? source,
    String? fromDate,
    String? toDate,
    bool?   geolocated,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'limit':  limit,
      'offset': offset,
      if (category   != null) 'category':  category,
      if (source     != null) 'source':     source,
      if (fromDate   != null) 'from_date':  fromDate,
      if (toDate     != null) 'to_date':    toDate,
      if (geolocated != null) 'geolocated': geolocated,
      if (search     != null) 'search':     search,
    };
    final resp = await _dio.get('/events', queryParameters: params);
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMapEvents({
    String? category,
    int days = 30,
  }) async {
    final params = <String, dynamic>{
      'days': days,
      if (category != null) 'category': category,
    };
    final resp = await _dio.get('/events/map', queryParameters: params);
    return resp.data as Map<String, dynamic>;
  }

  // ── Analytics ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getSentimentTrend({int days = 90}) async {
    final resp = await _dio.get(
      '/analytics/sentiment-trend',
      queryParameters: {'days': days},
    );
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCategoryBreakdown() async {
    final resp = await _dio.get('/analytics/category-breakdown');
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getKpi() async {
    final resp = await _dio.get('/analytics/kpi');
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTopEntities({int days = 30}) async {
    final resp = await _dio.get(
      '/analytics/top-entities',
      queryParameters: {'days': days, 'limit': 15},
    );
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getEventVolume({int days = 30}) async {
    final resp = await _dio.get(
      '/analytics/volume',
      queryParameters: {'days': days},
    );
    return resp.data as Map<String, dynamic>;
  }

  // ── Health ────────────────────────────────────────────────

  Future<Map<String, dynamic>> getHealth() async {
    final resp = await _dio.get('/health');
    return resp.data as Map<String, dynamic>;
  }
}
