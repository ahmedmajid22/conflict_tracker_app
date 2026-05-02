class KpiModel {
  const KpiModel({
    required this.totalEvents,
    required this.todayEvents,
    required this.avgSentiment7d,
    required this.topSource,
    required this.topCategory,
  });

  final int    totalEvents;
  final int    todayEvents;
  final double avgSentiment7d;
  final String topSource;
  final String topCategory;

  factory KpiModel.fromJson(Map<String, dynamic> json) => KpiModel(
    totalEvents:    (json['total_events']       as num?)?.toInt()    ?? 0,
    todayEvents:    (json['today_events']        as num?)?.toInt()    ?? 0,
    avgSentiment7d: (json['avg_sentiment_7d']    as num?)?.toDouble() ?? 0.0,
    topSource:       json['top_source']          as String? ?? 'N/A',
    topCategory:     json['top_category']        as String? ?? 'N/A',
  );
}

class SentimentDailyModel {
  const SentimentDailyModel({
    required this.date,
    required this.avgScore,
    required this.negCount,
    required this.neuCount,
    required this.posCount,
    required this.eventCount,
  });

  final String date;        // 'YYYY-MM-DD'
  final double avgScore;
  final int    negCount;
  final int    neuCount;
  final int    posCount;
  final int    eventCount;

  factory SentimentDailyModel.fromJson(Map<String, dynamic> json) => SentimentDailyModel(
    date:       json['date']        as String,
    avgScore:   (json['avg_score']  as num?)?.toDouble() ?? 0.0,
    negCount:   (json['neg_count']  as num?)?.toInt()    ?? 0,
    neuCount:   (json['neu_count']  as num?)?.toInt()    ?? 0,
    posCount:   (json['pos_count']  as num?)?.toInt()    ?? 0,
    eventCount: (json['event_count'] as num?)?.toInt()   ?? 0,
  );
}

class CategoryCountModel {
  const CategoryCountModel({required this.category, required this.count});
  final String category;
  final int    count;

  factory CategoryCountModel.fromJson(Map<String, dynamic> json) => CategoryCountModel(
    category: json['category'] as String? ?? 'other',
    count:    (json['count']   as num?)?.toInt() ?? 0,
  );
}