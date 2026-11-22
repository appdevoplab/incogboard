// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kosha';

  @override
  String get homeTagline => 'Private typing, on this phone';

  @override
  String get homeOfflinePromise =>
      'Kosha works offline and sends nothing anywhere.';
}
