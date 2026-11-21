// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A (settings app). Wave 0 placeholder: setup steps, privacy
// proof and a test field. Keep MynaSettingsApp's constructor stable.
// main() wraps it in AppScope, so `AppScope.of(context)` works everywhere.
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../bridge/messages.g.dart';
import 'privacy/privacy_center_screen.dart';
import 'themes/theme_gallery_screen.dart';

class MynaSettingsApp extends StatelessWidget {
  const MynaSettingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6750A4);
    return MaterialApp(
      title: 'Myna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      ),
      home: const _SetupScreen(),
    );
  }
}

class _SetupScreen extends StatefulWidget {
  const _SetupScreen();

  @override
  State<_SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<_SetupScreen> {
  final _app = AppHostApi();
  final _platform = PlatformHostApi();
  late final AppLifecycleListener _lifecycle;
  bool _enabled = false;
  bool _selected = false;
  bool? _internet;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_refresh()));
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final enabled = await _app.isMynaEnabled();
    final selected = await _app.isMynaSelected();
    final internet = await _platform.hasInternetPermission();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _selected = selected;
      _internet = internet;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Myna')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Step(
            done: _enabled,
            title: '1. Turn on Myna',
            subtitle: 'Enable Myna in Android\'s keyboard settings.',
            action: FilledButton(
              onPressed: () => unawaited(_app.openInputMethodSettings()),
              child: const Text('Open settings'),
            ),
          ),
          _Step(
            done: _selected,
            title: '2. Switch to Myna',
            subtitle: 'Choose Myna as your keyboard.',
            action: FilledButton(
              onPressed: () => unawaited(_app.showInputMethodPicker()),
              child: const Text('Choose keyboard'),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Try typing here'),
          ),
          const SizedBox(height: 24),
          Card(
            color: scheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(
                _internet == null
                    ? 'Checking network access…'
                    : _internet!
                    ? 'Debug build: network allowed for development tools'
                    : 'No internet permission: Myna cannot send anything',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Themes'),
            onTap: () => unawaited(
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ThemeGalleryScreen())),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Privacy'),
            onTap: () => unawaited(
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PrivacyCenterScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.done, required this.title, required this.subtitle, required this.action});

  final bool done;
  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: done ? null : action,
    ),
  );
}
