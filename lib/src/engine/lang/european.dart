// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-A. European languages (es, fr, de, pt-BR, pt-PT, id, ru, uk): their info and rules.
// The orchestrator seeded the entries; refine them (layouts, currency, domains) as you build.
import '../contracts.dart';
import 'language_info.dart';

const List<LanguageInfo> europeanLanguages = [
  LanguageInfo(
    id: 'es',
    englishName: 'Spanish',
    nativeName: 'Español',
    script: 'Latn',
    layouts: [LayoutChoice('qwerty_es', 'QWERTY (Ñ)', script: 'Latn')],
    currency: '€',
    domains: ['.es', '.com.mx', '.com.ar'],
  ),
  LanguageInfo(
    id: 'fr',
    englishName: 'French',
    nativeName: 'Français',
    script: 'Latn',
    layouts: [
      LayoutChoice('azerty', 'AZERTY', script: 'Latn'),
      LayoutChoice('qwerty', 'QWERTY', script: 'Latn'),
    ],
    currency: '€',
    domains: ['.fr', '.be', '.ca'],
  ),
  LanguageInfo(
    id: 'de',
    englishName: 'German',
    nativeName: 'Deutsch',
    script: 'Latn',
    layouts: [
      LayoutChoice('qwertz', 'QWERTZ', script: 'Latn'),
      LayoutChoice('qwerty', 'QWERTY', script: 'Latn'),
    ],
    currency: '€',
    domains: ['.de', '.at', '.ch'],
  ),
  LanguageInfo(
    id: 'pt-BR',
    englishName: 'Portuguese (Brazil)',
    nativeName: 'Português (Brasil)',
    spaceLabel: 'Português',
    script: 'Latn',
    layouts: [LayoutChoice('qwerty', 'QWERTY', script: 'Latn')],
    currency: r'R$',
    domains: ['.com.br', '.br'],
  ),
  LanguageInfo(
    id: 'pt-PT',
    englishName: 'Portuguese (Portugal)',
    nativeName: 'Português (Portugal)',
    spaceLabel: 'Português',
    script: 'Latn',
    layouts: [LayoutChoice('qwerty', 'QWERTY', script: 'Latn')],
    currency: '€',
    domains: ['.pt'],
  ),
  LanguageInfo(
    id: 'id',
    englishName: 'Indonesian',
    nativeName: 'Bahasa Indonesia',
    spaceLabel: 'Indonesia',
    script: 'Latn',
    layouts: [LayoutChoice('qwerty', 'QWERTY', script: 'Latn')],
    currency: 'Rp',
    domains: ['.co.id', '.id'],
  ),
  LanguageInfo(
    id: 'ru',
    englishName: 'Russian',
    nativeName: 'Русский',
    script: 'Cyrl',
    layouts: [LayoutChoice('jcuken_ru', 'ЙЦУКЕН', script: 'Cyrl')],
    currency: '₽',
    domains: ['.ru', '.рф'],
  ),
  LanguageInfo(
    id: 'uk',
    englishName: 'Ukrainian',
    nativeName: 'Українська',
    script: 'Cyrl',
    layouts: [LayoutChoice('jcuken_uk', 'ЙЦУКЕН', script: 'Cyrl')],
    currency: '₴',
    domains: ['.ua', '.com.ua'],
  ),
];

/// Rules for the languages above; null for any other language.
LanguageRules? europeanRules(LanguageId language) => null;
