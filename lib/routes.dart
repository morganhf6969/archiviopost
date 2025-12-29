import 'package:flutter/material.dart';

import 'features/home/home_page.dart';
import 'features/settings/settings_page.dart';

class AppRoutes {
  static const home = '/';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    home: (_) => const HomePage(),
    settings: (_) => const SettingsPage(),
  };
}
