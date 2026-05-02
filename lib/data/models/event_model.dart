import 'package:intl/intl.dart';
import 'sentiment_model.dart';

class EventModel {
  const EventModel({
    required this.id,
    required this.source,
    required this.title,
    required this.publishedAt,
    this.description,
    this.url,
    this.locationName,
    this.lat,
    this.lon,
    this.category,
    this.sentiment,
  });

  final String  id;
  final String  source;
  final String  title;
  final DateTime publishedAt;
  final String? description;
  final String? url;
  final String? locationName;
  final double? lat;
  final double? lon;
  final String? category;
  final SentimentModel? sentiment;

  bool get hasCoordinates => lat != null && lon != null;
  bool get hasUrl         => url != null && url!.isNotEmpty;

  /// Human-readable relative time, e.g. "2 hours ago"
  String get timeAgo {
    final diff = DateTime.now().toUtc().difference(publishedAt.toUtc());
    if (diff.inMinutes < 1)   return 'just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 7)   return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(publishedAt);
  }

  /// Formatted publication date for detail views
  String get formattedDate =>
      DateFormat('MMM d, yyyy • HH:mm UTC').format(publishedAt.toUtc());

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // sentiment may be a List (from Supabase join) or a Map (from direct query)
    SentimentModel? sentiment;
    final rawSent = json['sentiment'];
    if (rawSent is List && rawSent.isNotEmpty) {
      sentiment = SentimentModel.fromJson(rawSent.first as Map<String, dynamic>);
    } else if (rawSent is Map<String, dynamic>) {
      sentiment = SentimentModel.fromJson(rawSent);
    }

    return EventModel(
      id:           json['id']            as String,
      source:       json['source']        as String,
      title:        json['title']         as String,
      description:  json['description']   as String?,
      url:          json['url']           as String?,
      locationName: json['location_name'] as String?,
      lat:          (json['lat']          as num?)?.toDouble(),
      lon:          (json['lon']          as num?)?.toDouble(),
      category:     json['category']      as String?,
      sentiment:    sentiment,
      publishedAt:  DateTime.parse(json['published_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) => other is EventModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}