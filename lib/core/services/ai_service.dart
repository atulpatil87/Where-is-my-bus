/// AI Service using Firebase Vertex AI (Gemini) for smart features.
/// All methods return structured responses for the UI layer.
class AIService {
  // NOTE: Replace with actual firebase_vertexai integration.
  // import 'package:firebase_vertexai/firebase_vertexai.dart';
  // final _model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');

  /// Parses a natural-language trip query into structured fields.
  Future<TripPlanResponse> parseTripQuery(String query) async {
    // TODO: Wire to actual Gemini SDK.
    // Prompt: "Extract travel intent from: '{query}' → JSON"
    return TripPlanResponse(
      fromLocation: 'Swargate',
      toLocation: 'Hinjewadi Phase 1',
      travelTime: null,
      preferences: [],
    );
  }

  /// Predicts ETA in minutes using historical patterns.
  Future<int> predictETA({
    required String routeId,
    required String stopId,
    required DateTime currentTime,
    required int crowdLevel,
  }) async {
    // Baseline: consider hour + crowdLevel as simple multiplier.
    const baseDelay = 0;
    final peak = _isPeakHour(currentTime.hour) ? 5 : 0;
    final crowdDelay = (crowdLevel - 1) * 2;
    return baseDelay + peak + crowdDelay;
  }

  /// Returns best / worst travel times for a route.
  Future<TravelSuggestion> getBestTravelTime({
    required String routeId,
    required String fromStopId,
    required String toStopId,
  }) async {
    // Placeholder — replace with Gemini call using historical crowd data.
    return TravelSuggestion(
      bestTime: '7:00 AM – 8:00 AM',
      worstTime: '9:30 AM – 11:00 AM',
      reason: 'Based on historical patterns, avoid peak office hours.',
      hourlyCrowdScore: List.generate(24, (h) => _typicalCrowd(h)),
    );
  }

  /// Returns a one-sentence contextual AI tip for the Route Finder screen.
  Future<String> getRouteTip({
    required String routeNumber,
    required String dayOfWeek,
    required int hour,
  }) async {
    final tips = {
      'Friday': 'Route $routeNumber is 20% more crowded on Fridays. '
          'Leave before 8:30 AM for a comfortable ride.',
      'Monday': 'Monday mornings on Route $routeNumber fill up after 9 AM. '
          'Board early for a seat.',
    };
    return tips[dayOfWeek] ??
        'Route $routeNumber runs on schedule today. '
            'Expect moderate crowd during peak hours.';
  }

  bool _isPeakHour(int hour) =>
      (hour >= 8 && hour <= 10) || (hour >= 17 && hour <= 19);

  int _typicalCrowd(int hour) {
    if (hour >= 8 && hour <= 10) return 4;
    if (hour >= 17 && hour <= 20) return 4;
    if (hour >= 11 && hour <= 16) return 2;
    if (hour >= 6 && hour <= 7) return 3;
    return 1;
  }
}

class TripPlanResponse {
  final String fromLocation;
  final String toLocation;
  final String? travelTime;
  final List<String> preferences;

  const TripPlanResponse({
    required this.fromLocation,
    required this.toLocation,
    this.travelTime,
    required this.preferences,
  });
}

class TravelSuggestion {
  final String bestTime;
  final String worstTime;
  final String reason;
  final List<int> hourlyCrowdScore; // index 0–23

  const TravelSuggestion({
    required this.bestTime,
    required this.worstTime,
    required this.reason,
    required this.hourlyCrowdScore,
  });
}
