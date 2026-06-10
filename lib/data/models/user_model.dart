import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

class UserPreferencesModel extends Equatable {
  final String language;
  final bool darkMode;
  final bool notifications;
  final bool shareLocation;

  const UserPreferencesModel({
    this.language = 'en',
    this.darkMode = false,
    this.notifications = true,
    this.shareLocation = false,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      UserPreferencesModel(
        language: json['language'] as String? ?? 'en',
        darkMode: json['darkMode'] as bool? ?? false,
        notifications: json['notifications'] as bool? ?? true,
        shareLocation: json['shareLocation'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'language': language,
        'darkMode': darkMode,
        'notifications': notifications,
        'shareLocation': shareLocation,
      };

  UserPreferences toEntity() => UserPreferences(
        language: language,
        darkMode: darkMode,
        notifications: notifications,
        shareLocation: shareLocation,
      );

  @override
  List<Object?> get props => [language, darkMode, notifications, shareLocation];
}

class UserStatsModel extends Equatable {
  final int totalTrips;
  final int crowdReports;
  final int locationShares;
  final int points;
  final int rank;

  const UserStatsModel({
    this.totalTrips = 0,
    this.crowdReports = 0,
    this.locationShares = 0,
    this.points = 0,
    this.rank = 0,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      UserStatsModel(
        totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
        crowdReports: (json['crowdReports'] as num?)?.toInt() ?? 0,
        locationShares: (json['locationShares'] as num?)?.toInt() ?? 0,
        points: (json['points'] as num?)?.toInt() ?? 0,
        rank: (json['rank'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'totalTrips': totalTrips,
        'crowdReports': crowdReports,
        'locationShares': locationShares,
        'points': points,
        'rank': rank,
      };

  UserStats toEntity() => UserStats(
        totalTrips: totalTrips,
        crowdReports: crowdReports,
        locationShares: locationShares,
        points: points,
        rank: rank,
      );

  @override
  List<Object?> get props => [points, rank];
}

class UserModel extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String authProvider;
  final List<String> selectedCities;
  final String primaryCity;
  final List<String> savedRoutes;
  final List<String> savedStops;
  final UserPreferencesModel preferences;
  final UserStatsModel stats;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'User',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        authProvider: json['authProvider'] as String? ?? 'guest',
        selectedCities:
            List<String>.from(json['selectedCities'] as List? ?? ['pune']),
        primaryCity: json['primaryCity'] as String? ?? 'pune',
        savedRoutes: List<String>.from(json['savedRoutes'] as List? ?? []),
        savedStops: List<String>.from(json['savedStops'] as List? ?? []),
        preferences: UserPreferencesModel.fromJson(
          (json['preferences'] as Map<String, dynamic>?) ?? {},
        ),
        stats: UserStatsModel.fromJson(
          (json['stats'] as Map<String, dynamic>?) ?? {},
        ),
        badges: List<String>.from(json['badges'] as List? ?? []),
        createdAt: (json['createdAt'] is Timestamp)
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        lastActiveAt: (json['lastActiveAt'] is Timestamp)
            ? (json['lastActiveAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'authProvider': authProvider,
        'selectedCities': selectedCities,
        'primaryCity': primaryCity,
        'savedRoutes': savedRoutes,
        'savedStops': savedStops,
        'preferences': preferences.toJson(),
        'stats': stats.toJson(),
        'badges': badges,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      };

  UserModel copyWith({
    String? name,
    String? avatarUrl,
    List<String>? savedRoutes,
    List<String>? savedStops,
    UserPreferencesModel? preferences,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProvider: authProvider,
      selectedCities: selectedCities,
      primaryCity: primaryCity,
      savedRoutes: savedRoutes ?? this.savedRoutes,
      savedStops: savedStops ?? this.savedStops,
      preferences: preferences ?? this.preferences,
      stats: stats,
      badges: badges,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
    );
  }

  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        authProvider: authProvider,
        selectedCities: selectedCities,
        primaryCity: primaryCity,
        savedRoutes: savedRoutes,
        savedStops: savedStops,
        preferences: preferences.toEntity(),
        stats: stats.toEntity(),
        badges: badges,
        createdAt: createdAt,
        lastActiveAt: lastActiveAt,
      );

  @override
  List<Object?> get props => [id];
}
