// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T. Which Kosha languages translate, and how a pair maps to a translation pack.
// Every pack is English with one language, in both directions (12 directions, 6 languages).
import '../../bridge/messages.g.dart';

/// The Kosha languages that have a pack with English. Both Portuguese variants share the `pt` models.
const List<String> translatableLanguages = ['en', 'es', 'fr', 'de', 'pt-BR', 'pt-PT', 'hi', 'ru'];

const Set<String> _packLanguages = {'es', 'fr', 'de', 'pt', 'hi', 'ru'};

/// The pack language for a Kosha language id ('pt-BR' and 'pt-PT' are 'pt').
String packLanguage(String id) => (id == 'pt-BR' || id == 'pt-PT') ? 'pt' : id;

/// True when a pair has a pack: English with one of the supported languages, in either direction.
bool isSupportedPair(String from, String to) {
  if (from == to) return false;
  if (from == 'en') return _packLanguages.contains(packLanguage(to));
  if (to == 'en') return _packLanguages.contains(packLanguage(from));
  return false;
}

/// Pair key of the installed translation packs, as `from>to` with pack language ids.
String pairKey(String from, String to) => '${packLanguage(from)}>${packLanguage(to)}';

/// The pack keys of the installed translation packs.
Set<String> installedPairKeys(Iterable<PackInfoMessage> packs) => {
  for (final p in packs)
    if (p.kind == PackKind.translation && p.languages.length == 2) pairKey(p.languages[0], p.languages[1]),
};

/// Short code for pair labels ('EN', 'PT-BR').
String shortCode(String id) => id.toUpperCase();
