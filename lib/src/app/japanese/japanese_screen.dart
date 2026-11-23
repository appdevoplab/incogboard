// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 4-B. Japanese typing options (route KoshaRoutes.japanese). Writes the `japanese`
// settings section (flick only, half-width space) and the default Japanese layout
// (`languages.layouts['ja']`), shows the dictionary pack status, and clears the learned words.
// Strings are plain English for now (Agent C localises the rest of the app).
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../bridge/messages.g.dart';
import '../../core/data_sections.dart';
import '../../engine/lang/japanese/japanese_learning.dart';
import '../../packs/installed_packs.dart';
import '../../settings/kosha_settings.dart';
import '../app_services.dart';
import '../common/settings_widgets.dart';
import '../routes.dart';
import '../shell/settings_actions.dart';

class JapaneseScreen extends StatefulWidget {
  const JapaneseScreen({super.key});

  @override
  State<JapaneseScreen> createState() => _JapaneseScreenState();
}

class _JapaneseScreenState extends State<JapaneseScreen> {
  Future<List<PackInfoMessage>>? _packs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _packs ??= _loadPacks(AppScope.of(context));
  }

  /// The installed Japanese dictionary packs. A failed read shows none rather than an error.
  static Future<List<PackInfoMessage>> _loadPacks(AppServices services) async {
    try {
      return await InstalledPacks(services.platform).dictionariesFor('ja');
    } on Object {
      return <PackInfoMessage>[];
    }
  }

  @override
  Widget build(BuildContext context) => LiveSettings(
    builder: (context, settings) {
      final j = settings.japanese;
      final layout = settings.languages.layouts['ja'] ?? 'kana12_ja';
      return SettingsPage(
        title: 'Japanese',
        children: [
          SettingsPanel(
            title: 'Layout',
            child: SettingsChoiceChips<String>(
              options: const [
                ChoiceOption('kana12_ja', '12-key (flick)'),
                ChoiceOption('romaji_ja', 'Romaji (QWERTY)'),
              ],
              selected: layout,
              onSelected: (id) => writeSettings(
                context,
                SettingsSection.languages,
                (s) => s.copyWith(languages: s.languages.copyWith(layouts: {...s.languages.layouts, 'ja': id})),
              ),
            ),
          ),
          SettingsGroup(
            title: 'Typing',
            children: [
              SettingsSwitchTile(
                icon: Icons.touch_app_outlined,
                title: 'Flick only',
                subtitle: 'No multi-tap: tapping あ twice types ああ, not い',
                value: j.flickOnly,
                onChanged: (on) => writeSettings(
                  context,
                  SettingsSection.japanese,
                  (s) => s.copyWith(japanese: s.japanese.copyWith(flickOnly: on)),
                ),
              ),
              SettingsSwitchTile(
                icon: Icons.space_bar_outlined,
                title: 'Half-width space',
                subtitle: 'Space types a normal space when nothing is being typed. Off types a full-width space.',
                value: j.halfWidthSpace,
                onChanged: (on) => writeSettings(
                  context,
                  SettingsSection.japanese,
                  (s) => s.copyWith(japanese: s.japanese.copyWith(halfWidthSpace: on)),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Dictionary',
            children: [
              FutureBuilder<List<PackInfoMessage>>(
                future: _packs,
                builder: (context, snap) {
                  final packs = snap.data;
                  final installed = packs != null && packs.isNotEmpty;
                  return SettingsTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Dictionary pack',
                    subtitle: !snap.hasData
                        ? 'Checking...'
                        : installed
                        ? '${packs.first.name} is installed. Kanji conversion is on.'
                        : 'Not installed. Kana still types; kanji need the pack.',
                    onTap: () => unawaited(Navigator.of(context).pushNamed(KoshaRoutes.packs)),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear learned words',
                subtitle: 'Forgets the Japanese words you picked. Stored encrypted on this phone.',
                onTap: () => unawaited(_clearLearned(context)),
              ),
            ],
          ),
        ],
      );
    },
  );

  Future<void> _clearLearned(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear learned Japanese words?'),
        content: const Text('This deletes every Japanese word you picked. It cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final services = AppScope.of(context);
    await services.secureStore.delete(JapaneseLearning.blobName);
    await services.notifyDataChanged(const [DataSections.learned]);
  }
}
