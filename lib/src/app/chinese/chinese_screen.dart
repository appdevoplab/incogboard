// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 4-A. Chinese typing options (route KoshaRoutes.chinese): Traditional output, fuzzy
// pinyin, the dictionary pack status and clearing the learned phrases. Writes the `chinese` section.
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../bridge/messages.g.dart';
import '../../core/data_sections.dart';
import '../../engine/lang/chinese/learned_phrases.dart';
import '../../packs/installed_packs.dart';
import '../../settings/kosha_settings.dart';
import '../app_services.dart';
import '../common/settings_widgets.dart';
import '../routes.dart';
import '../shell/settings_actions.dart';

class ChineseScreen extends StatelessWidget {
  const ChineseScreen({super.key});

  @override
  Widget build(BuildContext context) => LiveSettings(
    builder: (context, settings) {
      final c = settings.chinese;
      return SettingsPage(
        title: 'Chinese',
        children: [
          SettingsGroup(
            children: [
              SettingsSwitchTile(
                icon: Icons.translate,
                title: 'Traditional characters',
                subtitle: 'Show candidates in Traditional characters (Taiwan standard).',
                value: c.traditional,
                onChanged: (on) => writeSettings(
                  context,
                  SettingsSection.chinese,
                  (s) => s.copyWith(chinese: s.chinese.copyWith(traditional: on)),
                ),
              ),
              SettingsSwitchTile(
                icon: Icons.swap_horiz,
                title: 'Fuzzy pinyin',
                subtitle: 'Also accept z and zh, c and ch, s and sh, n and l, an and ang, en and eng, in and ing.',
                value: c.fuzzyPinyin,
                onChanged: (on) => writeSettings(
                  context,
                  SettingsSection.chinese,
                  (s) => s.copyWith(chinese: s.chinese.copyWith(fuzzyPinyin: on)),
                ),
              ),
            ],
          ),
          const SettingsGroup(title: 'Dictionary', children: [_PackTile()]),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear learned phrases',
                subtitle: 'Forget the words you picked. The dictionary stays.',
                onTap: () => unawaited(_confirmClear(context)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Text(
              'Chinese is typed on this phone. Learned phrases are encrypted and never leave it.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    },
  );

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear learned phrases?'),
        content: const Text('The words you picked for Chinese are removed. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Clear')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final services = AppScope.of(context);
    try {
      await services.secureStore.delete(learnedZhBlobName);
      await services.notifyDataChanged(const [DataSections.learned]);
    } on Object {
      // The blob may already be gone; the list is empty either way.
    }
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text('Learned phrases cleared')));
    }
  }
}

/// The Chinese dictionary pack: its name and size, or a link to install it.
class _PackTile extends StatefulWidget {
  const _PackTile();

  @override
  State<_PackTile> createState() => _PackTileState();
}

class _PackTileState extends State<_PackTile> {
  Future<List<PackInfoMessage>>? _packs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _packs ??= _load(AppScope.of(context));
  }

  static Future<List<PackInfoMessage>> _load(AppServices services) async {
    try {
      return await InstalledPacks(services.platform).dictionariesFor('zh');
    } on Object {
      return <PackInfoMessage>[];
    }
  }

  static String _mb(int bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';

  @override
  Widget build(BuildContext context) => FutureBuilder<List<PackInfoMessage>>(
    future: _packs,
    builder: (context, snap) {
      final loading = snap.connectionState != ConnectionState.done;
      final packs = snap.data ?? const <PackInfoMessage>[];
      void open() => unawaited(Navigator.of(context).pushNamed(KoshaRoutes.packs));
      if (loading) {
        return const SettingsTile(icon: Icons.inventory_2_outlined, title: 'Looking for the dictionary');
      }
      if (packs.isEmpty) {
        return SettingsTile(
          icon: Icons.inventory_2_outlined,
          title: 'Chinese dictionary',
          subtitle: 'Not installed. Chinese typing needs it; install it under Model packs.',
          onTap: open,
        );
      }
      final pack = packs.first;
      return SettingsTile(
        icon: Icons.inventory_2_outlined,
        title: pack.name,
        subtitle: 'Installed. ${pack.license}',
        trailing: Text(_mb(pack.sizeBytes)),
        onTap: open,
      );
    },
  );
}
