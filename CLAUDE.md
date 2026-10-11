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
    │   ├── animations/                # AppDurations, AppCurves, FadeSlideIn, PressableScale
    │   ├── constants/                 # AppColors, AppStrings (i18n keys), AppImages, AppIcons
    │   ├── theme/                     # AppTheme (light theme with Poppins font)
    │   └── widgets/                   # Reusable widgets (custom_button, state views, shimmer primitives + shared skeletons)
    ├── data/                          # Models, repositories, json parsers (one model class per file)
    ├── features/                      # Feature modules organized by domain
    │   ├── auth/ splash/ onboarding/ role_selection/ service_selection/
    │   ├── shell/                     # Post-role-selection shell; switches between dashboards
    │   ├── client/                    # "I need help": home, dashboard, helper_list, helper_profile, custom_offer, order, payment, profile, support, vouchers, saved_helpers
    │   ├── worker/                    # "I want to work": home, dashboard, my_job, profile, helper_profile, account_verification, support, report
    │   ├── chat/                      # Chat list + chat room (controllers, mappers, models, utils)
    │   ├── notification/ about/ payout/
    ├── routes/                        # Centralized GetX route definitions (app_pages.dart + app_routes.dart)
    └── service/                       # ApiClient, WebSocketService (ReconnectingSocket), event bus, storage helpers
```

### Feature module pattern (MVVM)

```
features/<area>/<feature>/
├── bindings/        # GetX bindings — declares dependencies (lazyPut/create)
├── controllers/     # ViewModels — GetX controllers, state with .obs
├── models/          # Optional — feature-only models
├── utils/           # Optional — pure helpers (formatters, mappers)
└── views/
    └── <page>/
        ├── <page>_view.dart     # The page; composes widgets only
        └── widgets/             # One widget per file, used only by this page
            ├── shimmer/         # Page-specific loading skeleton mirroring the real layout
            ├── sheets/ dialogs/ # `show...()` functions for bottom sheets/dialogs
            └── <widget>/        # Sub-widgets of a large widget file
```

- Keep one public class per file. Data repositories and API calls live in `data/`.
- Loading lists show the page's shimmer skeleton (`ShimmerList` + a skeleton widget). Buttons never shimmer; `CustomButton(isLoading: true)` shows "Please wait...".

Bindings must be registered in `app_pages.dart` for routes that need dependency injection. Routes are defined in two files: `app_pages.dart` (GetPage list) and `app_routes.dart` (static path/name constants). The `_Paths` class holds raw URIs; `Routes` exposes them as constants.

### Dual-role routing

After role selection, `MainView` (at `/main`) uses `IndexedStack` to toggle between `DashboardView` (client) and `WorkerDashboardView` (worker), driven by `MainController.activePhase`. Individual feature routes (create task, worker home, etc.) exist as separate named routes.

### State & storage

- **GetX reactive state**: Controllers use `.obs` for reactive variables; views use `Obx()` to rebuild.
- **GetStorage**: Simple key-value persistence (user role, language preference). Initialized in `main()` before `runApp`.
- **FlutterSecureStorage**: Sensitive tokens (access/refresh tokens) managed by `SharedPrefsHelper` (`service/shared_prefs_helper.dart`).
- **API base URL**: `https://samimdev.pythonanywhere.com/api/v1` (defined in `ApiEndpoints`).

### Internationalization

`AppStrings` extends `GetX Translations`. All user-facing strings are referenced by static const keys (not string literals in widgets). Two locales: `en_US` and `zh_CN`. Language is read from GetStorage on startup and persisted.

### Theming

Single light theme in `AppTheme.lightTheme`. Uses Poppins font via `google_fonts`. Colors centralized in `AppColors` (primary green `#6DA54B`). Responsive breakpoints (mobile/tablet/desktop/4K) via `responsive_framework`.
