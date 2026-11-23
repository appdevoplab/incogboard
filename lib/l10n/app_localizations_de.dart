// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Kosha';

  @override
  String get homeTagline => 'Private Eingabe, auf diesem Gerät';

  @override
  String get homeOfflinePromise =>
      'Kosha funktioniert offline und sendet nichts irgendwohin.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get save => 'Speichern';

  @override
  String get useAction => 'Verwenden';

  @override
  String get off => 'Aus';

  @override
  String get left => 'Links';

  @override
  String get right => 'Rechts';

  @override
  String get settingsLanguages => 'Sprachen';

  @override
  String get settingsTyping => 'Tippen';

  @override
  String get settingsFeel => 'Gefühl';

  @override
  String get settingsThemes => 'Designs';

  @override
  String get settingsPanels => 'Bereiche';

  @override
  String get settingsVoice => 'Sprache';

  @override
  String get settingsTranslation => 'Übersetzung';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsAbout => 'Info';

  @override
  String get settingsModelPacks => 'Modellpakete';

  @override
  String get homeSetupTurnOn =>
      'Aktiviere Kosha in der Tastaturliste von Android.';

  @override
  String get homeSetupChoose => 'Wähle Kosha als Tastatur zum Schreiben aus.';

  @override
  String get homeFinishSetup => 'Kosha einrichten abschließen';

  @override
  String get homeTypingSubtitle =>
      'Korrekturen, Vorschläge, Tasten und Wischen';

  @override
  String get homeFeelSubtitle => 'Haptik, Töne, Höhe und Einhandmodus';

  @override
  String get homePanelsSubtitle => 'Zwischenablage und Emoji';

  @override
  String get homeVoiceSubtitle => 'Sprich zum Schreiben, auf diesem Gerät';

  @override
  String get homeTranslationSubtitle => 'Übersetzt beim Tippen, offline';

  @override
  String get homePrivacySubtitle =>
      'Was gespeichert wird, Inkognito, App-Sperre und Sicherung';

  @override
  String get homeAboutSubtitle => 'Version, Lizenzen und Quellcode';

  @override
  String get aboutTitle => 'Info';

  @override
  String aboutVersion(String versionCode, String versionName) {
    return 'Version $versionName ($versionCode)';
  }

  @override
  String aboutVersionDebug(String versionCode, String versionName) {
    return 'Version $versionName ($versionCode) · Debug-Build';
  }

  @override
  String get aboutReadingVersion => 'Version wird gelesen…';

  @override
  String get aboutPrivacy => 'Datenschutz';

  @override
  String get aboutNoInternet => 'Kosha kann das Internet nicht nutzen';

  @override
  String get aboutNoInternetBody =>
      'Veröffentlichte Versionen haben keine Internetberechtigung, daher verlässt nichts, was du tippst, dieses Gerät.';

  @override
  String get aboutLicence => 'Lizenz';

  @override
  String get aboutGplTitle => 'GNU General Public License v3 oder neuer';

  @override
  String get aboutGplBody =>
      'Kosha ist freie Software. Du darfst sie unter der GPL untersuchen, ändern und weitergeben.';

  @override
  String get aboutSourceCode => 'Quellcode';

  @override
  String get aboutSourceBody =>
      'Kosha steht unter GPL-3.0-or-later. Der Quellcode ist auf der Projektseite verfügbar.';

  @override
  String get aboutLicences => 'Lizenzen';

  @override
  String get aboutOpenSource => 'Open-Source-Lizenzen';

  @override
  String get aboutOpenSourceBody =>
      'Flutter, material_ui und jedes Paket, das Kosha verwendet';

  @override
  String get aboutTextLoadFailed => 'Dieser Text konnte nicht geladen werden.';

  @override
  String get languagesEnabledHeader =>
      'Aktiviert, die erste ist die Standardsprache';

  @override
  String get languagesActive => 'Aktive Sprache';

  @override
  String get languagesAdd => 'Sprache hinzufügen';

  @override
  String get languagesAllEnabled => 'Alle Sprachen sind aktiviert';

  @override
  String get languagesAllEnabledBody =>
      'Entferne eine oben, um Platz zu schaffen.';

  @override
  String get languagesMultilingual => 'Mehrsprachiges Tippen';

  @override
  String get languagesMultilingualBody =>
      'Schlägt Wörter aus bis zu drei aktivierten Sprachen mit derselben Schrift vor. Ein Wort, das eine davon kennt, wird nie automatisch korrigiert.';

  @override
  String get languagesNativeDigits => 'Einheimische Ziffern';

  @override
  String get languagesNativeDigitsBody =>
      'Schreibt Ziffern in der Schrift der aktiven Sprache, sofern sie welche hat (०१२, ٠١٢).';

  @override
  String get languagesOptions => 'Sprachoptionen';

  @override
  String get languagesZhSubtitle =>
      'Pinyin, traditionelle Schriftzeichen und Wörterbuchpakete';

  @override
  String get languagesJaSubtitle =>
      'Fächer-Eingabe, Umwandlung und Wörterbuchpakete';

  @override
  String languagesReorderLabel(String language) {
    return 'Zum Umsortieren von $language ziehen';
  }

  @override
  String languageDefaultLabel(String language) {
    return '$language, Standard';
  }

  @override
  String languageLayoutTooltip(String language) {
    return 'Layout für $language';
  }

  @override
  String languageRemoveTooltip(String language) {
    return '$language entfernen';
  }

  @override
  String get feelHaptics => 'Haptik';

  @override
  String get feelHapticFeedback => 'Haptisches Feedback';

  @override
  String get feelHapticFeedbackBody =>
      'Eine kurze Vibration bei jeder Taste, abhängig von der Systemeinstellung';

  @override
  String get feelHapticStrength => 'Haptik-Stärke';

  @override
  String get feelSounds => 'Töne';

  @override
  String get feelKeySounds => 'Tastentöne';

  @override
  String get feelKeySoundsBody =>
      'Klicks für Tasten, Leerzeichen, Löschen und Eingabe';

  @override
  String get feelUseSystemVolume => 'Systemlautstärke verwenden';

  @override
  String get feelKeySoundVolume => 'Lautstärke der Tastentöne';

  @override
  String get feelHeight => 'Höhe';

  @override
  String get feelPortraitHeight => 'Höhe im Hochformat';

  @override
  String get feelLandscapeHeight => 'Höhe im Querformat';

  @override
  String get feelOneHandedFloating => 'Einhand und schwebend';

  @override
  String get feelOneHandedSide => 'Seite für Einhandmodus';

  @override
  String get feelFloatingKeyboard => 'Schwebende Tastatur';

  @override
  String get feelFloatingBody => 'Auf dem Bildschirm beliebig verschiebbar';

  @override
  String get panelsClipboard => 'Zwischenablage';

  @override
  String get panelsClipboardHistory => 'Zwischenablage-Verlauf';

  @override
  String get panelsClipboardHistoryBody =>
      'Speichert, was du kopierst, verschlüsselt auf diesem Gerät';

  @override
  String get panelsRecentChip => 'Chip für letzte Kopie';

  @override
  String get panelsRecentChipBody =>
      'Bietet deine letzte Kopie eine Minute lang in der Vorschlagsleiste an';

  @override
  String get panelsKeepUnpinned => 'Nicht angeheftete Kopien behalten für';

  @override
  String get panelsClipsToKeep => 'Zu behaltende Clips';

  @override
  String get panelsEmoji => 'Emoji';

  @override
  String get emojiSuggestions => 'Emoji-Vorschläge';

  @override
  String get emojiSuggestionsPanelBody =>
      'Bietet bei manchen Wörtern ein Emoji in der Vorschlagsleiste an';

  @override
  String get panelsPasswordsNeverSaved => 'Passwörter werden nie gespeichert';

  @override
  String get panelsSensitiveBody =>
      'Kopien, die Android als vertraulich markiert, werden nie behalten.';

  @override
  String get typingCorrections => 'Korrekturen';

  @override
  String get typingAutocorrect => 'Automatische Korrektur';

  @override
  String get typingAutocorrectBody =>
      'Korrigiert wahrscheinliche Tippfehler, wenn du ein Wort beendest';

  @override
  String get typingAutoCapitalise => 'Automatische Großschreibung';

  @override
  String get typingAutoCapitaliseBody => 'Großbuchstaben am Satzanfang';

  @override
  String get typingDoubleSpace => 'Doppelleerzeichen für Punkt';

  @override
  String get typingDoubleSpaceBody => 'Zweimal Leertaste schreibt „. “';

  @override
  String get typingSmartPunctuation => 'Intelligente Interpunktion';

  @override
  String get typingSmartPunctuationBody =>
      'Leerzeichen um Satzzeichen bereinigen und lokale Anführungszeichen verwenden';

  @override
  String get typingSuggestions => 'Vorschläge';

  @override
  String get typingSuggestionsBody => 'Zeigt Wörter in der Vorschlagsleiste an';

  @override
  String get typingNextWord => 'Nächstes-Wort-Vorhersage';

  @override
  String get typingNextWordBody => 'Schlägt das Wort vor, das oft folgt';

  @override
  String get typingEmojiBody => 'Bietet bei manchen Wörtern ein Emoji an';

  @override
  String get typingHideOffensive => 'Anstößige Wörter ausblenden';

  @override
  String get typingHideOffensiveBody =>
      'Nie vorschlagen, außer du tippst sie vollständig';

  @override
  String get typingKeys => 'Tasten';

  @override
  String get typingKeyPopups => 'Tastenpopups';

  @override
  String get typingKeyPopupsBody =>
      'Vergrößert eine Taste, während du sie drückst';

  @override
  String get typingLongPressDelay => 'Verzögerung für langes Drücken';

  @override
  String get typingNumberRow => 'Zahlenreihe';

  @override
  String get typingNumberRowBody => 'Zeigt 0 bis 9 über den Buchstaben';

  @override
  String get typingHintLabels => 'Hinweisbeschriftungen';

  @override
  String get typingHintLabelsBody =>
      'Kleine Zeichen auf den Tasten, zum Beispiel Akzente';

  @override
  String get typingLowercaseLabels => 'Kleinbuchstaben-Beschriftung';

  @override
  String get typingLowercaseLabelsBody =>
      'Tastenbuchstaben bleiben klein, wenn Umschalt aktiv ist';

  @override
  String get typingSwipe => 'Wischen';

  @override
  String get typingSwipeTyping => 'Wischeingabe';

  @override
  String get typingSwipeTypingBody =>
      'Über Buchstaben gleiten, um ein Wort zu schreiben';

  @override
  String get typingShowTrail => 'Spur anzeigen';

  @override
  String get typingTrailWidth => 'Spurbreite';

  @override
  String get typingTrailFade => 'Spur-Ausblendung';

  @override
  String get typingLivePreview => 'Live-Vorschau';

  @override
  String get typingLivePreviewBody =>
      'Zeigt das wahrscheinliche Wort beim Gleiten an';

  @override
  String get typingSpaceMovesCursor => 'Leertaste bewegt den Cursor';

  @override
  String get typingSpaceMovesCursorBody =>
      'Auf der Leertaste ziehen, um den Cursor zu bewegen';

  @override
  String get typingSwipeBackspace =>
      'Auf Löschen wischen, um Wörter zu löschen';

  @override
  String get typingSwipeBackspaceBody =>
      'Auf Löschen nach links wischen, um Wörter auszuwählen und zu löschen';

  @override
  String get voiceTyping => 'Spracheingabe';

  @override
  String get voiceTypingBody =>
      'Sprich zum Schreiben. Die Erkennung läuft auf diesem Gerät.';

  @override
  String get voiceRecognition => 'Erkennung';

  @override
  String get voiceDetectLanguage => 'Sprache automatisch erkennen';

  @override
  String get voiceDetectLanguageBody =>
      'Whisper erkennt, welche Sprache du sprichst.';

  @override
  String get voiceModelPacksBody =>
      'Sprach- und Übersetzungspakete installieren oder entfernen';

  @override
  String get voiceAudioStays =>
      'Audio bleibt auf diesem Gerät und wird nie gespeichert.';

  @override
  String get voicePackAutomatic => 'Automatisch';

  @override
  String get voicePackAutomaticSelected => 'Automatisch (ausgewählt)';

  @override
  String get voicePack => 'Sprachpaket';

  @override
  String get voiceNoPack =>
      'Kein Sprachpaket installiert. Installiere eines unter Modellpakete.';

  @override
  String get voiceLooking => 'Installierte Pakete werden gesucht';

  @override
  String voicePackItem(String name, String size) {
    return '$name · $size';
  }

  @override
  String voicePackItemSelected(String name, String size) {
    return '$name · $size (ausgewählt)';
  }

  @override
  String megabytes(num count) {
    return '$count MB';
  }

  @override
  String milliseconds(num count) {
    return '$count ms';
  }

  @override
  String dpValue(num count) {
    return '$count dp';
  }

  @override
  String get packsOpenFailed => 'Kosha konnte die Dateiauswahl nicht öffnen.';

  @override
  String packsInstalled(String name) {
    return '$name installiert.';
  }

  @override
  String packsDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get packsDeleteBody =>
      'Die Dateien werden von diesem Telefon entfernt. Du kannst das Paket später aus seiner Datei wieder importieren.';

  @override
  String packsDeleted(String name) {
    return '$name gelöscht.';
  }

  @override
  String packsDeleteFailed(String name) {
    return 'Kosha konnte $name nicht löschen. Versuche es erneut.';
  }

  @override
  String get packsIntro =>
      'Pakete werden vor der Installation geprüft. Sie enthalten nur Daten, niemals Code.';

  @override
  String get packsImport => 'Importieren';

  @override
  String get packsImportTitle => 'Paketdatei importieren';

  @override
  String get packsChecking => 'Wird geprüft und installiert…';

  @override
  String get packsImportBody =>
      'Eine .koshapack-Datei, zum Beispiel aus Downloads';

  @override
  String get packsNoVoice => 'Keine Sprachpakete installiert';

  @override
  String get packsNoVoiceBody => 'Spracheingabe benötigt ein Sprachpaket.';

  @override
  String get packsNoTranslation => 'Keine Übersetzungspakete installiert';

  @override
  String get packsNoTranslationBody =>
      'Übersetzung benötigt ein Paket pro Richtung.';

  @override
  String get packsDictionaries => 'Wörterbücher';

  @override
  String get packsNoDictionary => 'Keine Wörterbuchpakete installiert';

  @override
  String get packsNoDictionaryBody =>
      'Chinesisches und japanisches Tippen benötigt ein Wörterbuchpaket.';

  @override
  String get packsNothingStored => 'Noch nichts gespeichert.';

  @override
  String packsInstalledUse(String size) {
    return 'Installierte Pakete belegen $size auf diesem Gerät.';
  }

  @override
  String get packErrorBadSignature =>
      'Dieses Paket ist nicht für Kosha signiert, daher wurde nichts installiert.';

  @override
  String get packErrorBadFormat =>
      'Diese Datei ist kein Kosha-Paket. Es wurde nichts installiert.';

  @override
  String get packErrorTooLarge => 'Dieses Paket ist zu groß für dieses Gerät.';

  @override
  String get packErrorVersion =>
      'Dieses Paket benötigt eine neuere Version von Kosha.';

  @override
  String get packErrorNoSpace =>
      'Es ist nicht genug freier Speicher für dieses Paket vorhanden.';

  @override
  String get packErrorGeneric =>
      'Das Paket konnte nicht installiert werden. Es wurde nichts geändert.';

  @override
  String get translateDefaultPair => 'Standard-Sprachpaar';

  @override
  String translatePairName(String from, String to) {
    return '$from → $to';
  }

  @override
  String get translateOffline => 'Offline-Übersetzung';

  @override
  String get translateOfflineBody =>
      'Übersetzt beim Tippen auf der Tastatur und markierten Text in jeder App.';

  @override
  String get translateDefaultPairTile => 'Standardpaar';

  @override
  String get translatePackInstalled => 'Paket installiert';

  @override
  String get translatePackNotInstalled =>
      'Paket nicht installiert. Hole es unter Modellpakete.';

  @override
  String get translateInstalled => 'Installierte Richtungen';

  @override
  String get translateInstalledBody =>
      'Jede Richtung ist ein Paket, zum Beispiel Englisch → Spanisch.';

  @override
  String translatePackMeta(String license, String size) {
    return '$size · $license';
  }

  @override
  String get translateModelPacksBody =>
      'Übersetzungspakete installieren oder löschen';

  @override
  String get translateRunsOnPhone =>
      'Die Übersetzung läuft auf diesem Gerät. Nichts, was du übersetzt, wird gespeichert.';

  @override
  String get privacyUnlockReason =>
      'Entsperre Kosha, um deine Einstellungen und Daten zu sehen';

  @override
  String get privacyLockUnavailable =>
      'Die Gerätesperre ist gerade nicht verfügbar. Versuche es gleich noch einmal.';

  @override
  String get privacyLockedTitle => 'Kosha ist gesperrt';

  @override
  String get privacyLockedBody =>
      'Entsperre mit deinem Fingerabdruck oder der Geräte-PIN, um fortzufahren.';

  @override
  String get privacyUnlock => 'Entsperren';

  @override
  String backupSaved(String size) {
    return 'Backup gespeichert ($size). Bewahre deine Passphrase gut auf.';
  }

  @override
  String get backupUnlockRetrySaved =>
      'Entsperre das Gerät und versuche es erneut. Es wurde nichts gespeichert.';

  @override
  String get backupSaveFailed =>
      'Das Backup konnte nicht gespeichert werden. Es wurde nichts geändert.';

  @override
  String get backupWrongPassphrase =>
      'Falsche Passphrase oder beschädigte Datei. Es wurde nichts geändert.';

  @override
  String get backupInvalidFile =>
      'Diese Datei ist kein gültiges Kosha-Backup. Es wurde nichts geändert.';

  @override
  String get backupTooLarge => 'Diese Datei ist zu groß für ein Kosha-Backup.';

  @override
  String get backupNewerVersion =>
      'Dieses Backup wurde mit einer neueren Kosha-Version erstellt. Aktualisiere Kosha, um es wiederherzustellen.';

  @override
  String get backupBusy =>
      'Schließe zuerst das andere Dateifenster und versuche es erneut.';

  @override
  String get backupOpenFailed =>
      'Das Backup konnte nicht geöffnet werden. Es wurde nichts geändert.';

  @override
  String get backupEmpty => 'Dieses Backup ist leer.';

  @override
  String get backupRestoreTitle => 'Backup wiederherstellen';

  @override
  String backupMadeBy(String date, String version) {
    return 'Erstellt am $date mit Kosha $version.';
  }

  @override
  String get backupMerge => 'Zusammenführen';

  @override
  String get backupMergeBody =>
      'Behält, was auf diesem Gerät ist, und fügt hinzu, was im Backup ist.';

  @override
  String get backupReplace => 'Ersetzen';

  @override
  String get backupReplaceBody =>
      'Macht die gewählten Bereiche wie im Backup. Vorhandene Daten werden vorher gelöscht.';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get backupReplaceTitle => 'Daten auf diesem Gerät ersetzen?';

  @override
  String get backupReplaceConfirm =>
      'Die gewählten Bereiche auf diesem Gerät werden gelöscht und ersetzt. Das kann nicht rückgängig gemacht werden.';

  @override
  String get backupUnlockRetryChanged =>
      'Entsperre das Gerät und versuche es erneut. Es wurde nichts geändert.';

  @override
  String get backupRestoreFailed =>
      'Kosha konnte die Wiederherstellung nicht abschließen. Einige Daten wurden möglicherweise nicht geschrieben.';

  @override
  String get restoreNothingNew => 'Nichts Neues wiederhergestellt.';

  @override
  String restoreSummary(String items) {
    return 'Wiederhergestellt: $items.';
  }

  @override
  String restoreSummarySkipped(String added, String skipped) {
    return '$added Übersprungen: $skipped.';
  }

  @override
  String restoreLearnedFor(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sprachen',
      one: '1 Sprache',
    );
    return 'gelernte Wörter für $_temp0';
  }

  @override
  String countFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien',
      one: '1 Datei',
    );
    return '$_temp0';
  }

  @override
  String countWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wörter',
      one: '1 Wort',
    );
    return '$_temp0';
  }

  @override
  String countLanguages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sprachen',
      one: '1 Sprache',
    );
    return '$_temp0';
  }

  @override
  String countShortcuts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kürzel',
      one: '1 Kürzel',
    );
    return '$_temp0';
  }

  @override
  String countClipboardItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zwischenablage-Einträge',
      one: '1 Zwischenablage-Eintrag',
    );
    return '$_temp0';
  }

  @override
  String countThemeFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Designdateien',
      one: '1 Designdatei',
    );
    return '$_temp0';
  }

  @override
  String countPinnedItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count angeheftete Elemente',
      one: '1 angeheftetes Element',
    );
    return '$_temp0';
  }

  @override
  String countPacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Pakete',
      one: '1 Paket',
    );
    return '$_temp0';
  }

  @override
  String countBlockedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gesperrte Wörter',
      one: '1 gesperrtes Wort',
    );
    return '$_temp0';
  }

  @override
  String countTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal',
      one: '1 Mal',
    );
    return '$_temp0';
  }

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Minuten',
      one: 'vor 1 Minute',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Stunden',
      one: 'vor 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get timeJustNow => 'gerade eben';

  @override
  String get languagePortuguese => 'Portugiesisch';

  @override
  String packMeta(String languages, String license, String size) {
    return '$languages · $size · $license';
  }

  @override
  String privacyLearnedWordsTitle(String language) {
    return 'Gelernte Wörter ($language)';
  }

  @override
  String privacyClearLanguageTitle(String language) {
    return '$language-Wörter löschen?';
  }

  @override
  String get privacyClearLanguageBody =>
      'Dadurch werden alle in dieser Sprache gelernten Wörter und die gesperrten Wörter gelöscht. Das kann nicht rückgängig gemacht werden.';

  @override
  String get privacyClear => 'Leeren';

  @override
  String get privacySaveFailed =>
      'Die Änderung konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get privacyCouldNotReadWords =>
      'Kosha konnte diese Wörter nicht lesen.';

  @override
  String get privacyCannotReadWordsNow =>
      'Kosha kann diese Wörter gerade nicht lesen. Entsperre das Gerät und versuche es erneut.';

  @override
  String get privacyNoWordsLanguage =>
      'In dieser Sprache wurden noch keine Wörter gelernt. Kosha lernt ein Wort, nachdem du es ein paar Mal getippt hast.';

  @override
  String privacyBlockedWordsTooltip(num count) {
    return 'Gesperrte Wörter ($count)';
  }

  @override
  String get privacySortTooltip => 'Sortieren';

  @override
  String get privacySortMostUsed => 'Am häufigsten zuerst';

  @override
  String get privacySortAZ => 'A bis Z';

  @override
  String get privacyMoreTooltip => 'Mehr';

  @override
  String get privacyClearThisLanguage => 'Diese Sprache leeren';

  @override
  String get privacySearchWords => 'Wörter suchen';

  @override
  String privacyWordsSummary(String blocked, String words) {
    return '$words · $blocked';
  }

  @override
  String get privacyNoWordsYet => 'Noch keine Wörter.';

  @override
  String privacyNoWordsMatch(String query) {
    return 'Keine Wörter passen zu „$query“.';
  }

  @override
  String get privacyNeverSuggested => 'Nie vorgeschlagen';

  @override
  String get privacyBlockedExplain =>
      'Kosha schlägt diese Wörter nicht vor und korrigiert nicht zu ihnen.';

  @override
  String get privacyNoBlockedWords => 'Keine gesperrten Wörter.';

  @override
  String get privacyAllowAgain => 'Wieder erlauben';

  @override
  String privacyWordLastUsed(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal getippt',
      one: 'Einmal getippt',
    );
    return '$_temp0 · zuletzt $when';
  }

  @override
  String privacyWordNotYetSuggested(String when) {
    return 'Bisher einmal getippt, noch nicht vorgeschlagen · zuletzt $when';
  }

  @override
  String get privacyToday => 'heute';

  @override
  String get privacyYesterday => 'gestern';

  @override
  String privacyActionsFor(String word) {
    return 'Aktionen für $word';
  }

  @override
  String get privacyForgetWord => 'Dieses Wort vergessen';

  @override
  String get privacyNeverSuggestWord => 'Dieses Wort nie vorschlagen';

  @override
  String get privacyTryAgain => 'Erneut versuchen';

  @override
  String get privacyCenterLoadFailed =>
      'Kosha konnte seine Datenschutzdaten nicht lesen. Versuche es später erneut.';

  @override
  String get privacyDevBuildNetwork =>
      'Dieser Build fordert Internetzugriff an. Kosha sollte das nie tun. Bitte melde es.';

  @override
  String get privacyNoInternetPermission =>
      'Kosha hat keine Internetberechtigung. Es kann nichts senden.';

  @override
  String get privacyDevBuildNote =>
      'Dies ist ein Entwicklungs-Build. Seine Netzwerkberechtigung gilt nur für Entwicklungswerkzeuge.';

  @override
  String get privacyDevBuildShort =>
      'Entwicklungs-Build. Kosha hat weiterhin keine Internetberechtigung.';

  @override
  String privacyStorageSize(String size, String when) {
    return '$size · geändert $when';
  }

  @override
  String get privacyCustomThemes => 'Eigene Designs';

  @override
  String get privacyNoPacks =>
      'Keine installiert. Sprach- und Übersetzungspakete erscheinen hier.';

  @override
  String privacyPacksSize(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Pakete',
      one: '1 Paket',
    );
    return '$_temp0 · $size';
  }

  @override
  String get privacyWhatKoshaStores => 'Was Kosha speichert';

  @override
  String get privacyShowsSizesOnly =>
      'Kosha zeigt hier nur Größen, nie den Inhalt. Die Größen enthalten die letzte gespeicherte Kopie, die deine Daten schützt, wenn ein Speichern unterbrochen wird.';

  @override
  String get privacyTypingPrivacy => 'Datenschutz beim Tippen';

  @override
  String get privacyLearnNewWords => 'Neue Wörter lernen';

  @override
  String get privacyLearnNewWordsBody =>
      'Lernt Wörter und Wendungen aus deinen Eingaben. Nie in Passwortfeldern oder im Inkognito-Modus.';

  @override
  String get privacyIncognito => 'Inkognito';

  @override
  String get privacyIncognitoBody =>
      'Lernt und merkt sich nichts, solange es an ist. Inkognito-Tabs im Browser schalten es selbst ein.';

  @override
  String get privacyHideScreenshots => 'Vor Screenshots verbergen';

  @override
  String get privacyHideScreenshotsBody =>
      'Verhindert Screenshots und Bildschirmaufnahmen der Tastatur in jeder App. Passwortfelder sind immer verborgen.';

  @override
  String get privacyAutoOffApps => 'In diesen Apps automatisch ausgeschaltet';

  @override
  String get privacyAutoOffAppsBody =>
      'Kosha speichert App-Namen nur, um diese Liste zu füllen. Sie sind verschlüsselt, werden im Inkognito-Modus nie gespeichert, und du kannst sie unten löschen.';

  @override
  String get privacyNoAppsYet => 'Noch keine Apps';

  @override
  String get privacyNoAppsYetBody =>
      'Apps, in denen du tippst, erscheinen hier.';

  @override
  String get privacyAlwaysIncognitoApps => 'Apps immer im Inkognito-Modus';

  @override
  String get privacyPersonalShortcuts => 'Persönliche Kürzel';

  @override
  String get privacyOfferShortcuts => 'Kürzel anbieten';

  @override
  String get privacyOfferShortcutsBody =>
      'Zeigt deine Kurzformen, wie „omw“, als ersten Vorschlag an.';

  @override
  String get privacyEditShortcuts => 'Kürzel bearbeiten';

  @override
  String get privacyNoShortcutsYet => 'Noch keine';

  @override
  String get privacyLearnedAndClipboard => 'Gelernte Wörter und Zwischenablage';

  @override
  String get privacyNoWordsLearnedYet => 'Noch keine Wörter gelernt';

  @override
  String get privacyWordsLearnedBody =>
      'Wörter, die du tippst, werden hier gelernt, sobald Kosha sie ein paar Mal gesehen hat.';

  @override
  String privacyReviewWords(String when) {
    return 'Wörter prüfen, entfernen oder sperren · $when';
  }

  @override
  String get privacyClipboardHistoryEmpty =>
      'Der Verlauf ist leer. Ändere die Zwischenablage-Einstellungen unter Bereiche.';

  @override
  String privacyClipboardInHistory(String size) {
    return '$size im Verlauf. Ändere die Zwischenablage-Einstellungen unter Bereiche.';
  }

  @override
  String get privacyAppLock => 'App-Sperre';

  @override
  String get privacyLockKosha => 'Kosha sperren';

  @override
  String get privacyLockKoshaBody =>
      'Fragt beim Öffnen der App oder nach dem Hintergrundbetrieb nach Fingerabdruck oder Geräte-PIN.';

  @override
  String get privacyLockAfter => 'Sperren nach';

  @override
  String get privacySetScreenLockFirst => 'Lege zuerst eine Displaysperre fest';

  @override
  String get privacySetScreenLockBody =>
      'Die App-Sperre nutzt deinen Fingerabdruck oder die Geräte-PIN. Lege in den Sicherheitseinstellungen von Android eine PIN, ein Muster oder ein Passwort fest und komm dann zurück.';

  @override
  String get privacyTurnOnAppLockReason => 'App-Sperre für Kosha einschalten';

  @override
  String get privacyNotAvailable => 'Gerade nicht verfügbar';

  @override
  String get privacyNotAvailableBody =>
      'Die Gerätesperre konnte nicht verwendet werden. Die App-Sperre bleibt aus.';

  @override
  String get privacyBackupTitle => 'Backup';

  @override
  String get privacyBackupRestore => 'Backup und Wiederherstellung';

  @override
  String get privacyBackupRestoreBody =>
      'Eine verschlüsselte .koshabackup-Datei, die du aufbewahrst. Du wählst, was darin enthalten ist.';

  @override
  String get privacyDeleteData => 'Daten löschen';

  @override
  String get privacyEraseEverything => 'Alles löschen';

  @override
  String get privacyEraseEverythingBody =>
      'Alle oben genannten Kategorien, deine eigenen Designs und der Schlüssel, der sie schützt.';

  @override
  String privacyDeleteTitle(String category) {
    return '$category löschen?';
  }

  @override
  String get privacyEraseTitle => 'Alles löschen?';

  @override
  String get privacyWillDelete => 'Dies löscht dauerhaft:';

  @override
  String get privacyResetSettings =>
      'Alle Einstellungen außerdem auf die Standardwerte zurücksetzen';

  @override
  String get privacyCannotBeUndone =>
      'Das kann nicht rückgängig gemacht werden.';

  @override
  String get privacyDeleted => 'Gelöscht.';

  @override
  String get privacyDeleteFailed =>
      'Kosha konnte nicht alles löschen. Versuche es erneut.';

  @override
  String get privacyOk => 'OK';

  @override
  String get backupMakeTitle => 'Backup erstellen';

  @override
  String get backupIncludeImages => 'Hintergrundbilder einschließen';

  @override
  String get backupPhotosLarger => 'Fotos machen die Datei deutlich größer.';

  @override
  String get backupCreateButton => 'Verschlüsseltes Backup erstellen';

  @override
  String get backupRestoreSection => 'Wiederherstellen';

  @override
  String get backupRestoreFromFile => 'Aus einer Backup-Datei wiederherstellen';

  @override
  String get backupRestoreFromFileBody =>
      'Öffne eine .koshabackup-Datei, prüfe den Inhalt und führe dann zusammen oder ersetze.';

  @override
  String get backupChoosePassphrase => 'Passphrase wählen';

  @override
  String get backupEnterPassphrase => 'Passphrase eingeben';

  @override
  String get backupWriteItDown =>
      'Schreib sie an einen sicheren Ort. Eine verlorene Passphrase kann nicht wiederhergestellt werden.';

  @override
  String get backupPassphrase => 'Passphrase';

  @override
  String get backupTypeAgain => 'Noch einmal eingeben';

  @override
  String get backupMismatch => 'Die Passphrasen stimmen nicht überein';

  @override
  String backupStrength(String strength) {
    return 'Passphrase-Stärke: $strength';
  }

  @override
  String get strengthTooShort => 'Mindestens 8 Zeichen verwenden';

  @override
  String get strengthWeak => 'Schwach';

  @override
  String get strengthFair => 'Ausreichend';

  @override
  String get strengthGood => 'Gut';

  @override
  String get strengthStrong => 'Stark';

  @override
  String get backupOpen => 'Öffnen';

  @override
  String get backupNothingYet => 'Noch nichts';

  @override
  String get backupSettingsSummary =>
      'Design, Sprachen, Tippen und Datenschutzeinstellungen';

  @override
  String backupLearnedSummary(String languages, String words) {
    return '$words in $languages';
  }

  @override
  String backupPinnedOff(String items) {
    return '$items. Aus, außer du schaltest es ein.';
  }

  @override
  String backupAlreadyHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kürzel schon vorhanden',
      one: '1 Kürzel schon vorhanden',
    );
    return '$_temp0';
  }

  @override
  String backupThemesAlreadyHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Designdateien schon vorhanden',
      one: '1 Designdatei schon vorhanden',
    );
    return '$_temp0';
  }

  @override
  String get backupClipboardKept =>
      'Zwischenablage unverändert (unbekanntes Layout)';

  @override
  String get backupEmojiKept => 'zuletzt genutzte Emoji behalten';

  @override
  String get backupSettingsApplied => 'Einstellungen';

  @override
  String backupLearnedAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sprachen',
      one: '1 Sprache',
    );
    return 'gelernte Wörter für $_temp0';
  }

  @override
  String shortcutDeleteTitle(String trigger) {
    return '„$trigger“ löschen?';
  }

  @override
  String get shortcutDeleteBody =>
      'Dadurch wird das Kürzel entfernt. Das kann nicht rückgängig gemacht werden.';

  @override
  String get shortcutAdd => 'Kürzel hinzufügen';

  @override
  String get shortcutSearch => 'Kürzel suchen';

  @override
  String get shortcutNoMatch => 'Keine Kürzel passen zu deiner Suche.';

  @override
  String shortcutDeleteTooltip(String trigger) {
    return '$trigger löschen';
  }

  @override
  String get shortcutNoneYet => 'Noch keine Kürzel';

  @override
  String get shortcutExplain =>
      'Ein Kürzel macht aus einer Kurzform einen längeren Text. Beispiele:';

  @override
  String shortcutExamples(String first, String second) {
    return '$first\n$second';
  }

  @override
  String get shortcutEncrypted =>
      'Kürzel sind auf diesem Gerät verschlüsselt, wie deine gelernten Wörter.';

  @override
  String get shortcutNew => 'Neues Kürzel';

  @override
  String get shortcutEdit => 'Kürzel bearbeiten';

  @override
  String get shortcutShortForm => 'Kurzform';

  @override
  String get shortcutExpandsTo => 'Wird erweitert zu';

  @override
  String get privacyMascotLabel => 'Kosha-Datenschutzmaskottchen';

  @override
  String get privacyStoredEmoji => 'Zuletzt verwendete Emoji';

  @override
  String get privacyStoredApps => 'App-Liste';

  @override
  String get privacyStoredOther => 'Andere gespeicherte Daten';

  @override
  String privacyUnitBytes(num count) {
    return '$count B';
  }

  @override
  String privacyUnitKilobytes(num count) {
    return '$count KB';
  }

  @override
  String privacyUnitMegabytes(num count) {
    return '$count MB';
  }

  @override
  String get shortcutProblemEmptyTrigger =>
      'Gib die Kurzform ein, die erweitert werden soll.';

  @override
  String shortcutProblemTriggerTooLong(num count) {
    return 'Die Kurzform darf höchstens $count Zeichen haben.';
  }

  @override
  String get shortcutProblemTriggerCharacters =>
      'Verwende in der Kurzform nur Buchstaben, Ziffern und Apostrophe.';

  @override
  String get shortcutProblemEmptyExpansion =>
      'Gib ein, wofür die Kurzform stehen soll.';

  @override
  String shortcutProblemExpansionTooLong(num count) {
    return 'Die Erweiterung darf höchstens $count Zeichen haben.';
  }

  @override
  String get shortcutProblemDuplicate =>
      'Du hast bereits ein Kürzel mit dieser Kurzform.';

  @override
  String shortcutProblemTooMany(num count) {
    return 'Du kannst höchstens $count Kürzel behalten.';
  }

  @override
  String get onboardingTurnOnTitle => 'Kosha einschalten';

  @override
  String get onboardingTurnOnBody =>
      'Android führt eine Liste der aktivierten Tastaturen. Aktiviere Kosha dort und komm dann hierher zurück. Kosha bemerkt die Änderung selbst.';

  @override
  String get onboardingKeyboardOn => 'Kosha ist eingeschaltet.';

  @override
  String get onboardingKeyboardOff => 'Kosha ist noch nicht eingeschaltet.';

  @override
  String get onboardingOpenKeyboardSettings => 'Tastatureinstellungen öffnen';

  @override
  String get onboardingSwitchTitle => 'Zu Kosha wechseln';

  @override
  String get onboardingSwitchBody =>
      'Wähle Kosha als Tastatur aus. Android zeigt eventuell zuerst eine kurze Liste. Dieser Bildschirm aktualisiert sich selbst.';

  @override
  String get onboardingKeyboardIsYours => 'Kosha ist deine Tastatur.';

  @override
  String get onboardingKeyboardNotYours =>
      'Kosha ist noch nicht deine Tastatur.';

  @override
  String get onboardingTurnOnFirst =>
      'Schalte Kosha zuerst im vorherigen Schritt ein.';

  @override
  String get onboardingChooseKeyboard => 'Tastatur wählen';

  @override
  String get onboardingCheckingPermissions =>
      'App-Berechtigungen werden geprüft…';

  @override
  String get onboardingDebugInternet =>
      'Dieser Debug-Build kann das Internet erreichen. Debug-Builds haben diese Berechtigung nur für die Entwicklung.';

  @override
  String get onboardingReleaseInternet =>
      'Dieser Build kann das Internet erreichen.';

  @override
  String get onboardingNoInternet =>
      'Kosha hat keine Internetberechtigung und kann deshalb nichts irgendwohin senden.';

  @override
  String get onboardingWarningTitle => 'Warum die Warnung nicht zutrifft';

  @override
  String get onboardingWarningBody =>
      'Android warnt, dass jede Tastatur eingeben kann, was du tippst. Diese Warnung betrifft Tastaturen, die das Internet erreichen können. Kosha kann das nicht.';

  @override
  String get onboardingInternetAccess => 'Internetzugriff';

  @override
  String get onboardingEverythingHere => 'Alles bleibt auf diesem Gerät';

  @override
  String get onboardingEverythingHereBody =>
      'Gelernte Wörter, Zwischenablage und Einstellungen sind mit einem Schlüssel im Android Keystore verschlüsselt.';

  @override
  String get onboardingLanguagesTitle => 'Sprachen und ein Design auswählen';

  @override
  String get onboardingLanguagesBody =>
      'Wähle die Sprachen, in denen du tippst. Mehrere können gleichzeitig aktiv sein, und du kannst sie später unter Sprachen ändern.';

  @override
  String get onboardingThemeTitle => 'Design';

  @override
  String get onboardingMoreThemes => 'Weitere Designs';

  @override
  String get onboardingTryTyping => 'Schreibe einen Satz';

  @override
  String get onboardingTrySwipe =>
      'Wische ein Wort: gleite von Buchstabe zu Buchstabe';

  @override
  String get onboardingTryAccents =>
      'Halte einen Buchstaben gedrückt, um seine Akzente zu sehen';

  @override
  String get onboardingTryTitle => 'Ausprobieren';

  @override
  String get onboardingTryBody =>
      'Tippe auf das Feld unten. Die Tastatur erscheint, und du kannst jeden Punkt der Liste ausprobieren.';

  @override
  String get onboardingTryField => 'Hier tippen zum Ausprobieren';

  @override
  String get onboardingChecklist => 'Checkliste';

  @override
  String get onboardingAllSetTitle => 'Alles eingerichtet';

  @override
  String get onboardingAllSetBody =>
      'Kosha ist bereit. Alles lässt sich später in den Einstellungen ändern: Sprachen, Tippen, Gefühl, Bereiche und Designs. Tippe auf Fertig, um abzuschließen.';

  @override
  String get onboardingSetUp => 'Kosha einrichten';

  @override
  String onboardingStepOf(String step, String total) {
    return 'Schritt $step von $total';
  }

  @override
  String onboardingStepFraction(String step, String total) {
    return '$step/$total';
  }

  @override
  String get onboardingBack => 'Zurück';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingDone => 'Fertig';

  @override
  String get onboardingSearchLanguages => 'Sprachen suchen';

  @override
  String onboardingSelected(String languages) {
    return 'Ausgewählt: $languages';
  }

  @override
  String get onboardingNoLanguageMatch =>
      'Keine Sprache passt zu dieser Suche.';

  @override
  String get themeCreate => 'Design erstellen';

  @override
  String themeSelectedLabel(String name) {
    return '$name, ausgewählt';
  }

  @override
  String themeCardOptions(String name) {
    return 'Optionen für $name';
  }

  @override
  String get themeEdit => 'Bearbeiten';

  @override
  String get themeDuplicate => 'Duplizieren';

  @override
  String get themeRename => 'Umbenennen';

  @override
  String get themeDeleteAction => 'Löschen';

  @override
  String get themeTryTyping => 'Ausprobieren';

  @override
  String get themeTryLabel => 'Hier tippen, um das Design zu testen';

  @override
  String get themeTryHelper =>
      'Die Tastatur erscheint hier, wenn Kosha ausgewählt ist.';

  @override
  String get themeRenameTitle => 'Design umbenennen';

  @override
  String get themeNameField => 'Name';

  @override
  String get themeEditTitle => 'Design bearbeiten';

  @override
  String get themeNewTitle => 'Neues Design';

  @override
  String get themeEditorTitle => 'Design';

  @override
  String get themeOpenFailed => 'Dieses Design konnte nicht geöffnet werden.';

  @override
  String get themeSaveFailed => 'Das Design konnte nicht gespeichert werden.';

  @override
  String get themePhotoPickerFailed =>
      'Die Fotoauswahl konnte nicht geöffnet werden.';

  @override
  String get themeDiscardTitle => 'Änderungen verwerfen?';

  @override
  String get themeDiscardBody =>
      'Deine Änderungen an diesem Design gehen verloren.';

  @override
  String get themeKeepEditing => 'Weiter bearbeiten';

  @override
  String get themeDiscard => 'Verwerfen';

  @override
  String get themeSave => 'Speichern';

  @override
  String get themeNameRequired => 'Ein Name ist erforderlich';

  @override
  String get themeNameLabel => 'Designname';

  @override
  String get themeDefaultName => 'Mein Design';

  @override
  String get themeSectionName => 'Name';

  @override
  String get themeSectionLook => 'Aussehen';

  @override
  String get themeDarkMode => 'Dunkelmodus';

  @override
  String get themeChoiceSystem => 'System';

  @override
  String get themeChoiceLight => 'Hell';

  @override
  String get themeChoiceDark => 'Dunkel';

  @override
  String get themePureBlack => 'Reines Schwarz';

  @override
  String get themePureBlackBody => 'Schwarzer Hintergrund';

  @override
  String get themePureBlackOnlyDark => 'Nur im Dunkelmodus';

  @override
  String get themeGalleryPureBlackDark =>
      'Schwarzer Hintergrund im Dunkelmodus';

  @override
  String get themeContrast => 'Kontrast';

  @override
  String get themeChoiceStandard => 'Standard';

  @override
  String get themeChoiceMedium => 'Mittel';

  @override
  String get themeChoiceHigh => 'Hoch';

  @override
  String get themeKeyboardHeight => 'Tastaturhöhe';

  @override
  String get themeSectionColours => 'Farben';

  @override
  String get themeSource => 'Quelle';

  @override
  String get themeSourceWallpaper => 'Hintergrundbild';

  @override
  String get themeSourceSeed => 'Basisfarbe';

  @override
  String get themeSourcePerRole => 'Pro Rolle';

  @override
  String get themeWallpaperNeedsAndroid12 =>
      'Wallpaper-Farben benötigen Android 12 oder neuer.';

  @override
  String get themeSeedColour => 'Basisfarbe';

  @override
  String get themeScheme => 'Schema';

  @override
  String get themeColourRoles => 'Farbrollen';

  @override
  String themeEditingColours(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'dark': 'Dunkle Farben werden bearbeitet',
      'other': 'Helle Farben werden bearbeitet',
    });
    return '$_temp0';
  }

  @override
  String get themeResetRoles => 'Alle Rollen zurücksetzen';

  @override
  String get themeKeys => 'Tasten';

  @override
  String get themeShape => 'Form';

  @override
  String get themeShapePill => 'Kapsel';

  @override
  String get themeShapeRounded => 'Abgerundet';

  @override
  String get themeShapeSquare => 'Eckig';

  @override
  String get themeKeyBorders => 'Tastenränder';

  @override
  String get themeBorderWidth => 'Randbreite';

  @override
  String get themeKeyGap => 'Tastenabstand';

  @override
  String get themeFontWeight => 'Schriftstärke';

  @override
  String get themeFontSize => 'Schriftgröße';

  @override
  String get themeHintCharacters => 'Hinweiszeichen';

  @override
  String get themeHintCharactersBody => 'Kleine Zeichen beim langen Drücken';

  @override
  String get themeBackground => 'Hintergrund';

  @override
  String get themeBackgroundType => 'Typ';

  @override
  String get themeTypeSolid => 'Einfarbig';

  @override
  String get themeTypeGradient => 'Verlauf';

  @override
  String get themeTypePhoto => 'Foto';

  @override
  String get themeNoPhotoYet =>
      'Noch kein Foto. Wähle eines aus, um es auf die Tastatur zuzuschneiden.';

  @override
  String get themeChoosePhoto => 'Foto wählen';

  @override
  String get themeEditCrop => 'Zuschnitt und Unschärfe bearbeiten';

  @override
  String get themeDim => 'Abdunkeln';

  @override
  String get themeSectionPopups => 'Pop-ups und Spur';

  @override
  String get themeSolidPopups => 'Einfarbige Pop-ups';

  @override
  String get themeSolidPopupsBodyWallpaper => 'Nicht mit Wallpaper-Farben';

  @override
  String get themeSolidPopupsBodyPrimary => 'Pop-ups in der Hauptfarbe';

  @override
  String get themeSwipeTrail => 'Wischspur';

  @override
  String get themeTrailWidth => 'Spurbreite';

  @override
  String get themeTrailFade => 'Spur-Ausblendung';

  @override
  String get themeTrailInstant => 'Sofort';

  @override
  String get themeTrailColours => 'Spurfarben';

  @override
  String get themeTrailStart => 'Anfang';

  @override
  String get themeTrailEnd => 'Ende';

  @override
  String get themeTrailStartTitle => 'Spuranfang';

  @override
  String get themeTrailEndTitle => 'Spurende';

  @override
  String get themeAutomatic => 'Automatisch';

  @override
  String get themeSectionMotion => 'Bewegung';

  @override
  String get themeKeyPressAnimation => 'Animation beim Tastendruck';

  @override
  String get themeReduceMotion =>
      '„Animationen entfernen“ ist in den Systemeinstellungen aktiv, daher werden Tasten nicht animiert.';

  @override
  String get themeMotionOff => 'Aus';

  @override
  String get themeMotionSubtle => 'Dezent';

  @override
  String get themeMotionStandard => 'Standard';

  @override
  String get themeMotionBouncy => 'Federnd';

  @override
  String get themeSchemeTonalSpot => 'Tonal-Spot';

  @override
  String get themeSchemeVibrant => 'Lebendig';

  @override
  String get themeSchemeExpressive => 'Ausdrucksstark';

  @override
  String get themeSchemeFidelity => 'Treue';

  @override
  String get themeSchemeContent => 'Inhalt';

  @override
  String get themeSchemeMonochrome => 'Monochrom';

  @override
  String get themeSchemeNeutral => 'Neutral';

  @override
  String get themeSchemeRainbow => 'Regenbogen';

  @override
  String get themeSchemeFruitSalad => 'Obstsalat';

  @override
  String themeCustomColourHex(String hex) {
    return 'Eigene Farbe #$hex';
  }

  @override
  String get themeCustomColour => 'Eigene Farbe';

  @override
  String themeSwatchLabel(String hex, String label) {
    return '$label-Farbe, #$hex';
  }

  @override
  String themeUseSchemeColour(String label) {
    return 'Die Schemafarbe für $label verwenden';
  }

  @override
  String get themeFromScheme => 'Aus dem Schema';

  @override
  String get themeOverridden => 'Festgelegt';

  @override
  String themeStopLabel(String n) {
    return 'Stopp $n';
  }

  @override
  String themePickStopTitle(String n) {
    return 'Stopp $n';
  }

  @override
  String get themeAddStop => 'Stopp hinzufügen';

  @override
  String get themeRemoveStop => 'Stopp entfernen';

  @override
  String get themeAngle => 'Winkel';

  @override
  String get themeUseSchemeTooltipLabel => 'Schemafarbe verwenden';

  @override
  String get themeCropTitle => 'Foto zuschneiden';

  @override
  String get themeUsePhoto => 'Foto verwenden';

  @override
  String get themeCropSaveFailed => 'Das Foto konnte nicht gespeichert werden.';

  @override
  String get themeCropSemantics =>
      'Fotozuschnitt. Ziehen, um das Foto zu verschieben, und mit zwei Fingern oder dem Zoomregler vergrößern.';

  @override
  String get themeCropZoom => 'Zoom';

  @override
  String get themeCropBlur => 'Unschärfe';

  @override
  String get themeCropBlurOff => 'Aus';

  @override
  String get themeCropNote =>
      'Die Unschärfe wird im Bild gespeichert. Die Abdunklung wird im Editor eingestellt und sofort angewendet.';

  @override
  String get themeHexLabel => 'Hex';

  @override
  String get themeHexError => 'Verwende sechs Hex-Ziffern, zum Beispiel F5B700';

  @override
  String get themeHue => 'Farbton';

  @override
  String get themeSaturation => 'Sättigung';

  @override
  String get themeBrightness => 'Helligkeit';

  @override
  String get themePickShadeHint =>
      'Wähle einen Farbton und tippe dann auf Verwenden.';

  @override
  String get themePickColourUse => 'Verwenden';

  @override
  String get themeCopySuffix => 'Kopie';

  @override
  String themeCopyName(String name) {
    return 'Kopie von $name';
  }

  @override
  String themeDeleteTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get themeDeleteSelectedBody =>
      'Dieses Design ist ausgewählt. Stattdessen wird Kosha Dynamic verwendet. Das kann nicht rückgängig gemacht werden.';

  @override
  String get themeDeleteBody => 'Das kann nicht rückgängig gemacht werden.';

  @override
  String get themeDeleteFailed => 'Das Design konnte nicht gelöscht werden.';

  @override
  String get themeRenameFailed => 'Das Design konnte nicht umbenannt werden.';

  @override
  String get themeDuplicateFailed => 'Das Design konnte nicht kopiert werden.';

  @override
  String get themeSettingFailed =>
      'Die Einstellung konnte nicht gespeichert werden.';

  @override
  String get themeSystemColoursUnavailable =>
      'Systemfarben sind nicht verfügbar.';

  @override
  String get themeKoshaDynamicFollows =>
      'Kosha Dynamic folgt deinem Hintergrundbild';

  @override
  String get themeKoshaDynamicBody =>
      'Seine Farben aktualisieren sich, wenn sich das Hintergrundbild ändert';

  @override
  String get themeSectionPresets => 'Voreinstellungen';

  @override
  String get themeSectionMyThemes => 'Meine Designs';

  @override
  String get themeSectionTry => 'Ausprobieren';

  @override
  String get themeAppearance => 'Erscheinungsbild';

  @override
  String get themesTitle => 'Designs';

  @override
  String privacyThemesSize(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Designdateien',
      one: '1 Designdatei',
    );
    return '$_temp0 · $size';
  }

  @override
  String get backupUnlockToSeeCount =>
      'Entsperre dein Gerät, um die Anzahl zu sehen';

  @override
  String get shortcutHelp =>
      'Ein Kürzel macht aus einer Kurzform einen längeren Text. Beispiele:\nomw → on my way\naddr → your address';

  @override
  String privacyStoredLearned(String language) {
    return 'Gelernte Wörter ($language)';
  }

  @override
  String get settingsComingLater => 'Kommt in einem späteren Update';

  @override
  String get backupExplainer =>
      'Ein Backup ist eine einzelne Datei, verschlüsselt mit einer Passphrase deiner Wahl. Nur diese Passphrase öffnet sie. Wenn du die Passphrase vergisst, kann niemand das Backup wiederherstellen, auch Kosha nicht.';

  @override
  String privacyCategoryLine(String detail, String title) {
    return '$title: $detail';
  }

  @override
  String get shortcutShortFormHint => 'omw';

  @override
  String get shortcutExpansionHint => 'unterwegs';

  @override
  String get durationMinutes15 => '15 Minuten';

  @override
  String get durationHour => '1 Stunde';

  @override
  String get durationDay => '1 Tag';

  @override
  String get durationWeek => '1 Woche';

  @override
  String get onboardingCloseSetup => 'Einrichtung schließen';

  @override
  String get packsCouldNotRead => 'Kosha konnte seine Pakete nicht lesen';

  @override
  String packsDeleteTooltip(String name) {
    return '$name löschen';
  }

  @override
  String get privacyNothingStored => 'Noch nichts gespeichert';

  @override
  String privacyRemoveAppTooltip(String app) {
    return '$app aus der Liste entfernen';
  }
}
