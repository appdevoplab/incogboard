// SPDX-License-Identifier: GPL-3.0-or-later
//
// Plain-language helpers for the privacy screens: friendly names for stored blobs, byte sizes,
// counts and the backup passphrase strength. Pure Dart, so they are unit-tested directly.
import '../../core/data_sections.dart';
import '../../security/shortcuts_store.dart';

const Map<String, String> _languageNames = {
  'en': 'English',
  'es': 'Spanish',
  'fr': 'French',
  'de': 'German',
  'pt': 'Portuguese',
  'it': 'Italian',
  'id': 'Indonesian',
  'hi': 'Hindi',
  'nl': 'Dutch',
  'ru': 'Russian',
  'tr': 'Turkish',
  'ar': 'Arabic',
};

/// The language's name in English, or its code when it is not in the table.
String languageName(String code) => _languageNames[code] ?? code;

/// What a stored blob holds, for the privacy center's list. Never shows contents.
String friendlyBlobName(String name) {
  if (name == DataBlobs.learnedZhPhrases) return 'Chinese phrases';
  if (name == DataBlobs.learnedJaWords) return 'Japanese words';
  if (name.startsWith(DataBlobs.learnedPrefix)) {
    return 'Learned words (${languageName(name.substring(DataBlobs.learnedPrefix.length))})';
  }
  return switch (name) {
    DataBlobs.clipboard => 'Clipboard history',
    DataBlobs.emoji => 'Emoji recents',
    DataBlobs.shortcuts => 'Personal shortcuts',
    DataBlobs.seenApps => 'Apps list',
    _ => 'Other stored data',
  };
}

/// "1,240": thousands separators with a comma, for counts shown to the user.
String formatCount(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Bytes as "512 B", "14 KB" or "2.4 MB".
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  final mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
}

/// "3 seconds ago", "5 minutes ago", "2 days ago", given the milliseconds since the epoch.
String timeAgo(int millis, {required int nowMillis}) {
  final seconds = ((nowMillis - millis) / 1000).round();
  if (seconds < 60) return 'just now';
  final minutes = seconds ~/ 60;
  if (minutes < 60) return minutes == 1 ? '1 minute ago' : '$minutes minutes ago';
  final hours = minutes ~/ 60;
  if (hours < 24) return hours == 1 ? '1 hour ago' : '$hours hours ago';
  final days = hours ~/ 24;
  return days == 1 ? '1 day ago' : '$days days ago';
}

/// Plural helper: "1 shortcut", "12 shortcuts".
String plural(int count, String singular, [String? pluralForm]) =>
    '${formatCount(count)} ${count == 1 ? singular : (pluralForm ?? '${singular}s')}';

/// Message for a refused shortcut.
String shortcutProblemText(ShortcutProblem problem) => switch (problem) {
  ShortcutProblem.emptyTrigger => 'Type the short form you want to expand.',
  ShortcutProblem.triggerTooLong => 'The short form can be at most ${ShortcutRules.maxTriggerLength} characters.',
  ShortcutProblem.triggerCharacters => 'Use only letters, digits and apostrophes in the short form.',
  ShortcutProblem.emptyExpansion => 'Type what the short form should expand to.',
  ShortcutProblem.expansionTooLong => 'The expansion can be at most ${ShortcutRules.maxExpansionLength} characters.',
  ShortcutProblem.duplicateTrigger => 'You already have a shortcut with this short form.',
  ShortcutProblem.tooManyShortcuts => 'You can keep at most ${ShortcutRules.maxShortcuts} shortcuts.',
};

enum PassphraseStrength {
  tooShort('Use at least 8 characters'),
  weak('Weak'),
  fair('Fair'),
  good('Good'),
  strong('Strong');

  const PassphraseStrength(this.label);

  final String label;

  /// Fraction for a meter, 0 to 1.
  double get fraction => switch (this) {
    PassphraseStrength.tooShort => 0,
    PassphraseStrength.weak => 0.25,
    PassphraseStrength.fair => 0.5,
    PassphraseStrength.good => 0.75,
    PassphraseStrength.strong => 1,
  };
}

abstract final class PassphraseRules {
  static const int minLength = 8;

  /// A simple estimate from length and character variety. It only guides the user: the real
  /// protection is the 600,000-iteration key derivation.
  static PassphraseStrength strength(String passphrase) {
    final length = passphrase.runes.length;
    if (length < minLength) return PassphraseStrength.tooShort;
    final classes = [
      RegExp(r'[a-z]').hasMatch(passphrase),
      RegExp(r'[A-Z]').hasMatch(passphrase),
      RegExp(r'[0-9]').hasMatch(passphrase),
      RegExp(r'[^A-Za-z0-9]').hasMatch(passphrase) || passphrase.runes.any((r) => r > 127),
    ].where((b) => b).length;
    var score = 0;
    if (length >= 12) score++;
    if (length >= 16) score++;
    if (classes >= 3) score++;
    if (classes >= 4 || length >= 24) score++;
    return switch (score) {
      0 => PassphraseStrength.weak,
      1 => PassphraseStrength.fair,
      2 || 3 => PassphraseStrength.good,
      _ => PassphraseStrength.strong,
    };
  }
}
