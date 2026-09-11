# Property Listing App

**NestFind** — a Flutter property listing prototype with role-based User and Property Owner experiences.

## Tech Stack

```text
Flutter
Dart
flutter_bloc
Equatable
Material 3
GoRouter
image_picker
Mock Repository
```

## Architecture

```text
UI → BLoC → Repository → Mock Data
```

## Features

- Role-based login and signup (User / Property Owner)
- User dashboard with search, filters, sorting
- Property details and interest submission
- Favorites (save/unsave properties)
- Owner dashboard with pinned TabBar
- Owner property CRUD (add / edit / delete)
- Gallery and camera image selection
- Form validation
- Logout confirmation
- Owner-scoped interests and properties

## Demo Credentials

```text
User
Email: user@test.com
Password: user123

Property Owner
Email: owner@test.com
Password: owner123
```

Additional owners: `owner2@test.com`, `owner3@test.com` (password: `owner123`).

You can also create new demo accounts via **Sign Up**.

## Image Handling

Property images are selected locally using `image_picker` (gallery or camera).
No real image server is used. Local paths may not survive app restarts; the UI falls back to placeholder/network images.

## Data Storage

This prototype uses in-memory/mock repositories.
Demo data and newly created records are stored in memory and may reset when the application restarts.

Within one session: added/edited/deleted properties, favorites, signup accounts, and interests persist.

## Run Instructions

```bash
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
```

APK location:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Tests

```bash
flutter test
flutter analyze
```
