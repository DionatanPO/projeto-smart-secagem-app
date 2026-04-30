import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'routes/app_pages.dart';
import 'modules/settings/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize Services
  Get.put(ApiService());
  await Get.putAsync(() => AuthService().init());

  // Initialize the controller at the top level
  final settingsController = Get.put(SettingsController());

  runApp(
    Obx(() => GetMaterialApp(
          title: "Smart Secagem",
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(settingsController.primaryColor.value),
          darkTheme: AppTheme.dark(settingsController.primaryColor.value),
          themeMode: settingsController.themeMode,
          builder: (context, child) {
            return MediaQuery.withClampedTextScaling(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
              child: child!,
            );
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
          ],
        )),
  );
}
