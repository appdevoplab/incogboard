// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. Kosha's own licence texts (copied from THIRD_PARTY_NOTICES.md and the licence
// files) live in assets/notices/. They are shown on the About screen and registered with
// Flutter's LicenseRegistry, so the standard licence page lists them too.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KoshaNotice {
  const KoshaNotice(this.title, this.asset);

  final String title;
  final String asset;
}

abstract final class KoshaNotices {
  static const List<KoshaNotice> all = [
    KoshaNotice('GNU General Public Licence v3', 'assets/notices/gpl-3.0.txt'),
    KoshaNotice('Apache License 2.0', 'assets/notices/apache-2.0.txt'),
    KoshaNotice('SIL Open Font License 1.1 (Google Sans Flex)', 'assets/notices/ofl-1.1-google-sans-flex.txt'),
    KoshaNotice('Third-party code', 'assets/notices/third-party-code.txt'),
    KoshaNotice('Third-party data', 'assets/notices/third-party-data.txt'),
    KoshaNotice('Algorithm references', 'assets/notices/third-party-algorithms.txt'),
  ];

  static bool _registered = false;

  /// Adds every notice to [LicenseRegistry] once. Safe to call repeatedly.
  static void register() {
    if (_registered) return;
    _registered = true;
    for (final notice in all) {
      LicenseRegistry.addLicense(() async* {
        final text = await rootBundle.loadString(notice.asset);
        yield LicenseEntryWithLineBreaks([notice.title], text);
      });
    }
  }
}

/// Where the source code is published. Set at build time with
/// `--dart-define=KOSHA_SOURCE_URL=<url>`; empty means the About screen shows no link.
const String koshaSourceCodeUrl = String.fromEnvironment('KOSHA_SOURCE_URL');
