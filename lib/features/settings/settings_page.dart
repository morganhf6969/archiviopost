import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/backup/backup_service.dart';
import '../../theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoBackup = false;
  String _lastBackup = 'Mai';

  @override
  void initState() {
    super.initState();
    _loadBackupSettings();
  }

  // =========================
  // LOAD BACKUP SETTINGS
  // =========================
  Future<void> _loadBackupSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _autoBackup = prefs.getBool('auto_backup') ?? false;
      _lastBackup = prefs.getString('last_backup') ?? 'Mai';
    });
  }

  // =========================
  // AUTO BACKUP
  // =========================
  Future<void> _setAutoBackup(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_backup', value);

    setState(() {
      _autoBackup = value;
    });
  }

  // =========================
  // BACKUP NOW
  // =========================
  Future<void> _backupNow() async {
    try {
      final File file = await BackupService.exportJson();

      final now = DateTime.now();
      final formatted =
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/'
          '${now.year} '
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_backup', formatted);

      setState(() {
        _lastBackup = formatted;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Backup completato\n${file.path}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore durante il backup'),
          ),
        );
      }
    }
  }

  // =========================
  // IMPORT JSON
  // =========================
  Future<void> _importJson() async {
    try {
      final int imported = await BackupService.importJson();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              imported > 0
                  ? 'Importati $imported elementi'
                  : 'Nessun elemento importato',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore durante l’importazione'),
          ),
        );
      }
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        children: [
          const _SectionHeader('Tema'),

          RadioListTile<ThemeMode>(
            title: const Text('Automatico'),
            value: ThemeMode.system,
            groupValue: themeController.themeMode,
            onChanged: (v) => themeController.setTheme(v!),
          ),

          RadioListTile<ThemeMode>(
            title: const Text('Chiaro'),
            value: ThemeMode.light,
            groupValue: themeController.themeMode,
            onChanged: (v) => themeController.setTheme(v!),
          ),

          RadioListTile<ThemeMode>(
            title: const Text('Scuro'),
            value: ThemeMode.dark,
            groupValue: themeController.themeMode,
            onChanged: (v) => themeController.setTheme(v!),
          ),

          const Divider(),

          const _SectionHeader('Backup'),

          SwitchListTile(
            title: const Text('Backup automatico'),
            subtitle: const Text('Salva i link nel cloud'),
            value: _autoBackup,
            onChanged: _setAutoBackup,
          ),

          const ListTile(
            leading: Icon(Icons.cloud),
            title: Text('Provider'),
            subtitle: Text('Google Drive / iCloud'),
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Ultimo backup'),
            subtitle: Text(_lastBackup),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.backup),
              label: const Text('Backup ora'),
              onPressed: _backupNow,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Importa da file JSON'),
              onPressed: _importJson,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
