import 'package:equatable/equatable.dart';

enum DayType { weekday, saturday, sunday }

class Timetable extends Equatable {
  final String routeId;
  final String cityId;
  final int version;
  final DateTime lastUpdated;
  final Map<DayType, List<TimetableStop>> schedule;

  const Timetable({
    required this.routeId,
    required this.cityId,
    required this.version,
    required this.lastUpdated,
    required this.schedule,
  });

  List<TimetableStop> stopsFor(DayType day) => schedule[day] ?? [];

  @override
  List<Object?> get props => [routeId, cityId, version];
}

class TimetableStop extends Equatable {
  final String stopId;
  final String stopName;
  final int sequence;
  final List<String> scheduledTimes; // ["05:30", "05:42", ...]
  final int fareFromStart;
  final bool isMajorStop;

  const TimetableStop({
    required this.stopId,
    required this.stopName,
    required this.sequence,
    required this.scheduledTimes,
    required this.fareFromStart,
    required this.isMajorStop,
  });

  @override
  List<Object?> get props => [stopId, sequence];
}
