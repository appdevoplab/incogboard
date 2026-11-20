// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:meta/meta.dart';

import '../json_util.dart';

@immutable
class LanguageSettings {
  const LanguageSettings({
    this.enabled = const ['en'],
    this.active = 'en',
    this.layouts = const {'en': 'qwerty'},
    this.multilingual = true,
  });

  factory LanguageSettings.fromJson(Json j) {
    final enabled = jStrings(j, 'enabled', const ['en']);
    final safeEnabled = enabled.isEmpty ? const ['en'] : enabled;
    final active = jString(j, 'active', safeEnabled.first);
    return LanguageSettings(
      enabled: safeEnabled,
      active: safeEnabled.contains(active) ? active : safeEnabled.first,
      layouts: jStringMap(j, 'layouts', const {'en': 'qwerty'}),
      multilingual: jBool(j, 'multilingual', true),
    );
  }

  /// Enabled languages in the user's order.
  final List<String> enabled;

  /// Language whose layout is showing.
  final String active;

  /// Chosen layout id per language (e.g. de -> qwertz).
  final Map<String, String> layouts;

  /// Blend up to 3 enabled languages that share the active layout's script.
  final bool multilingual;

  Json toJson() => {'enabled': enabled, 'active': active, 'layouts': layouts, 'multilingual': multilingual};

  LanguageSettings copyWith({
    List<String>? enabled,
    String? active,
    Map<String, String>? layouts,
    bool? multilingual,
  }) => LanguageSettings(
    enabled: enabled ?? this.enabled,
    active: active ?? this.active,
    layouts: layouts ?? this.layouts,
    multilingual: multilingual ?? this.multilingual,
  );
}
