import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String authProvider; // "google" | "phone" | "guest"
  final List<String> selectedCities;
  final String primaryCity;
  final List<String> savedRoutes;
  final List<String> savedStops;
  final UserPreferences preferences;
  final UserStats stats;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const User({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.authProvider,
    required this.selectedCities,
    required this.primaryCity,
    required this.savedRoutes,
    required this.savedStops,
    required this.preferences,
    required this.stats,
    required this.badges,
    required this.createdAt,
    required this.lastActiveAt,
  });

  bool get isGuest => authProvider == 'guest';

  @override
  List<Object?> get props => [id];
}

class UserPreferences extends Equatable {
  final String language;
  final bool darkMode;
  final bool notifications;
  final bool shareLocation;

  const UserPreferences({
    this.language = 'en',
    this.darkMode = false,
    this.notifications = true,
    this.shareLocation = false,
  });

  UserPreferences copyWith({
    String? language,
    bool? darkMode,
    bool? notifications,
    bool? shareLocation,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      shareLocation: shareLocation ?? this.shareLocation,
    );
  }

  @override
  List<Object?> get props => [language, darkMode, notifications, shareLocation];
}

class UserStats extends Equatable {
  final int totalTrips;
  final int crowdReports;
  final int locationShares;
  final int points;
  final int rank;

  const UserStats({
    this.totalTrips = 0,
    this.crowdReports = 0,
    this.locationShares = 0,
    this.points = 0,
    this.rank = 0,
  });

  static const empty = UserStats();

  @override
  List<Object?> get props => [totalTrips, points, rank];
}

class CrowdReport extends Equatable {
  final String? id;
  final String busId;
  final String routeId;
  final String cityId;
  final String userId;
  final int crowdLevel; // 1-4
  final String crowdLabel;
  final double lat;
  final double lng;
  final DateTime reportedAt;
  final DateTime expiresAt;

  const CrowdReport({
    this.id,
    required this.busId,
    required this.routeId,
    required this.cityId,
    required this.userId,
    required this.crowdLevel,
    required this.crowdLabel,
    required this.lat,
    required this.lng,
    required this.reportedAt,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [busId, userId, reportedAt];
}

class Trip extends Equatable {
  final String? id;
  final String userId;
  final String routeId;
  final String routeNumber;
  final String cityId;
  final String fromStopId;
  final String toStopId;
  final String fromStopName;
  final String toStopName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? farePaid;
  final String status; // "active" | "completed" | "cancelled"

  const Trip({
    this.id,
    required this.userId,
    required this.routeId,
    required this.routeNumber,
    required this.cityId,
    required this.fromStopId,
    required this.toStopId,
    required this.fromStopName,
    required this.toStopName,
    required this.startedAt,
    this.endedAt,
    this.farePaid,
    this.status = 'active',
  });

  @override
  List<Object?> get props => [id, userId, startedAt];
}
