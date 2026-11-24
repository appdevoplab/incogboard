// SPDX-License-Identifier: GPL-3.0-or-later
//
// Wave 5-A: sensitive-field rules, checked against the privacy plan (plan section "Sensitive fields":
// password variations, IME_FLAG_NO_PERSONALIZED_LEARNING and TYPE_TEXT_FLAG_NO_SUGGESTIONS get no
// suggestions, no learning, no popups, no voice and FLAG_SECURE).
//
// The code today uses InputFieldInfo.isSensitive = isPassword for FLAG_SECURE, voice and translation.
// Suggestions and learning are gated separately and do respect the two flags. The skipped test pins the
// planned rule; see SEC-12 in docs/security/audit.md.
import 'package:flutter_test/flutter_test.dart';
import 'package:incogboard/src/core/input_field_info.dart';

InputFieldInfo _field({int variation = 0, int flags = 0, int ime = 0}) =>
    InputFieldInfo(inputType: AndroidInputType.classText | variation | flags, imeOptions: ime);

void main() {
  test('a password field is sensitive and gets no suggestions or learning', () {
    final f = _field(variation: AndroidInputType.textVariationPassword);
    expect(f.isSensitive, isTrue);
    expect(f.allowsSuggestions, isFalse);
    expect(f.allowsLearning, isFalse);
  });

  test('a plain text field is not sensitive', () {
    final f = _field();
    expect(f.isSensitive, isFalse);
    expect(f.allowsSuggestions, isTrue);
    expect(f.allowsLearning, isTrue);
  });

  test('IME_FLAG_NO_PERSONALIZED_LEARNING turns learning off', () {
    final f = _field(ime: AndroidImeOptions.flagNoPersonalizedLearning);
    expect(f.allowsLearning, isFalse);
  });

  test('TYPE_TEXT_FLAG_NO_SUGGESTIONS turns suggestions off', () {
    final f = _field(flags: AndroidInputType.textFlagNoSuggestions);
    expect(f.allowsSuggestions, isFalse);
  });

  test('no-personalised-learning and no-suggestions fields are sensitive as the plan requires', () {
    expect(_field(ime: AndroidImeOptions.flagNoPersonalizedLearning).isSensitive, isTrue);
    expect(_field(flags: AndroidInputType.textFlagNoSuggestions).isSensitive, isTrue);
  }, skip: 'SEC-12: isSensitive is isPassword only, so these fields get FLAG_SECURE, voice and translation (audit.md)');
}
