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
    if (_enabled == false) return context.l10n.homeSetupTurnOn;
    return context.l10n.homeSetupChoose;
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
                  title: context.l10n.homeFinishSetup,
                  subtitle: _setupText,
                  onTap: () => open(KoshaRoutes.onboarding),
                ),
              ],
            ),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.translate,
                title: context.l10n.settingsLanguages,
                subtitle: languageLabel(settings.languages.active),
                onTap: () => open(KoshaRoutes.languages),
              ),
              SettingsTile(
                icon: Icons.keyboard_outlined,
                title: context.l10n.settingsTyping,
                subtitle: context.l10n.homeTypingSubtitle,
                onTap: () => open(KoshaRoutes.typing),
              ),
              SettingsTile(
                icon: Icons.vibration,
                title: context.l10n.settingsFeel,
                subtitle: context.l10n.homeFeelSubtitle,
                onTap: () => open(KoshaRoutes.feel),
              ),
              SettingsTile(
                icon: Icons.palette_outlined,
                title: context.l10n.settingsThemes,
                subtitle: ThemePresets.byId(settings.appearance.themeId).name,
                onTap: () => open(KoshaRoutes.themes),
              ),
              SettingsTile(
                icon: Icons.dashboard_customize_outlined,
                title: context.l10n.settingsPanels,
                subtitle: context.l10n.homePanelsSubtitle,
                onTap: () => open(KoshaRoutes.panels),
              ),
              SettingsTile(
                icon: Icons.mic_none_outlined,
                title: context.l10n.settingsVoice,
                subtitle: context.l10n.homeVoiceSubtitle,
                onTap: () => open(KoshaRoutes.voice),
              ),
              SettingsTile(
                icon: Icons.translate,
                title: context.l10n.settingsTranslation,
                subtitle: context.l10n.homeTranslationSubtitle,
                onTap: () => open(KoshaRoutes.translate),
              ),
            ],
          ),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.shield_outlined,
                title: context.l10n.settingsPrivacy,
                subtitle: context.l10n.homePrivacySubtitle,
                onTap: () => open(KoshaRoutes.privacy),
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: context.l10n.settingsAbout,
                subtitle: context.l10n.homeAboutSubtitle,
                onTap: () => open(KoshaRoutes.about),
              ),
            ],
          ),
        ],
      );
    },
  );
}
