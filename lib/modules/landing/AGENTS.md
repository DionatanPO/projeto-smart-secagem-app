# Module: Landing

## Purpose
Public landing page with feature portfolio, pricing, about, contact, and institutional information. Serves as the app entry point for unauthenticated users.

## Structure
- `bindings/` - GetX dependency injection
- `controllers/` - LandingController extends GetxController
- `views/` - Multiple public UI screens
- `widgets/` - Reusable landing UI components

## Key Files
- `views/landing_view.dart` - Main landing page
- `views/pricing_view.dart` - Pricing plans
- `views/features_view.dart` - Features showcase
- `views/contact_view.dart` - Contact form
- `views/about_view.dart` - About page
- `controllers/landing_controller.dart` - Main controller

## Routes (public)
- `/landing` (initial)
- `/features`
- `/about`
- `/contact`
- `/pricing`
