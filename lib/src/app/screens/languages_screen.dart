// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. Languages and layouts: the active language, its layout, the multilingual
// switch, and the languages that are coming. Writes the `languages` section.
import 'package:material_ui/material_ui.dart';

import '../../settings/myna_settings.dart';
import '../common/settings_widgets.dart';
import '../shell/language_catalog.dart';
import '../shell/settings_actions.dart';

class LanguagesScreen extends StatelessWidget {
  const LanguagesScreen({super.key});

  @override
  Widget build(BuildContext context) => LiveSettings(
    builder: (context, settings) {
      final l = settings.languages;
      final active = l.active;
      return SettingsPage(
        title: 'Languages',
        children: [
          SettingsPanel(
            title: 'Active language',
            child: SettingsChoiceChips<String>(
              options: [for (final id in l.enabled) ChoiceOption(id, languageLabel(id))],
              selected: active,
              onSelected: (id) => writeSettings(
                context,
                SettingsSection.languages,
                (s) => s.copyWith(languages: s.languages.copyWith(active: id)),
              ),
            ),
          ),
          SettingsGroup(
            title: 'Layout for ${languageLabel(active)}',
            children: [
              SettingsTile(
                icon: Icons.keyboard_alt_outlined,
                title: layoutLabel(layoutFor(l, active)),
                subtitle: 'More layouts arrive with more languages',
              ),
            ],
          ),
          SettingsGroup(
            children: [
              SettingsSwitchTile(
                icon: Icons.layers_outlined,
                title: 'Multilingual typing',
                subtitle: 'Blend up to three enabled languages that share the layout\'s script',
                value: l.multilingual,
                onChanged: (v) => writeSettings(
                  context,
                  SettingsSection.languages,
                  (s) => s.copyWith(languages: s.languages.copyWith(multilingual: v)),
                ),
              ),
            ],
          ),
          SettingsPanel(
            title: 'Coming soon',
            child: SettingsChoiceChips<String>(
              options: [for (final id in plannedLanguageIds) ChoiceOption(id, languageLabel(id), enabled: false)],
              selected: null,
              onSelected: (_) {},
            ),
          ),
        ],
      );
    },
  );
}
