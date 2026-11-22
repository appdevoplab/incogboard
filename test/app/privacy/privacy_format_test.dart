// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:flutter_test/flutter_test.dart';
import 'package:kosha/src/app/privacy/privacy_format.dart';
import 'package:kosha/src/security/shortcuts_store.dart';

void main() {
  test('counts use thousands separators', () {
    expect(formatCount(0), '0');
    expect(formatCount(999), '999');
    expect(formatCount(1240), '1,240');
    expect(formatCount(1234567), '1,234,567');
  });

  test('byte sizes read in plain units', () {
    expect(formatBytes(512), '512 B');
    expect(formatBytes(14 * 1024), '14 KB');
    expect(formatBytes(2 * 1024 * 1024 + 400 * 1024), '2.4 MB');
    expect(formatBytes(40 * 1024 * 1024), '40 MB');
  });

  test('stored blobs get friendly names and never show their raw names', () {
    expect(friendlyBlobName('learned_en'), 'Learned words (English)');
    expect(friendlyBlobName('learned_xx'), 'Learned words (xx)');
    expect(friendlyBlobName('clipboard'), 'Clipboard history');
    expect(friendlyBlobName('emoji'), 'Emoji recents');
    expect(friendlyBlobName('shortcuts'), 'Personal shortcuts');
    expect(friendlyBlobName('seen_apps'), 'Apps list');
    expect(friendlyBlobName('mystery'), 'Other stored data');
  });

  test('time ago reads naturally', () {
    const now = 10000000000;
    expect(timeAgo(now - 5000, nowMillis: now), 'just now');
    expect(timeAgo(now - 60000, nowMillis: now), '1 minute ago');
    expect(timeAgo(now - 3 * 3600000, nowMillis: now), '3 hours ago');
    expect(timeAgo(now - 2 * 86400000, nowMillis: now), '2 days ago');
  });

  test('plurals agree with the count', () {
    expect(plural(1, 'shortcut'), '1 shortcut');
    expect(plural(12, 'shortcut'), '12 shortcuts');
    expect(plural(1240, 'word'), '1,240 words');
    expect(plural(1, 'blocked word'), '1 blocked word');
  });

  test('passphrase strength: short is refused, variety and length raise the rating', () {
    expect(PassphraseRules.strength('short'), PassphraseStrength.tooShort);
    expect(PassphraseRules.strength('abcdefgh'), PassphraseStrength.weak);
    expect(PassphraseRules.strength('Correct Horse 9'), PassphraseStrength.good);
    expect(PassphraseRules.strength('Correct-Horse-Battery-9!'), PassphraseStrength.strong);
    expect(PassphraseStrength.strong.fraction, 1);
    expect(PassphraseStrength.tooShort.fraction, 0);
  });

  test('every refused shortcut has a message', () {
    for (final p in ShortcutProblem.values) {
      expect(shortcutProblemText(p), isNotEmpty);
    }
    expect(shortcutProblemText(ShortcutProblem.tooManyShortcuts), contains('500'));
  });
}
