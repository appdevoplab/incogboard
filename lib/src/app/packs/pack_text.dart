// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T. Plain words for model packs: error codes from the import, and the one-line
// description of an installed pack.
import '../../bridge/messages.g.dart';
import '../../engine/lang/registry.dart';
import '../privacy/privacy_format.dart';

/// The message for an import that failed with [code] (the codes of `AppHostApi.importPack`).
String importErrorText(String code) => switch (code) {
  'bad_signature' => 'This pack is not signed for Myna, so nothing was installed.',
  'bad_format' => 'This file is not a Myna pack. Nothing was installed.',
  'too_large' => 'This pack is too large to install on this phone.',
  'unsupported_version' => 'This pack needs a newer version of Myna.',
  'no_space' => 'There is not enough free space to install this pack.',
  _ => 'The pack could not be installed. Nothing was changed.',
};

/// A language name for a pack's language id ('pt' is the Portuguese that both Portuguese variants use).
String packLanguageName(String id) => id == 'pt' ? 'Portuguese' : languageInfo(id).englishName;

/// "English → Spanish" for a translation pack, "English, Hindi" for a voice pack.
String packLanguages(PackInfoMessage pack) {
  final names = pack.languages.map(packLanguageName);
  return pack.kind == PackKind.translation && pack.languages.length == 2 ? names.join(' → ') : names.join(', ');
}

/// "English → Spanish · 110 MB · Apache-2.0".
String packDescription(PackInfoMessage pack) =>
    '${packLanguages(pack)} · ${formatBytes(pack.sizeBytes)} · ${pack.license}';
