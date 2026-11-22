// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. Home: the mascot header, a setup card while Kosha is not enabled or selected,
// and the section tiles.
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/log.dart';
import '../../theme/presets.dart';
import '../app_services.dart';
import '../common/settings_widgets.dart';
import '../l10n.dart';
import '../onboarding/kosha_mascot.dart';
import '../routes.dart';
import '../shell/language_catalog.dart';
import '../shell/settings_actions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppServices? _services;
  late final AppLifecycleListener _lifecycle;

  /// Null until the first read.
  bool? _enabled;
  bool? _selected;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_refresh()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_services != null) return;
    _services = AppScope.of(context);
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final services = _services;
    if (services == null) return;
    try {
      final enabled = await services.app.isKoshaEnabled();
      final selected = await services.app.isKoshaSelected();
      if (!mounted) return;
      setState(() {
        _enabled = enabled;
        _selected = selected;
      });
    } on Object catch (e) {
      KoshaLog.w('Home', 'setup status unavailable', e.runtimeType);
    }
  }

  bool get _setupIncomplete => _enabled == false || _selected == false;

  String get _setupText {
    if (_enabled == false) return 'Turn Kosha on in Android\'s keyboard list.';
    return 'Choose Kosha as the keyboard you type with.';
  }

  @override
  Widget build(BuildContext context) => LiveSettings(
    builder: (context, settings) {
      void open(String route) => unawaited(Navigator.of(context).pushNamed(route));
      final l10n = context.l10n;
      return SettingsPage(
        title: l10n.appName,
        header: SettingsHero(
          mascot: const KoshaMascot(size: 76),
          title: l10n.homeTagline,
          subtitle: l10n.homeOfflinePromise,
        ),
        children: [
          if (_setupIncomplete)
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.task_alt_outlined,
                  title: 'Finish setting up Kosha',
                  subtitle: _setupText,
                  onTap: () => open(KoshaRoutes.onboarding),
                ),
              ],
            ),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.translate,
                title: 'Languages',
                subtitle: languageLabel(settings.languages.active),
                onTap: () => open(KoshaRoutes.languages),
              ),
              SettingsTile(
                icon: Icons.keyboard_outlined,
                title: 'Typing',
                subtitle: 'Corrections, suggestions, keys and swipe',
                onTap: () => open(KoshaRoutes.typing),
              ),
              SettingsTile(
                icon: Icons.vibration,
                title: 'Feel',
                subtitle: 'Haptics, sounds, height and one-handed mode',
                onTap: () => open(KoshaRoutes.feel),
              ),
              SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Themes',
                subtitle: ThemePresets.byId(settings.appearance.themeId).name,
                onTap: () => open(KoshaRoutes.themes),
              ),
              SettingsTile(
                icon: Icons.dashboard_customize_outlined,
                title: 'Panels',
                subtitle: 'Clipboard and emoji',
                onTap: () => open(KoshaRoutes.panels),
              ),
              SettingsTile(
                icon: Icons.mic_none_outlined,
                title: 'Voice',
                subtitle: 'Speak to type, on this phone',
                onTap: () => open(KoshaRoutes.voice),
              ),
              SettingsTile(
                icon: Icons.translate,
                title: 'Translation',
                subtitle: 'Translate as you type, offline',
                onTap: () => open(KoshaRoutes.translate),
              ),
            ],
          ),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.shield_outlined,
                title: 'Privacy',
                subtitle: 'What is stored, incognito, app lock and backup',
                onTap: () => open(KoshaRoutes.privacy),
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version, licences and source code',
                onTap: () => open(KoshaRoutes.about),
              ),
            ],
          ),
        ],
      );
    },
  );
}
