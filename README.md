# Where is my bus (busindia)

<img width="345" height="694" alt="Where is my bus" src="https://github.com/user-attachments/assets/53d2216e-3545-4d05-bfb3-a2c9f16af053" />

A unified bus tracking application designed for major Indian cities. "Where is my bus" provides real-time tracking, offline timetables, route discovery, and nearby bus stop information. Currently integrated with PMPML (Pune) and extensible to other municipal transport authorities.

## Key Features

- **Live Bus Tracking:** See real-time locations of buses on an interactive map.
- **Route Finder:** Plan your journey with A-to-B routing.
- **Timetables:** Access bus schedules offline.
- **Nearby Stops:** Find bus stops near your current location using geolocation.
- **City Selection:** Easily switch between supported cities.
- **Saved Routes & Stops:** Bookmark frequently used routes and stops for quick access.
- **PMPML Integration:** Deep integration with Pune's PMPML transport system.

## Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (SDK: >=3.4.0 <4.0.0)
- **Language:** [Dart](https://dart.dev/)
- **State Management:** [Riverpod](https://riverpod.dev/)
- **Backend & Services:** [Firebase](https://firebase.google.com/) (Auth, Firestore, Realtime Database, Storage, Messaging, Crashlytics, Analytics)
- **Local Storage:** [Hive](https://pub.dev/packages/hive_flutter)
- **Maps:** [flutter_map](https://pub.dev/packages/flutter_map) (OpenStreetMap)
- **Networking:** [Dio](https://pub.dev/packages/dio)

## Architecture

The application strictly follows **Clean Architecture** principles to separate concerns, making the app scalable, testable, and maintainable. The `lib` directory is divided into:

- **core:** App-wide constants, networking setup, error handling, themes, and utility classes.
- **domain:** Business logic including entities (Bus, City, Route, Stop, Timetable, User) and UseCases.
- **data:** Implementations of domain repositories, models, and data sources (Local via Hive, Remote via Firebase & Custom APIs like PMPML).
- **presentation:** UI layer containing Riverpod providers, screens (Home, Live Map, Profile, Route Finder, etc.), and reusable widgets.

## Setup & Run

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   ```
2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run Code Generation (if modifying models/providers):**
   ```bash
   dart run build_runner build -d
   ```
4. **Firebase Configuration:**
   Ensure you have configured Firebase correctly using `flutterfire configure`. The current project uses a `firebase_options.dart` file.
5. **Run the App:**
   ```bash
   flutter run
   ```

## License
[MIT License](LICENSE)
