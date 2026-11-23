// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T. Plain words for model packs: error codes from the import, and the one-line
// description of an installed pack.
import '../../bridge/messages.g.dart';
import '../../engine/lang/registry.dart';
import '../privacy/privacy_format.dart';
import 'package:kosha/src/app/l10n.dart';

/// The message for an import that failed with [code] (the codes of `AppHostApi.importPack`).
String importErrorText(String code) => switch (code) {
  'bad_signature' => context.l10n.packErrorBadSignature,
  'bad_format' => context.l10n.packErrorBadFormat,
  'too_large' => context.l10n.packErrorTooLarge,
  'unsupported_version' => context.l10n.packErrorVersion,
  'no_space' => context.l10n.packErrorNoSpace,
  _ => context.l10n.packErrorGeneric,
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
