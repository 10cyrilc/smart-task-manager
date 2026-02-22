# Smart Task Manager

A feature-rich task management app built with **Flutter**, following **Clean Architecture** principles. It integrates **Firebase** for authentication and user profiles, a **REST API** for task management, and an **offline-first** strategy using **Hive** for local caching.

## Features

### 🔐 Authentication (Firebase)
- Email & Password login / registration
- Persistent login sessions
- Form validation with user-friendly error messages
- Auto-fetch user profile from Firestore on login

### 👤 User Profile (Firestore)
- Profile stored in Firestore under `users/{userId}`
- Fields: `name`, `email`, `createdAt`, `themeMode`
- Dark / Light mode toggle synced to Firestore
- Update profile support

### ✅ Task Management (REST API)
- Full CRUD — create, read, update, delete tasks
- Infinite scroll pagination (`skip` & `limit`)
- Pull-to-refresh
- Client-side filtering: **All / Completed / Pending**
- Search tasks by title
- Sort by **Due Date**, **Priority**, or **Created Date**
- Task fields: `priority`, `category`, `due_date`, `is_completed`
- Optimistic UI updates

### 📶 Offline-First Strategy
- Tasks cached locally with **Hive**
- Loads from cache when offline
- Syncs with the server when connectivity is restored
- Offline banner displayed to the user

### 🛡️ Error Handling
- Typed exception model: `AppException`, `NetworkException`, `ServerException`, `CacheException`, `AuthException`
- UI reacts based on error type with appropriate feedback

## Architecture

The project follows **Clean Architecture** with a feature-based folder structure:

```
lib/
├── core/
│   ├── errors/          # Exception & failure classes
│   ├── network/         # Dio client, interceptors, connectivity
│   ├── utils/           # Helpers & extensions
│   ├── constants/       # App-wide constants
│   └── theme/           # Material 3 theme (light & dark)
│
├── features/
│   ├── auth/            # Authentication feature
│   │   ├── data/        # Data sources, models, repository impl
│   │   ├── domain/      # Entities, repository contracts, use cases
│   │   └── presentation/# Screens, providers, widgets
│   ├── profile/         # User profile feature
│   └── tasks/           # Task management feature
│
├── shared/
│   ├── widgets/         # Reusable UI components
│   └── providers/       # Shared Riverpod providers
│
└── main.dart
```

## Tech Stack

| Category            | Technology                       |
|---------------------|----------------------------------|
| Framework           | Flutter (Dart SDK ^3.9.0)        |
| State Management    | Riverpod (flutter_riverpod)      |
| Routing             | GoRouter                         |
| Authentication      | Firebase Auth                    |
| Database (Cloud)    | Cloud Firestore                  |
| Local Storage       | Hive                             |
| HTTP Client         | Dio                              |
| Connectivity        | connectivity_plus                |
| Code Generation     | riverpod_generator, build_runner |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.9.0)
- A Firebase project configured for Android/iOS
- An active internet connection for first run

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/10cyrilc/smart-task-manager.git
   cd smart-task-manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation** (for Riverpod generators)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Setup environment variables**
   ```bash
   cp .example-env.json .env.json
   ```
   Edit the `.env.json` file with your API base URL.

5. **Run the app**
   ```bash
   flutter run --dart-define-from-file=.env.json
   ```

### Building a Release APK

```bash
flutter build apk --release --dart-define-from-file=.env.json
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`.

## UI

- **Material 3** design system
- Dark & Light mode support
- Animated splash screen & page transitions
- Empty state illustrations
- Responsive, clean UX with no overflow
