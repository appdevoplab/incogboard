// SPDX-License-Identifier: GPL-3.0-or-later
//
// CONTRACT (orchestrator-owned, Wave 3): what the keyboard and the settings app know about a
// language. The entries live in per-agent files (european.dart, indic.dart, arabic.dart) and are
// merged in registry.dart.
import 'package:meta/meta.dart';

import '../contracts.dart';

/// One keyboard layout a language can use.
@immutable
class LayoutChoice {
  const LayoutChoice(this.id, this.name, {required this.script, this.transliterates = false});

  /// `assets/layouts/<id>.json`.
  final String id;

  /// Shown in the settings app, in English ("QWERTZ", "InScript", "Phonetic", "English letters").
  final String name;

  /// ISO 15924 script the keys type: 'Latn', 'Cyrl', 'Deva', 'Beng', 'Taml', 'Telu', 'Arab'.
  final String script;

  /// The keys type Latin letters that the language's transliterator turns into
  /// [LanguageInfo.script] (Indic "English letters" typing).
  final bool transliterates;
}

@immutable
class LanguageInfo {
  const LanguageInfo({
    required this.id,
    required this.englishName,
    required this.nativeName,
    required this.script,
    required this.layouts,
    this.spaceLabel,
    this.hasCase = true,
    this.currency = r'$',
    this.domains = const [],
    this.nativeDigits,
  });

  final LanguageId id;
  final String englishName;

  /// The language's own name ("Deutsch", "हिन्दी").
  final String nativeName;

  /// ISO 15924 script of the language's words (the dictionary's script).
  final String script;

  /// First = default.
  final List<LayoutChoice> layouts;

  /// Short label drawn on the space bar; defaults to [nativeName].
  final String? spaceLabel;
  final bool hasCase;

  /// Main currency symbol for the symbols page (€, ₹, ₽, ...).
  final String currency;

  /// Country domains offered first on the ".com" key ('.de', '.co.id', ...).
  final List<String> domains;

  /// Digits 0-9 in the native script ('०१२३४५६७८९'), or null when the script has none.
  final String? nativeDigits;

  bool get isRtl => script == 'Arab' || script == 'Hebr';

  LayoutChoice get defaultLayout => layouts.first;

  String get spaceBarLabel => spaceLabel ?? nativeName;

  LayoutChoice? layout(String? id) {
    for (final l in layouts) {
      if (l.id == id) return l;
    }
    return null;
  }
}
