// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-A. The language step of onboarding: pick one or more languages, with search. The
// system locale is pre-selected when Myna supports it. Writes the `languages` section.
import 'dart:ui' show PlatformDispatcher;

import 'package:material_ui/material_ui.dart';

import '../../settings/myna_settings.dart';
import '../app_services.dart';
import '../common/settings_widgets.dart';
import '../shell/language_catalog.dart';
import '../shell/settings_actions.dart';

class OnboardingLanguagePicker extends StatefulWidget {
  const OnboardingLanguagePicker({super.key});

  @override
  State<OnboardingLanguagePicker> createState() => _OnboardingLanguagePickerState();
}

class _OnboardingLanguagePickerState extends State<OnboardingLanguagePicker> {
  final TextEditingController _search = TextEditingController();
  bool _preselected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _preselectLocale(AppScope.of(context).settings.value.languages);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// First run only: add the system locale's language to the front, unless it is already enabled.
  void _preselectLocale(LanguageSettings languages) {
    if (_preselected) return;
    _preselected = true;
    if (languages.onboardingDone) return;
    final locale = supportedLocaleLanguage(PlatformDispatcher.instance.locale);
    if (locale == null || languages.enabled.contains(locale)) return;
    _write((l) => l.copyWith(enabled: [locale, ...l.enabled], active: locale));
  }

  void _write(LanguageSettings Function(LanguageSettings current) change) {
    writeSettings(context, SettingsSection.languages, (s) {
      final next = change(s.languages);
      final enabled = next.enabled.isEmpty ? const ['en'] : next.enabled;
      return s.copyWith(
        languages: next.copyWith(enabled: enabled, active: enabled.contains(next.active) ? next.active : enabled.first),
      );
    });
  }

  void _toggle(LanguageSettings languages, String id) {
    if (languages.enabled.contains(id)) {
      if (languages.enabled.length == 1) return; // at least one language stays on
      _write((l) => l.copyWith(enabled: [...l.enabled]..remove(id)));
    } else {
      _write((l) => l.copyWith(enabled: [...l.enabled, id], active: l.active));
    }
  }

  @override
  Widget build(BuildContext context) => LiveSettings(
    builder: (context, settings) {
      final languages = settings.languages;
      final results = searchLanguages(_search.text);
      final scheme = Theme.of(context).colorScheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search languages',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              isDense: false,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Selected: ${[for (final id in languages.enabled) languageLabel(id)].join(', ')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          if (results.isNotEmpty)
            // A fixed-height region with its own scroll, so the rest of the step stays on screen.
            SizedBox(
              height: 300,
              child: ListView(
                children: [
                  SettingsGroup(
                    children: [
                      for (final info in results)
                        SettingsTile(
                          title: info.nativeName,
                          subtitle: info.englishName,
                          trailing: Checkbox(
                            value: languages.enabled.contains(info.id),
                            onChanged: (_) => _toggle(languages, info.id),
                          ),
                          onTap: () => _toggle(languages, info.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          if (results.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('No language matches that search.')),
        ],
      );
    },
  );
}
