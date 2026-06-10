import 'package:equatable/equatable.dart';

/// A step in a journey (walk or bus segment).
class PmpmlJourneyStep extends Equatable {
  final String type; // 'walk' | 'bus'
  final String? routeNumber;
  final String? fromStop;
  final String? toStop;
  final int durationMins;
  final int distanceMeters;
  final String? instruction;

  const PmpmlJourneyStep({
    required this.type,
    this.routeNumber,
    this.fromStop,
    this.toStop,
    required this.durationMins,
    required this.distanceMeters,
    this.instruction,
  });

  factory PmpmlJourneyStep.fromJson(Map<String, dynamic> json) =>
      PmpmlJourneyStep(
        type: (json['type'] ?? json['mode'] ?? 'bus').toString().toLowerCase(),
        routeNumber: json['route_number'] as String? ?? json['route'] as String?,
        fromStop: json['from_stop'] as String? ?? json['from'] as String?,
        toStop: json['to_stop'] as String? ?? json['to'] as String?,
        durationMins: (json['duration_mins'] ?? json['duration'] ?? 0) is num
            ? (json['duration_mins'] ?? json['duration'] ?? 0).toInt()
            : 0,
        distanceMeters:
            (json['distance_meters'] ?? json['distance'] ?? 0) is num
                ? (json['distance_meters'] ?? json['distance'] ?? 0).toInt()
                : 0,
        instruction: json['instruction'] as String?,
      );

  bool get isBus => type == 'bus';
  bool get isWalk => type == 'walk';

  @override
  List<Object?> get props => [type, routeNumber, fromStop, toStop];
}

/// Full direction result from /v2/get_directions_bus.
class PmpmlDirectionModel extends Equatable {
  final int totalDurationMins;
  final int totalDistanceMeters;
  final int totalFare;
  final int walkingMins;
  final List<PmpmlJourneyStep> steps;
  final List<String> routeNumbers; // convenience — all bus routes used

  const PmpmlDirectionModel({
    required this.totalDurationMins,
    required this.totalDistanceMeters,
    required this.totalFare,
    required this.walkingMins,
    required this.steps,
    required this.routeNumbers,
  });

  factory PmpmlDirectionModel.fromJson(Map<String, dynamic> json) {
    final rawSteps =
        (json['steps'] ?? json['legs'] ?? json['journey'] ?? []) as List;
    final steps = rawSteps
        .whereType<Map<String, dynamic>>()
        .map(PmpmlJourneyStep.fromJson)
        .toList();

    final routeNumbers = steps
        .where((s) => s.isBus && s.routeNumber != null)
        .map((s) => s.routeNumber!)
        .toList();

    return PmpmlDirectionModel(
      totalDurationMins:
          (json['total_duration_mins'] ?? json['duration'] ?? 0) is num
              ? (json['total_duration_mins'] ?? json['duration'] ?? 0).toInt()
              : 0,
      totalDistanceMeters:
          (json['total_distance_meters'] ?? json['distance'] ?? 0) is num
              ? (json['total_distance_meters'] ?? json['distance'] ?? 0).toInt()
              : 0,
      totalFare: (json['fare'] ?? json['total_fare'] ?? 0) is num
          ? (json['fare'] ?? json['total_fare'] ?? 0).toInt()
          : 0,
      walkingMins: (json['walking_mins'] ?? json['walk_time'] ?? 0) is num
          ? (json['walking_mins'] ?? json['walk_time'] ?? 0).toInt()
          : 0,
      steps: steps,
      routeNumbers: routeNumbers,
    );
  }

  bool get isDirect =>
      steps.where((s) => s.isBus).length == 1;

  @override
  List<Object?> get props => [totalDurationMins, totalFare, routeNumbers];
}
