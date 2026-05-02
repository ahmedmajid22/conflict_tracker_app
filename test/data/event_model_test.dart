import 'package:flutter_test/flutter_test.dart';
import 'package:conflict_tracker_app/data/models/event_model.dart';
import 'package:conflict_tracker_app/data/models/sentiment_model.dart';

void main() {
  group('EventModel.fromJson', () {
    final validJson = {
      'id':           'test-uuid-001',
      'source':       'bbc',
      'title':        'Airstrike reported in the region',
      'description':  'Military forces conducted airstrikes.',
      'url':          'https://bbc.com/article/1',
      'published_at': '2024-06-01T12:00:00+00:00',
      'location_name': 'Baghdad',
      'lat':          33.3152,
      'lon':          44.3661,
      'category':     'military',
      'sentiment': [
        {'score': -0.85, 'label': 'negative', 'model_name': 'test-model'},
      ],
    };

    test('parses all fields correctly', () {
      final event = EventModel.fromJson(validJson);
      expect(event.id,           'test-uuid-001');
      expect(event.source,       'bbc');
      expect(event.title,        'Airstrike reported in the region');
      expect(event.category,     'military');
      expect(event.lat,          33.3152);
      expect(event.lon,          44.3661);
      expect(event.locationName, 'Baghdad');
    });

    test('parses sentiment from list correctly', () {
      final event = EventModel.fromJson(validJson);
      expect(event.sentiment,            isNotNull);
      expect(event.sentiment!.label,     'negative');
      expect(event.sentiment!.score,     closeTo(-0.85, 0.001));
    });

    test('hasCoordinates is true when lat and lon are set', () {
      final event = EventModel.fromJson(validJson);
      expect(event.hasCoordinates, isTrue);
    });

    test('hasCoordinates is false when lat is null', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['lat'] = null
        ..['lon'] = null;
      final event = EventModel.fromJson(json);
      expect(event.hasCoordinates, isFalse);
    });

    test('hasUrl is true when url is set', () {
      final event = EventModel.fromJson(validJson);
      expect(event.hasUrl, isTrue);
    });

    test('hasUrl is false when url is null', () {
      final json = Map<String, dynamic>.from(validJson)..['url'] = null;
      final event = EventModel.fromJson(json);
      expect(event.hasUrl, isFalse);
    });

    test('handles null sentiment gracefully', () {
      final json = Map<String, dynamic>.from(validJson)..['sentiment'] = null;
      final event = EventModel.fromJson(json);
      expect(event.sentiment, isNull);
    });

    test('handles empty sentiment list', () {
      final json = Map<String, dynamic>.from(validJson)..['sentiment'] = [];
      final event = EventModel.fromJson(json);
      expect(event.sentiment, isNull);
    });

    test('timeAgo returns "just now" for recent events', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['published_at'] = DateTime.now().toUtc().toIso8601String();
      final event = EventModel.fromJson(json);
      expect(event.timeAgo, 'just now');
    });

    test('two events with same id are equal', () {
      final a = EventModel.fromJson(validJson);
      final b = EventModel.fromJson(validJson);
      expect(a, equals(b));
    });
  });

  group('SentimentModel', () {
    test('normalizedScore maps -1 to 0.0', () {
      final s = SentimentModel(score: -1.0, label: 'negative');
      expect(s.normalizedScore, closeTo(0.0, 0.001));
    });

    test('normalizedScore maps 0 to 0.5', () {
      final s = SentimentModel(score: 0.0, label: 'neutral');
      expect(s.normalizedScore, closeTo(0.5, 0.001));
    });

    test('normalizedScore maps +1 to 1.0', () {
      final s = SentimentModel(score: 1.0, label: 'positive');
      expect(s.normalizedScore, closeTo(1.0, 0.001));
    });

    test('isNegative returns true for negative label', () {
      final s = SentimentModel(score: -0.8, label: 'negative');
      expect(s.isNegative, isTrue);
      expect(s.isPositive, isFalse);
    });
  });
}