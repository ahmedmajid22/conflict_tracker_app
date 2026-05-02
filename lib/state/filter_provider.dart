import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterState {
  const FilterState({
    this.category,
    this.source,
    this.search,
    this.geolocatedOnly = false,
    this.days           = 30,
  });

  final String? category;
  final String? source;
  final String? search;
  final bool    geolocatedOnly;
  final int     days;

  FilterState copyWith({
    String? category,
    String? source,
    String? search,
    bool?   geolocatedOnly,
    int?    days,
    bool    clearCategory = false,
    bool    clearSource   = false,
    bool    clearSearch   = false,
  }) =>
      FilterState(
        category:      clearCategory   ? null : category      ?? this.category,
        source:        clearSource     ? null : source         ?? this.source,
        search:        clearSearch     ? null : search         ?? this.search,
        geolocatedOnly: geolocatedOnly ?? this.geolocatedOnly,
        days:           days           ?? this.days,
      );

  bool get hasActiveFilters =>
      category != null || source != null || search != null || geolocatedOnly;
}

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() => const FilterState();

  void setCategory(String? v)   => state = state.copyWith(category: v,  clearCategory: v == null);
  void setSource(String? v)     => state = state.copyWith(source:   v,  clearSource:   v == null);
  void setSearch(String? v)     => state = state.copyWith(search:   v,  clearSearch:   v == null);
  void setGeolocated(bool v)    => state = state.copyWith(geolocatedOnly: v);
  void setDays(int v)           => state = state.copyWith(days: v);
  void clearAll()               => state = const FilterState();
}

final filterProvider =
    NotifierProvider<FilterNotifier, FilterState>(FilterNotifier.new);