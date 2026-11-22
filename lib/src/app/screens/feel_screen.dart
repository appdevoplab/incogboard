// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. Feel: haptics, sounds, keyboard height per orientation, and the one-handed
// and floating modes. Writes `feedback`, `appearance` and `modes` (values only; the keyboard owns
// the behaviour).
import 'package:material_ui/material_ui.dart';

import '../../settings/kosha_settings.dart';
import '../common/settings_widgets.dart';
import '../shell/settings_actions.dart';

String _percent(double v) => '${(v * 100).round()}%';

class FeelScreen extends StatelessWidget {
  const FeelScreen({super.key});

  @override
  Widget build(BuildContext context) => LiveSettings(
    builder: (context, settings) {
      final f = settings.feedback;
      final a = settings.appearance;
      final m = settings.modes;
      // -1 means "system default volume".
      final systemVolume = f.soundVolume < 0;

      return SettingsPage(
        title: 'Feel',
        children: [
          SettingsGroup(
            title: 'Haptics',
            children: [
              SettingsSwitchTile(
                icon: Icons.vibration,
                title: 'Haptic feedback',
                subtitle: 'A short vibration on each key, following the system setting',
                value: f.haptics,
                onChanged: (v) => writeSettings(
                  context,
                  SettingsSection.feedback,
                  (s) => s.copyWith(feedback: s.feedback.copyWith(haptics: v)),
                ),
              ),
              SettingsSliderTile(
                icon: Icons.graphic_eq,
                title: 'Haptic strength',
                value: f.hapticStrength,
                min: 0,
                max: 1,
                divisions: 10,
                valueLabel: _percent,
                onChanged: (v) => writeSettings(
                  context,
                  SettingsSection.feedback,
                  (s) => s.copyWith(feedback: s.feedback.copyWith(hapticStrength: v)),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Sounds',
            children: [
              SettingsSwitchTile(
                icon: Icons.volume_up_outlined,
                title: 'Key sounds',
                subtitle: 'Clicks for keys, space, delete and enter',
                value: f.sounds,
                onChanged: (v) => writeSettings(
                  context,
                  SettingsSection.feedback,
                  (s) => s.copyWith(feedback: s.feedback.copyWith(sounds: v)),
                ),
              ),
              SettingsSwitchTile(
                icon: Icons.settings_suggest_outlined,
                title: 'Use system volume',
                value: systemVolume,
                onChanged: f.sounds
                    ? (v) => writeSettings(
                        context,
                        SettingsSection.feedback,
                        (s) => s.copyWith(feedback: s.feedback.copyWith(soundVolume: v ? -1 : 0.5)),
                      )
                    : null,
              ),
              if (!systemVolume)
                SettingsSliderTile(
                  icon: Icons.equalizer,
                  title: 'Key sound volume',
                  value: f.soundVolume,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  valueLabel: _percent,
                  onChanged: (v) => writeSettings(
                    context,
                    SettingsSection.feedback,
                    (s) => s.copyWith(feedback: s.feedback.copyWith(soundVolume: v)),
                  ),
                ),
            ],
          ),
          SettingsGroup(
            title: 'Height',
            children: [
              SettingsSliderTile(
                icon: Icons.stay_current_portrait,
                title: 'Portrait height',
                value: a.heightScale,
                min: 0.7,
                max: 1.5,
                divisions: 16,
                valueLabel: _percent,
                onChanged: (v) => writeSettings(
                  context,
                  SettingsSection.appearance,
                  (s) => s.copyWith(appearance: s.appearance.copyWith(heightScale: v)),
                ),
              ),
              SettingsSliderTile(
                icon: Icons.stay_current_landscape,
                title: 'Landscape height',
                value: a.landscapeHeightScale,
                min: 0.6,
                max: 1.5,
                divisions: 18,
                valueLabel: _percent,
                onChanged: (v) => writeSettings(
                  context,
                  SettingsSection.appearance,
                  (s) => s.copyWith(appearance: s.appearance.copyWith(landscapeHeightScale: v)),
                ),
              ),
            ],
          ),
          SettingsPanel(
            title: 'One-handed and floating',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('One-handed side', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
                SegmentedButton<OneHandedMode>(
                  segments: const [
                    ButtonSegment<OneHandedMode>(value: OneHandedMode.off, label: Text('Off')),
                    ButtonSegment<OneHandedMode>(value: OneHandedMode.left, label: Text('Left')),
                    ButtonSegment<OneHandedMode>(value: OneHandedMode.right, label: Text('Right')),
                  ],
                  selected: {m.oneHanded},
                  onSelectionChanged: (sides) => writeSettings(
                    context,
                    SettingsSection.modes,
                    (s) => s.copyWith(modes: s.modes.copyWith(oneHanded: sides.first)),
                  ),
                ),
                const SizedBox(height: 8),
                SettingsSwitchTile(
                  icon: Icons.open_with,
                  title: 'Floating keyboard',
                  subtitle: 'Drag it anywhere on the screen',
                  value: m.floating,
                  onChanged: (v) => writeSettings(
                    context,
                    SettingsSection.modes,
                    (s) => s.copyWith(modes: s.modes.copyWith(floating: v)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
