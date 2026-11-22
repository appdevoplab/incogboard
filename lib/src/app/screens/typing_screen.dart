// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. Typing: corrections, suggestions, keys, and swipe. Swipe settings live here
// because they change how typing feels; they write the `swipe` section.
import 'package:material_ui/material_ui.dart';

import '../../settings/kosha_settings.dart';
import '../common/settings_widgets.dart';
import '../shell/settings_actions.dart';

class TypingScreen extends StatelessWidget {
  const TypingScreen({super.key});

  @override
  Widget build(BuildContext context) => LiveSettings(
    builder: (context, settings) {
      final t = settings.typing;
      final w = settings.swipe;

      void typing(KoshaSettings Function(KoshaSettings s, TypingSettings t) change) =>
          writeSettings(context, SettingsSection.typing, (s) => change(s, s.typing));
      void swipe(KoshaSettings Function(KoshaSettings s, SwipeSettings w) change) =>
          writeSettings(context, SettingsSection.swipe, (s) => change(s, s.swipe));

      return SettingsPage(
        title: 'Typing',
        children: [
          SettingsGroup(
            title: 'Corrections',
            children: [
              SettingsSwitchTile(
                icon: Icons.spellcheck,
                title: 'Autocorrect',
                subtitle: 'Fix likely typos as you finish a word',
                value: t.autoCorrect,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(autoCorrect: v))),
              ),
              SettingsSwitchTile(
                icon: Icons.text_fields,
                title: 'Auto-capitalise',
                subtitle: 'Capital letters at the start of sentences',
                value: t.autoCapitalize,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(autoCapitalize: v))),
              ),
              SettingsSwitchTile(
                icon: Icons.more_horiz,
                title: 'Double-space full stop',
                subtitle: 'Two taps of space write ". "',
                value: t.doubleSpacePeriod,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(doubleSpacePeriod: v))),
              ),
              SettingsSwitchTile(
                icon: Icons.format_quote_outlined,
                title: 'Smart punctuation',
                subtitle: 'Tidy spaces around punctuation and use local quotes',
                value: t.smartPunctuation,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(smartPunctuation: v))),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Suggestions',
            children: [
              SettingsSwitchTile(
                icon: Icons.lightbulb_outline,
                title: 'Suggestions',
                subtitle: 'Show words in the suggestion bar',
                value: t.showSuggestions,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(showSuggestions: v))),
              ),
              SettingsSwitchTile(
                icon: Icons.arrow_forward,
                title: 'Next-word prediction',
                subtitle: 'Suggest the word that often follows',
                value: t.nextWordPrediction,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(nextWordPrediction: v))),
              ),
              SettingsSwitchTile(
                icon: Icons.emoji_emotions_outlined,
                title: 'Emoji suggestions',
                subtitle: 'Offer an emoji for some words',
                value: t.emojiSuggestions,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(emojiSuggestions: v))),
              ),
              SettingsSwitchTile(
                icon: Icons.block,
                title: 'Hide offensive words',
                subtitle: 'Never suggest them unless you type them in full',
                value: t.blockOffensiveWords,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(blockOffensiveWords: v))),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Keys',
            children: [
              SettingsSwitchTile(
                icon: Icons.bubble_chart_outlined,
                title: 'Key popups',
                subtitle: 'Enlarge a key while you press it',
                value: t.keyPopups,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(keyPopups: v))),
              ),
              SettingsSliderTile(
                icon: Icons.timer_outlined,
                title: 'Long-press delay',
                value: t.longPressDelayMs.toDouble(),
                min: 150,
                max: 1000,
                divisions: 17,
                valueLabel: (v) => '${v.round()} ms',
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(longPressDelayMs: v.round()))),
              ),
              SettingsSwitchTile(
                icon: Icons.pin_outlined,
                title: 'Number row',
                subtitle: 'Show 0 to 9 above the letters',
                value: t.numberRow,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(numberRow: v))),
              ),
              SettingsSwitchTile(
                icon: Icons.label_outline,
                title: 'Hint labels',
                subtitle: 'Small symbols on keys, such as accents',
                value: t.hintLabels,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(hintLabels: v))),
              ),
              SettingsSwitchTile(
                icon: Icons.text_format,
                title: 'Lowercase labels',
                subtitle: 'Keep key letters lowercase when shift is on',
                value: t.lowercaseLabels,
                onChanged: (v) => typing((s, t) => s.copyWith(typing: t.copyWith(lowercaseLabels: v))),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Swipe',
            children: [
              SettingsSwitchTile(
                icon: Icons.gesture,
                title: 'Swipe typing',
                subtitle: 'Glide across letters to write a word',
                value: w.enabled,
                onChanged: (v) => swipe((s, w) => s.copyWith(swipe: w.copyWith(enabled: v))),
              ),
              SettingsSwitchTile(
                icon: Icons.timeline,
                title: 'Show trail',
                value: w.showTrail,
                onChanged: w.enabled ? (v) => swipe((s, w) => s.copyWith(swipe: w.copyWith(showTrail: v))) : null,
              ),
              SettingsSliderTile(
                icon: Icons.line_weight,
                title: 'Trail width',
                value: w.trailWidth,
                min: 2,
                max: 16,
                divisions: 14,
                valueLabel: (v) => '${v.round()} dp',
                onChanged: (v) => swipe((s, w) => s.copyWith(swipe: w.copyWith(trailWidth: v))),
              ),
              SettingsSliderTile(
                icon: Icons.blur_on,
                title: 'Trail fade',
                value: w.trailFadeMs.toDouble(),
                min: 0,
                max: 2000,
                divisions: 20,
                valueLabel: (v) => '${v.round()} ms',
                onChanged: (v) => swipe((s, w) => s.copyWith(swipe: w.copyWith(trailFadeMs: v.round()))),
              ),
              SettingsSwitchTile(
                icon: Icons.visibility_outlined,
                title: 'Live preview',
                subtitle: 'Show the likely word while you glide',
                value: w.livePreview,
                onChanged: w.enabled ? (v) => swipe((s, w) => s.copyWith(swipe: w.copyWith(livePreview: v))) : null,
              ),
              SettingsSwitchTile(
                icon: Icons.space_bar,
                title: 'Space bar moves the cursor',
                subtitle: 'Drag on the space bar to move the cursor',
                value: w.spaceCursorControl,
                onChanged: w.enabled
                    ? (v) => swipe((s, w) => s.copyWith(swipe: w.copyWith(spaceCursorControl: v)))
                    : null,
              ),
              SettingsSwitchTile(
                icon: Icons.backspace_outlined,
                title: 'Swipe backspace to delete words',
                subtitle: 'Slide left on backspace to select and delete words',
                value: w.backspaceSwipeDelete,
                onChanged: w.enabled
                    ? (v) => swipe((s, w) => s.copyWith(swipe: w.copyWith(backspaceSwipeDelete: v)))
                    : null,
              ),
            ],
          ),
        ],
      );
    },
  );
}
