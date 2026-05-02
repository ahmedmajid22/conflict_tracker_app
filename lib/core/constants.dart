// All app-wide constants in one place.
// Update BASE_URL to your real Render.com URL before building.

class AppConstants {
  AppConstants._();

  // ── API ──────────────────────────────────────────────────
  // Replace this with your actual Render.com URL from Stage 2
static const String baseUrl = 'https://conflict-tracker-api-ja8o.onrender.com';

  static const Duration connectTimeout = Duration(seconds: 30);   // was 15
  static const Duration receiveTimeout = Duration(seconds: 90);   // was 20

  // ── Pagination ────────────────────────────────────────────
  static const int defaultPageSize = 30;
  static const int mapEventLimit   = 500;

  // ── Map defaults ─────────────────────────────────────────
  static const double defaultLat  = 32.0;   // Centred on Middle East
  static const double defaultLon  = 44.0;
  static const double defaultZoom = 3.5;

  // ── Cache durations ───────────────────────────────────────
  static const Duration eventsCacheDuration    = Duration(minutes: 2);
  static const Duration analyticsCacheDuration = Duration(minutes: 10);

  // ── Category colours (hex) ────────────────────────────────
  static const Map<String, int> categoryColors = {
    'military':     0xFFE53935,  // red
    'diplomatic':   0xFF1E88E5,  // blue
    'economic':     0xFFFFB300,  // amber
    'humanitarian': 0xFF43A047,  // green
    'social':       0xFF8E24AA,  // purple
    'other':        0xFF757575,  // grey
  };

  // ── Sentiment colour stops ────────────────────────────────
  // score: -1 → red, 0 → grey, +1 → green
  static const int sentimentNegativeColor  = 0xFFE53935;
  static const int sentimentNeutralColor   = 0xFF757575;
  static const int sentimentPositiveColor  = 0xFF43A047;

  // ── App strings ────────────────────────────────────────────
  static const String appName       = 'Conflict Tracker';
  static const String appTagline    = 'Real-time global event monitoring';

  // ── Tab labels ────────────────────────────────────────────
  static const List<String> tabLabels = ['Home', 'Map', 'Feed', 'Analytics'];
}