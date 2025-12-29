import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'core/services/share_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Database desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inizializza servizio share
  await ShareService.init();

  // Recupera eventuale link condiviso all'avvio
  final String? sharedLink = await ShareService.getInitialSharedText();

  runApp(
    MyApp(
      initialSharedLink: sharedLink,
    ),
  );
}
