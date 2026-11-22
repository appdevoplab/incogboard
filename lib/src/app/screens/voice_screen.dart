// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-D. Voice settings: voice typing on or off, the voice pack (Automatic or one of the installed
// voice packs), automatic language detection, a link to the model packs, and the privacy line.
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../bridge/messages.g.dart';
import '../../settings/myna_settings.dart';
import '../common/settings_widgets.dart';
import '../app_services.dart';
import '../routes.dart';
import '../shell/settings_actions.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) => LiveSettings(
    builder: (context, settings) {
      final v = settings.voice;
      return SettingsPage(
        title: 'Voice',
        children: [
          SettingsGroup(
            children: [
              SettingsSwitchTile(
                icon: Icons.mic_none_outlined,
                title: 'Voice typing',
                subtitle: 'Speak to type. Recognition runs on this phone.',
                value: v.enabled,
                onChanged: (on) => writeSettings(
                  context,
                  SettingsSection.voice,
                  (s) => s.copyWith(voice: s.voice.copyWith(enabled: on)),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Recognition',
            children: [
              _VoicePackTile(selectedId: v.modelId),
              SettingsSwitchTile(
                icon: Icons.translate,
                title: 'Detect language automatically',
                subtitle: 'Whisper works out which language you speak.',
                value: v.autoDetectLanguage,
                onChanged: (on) => writeSettings(
                  context,
                  SettingsSection.voice,
                  (s) => s.copyWith(voice: s.voice.copyWith(autoDetectLanguage: on)),
                ),
              ),
              SettingsTile(
                icon: Icons.inventory_2_outlined,
                title: 'Model packs',
                subtitle: 'Install or remove voice and translation packs',
                onTap: () => unawaited(Navigator.of(context).pushNamed(MynaRoutes.packs)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Text('Audio stays on this phone and is never saved.', textAlign: TextAlign.center),
          ),
        ],
      );
    },
  );
}

/// The voice pack to use: Automatic (the first installed voice pack that covers the language) or one pack.
class _VoicePackTile extends StatefulWidget {
  const _VoicePackTile({required this.selectedId});

  final String selectedId;

  @override
  State<_VoicePackTile> createState() => _VoicePackTileState();
}

class _VoicePackTileState extends State<_VoicePackTile> {
  Future<List<PackInfoMessage>>? _packs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _packs ??= _loadVoicePacks(AppScope.of(context));
  }

  /// The installed voice packs. A failed read shows no packs rather than an error.
  static Future<List<PackInfoMessage>> _loadVoicePacks(AppServices services) async {
    try {
      final all = await services.platform.listPacks();
      return all.where((p) => p.kind == PackKind.voice).toList();
    } on Object {
      return <PackInfoMessage>[];
    }
  }

  String _label(List<PackInfoMessage> packs) {
    if (widget.selectedId.isEmpty) return 'Automatic';
    for (final p in packs) {
      if (p.id == widget.selectedId) return p.name;
    }
    return widget.selectedId;
  }

  Future<void> _choose(List<PackInfoMessage> packs) async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Voice pack'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(''),
            child: Text(widget.selectedId.isEmpty ? 'Automatic (selected)' : 'Automatic'),
          ),
          for (final p in packs)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(p.id),
              child: Text('${p.name}  ·  ${_mb(p.sizeBytes)}${p.id == widget.selectedId ? '  (selected)' : ''}'),
            ),
          if (packs.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text('No voice pack is installed. Install one under Model packs.'),
            ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
    writeSettings(context, SettingsSection.voice, (s) => s.copyWith(voice: s.voice.copyWith(modelId: chosen)));
  }

  static String _mb(int bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';

  @override
  Widget build(BuildContext context) => FutureBuilder<List<PackInfoMessage>>(
    future: _packs,
    builder: (context, snap) {
      final packs = snap.data ?? const <PackInfoMessage>[];
      final loading = snap.connectionState != ConnectionState.done;
      return SettingsTile(
        icon: Icons.settings_voice_outlined,
        title: 'Voice pack',
        subtitle: loading ? 'Looking for installed packs' : null,
        trailing: Text(loading ? '' : _label(packs)),
        onTap: loading ? null : () => unawaited(_choose(packs)),
      );
    },
  );
}
