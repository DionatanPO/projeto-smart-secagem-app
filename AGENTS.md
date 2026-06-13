# Smart Secagem - Flutter Project

## Project Overview
Agricultural post-harvest monitoring and automation platform. Manages grain silos, drying processes, IoT devices, and AI-powered predictive analytics for optimal grain storage.

## Tech Stack
- **Framework:** Flutter (Web/Mobile/Desktop)
- **Language:** Dart 3.x
- **State Management & Routing:** GetX (`get`)
- **Local Storage:** GetStorage (`get_storage`)
- **HTTP Client:** Dio (`dio`)
- **Secure Storage:** flutter_secure_storage
- **Charts:** fl_chart
- **Code Generation:** freezed + json_serializable + build_runner
- **Backend:** Django REST API at `apismart.secagem-digital.com/api/`

## Architecture
Feature-first modular architecture with GetX MVC pattern:
- `lib/core/` - Shared infrastructure (theme, models, services, middlewares, values)
- `lib/modules/` - 19 feature modules, each with `bindings/`, `controllers/`, `views/`
- `lib/routes/` - GetX route definitions with AuthMiddleware protection

## Commands
- `flutter pub get` - Install dependencies
- `flutter run -d chrome` - Run on web
- `flutter run` - Run on connected device
- `dart run build_runner build --delete-conflicting-outputs` - Generate code (freezed, json_serializable)
- `flutter analyze` - Run static analysis
- `flutter test` - Run tests

## Conventions
- Use GetX for state management (GetxController, Bindings)
- Single-view modules: one view file per module named after the module
- Routes defined in `lib/routes/app_routes.dart` and `lib/routes/app_pages.dart`
- Protected routes use `AuthMiddleware` from `core/middlewares/`
- All controllers extend `GetxController`
- Use `Bindings` for dependency injection
- API calls via Dio through core services
- Dark/Light mode support via GetX theme switching
