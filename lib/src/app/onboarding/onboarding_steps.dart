// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. The steps of first-run setup. The screen (onboarding_screen.dart) owns the
// status values and passes them in; each step only shows them and calls back.
import 'package:material_ui/material_ui.dart';

import '../../settings/kosha_settings.dart';
import '../../theme/presets.dart';
import '../common/settings_widgets.dart';
import '../routes.dart';
import '../shell/settings_actions.dart';
import 'kosha_mascot.dart';
import 'onboarding_languages.dart';

import 'package:kosha/src/app/l10n.dart';

/// Shared layout: a scrollable column with a heading and body text.
class _StepPage extends StatelessWidget {
  const _StepPage({required this.title, required this.body, required this.children, this.mascot});

  final String title;
  final String body;
  final List<Widget> children;
  final Widget? mascot;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (mascot != null) Center(child: mascot),
        if (mascot != null) const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(title, style: text.headlineMedium?.copyWith(color: scheme.onSurface)),
        ),
        const SizedBox(height: 8),
        Text(body, style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

/// A rounded status row with a tick once the step is done.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.done, required this.doneText, required this.pendingText});

  final bool done;
  final String doneText;
  final String pendingText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label: done ? doneText : pendingText,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: done ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: scheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                done ? doneText : pendingText,
                style: TextStyle(color: done ? scheme.onPrimaryContainer : scheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 1: turn Kosha on in Android's keyboard list.
class EnableStep extends StatelessWidget {
  const EnableStep({super.key, required this.enabled, required this.onOpenSettings});

  final bool enabled;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) => _StepPage(
    mascot: const KoshaMascot(size: 112),
    title: context.l10n.onboardingTurnOnTitle,
    body: context.l10n.onboardingTurnOnBody,
    children: [
      _StatusCard(
        done: enabled,
        doneText: context.l10n.onboardingKeyboardOn,
        pendingText: context.l10n.onboardingKeyboardOff,
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: onOpenSettings,
        icon: const Icon(Icons.open_in_new),
        label: Text(context.l10n.onboardingOpenKeyboardSettings),
      ),
    ],
  );
}

/// Step 2: choose Kosha as the keyboard in use. The screen polls while this step shows.
class SwitchStep extends StatelessWidget {
  const SwitchStep({super.key, required this.enabled, required this.selected, required this.onChoose});

  final bool enabled;
  final bool selected;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) => _StepPage(
    title: context.l10n.onboardingSwitchTitle,
    body: context.l10n.onboardingSwitchBody,
    children: [
      _StatusCard(
        done: selected,
        doneText: context.l10n.onboardingKeyboardIsYours,
        pendingText: enabled ? context.l10n.onboardingKeyboardNotYours : context.l10n.onboardingTurnOnFirst,
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: onChoose,
        icon: const Icon(Icons.keyboard_alt_outlined),
        label: Text(context.l10n.onboardingChooseKeyboard),
      ),
    ],
  );
}

/// Step 3: why Android's "may collect your text" warning does not apply to Kosha.
class PrivacyStep extends StatelessWidget {
  const PrivacyStep({super.key, required this.internet, required this.debugBuild});

  /// Null while the permission is still being read.
  final bool? internet;
  final bool debugBuild;

  @override
  Widget build(BuildContext context) {
    final String internetText;
    if (internet == null) {
      internetText = context.l10n.onboardingCheckingPermissions;
    } else if (internet!) {
      internetText = debugBuild ? context.l10n.onboardingDebugInternet : context.l10n.onboardingReleaseInternet;
    } else {
      internetText = context.l10n.onboardingNoInternet;
    }
    return _StepPage(
      title: context.l10n.onboardingWarningTitle,
      body: context.l10n.onboardingWarningBody,
      children: [
        SettingsGroup(
          children: [
            SettingsTile(
              icon: internet == false ? Icons.lock_outline : Icons.wifi_off_outlined,
              title: context.l10n.onboardingInternetAccess,
              subtitle: internetText,
            ),
            SettingsTile(
              icon: Icons.phone_android_outlined,
              title: context.l10n.onboardingEverythingHere,
              subtitle: context.l10n.onboardingEverythingHereBody,
            ),
          ],
        ),
      ],
    );
  }
}

/// Step 4: languages (only English today) and a theme preset.
class PersonaliseStep extends StatelessWidget {
  const PersonaliseStep({super.key});

  @override
  Widget build(BuildContext context) => _StepPage(
    title: context.l10n.onboardingLanguagesTitle,
    body: context.l10n.onboardingLanguagesBody,
    children: [
      SettingsPanel(title: context.l10n.settingsLanguages, child: OnboardingLanguagePicker()),
      const SizedBox(height: 4),
      SettingsPanel(
        title: context.l10n.onboardingThemeTitle,
        child: LiveSettings(
          builder: (context, settings) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsChoiceChips<String>(
                options: [for (final p in ThemePresets.all) ChoiceOption(p.id, p.name)],
                selected: settings.appearance.themeId,
                onSelected: (id) => writeSettings(
                  context,
                  SettingsSection.appearance,
                  (s) => s.copyWith(appearance: s.appearance.copyWith(themeId: id)),
                ),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(KoshaRoutes.themes),
                  child: Text(context.l10n.onboardingMoreThemes),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// Step 5: a test field and a short checklist.
class TryStep extends StatefulWidget {
  const TryStep({super.key});

  @override
  State<TryStep> createState() => _TryStepState();
}

class _TryStepState extends State<TryStep> {
  static const int _taskCount = 3;

  static List<String> _taskTitles(AppLocalizations l10n) => [
    l10n.onboardingTryTyping,
    l10n.onboardingTrySwipe,
    l10n.onboardingTryAccents,
  ];
  final List<bool> _done = List.filled(_taskCount, false);

  @override
  Widget build(BuildContext context) => _StepPage(
    title: context.l10n.onboardingTryTitle,
    body: context.l10n.onboardingTryBody,
    children: [
      TextField(
        decoration: InputDecoration(border: OutlineInputBorder(), labelText: context.l10n.onboardingTryField),
      ),
      const SizedBox(height: 16),
      SettingsGroup(
        title: context.l10n.onboardingChecklist,
        children: [
          for (var i = 0; i < _taskCount; i++)
            CheckboxListTile(
              value: _done[i],
              title: Text(_taskTitles(context.l10n)[i]),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: (v) => setState(() => _done[i] = v ?? false),
            ),
        ],
      ),
    ],
  );
}

/// Step 6: the last step; the screen's Done button stores that setup is finished.
class FinishStep extends StatelessWidget {
  const FinishStep({super.key});

  @override
  Widget build(BuildContext context) => _StepPage(
    mascot: const KoshaMascot(size: 112),
    title: context.l10n.onboardingAllSetTitle,
    body: context.l10n.onboardingAllSetBody,
    children: const [],
  );
}
