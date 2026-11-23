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
  String aboutVersion(Object versionCode, Object versionName) {
    return 'Version $versionName ($versionCode)';
  }

  @override
  String aboutVersionDebug(Object versionCode, Object versionName) {
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
  String languagesReorderLabel(Object language) {
    return 'Zum Umsortieren von $language ziehen';
  }

  @override
  String languageDefaultLabel(Object language) {
    return '$language, Standard';
  }

  @override
  String languageLayoutTooltip(Object language) {
    return 'Layout für $language';
  }

  @override
  String languageRemoveTooltip(Object language) {
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
  String voicePackItem(Object name, Object size) {
    return '$name · $size';
  }

  @override
  String voicePackItemSelected(Object name, Object size) {
    return '$name · $size (ausgewählt)';
  }

  @override
  String megabytes(Object count) {
    return '$count MB';
  }

  @override
  String milliseconds(Object count) {
    return '$count ms';
  }

  @override
  String dpValue(Object count) {
    return '$count dp';
  }

  @override
  String get packsOpenFailed => 'Kosha konnte die Dateiauswahl nicht öffnen.';

  @override
  String packsInstalled(Object name) {
    return '$name installiert.';
  }

  @override
  String packsDeleteTitle(Object name) {
    return '$name löschen?';
  }

  @override
  String packsDeleted(Object name) {
    return '$name gelöscht.';
  }

  @override
  String packsDeleteFailed(Object name) {
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
  String packsInstalledUse(Object size) {
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
  String translatePairName(Object from, Object to) {
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
  String translatePackMeta(Object license, Object size) {
    return '$size · $license';
  }

  @override
  String get translateModelPacksBody =>
      'Übersetzungspakete installieren oder löschen';

  @override
  String get translateRunsOnPhone =>
      'Die Übersetzung läuft auf diesem Gerät. Nichts, was du übersetzt, wird gespeichert.';
}
