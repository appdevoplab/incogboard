// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T. Settings → Translation: on or off, the default language pair, the installed
// directions, and a link to Model packs. Translation runs on the phone; nothing translated is saved.
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../bridge/messages.g.dart';
import '../../engine/lang/registry.dart';
import '../../features/translate/translate_languages.dart';
import '../../settings/incogboard_settings.dart';
import '../app_services.dart';
import '../common/settings_widgets.dart';
import '../privacy/privacy_format.dart';
import '../routes.dart';
import '../packs/pack_text.dart';

import 'package:incogboard/src/app/l10n.dart';

/// The directions offered as the default pair: English with each supported language, both ways.
const List<(String, String)> defaultPairChoices = [
  ('en', 'es'),
  ('es', 'en'),
  ('en', 'fr'),
  ('fr', 'en'),
  ('en', 'de'),
  ('de', 'en'),
  ('en', 'pt-BR'),
  ('pt-BR', 'en'),
  ('en', 'hi'),
  ('hi', 'en'),
  ('en', 'ru'),
  ('ru', 'en'),
];

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  AppServices? _services;
  Future<List<PackInfoMessage>>? _packs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_services != null) return;
    _services = AppScope.of(context);
    _packs = _readPacks();
  }

  Future<List<PackInfoMessage>> _readPacks() async {
    try {
      final packs = await _services!.platform.listPacks();
      return packs.where((p) => p.kind == PackKind.translation).toList();
    } on Object {
      return const [];
    }
  }

  void _reloadPacks() {
    setState(() {
      _packs = _readPacks();
    });
  }

  Future<void> _update(TranslateSettings Function(TranslateSettings t) change) async {
    final services = _services!;
    await services.settings.update(
      (s) => s.copyWith(translate: change(s.translate)),
      sections: const [SettingsSection.translate],
    );
  }

  Future<void> _pickDefaultPair(TranslateSettings current) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.translateDefaultPair),
        children: [
          RadioGroup<String>(
            groupValue: pairKey(current.from, current.to),
            onChanged: (v) => Navigator.of(context).pop(v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (from, to) in defaultPairChoices)
                  RadioListTile<String>(
                    value: pairKey(from, to),
                    title: Text(
                      context.l10n.translatePairName(languageInfo(from).englishName, languageInfo(to).englishName),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    final choice = defaultPairChoices.firstWhere((c) => pairKey(c.$1, c.$2) == picked);
    await _update((t) => t.copyWith(from: choice.$1, to: choice.$2));
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    if (services == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return ListenableBuilder(
      listenable: services.settings,
      builder: (context, _) {
        final t = services.settings.value.translate;
        return FutureBuilder<List<PackInfoMessage>>(
          future: _packs,
          builder: (context, snapshot) {
            final packs = snapshot.data ?? const <PackInfoMessage>[];
            final installed = installedPairKeys(packs);
            final current = pairKey(t.from, t.to);
            return SettingsPage(
              title: context.l10n.settingsTranslation,
              children: [
                SettingsGroup(
                  children: [
                    SettingsSwitchTile(
                      icon: Icons.translate,
                      title: context.l10n.translateOffline,
                      subtitle: context.l10n.translateOfflineBody,
                      value: t.enabled,
                      onChanged: (v) => unawaited(_update((s) => s.copyWith(enabled: v))),
                    ),
                  ],
                ),
                SettingsGroup(
                  title: context.l10n.translateDefaultPairTile,
                  children: [
                    SettingsTile(
                      icon: Icons.swap_horiz,
                      title: context.l10n.translatePairName(
                        languageInfo(t.from).englishName,
                        languageInfo(t.to).englishName,
                      ),
                      subtitle: installed.contains(current)
                          ? context.l10n.translatePackInstalled
                          : context.l10n.translatePackNotInstalled,
                      enabled: t.enabled,
                      onTap: t.enabled ? () => unawaited(_pickDefaultPair(t)) : null,
                    ),
                  ],
                ),
                SettingsGroup(
                  title: context.l10n.translateInstalled,
                  children: packs.isEmpty
                      ? [
                          SettingsTile(
                            icon: Icons.download_for_offline_outlined,
                            title: context.l10n.packsNoTranslation,
                            subtitle: context.l10n.translateInstalledBody,
                          ),
                        ]
                      : [
                          for (final p in packs)
                            SettingsTile(
                              icon: Icons.check_circle_outline,
                              title: packLanguages(p, context.l10n),
                              subtitle: context.l10n.translatePackMeta(formatBytes(p.sizeBytes), p.license),
                            ),
                        ],
                ),
                SettingsGroup(
                  children: [
                    SettingsTile(
                      icon: Icons.download_for_offline_outlined,
                      title: context.l10n.settingsModelPacks,
                      subtitle: context.l10n.translateModelPacksBody,
                      onTap: () => unawaited(
                        Navigator.of(context).pushNamed(IncogBoardRoutes.packs).then((_) => _reloadPacks()),
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 24), child: Text(context.l10n.translateRunsOnPhone)),
              ],
            );
          },
        );
      },
    );
  }
}
