// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-C. Arabic-script languages (ar, ur): their info and rules.
// The orchestrator seeded the entries; refine them as you build.
import '../contracts.dart';
import 'language_info.dart';

const List<LanguageInfo> arabicLanguages = [
  LanguageInfo(
    id: 'ar',
    englishName: 'Arabic',
    nativeName: 'العربية',
    script: 'Arab',
    hasCase: false,
    layouts: [LayoutChoice('arabic', 'Arabic', script: 'Arab')],
    currency: 'ر.س',
    domains: ['.sa', '.ae', '.eg'],
    nativeDigits: '٠١٢٣٤٥٦٧٨٩',
  ),
  LanguageInfo(
    id: 'ur',
    englishName: 'Urdu',
    nativeName: 'اردو',
    script: 'Arab',
    hasCase: false,
    layouts: [LayoutChoice('urdu_phonetic', 'Phonetic', script: 'Arab')],
    currency: 'Rs',
    domains: ['.pk', '.com.pk'],
    nativeDigits: '۰۱۲۳۴۵۶۷۸۹',
  ),
];

/// Rules for the languages above; null for any other language.
LanguageRules? arabicRules(LanguageId language) => null;
