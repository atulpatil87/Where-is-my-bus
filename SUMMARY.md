# Codebase Summary

This document provides a detailed overview of the "Where is my bus" (busindia) Flutter codebase.

## 1. Overview
The project is a robust, production-ready Flutter application built using **Clean Architecture**. It aims to provide real-time bus tracking and transport scheduling across major Indian cities, starting with integration for PMPML (Pune).

## 2. Directory Structure (`lib/`)

### 2.1. `core/`
Contains foundational code used across the application.
- **constants/**: Defines app-wide constants.
- **errors/**: Standardized error handling and exceptions.
- **network/**: Base network configurations (e.g., Dio client setup).
- **services/**: Global services like notifications and crash reporting.
- **theme/**: App styling, dark/light themes, and UI guidelines.
- **utils/**: Helper functions and extensions.

### 2.2. `domain/`
The core business logic of the app, independent of any UI or external data frameworks.
- **entities/**: The core data structures. Includes `bus.dart`, `city.dart`, `route.dart`, `stop.dart`, `timetable.dart`, and `user.dart`.
- **repositories/**: Abstract interfaces defining the contract for data operations (e.g., fetching a bus route).
- **usecases/**: Classes encapsulating specific business rules and operations (e.g., "GetNearbyStopsUseCase").

### 2.3. `data/`
The data implementation layer, responsible for fetching and caching data.
- **datasources/**: 
  - `local/`: Manages offline storage using Hive (`local_datasources.dart`), caching cities, timetables, user preferences, and saved entities.
  - `remote/`: Connects to Firebase and external REST APIs. It includes specific remote data sources for buses, cities, routes, stops, and users.
  - `remote/pmpml/`: Dedicated integrations for Pune's PMPML APIs, handling specific authentication, live tracking, routes, and schedule fetching.
- **models/**: Data Transfer Objects (DTOs) that extend/implement domain entities, typically adding JSON serialization logic.
- **repositories/**: Concrete implementations of the interfaces defined in the `domain` layer.

### 2.4. `presentation/`
The UI layer built with Flutter and Riverpod for state management.
- **providers/**: Riverpod state providers binding usecases and UI state together.
- **screens/**: The visual pages of the app. Major screens include:
  - `splash/`: Initial app loading and routing logic.
  - `home/`: The main dashboard.
  - `city_selection/`: UI for picking the current operational city.
  - `live_map/`: Interactive OSM map via `flutter_map` showing real-time bus locations.
  - `route_finder/`: A-to-B navigation and bus matching.
  - `nearby_stops/`: Geolocation-based stop discovery.
  - `timetable/`: Offline and online schedule viewing.
  - `profile/`: User settings, preferences, and saved items.
  - `pmpml_login/`: Specialized authentication flow for PMPML.
- **widgets/**: Reusable UI components (buttons, cards, dialogs, etc.).

## 3. Key Technologies & Packages
- **State Management:** `flutter_riverpod` provides a predictable and scalable way to manage state.
- **Local Storage:** `hive_flutter` is used extensively for fast, offline caching of timetables and preferences.
- **Backend:** The `firebase_*` suite is deeply integrated for authentication, remote configurations, crash analytics, and database operations.
- **Maps:** `flutter_map` is utilized for rendering OpenStreetMap data, avoiding proprietary map costs while providing a customizable mapping experience.
- **Network:** `dio` for handling HTTP requests, particularly to custom transport APIs (like PMPML).

## 4. Initialization Flow (`main.dart`)
1. **Flutter Bindings:** Ensures `WidgetsFlutterBinding` is initialized.
2. **Orientation:** Locks the app to portrait mode.
3. **Hive Setup:** Initializes Hive and opens persistent boxes (`cities_cache`, `timetables`, `user_prefs`, `saved_routes`, `saved_stops`, `cache_meta`).
4. **Firebase Setup:** Initializes Firebase services and configures Crashlytics for error reporting (non-web environments).
5. **App Launch:** Starts the Riverpod `ProviderScope` and runs the `BusIndiaApp`, which uses a `MaterialApp` pointing to `SplashScreen()`. Post-frame callbacks initialize notification services.
