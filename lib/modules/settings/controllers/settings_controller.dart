import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/values/app_colors.dart';

class SettingsController extends GetxController {
  final _storage = GetStorage();
  final _themeKey = 'theme_mode';
  final _colorKey = 'primary_color';

  // Observable for the selected theme mode index
  // 0: System, 1: Light, 2: Dark
  final selectedThemeIndex = 0.obs;

  // Getter for ThemeMode based on index
  ThemeMode get themeMode {
    switch (selectedThemeIndex.value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Observable for the primary color
  final primaryColor = Rx<Color>(AppColors.primary);

  // Preset colors for selection
  final List<Color> colorPresets = [
    const Color(0xFF518C52), // Original Green
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFEF4444), // Red
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFFEC4899), // Pink
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF1F2937), // Slate
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    // Load theme mode
    final mode = _storage.read(_themeKey) ?? 'system';
    switch (mode) {
      case 'light':
        selectedThemeIndex.value = 1;
        break;
      case 'dark':
        selectedThemeIndex.value = 2;
        break;
      default:
        selectedThemeIndex.value = 0;
    }

    // Load primary color
    final colorValue = _storage.read(_colorKey);
    if (colorValue != null) {
      primaryColor.value = Color(colorValue);
    }
  }

  void changeThemeMode(int index) {
    selectedThemeIndex.value = index;

    String storageValue;
    switch (index) {
      case 1:
        storageValue = 'light';
        break;
      case 2:
        storageValue = 'dark';
        break;
      default:
        storageValue = 'system';
    }

    _storage.write(_themeKey, storageValue);
    // The UI will react via the Obx in main.dart
  }

  void changePrimaryColor(Color color) {
    primaryColor.value = color;
    _storage.write(_colorKey, color.value);
    // The UI will react via the Obx in main.dart
  }
}
