# Smart Fujairah

A Flutter-based government services app for **Fujairah Municipality**, UAE. Built as a workshop project demonstrating a modern, production-style Flutter application with AI integration, interactive maps, and multi-platform support.

> **Live Demo:** [smart-fujairah-complete.pages.dev](https://smart-fujairah-complete.pages.dev)

![Fujairah Digital Government](web/og-image.png)

## Features

- **Government Services Catalog** — Browse categorized municipality services (building permits, land registration, health inspections, etc.) with detailed requirements, fees, and documents
- **Service Requests** — Submit and track service requests with status filtering (pending, under review, approved, rejected) and progress visualization
- **Interactive Land Map** — OpenStreetMap-based map with color-coded plot polygons (residential, commercial, industrial, government) and tap-to-inspect details
- **AI Assistant (Cloudflare Workers AI)** — Chat interface powered by Cloudflare Workers AI (Llama 3 / Qwen) for answering municipality-related questions in English and Arabic
- **AI Assistant (Firebase AI)** — Alternative chat screen using Google's Gemini via Firebase AI
- **Authentication** — Login/register with Emirates ID, token persistence, and route guards
- **Bilingual Support** — Full Arabic and English localization via `easy_localization`
- **Dark Mode** — System-aware theming with manual toggle
- **Push Notifications** — Firebase Cloud Messaging integration
- **Search** — Search across all available services

## Tech Stack

| Layer            | Technology                                 |
| ---------------- | ------------------------------------------ |
| Framework        | Flutter 3.11+ (Web, Android)               |
| State Management | Riverpod                                   |
| Navigation       | GoRouter (StatefulShellRoute)              |
| Networking       | Dio                                        |
| AI Chat          | `cloudflare_ai` (Cloudflare Workers AI)    |
| AI Chat (alt)    | `firebase_ai` (Gemini via Firebase)        |
| Maps             | `flutter_map` + `latlong2` (OpenStreetMap) |
| Localization     | `easy_localization` (EN/AR)                |
| Auth/Push        | Firebase Core, Messaging, Crashlytics      |
| Deployment       | Cloudflare Pages (via `peanut`)            |

## Project Structure

```text
lib/
├── main.dart                    # App entry point, Firebase & dotenv init
├── app.dart                     # MaterialApp setup, theming, localization
├── firebase_options.dart        # FlutterFire generated config
├── core/
│   ├── constants/
│   │   └── api_constants.dart   # API endpoint paths
│   ├── router/
│   │   └── app_router.dart      # GoRouter config with auth guards
│   └── theme/
│       └── app_theme.dart       # Light/dark Material 3 themes
├── models/
│   ├── announcement.dart        # News/announcement model
│   ├── category.dart            # Service category model
│   ├── service.dart             # Individual service model
│   ├── service_request.dart     # User's service request model
│   ├── plot.dart                # Land plot with GeoJSON polygon
│   └── user.dart                # User/auth model
├── providers/
│   ├── auth_provider.dart       # Authentication state
│   ├── categories_provider.dart # Service categories
│   ├── services_provider.dart   # Services list
│   ├── requests_provider.dart   # User's requests
│   ├── plots_provider.dart      # Land map plots
│   ├── search_provider.dart     # Search functionality
│   └── settings_provider.dart   # App settings (theme, locale)
├── screens/
│   ├── home_screen.dart         # Dashboard with announcements, categories, map card
│   ├── login_screen.dart        # Emirates ID login (demo credentials pre-filled)
│   ├── register_screen.dart     # User registration
│   ├── shell_screen.dart        # Bottom navigation shell (5 tabs)
│   ├── search_screen.dart       # Service search
│   ├── my_requests_screen.dart  # Requests with status tabs and progress tracking
│   ├── map_screen.dart          # Interactive land map with plot polygons
│   ├── cloudflare_ai_screen.dart # AI chat via Cloudflare Workers AI
│   ├── ai_assistant_screen.dart # AI chat via Firebase/Gemini
│   ├── settings_screen.dart     # Theme, language, logout
│   ├── category_services_screen.dart
│   ├── service_detail_screen.dart
│   └── service_request_screen.dart
├── services/
│   ├── api_service.dart         # Dio HTTP client with interceptors
│   └── cache_service.dart       # Local caching via SharedPreferences
├── widgets/
│   ├── message_bubble.dart      # Chat message bubble (user/AI)
│   ├── typing_indicator.dart    # Animated typing dots
│   ├── announcement_card.dart   # News card widget
│   ├── category_card.dart       # Category grid item
│   ├── service_tile.dart        # Service list item
│   ├── shimmer_loading.dart     # Loading skeleton animation
│   └── file_upload_widget.dart  # Document upload picker
└── exceptions/
    └── api_exception.dart       # Custom API error handling
```

## Getting Started

### Prerequisites

- Flutter SDK 3.11+
- Dart SDK 3.0+
- A Cloudflare account (for Workers AI)
- A Firebase project (for push notifications and Gemini AI)

### Setup

1. **Clone and install dependencies:**

   ```bash
   git clone <repo-url>
   cd smart_fujairah_complete
   flutter pub get
   ```

2. **Configure environment variables:**

   Create a `.env` file in the project root:

   ```env
   CLOUDFLARE_ACCOUNT_ID=your_account_id
   CLOUDFLARE_API_KEY=your_api_key
   ```

3. **Configure Firebase:**

   ```bash
   flutterfire configure --project=your-firebase-project
   ```

4. **Run the app:**

   ```bash
   # Web
   flutter run -d chrome

   # Android
   flutter run -d android
   ```

### Demo Credentials

The login screen is pre-filled with demo credentials:
- **Emirates ID:** `784-1990-1234567-1`
- **Password:** any value

## Deployment

The web build is deployed to Cloudflare Pages using the `peanut` package:

```bash
# Build and commit to gh-pages branch
dart pub global run peanut

# Deploy to Cloudflare Pages
npx wrangler pages deploy build/web --project-name=smart-fujairah-complete
```

## Architecture Overview

The app follows a clean, layered architecture:

- **Screens** consume **Providers** (Riverpod) which call **Services** (Dio) that hit the backend API
- **GoRouter** handles navigation with `StatefulShellRoute` for the bottom tab bar and auth redirect guards
- **Models** parse JSON from the API and expose localized getters (Arabic/English)
- **Widgets** are small, reusable UI components shared across screens

## License

This project is a workshop demonstration. Built for the Flutter Dubai Workshop 2026.
