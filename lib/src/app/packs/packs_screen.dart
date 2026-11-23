// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T. Model packs (voice and translation): what is installed with sizes and licences,
// import of a .koshapack file (the system file picker), and delete with a confirmation. A pack is checked
// before it is installed, and it only ever holds data. Voice uses this screen too.
import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:material_ui/material_ui.dart';

import '../../bridge/messages.g.dart';
import '../../core/data_sections.dart';
import '../app_services.dart';
import '../common/settings_widgets.dart';
import '../privacy/privacy_format.dart';
import 'pack_text.dart';
import 'package:kosha/src/app/l10n.dart';

class PacksScreen extends StatefulWidget {
  const PacksScreen({super.key});

  @override
  State<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends State<PacksScreen> {
  AppServices? _services;
  Future<List<PackInfoMessage>>? _packs;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_services != null) return;
    _services = AppScope.of(context);
    _reload();
  }

  void _reload() {
    setState(() {
      _packs = _readPacks();
    });
  }

  /// Async, so a failure (or a missing answer) shows as an error state instead of throwing while building.
  Future<List<PackInfoMessage>> _readPacks() async => _services!.platform.listPacks();

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _import() async {
    final services = _services!;
    String? uri;
    try {
      uri = await services.app.openDocument(const ['application/octet-stream', 'application/x-koshapack']);
    } on PlatformException {
      _show(context.l10n.packsOpenFailed);
      return;
    }
    if (uri == null) return; // The user cancelled.
    setState(() => _busy = true);
    try {
      final pack = await services.app.importPack(uri);
      await services.notifyDataChanged(const [DataSections.packs]);
      _show('Installed ${pack.name}.');
    } on PlatformException catch (e) {
      _show(importErrorText(e.code));
    } finally {
      if (mounted) setState(() => _busy = false);
      _reload();
    }
  }

  Future<void> _delete(PackInfoMessage pack) async {
    final services = _services!;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${pack.name}?'),
        content: const Text(
          'Its files are removed from this phone. You can import the pack again later from its file.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.delete)),
        ],
      ),
    );
    if (sure != true) return;
    try {
      await services.app.deletePack(pack.id);
      await services.notifyDataChanged(const [DataSections.packs]);
      _show('Deleted ${pack.name}.');
    } on PlatformException {
      _show('Kosha could not delete ${pack.name}. Try again.');
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PackInfoMessage>>(
      future: _packs,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SettingsPage(
            title: context.l10n.settingsModelPacks,
            children: [
              const SettingsGroup(
                children: [SettingsTile(icon: Icons.error_outline, title: 'Kosha could not read its packs')],
              ),
            ],
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final packs = snapshot.requireData;
        final voice = packs.where((p) => p.kind == PackKind.voice).toList();
        final translation = packs.where((p) => p.kind == PackKind.translation).toList();
        final dictionaries = packs.where((p) => p.kind == PackKind.dictionary).toList();
        final total = packs.fold<int>(0, (sum, p) => sum + p.sizeBytes);
        return SettingsPage(
          title: context.l10n.settingsModelPacks,
          header: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(context.l10n.packsIntro),
          ),
          children: [
            SettingsGroup(
              title: context.l10n.packsImport,
              children: [
                SettingsTile(
                  icon: Icons.file_open_outlined,
                  title: context.l10n.packsImportTitle,
                  subtitle: _busy ? context.l10n.packsChecking : context.l10n.packsImportBody,
                  enabled: !_busy,
                  onTap: _busy ? null : () => unawaited(_import()),
                ),
                if (_busy) const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 12), child: LinearProgressIndicator()),
              ],
            ),
            SettingsGroup(
              title: context.l10n.settingsVoice,
              children: voice.isEmpty
                  ? [
                      SettingsTile(
                        icon: Icons.mic_none,
                        title: context.l10n.packsNoVoice,
                        subtitle: context.l10n.packsNoVoiceBody,
                      ),
                    ]
                  : [for (final p in voice) _PackTile(pack: p, onDelete: () => _delete(p))],
            ),
            SettingsGroup(
              title: context.l10n.settingsTranslation,
              children: translation.isEmpty
                  ? [
                      SettingsTile(
                        icon: Icons.translate,
                        title: context.l10n.packsNoTranslation,
                        subtitle: context.l10n.packsNoTranslationBody,
                      ),
                    ]
                  : [for (final p in translation) _PackTile(pack: p, onDelete: () => _delete(p))],
            ),
            SettingsGroup(
              title: context.l10n.packsDictionaries,
              children: dictionaries.isEmpty
                  ? [
                      SettingsTile(
                        icon: Icons.menu_book_outlined,
                        title: context.l10n.packsNoDictionary,
                        subtitle: context.l10n.packsNoDictionaryBody,
                      ),
                    ]
                  : [for (final p in dictionaries) _PackTile(pack: p, onDelete: () => _delete(p))],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Text(
                packs.isEmpty ? context.l10n.packsNothingStored : 'Installed packs use ${formatBytes(total)} on this phone.',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PackTile extends StatelessWidget {
  const _PackTile({required this.pack, required this.onDelete});

  final PackInfoMessage pack;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(switch (pack.kind) {
      PackKind.voice => Icons.mic_none,
      PackKind.translation => Icons.translate,
      PackKind.dictionary => Icons.menu_book_outlined,
    }),
    title: Text(pack.name),
    subtitle: Text(packDescription(pack)),
    contentPadding: const EdgeInsets.only(left: 16, right: 8),
    minTileHeight: 56,
    trailing: IconButton(tooltip: 'Delete ${pack.name}', onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
  );
}
