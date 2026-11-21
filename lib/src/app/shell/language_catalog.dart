// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. Language names for the settings app, each written in its own language.
// Only English has a dictionary today; the others are listed as "coming soon" until Wave 3.
import '../../settings/myna_settings.dart';

const String englishId = 'en';

/// Display names by language id.
const Map<String, String> languageNames = {
  'en': 'English',
  'es': 'Español',
  'fr': 'Français',
  'de': 'Deutsch',
  'pt': 'Português',
  'id': 'Bahasa Indonesia',
  'ru': 'Русский',
  'uk': 'Українська',
  'hi': 'हिन्दी',
  'mr': 'मराठी',
  'bn': 'বাংলা',
  'ta': 'தமிழ்',
  'te': 'తెలుగు',
  'ar': 'العربية',
  'ur': 'اردو',
  'zh': '中文',
  'ja': '日本語',
};

/// Languages with a dictionary in this build.
const List<String> availableLanguageIds = [englishId];

/// Planned languages, shown as "coming soon".
List<String> get plannedLanguageIds => [
  for (final id in languageNames.keys)
    if (!availableLanguageIds.contains(id)) id,
];

String languageLabel(String id) => languageNames[id] ?? id;

/// Layout names by layout id. Only QWERTY exists today.
const Map<String, String> layoutNames = {'qwerty': 'QWERTY'};

String layoutLabel(String id) => layoutNames[id] ?? id;

/// The layout for [language] (QWERTY unless the settings say otherwise).
String layoutFor(LanguageSettings languages, String language) => languages.layouts[language] ?? 'qwerty';
