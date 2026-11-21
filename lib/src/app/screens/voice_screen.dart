// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. Voice is a placeholder for now: it shows the VoiceSettings values and says
// that offline voice typing arrives in a later update.
import 'package:material_ui/material_ui.dart';

import '../common/settings_widgets.dart';
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
          const SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.mic_none_outlined,
                title: 'Offline voice arrives in a later update',
                subtitle: 'Speech will be recognised on this phone. Nothing is recorded or sent.',
              ),
            ],
          ),
          SettingsGroup(
            title: 'Current settings',
            children: [
              SettingsTile(title: 'Voice typing', trailing: Text(v.enabled ? 'On' : 'Off')),
              SettingsTile(title: 'Model', trailing: Text(v.modelId == 'base' ? 'Built in' : v.modelId)),
              SettingsTile(title: 'Detect language automatically', trailing: Text(v.autoDetectLanguage ? 'On' : 'Off')),
            ],
          ),
        ],
      );
    },
  );
}
