import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'routes.dart';
import 'theme_controller.dart';
import 'features/categorize/categorize_page.dart';

class MyApp extends StatelessWidget {
  final String? initialSharedLink;

  const MyApp({
    super.key,
    this.initialSharedLink,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'MemoLink',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            initialRoute: AppRoutes.home,
            routes: AppRoutes.routes,
            builder: (context, child) {
              if (initialSharedLink != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategorizePage(
                        link: initialSharedLink,
                      ),
                    ),
                  );
                });
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}
