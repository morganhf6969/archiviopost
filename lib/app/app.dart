import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes.dart';
import 'theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // =========================
  // LOAD THEME FROM SETTINGS
  // =========================
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_mode') ?? 0;

    setState(() {
      _themeMode = ThemeMode.values[index];
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Evita flash di tema errato all’avvio
    if (!_loaded) {
      return const SizedBox.shrink();
    }

    return MaterialApp(
      title: 'Archivio Post',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
