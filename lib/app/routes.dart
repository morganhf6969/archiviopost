import 'package:flutter/material.dart';

import 'features/home/home_page.dart';
import 'features/settings/settings_page.dart';

class AppRoutes {
  // =========================
  // ROUTE NAMES
  // =========================
  static const String home = '/';
  static const String settings = '/settings';

  // =========================
  // ROUTES MAP
  // =========================
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    settings: (context) => const SettingsPage(),
  };
}
