# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app in debug mode
flutter run

# Run on a specific device
flutter devices                # list available devices
flutter run -d <device_id>

# Static analysis
flutter analyze

# Run tests
flutter test                   # all tests
flutter test test/some_test.dart  # single test file

# Build
flutter build apk              # Android
flutter build ios              # iOS
flutter build web              # Web

# Dependencies
flutter pub get
flutter pub outdated
flutter pub upgrade --major-versions

# Code generation (if/when build_runner is added)
flutter pub run build_runner build
```

## Architecture

This is a Flutter dual-role marketplace app (hire workers / work as a helper) built with **GetX** for state management, dependency injection, routing, and i18n.

### Project structure

```
lib/
├── main.dart                          # App entry point, GetMaterialApp config
└── app/
    ├── core/                          # Shared app-wide concerns
    │   ├── constants/                 # AppColors, AppStrings (i18n keys), AppImages
    │   ├── theme/                     # AppTheme (light theme with Poppins font)
    │   └── widgets/                   # Reusable widgets (custom_button, custom_text_field, bottom_nav_bar, etc.)
    ├── data/                          # Models, mock data, API endpoint constants
    ├── modules/                       # Feature modules organized by domain
    │   ├── auth/                      # login, sign_up, otp_verification, password_reset
    │   ├── splash/                    # Initial screen with role-based routing
    │   ├── onboarding/               # Onboarding flow
    │   ├── role_selection/           # "I need help" vs "I want to work"
    │   ├── service_selection/        # Service category picker
    │   ├── main/                     # Post-role-selection shell; switches between dashboards
    │   ├── i_need_help/              # Client-side features (home, dashboard, create_task, helper_list, order, payment, profile, request, custom_offer)
    │   ├── i_want_to_work/           # Worker-side features (home, dashboard, my_job, profile, saved_tasks)
    │   ├── message/                  # Chat/messaging
    │   ├── notification/             # Notifications
    │   ├── common/                   # Shared screens (about, payout)
    │   └── provider_verification/    # Provider identity verification
    ├── routes/                        # Centralized GetX route definitions (app_pages.dart + app_routes.dart)
    └── services/                      # App-wide services (AuthService extends GetxService)
```

### GetX module pattern

Each feature module follows a consistent structure:

```
modules/<feature>/
├── bindings/        # GetX bindings — declares dependencies (lazyPut/create)
├── controllers/     # GetX controllers — UI logic, state with .obs
├── providers/       # Optional — API/data layer (http calls)
├── views/           # Flutter widgets (GetView<Controller> pattern)
└── widgets/         # Optional — feature-specific sub-widgets
```

Bindings must be registered in `app_pages.dart` for routes that need dependency injection. Routes are defined in two files: `app_pages.dart` (GetPage list) and `app_routes.dart` (static path/name constants). The `_Paths` class holds raw URIs; `Routes` exposes them as constants.

### Dual-role routing

After role selection, `MainView` (at `/main`) uses `IndexedStack` to toggle between `DashboardView` (client) and `WorkerDashboardView` (worker), driven by `MainController.activePhase`. Individual feature routes (create task, worker home, etc.) exist as separate named routes.

### State & storage

- **GetX reactive state**: Controllers use `.obs` for reactive variables; views use `Obx()` to rebuild.
- **GetStorage**: Simple key-value persistence (user role, language preference). Initialized in `main()` before `runApp`.
- **FlutterSecureStorage**: Sensitive tokens (access/refresh tokens) managed by `AuthService`.
- **API base URL**: `https://samimdev.pythonanywhere.com/api/v1` (defined in `ApiEndpoints`).

### Internationalization

`AppStrings` extends `GetX Translations`. All user-facing strings are referenced by static const keys (not string literals in widgets). Two locales: `en_US` and `zh_CN`. Language is read from GetStorage on startup and persisted.

### Theming

Single light theme in `AppTheme.lightTheme`. Uses Poppins font via `google_fonts`. Colors centralized in `AppColors` (primary green `#6DA54B`). Responsive breakpoints (mobile/tablet/desktop/4K) via `responsive_framework`.
