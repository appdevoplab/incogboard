// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myna/src/security/app_auth.dart';
import 'package:myna/src/security/custom_theme_files.dart';

import 'support/fakes.dart';

void main() {
  group('AppLockPolicy', () {
    final start = DateTime(2026, 11, 21, 10);

    test('never locks when app lock is off or the app was never backgrounded', () {
      expect(AppLockPolicy.shouldLock(enabled: false, timeoutSeconds: 0, backgroundedAt: start, now: start), isFalse);
      expect(AppLockPolicy.shouldLock(enabled: true, timeoutSeconds: 0, backgroundedAt: null, now: start), isFalse);
    });

    test('immediately means any return locks; a timeout needs that long in the background', () {
      expect(AppLockPolicy.shouldLock(enabled: true, timeoutSeconds: 0, backgroundedAt: start, now: start), isTrue);
      final after29 = start.add(const Duration(seconds: 29));
      final after30 = start.add(const Duration(seconds: 30));
      expect(AppLockPolicy.shouldLock(enabled: true, timeoutSeconds: 30, backgroundedAt: start, now: after29), isFalse);
      expect(AppLockPolicy.shouldLock(enabled: true, timeoutSeconds: 30, backgroundedAt: start, now: after30), isTrue);
    });

    test('the offered timeouts have readable labels', () {
      expect(AppLockPolicy.timeoutChoices, [0, 30, 60, 300]);
      expect(AppLockPolicy.timeoutLabel(0), 'Immediately');
      expect(AppLockPolicy.timeoutLabel(300), 'After 5 minutes');
    });
  });

  group('SecureScreenGuard', () {
    late MockAppHost host;

    setUp(() {
      host = MockAppHost();
      when(() => host.setSecureScreen(any())).thenAnswer((_) async {});
      SecureScreenGuard.instance = SecureScreenGuard(host);
    });

    tearDown(() => SecureScreenGuard.instance = null);

    test('stays secure while any screen holds it, and clears only when the last one leaves', () {
      final guard = SecureScreenGuard.instance;
      guard.acquire(); // learned words
      guard.acquire(); // backup on top of it
      guard.release(); // backup closed
      guard.release(); // learned words closed
      expect(guard.isSecure, isFalse);
      final calls = verify(() => host.setSecureScreen(captureAny())).captured.cast<bool>();
      expect(calls, [true, true, true, false]);
    });

    test('an extra release never goes negative', () {
      final guard = SecureScreenGuard.instance..release();
      expect(guard.isSecure, isFalse);
      verify(() => host.setSecureScreen(false)).called(1);
    });
  });

  group('CustomThemeFiles names', () {
    test('plain names with a known extension are safe', () {
      expect(CustomThemeFiles.isSafeName('ocean.json'), isTrue);
      expect(CustomThemeFiles.isSafeName('my theme 2.png'), isTrue);
      expect(CustomThemeFiles.isSafeName('photo.JPG'), isTrue);
    });

    test('paths, dot files, traversal and other extensions are not', () {
      expect(CustomThemeFiles.isSafeName('../ocean.json'), isFalse);
      expect(CustomThemeFiles.isSafeName('a/b.json'), isFalse);
      expect(CustomThemeFiles.isSafeName(r'a\b.json'), isFalse);
      expect(CustomThemeFiles.isSafeName('a..b.json'), isFalse);
      expect(CustomThemeFiles.isSafeName('.hidden.json'), isFalse);
      expect(CustomThemeFiles.isSafeName('run.exe'), isFalse);
      expect(CustomThemeFiles.isSafeName('noextension'), isFalse);
      expect(CustomThemeFiles.isSafeName(''), isFalse);
    });
  });
}
