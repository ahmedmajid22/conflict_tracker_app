import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conflict_tracker_app/data/models/event_model.dart';
import 'package:conflict_tracker_app/data/models/sentiment_model.dart';
import 'package:conflict_tracker_app/presentation/widgets/event_card.dart';
import 'package:conflict_tracker_app/presentation/widgets/sentiment_badge.dart';
import 'package:conflict_tracker_app/presentation/widgets/category_chip.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
);

final _testEvent = EventModel(
  id:           'uuid-001',
  source:       'bbc',
  title:        'Missile strike confirmed near the capital',
  description:  'Military sources confirmed the attack occurred at dawn.',
  url:          'https://bbc.com/test',
  publishedAt:  DateTime.now().subtract(const Duration(hours: 2)),
  locationName: 'Baghdad',
  lat:          33.3,
  lon:          44.4,
  category:     'military',
  sentiment:    const SentimentModel(score: -0.9, label: 'negative'),
);

void main() {
  group('EventCard widget', () {
    testWidgets('renders the event title', (tester) async {
      await tester.pumpWidget(_wrap(EventCard(event: _testEvent)));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(_testEvent.title), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('renders the CategoryChip', (tester) async {
      await tester.pumpWidget(_wrap(EventCard(event: _testEvent)));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CategoryChip), findsWidgets);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('renders SentimentBadge', (tester) async {
      await tester.pumpWidget(_wrap(EventCard(event: _testEvent)));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(SentimentBadge), findsWidgets);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('renders location name', (tester) async {
      await tester.pumpWidget(_wrap(EventCard(event: _testEvent)));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Baghdad'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });

  group('SentimentBadge widget', () {
    testWidgets('shows negative label for negative sentiment', (tester) async {
      const badge = SentimentBadge(
          sentiment: SentimentModel(score: -0.9, label: 'negative'));
      await tester.pumpWidget(_wrap(badge));
      await tester.pump();
      expect(find.text('negative'), findsOneWidget);
    });

    testWidgets('shows nothing when sentiment is null', (tester) async {
      const badge = SentimentBadge(sentiment: null);
      await tester.pumpWidget(_wrap(badge));
      await tester.pump();
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}