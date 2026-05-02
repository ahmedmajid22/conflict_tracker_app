class SentimentModel {
  const SentimentModel({
    required this.score,
    required this.label,
    this.modelName,
  });

  final double score;
  final String label;    // 'negative' | 'neutral' | 'positive'
  final String? modelName;

  factory SentimentModel.fromJson(Map<String, dynamic> json) => SentimentModel(
    score:     (json['score'] as num?)?.toDouble() ?? 0.0,
    label:     json['label'] as String? ?? 'neutral',
    modelName: json['model_name'] as String?,
  );

  /// Returns a value from 0.0 to 1.0 suitable for colour interpolation.
  /// -1 → 0.0 (full red), 0 → 0.5 (grey), +1 → 1.0 (full green)
  double get normalizedScore => (score + 1.0) / 2.0;

  bool get isNegative => label == 'negative';
  bool get isPositive => label == 'positive';
  bool get isNeutral  => label == 'neutral';

  @override
  String toString() => 'SentimentModel(label: $label, score: $score)';
}