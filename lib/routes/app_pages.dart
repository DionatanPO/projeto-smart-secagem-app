import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/landing/bindings/landing_binding.dart';
import '../modules/landing/views/about_view.dart';
import '../modules/landing/views/contact_view.dart';
import '../modules/landing/views/features_view.dart';
import '../modules/landing/views/landing_view.dart';
import '../modules/landing/views/pricing_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/support/bindings/support_binding.dart';
import '../modules/support/views/support_view.dart';
import '../modules/smart_sense_ia/bindings/smart_sense_ia_binding.dart';
import '../modules/smart_sense_ia/views/smart_sense_ia_view.dart';
import '../modules/simulation/bindings/simulation_binding.dart';
import '../modules/simulation/views/simulation_view.dart';
import '../modules/batch_management/bindings/batch_management_binding.dart';
import '../modules/batch_management/views/batch_management_view.dart';
import 'app_routes.dart';
import '../core/middlewares/auth_middleware.dart';

class AppPages {
  static const initial = Routes.landing;

  static final routes = [
    GetPage(
      name: Routes.landing,
      page: () => const LandingView(),
      binding: LandingBinding(),
    ),
    GetPage(
      name: Routes.features,
      page: () => const FeaturesView(),
      binding: LandingBinding(),
    ),
    GetPage(
      name: Routes.about,
      page: () => const AboutView(),
      binding: LandingBinding(),
    ),
    GetPage(
      name: Routes.contact,
      page: () => const ContactView(),
      binding: LandingBinding(),
    ),
    GetPage(
      name: Routes.pricing,
      page: () => const PricingView(),
      binding: LandingBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.support,
      page: () => const SupportView(),
      binding: SupportBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.smartSenseIA,
      page: () => const SmartSenseIAView(),
      binding: SmartSenseIABinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.simulation,
      page: () => const SimulationView(),
      binding: SimulationBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.batchManagement,
      page: () => const BatchManagementView(),
      binding: BatchManagementBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
