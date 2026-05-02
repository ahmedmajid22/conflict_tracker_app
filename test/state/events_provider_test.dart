import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conflict_tracker_app/state/filter_provider.dart';

void main() {
  group('FilterNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has no active filters', () {
      final state = container.read(filterProvider);
      expect(state.hasActiveFilters, isFalse);
      expect(state.category,         isNull);
      expect(state.search,           isNull);
      expect(state.geolocatedOnly,   isFalse);
    });

    test('setCategory updates category', () {
      container.read(filterProvider.notifier).setCategory('military');
      expect(container.read(filterProvider).category, 'military');
      expect(container.read(filterProvider).hasActiveFilters, isTrue);
    });

    test('setCategory with null clears category', () {
      container.read(filterProvider.notifier).setCategory('military');
      container.read(filterProvider.notifier).setCategory(null);
      expect(container.read(filterProvider).category, isNull);
    });

    test('setSearch updates search', () {
      container.read(filterProvider.notifier).setSearch('airstrike');
      expect(container.read(filterProvider).search, 'airstrike');
    });

    test('clearAll resets all filters', () {
      container.read(filterProvider.notifier).setCategory('military');
      container.read(filterProvider.notifier).setSearch('test');
      container.read(filterProvider.notifier).setGeolocated(true);
      container.read(filterProvider.notifier).clearAll();
      final state = container.read(filterProvider);
      expect(state.hasActiveFilters, isFalse);
      expect(state.category,         isNull);
      expect(state.search,           isNull);
      expect(state.geolocatedOnly,   isFalse);
    });

    test('setDays updates days', () {
      container.read(filterProvider.notifier).setDays(7);
      expect(container.read(filterProvider).days, 7);
    });
  });
}