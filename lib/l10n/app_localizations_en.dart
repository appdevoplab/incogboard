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

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get useAction => 'Use';

  @override
  String get off => 'Off';

  @override
  String get left => 'Left';

  @override
  String get right => 'Right';

  @override
  String get settingsLanguages => 'Languages';

  @override
  String get settingsTyping => 'Typing';

  @override
  String get settingsFeel => 'Feel';

  @override
  String get settingsThemes => 'Themes';

  @override
  String get settingsPanels => 'Panels';

  @override
  String get settingsVoice => 'Voice';

  @override
  String get settingsTranslation => 'Translation';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsModelPacks => 'Model packs';

  @override
  String get homeSetupTurnOn => 'Turn Kosha on in Android\'s keyboard list.';

  @override
  String get homeSetupChoose => 'Choose Kosha as the keyboard you type with.';

  @override
  String get homeFinishSetup => 'Finish setting up Kosha';

  @override
  String get homeTypingSubtitle => 'Corrections, suggestions, keys and swipe';

  @override
  String get homeFeelSubtitle => 'Haptics, sounds, height and one-handed mode';

  @override
  String get homePanelsSubtitle => 'Clipboard and emoji';

  @override
  String get homeVoiceSubtitle => 'Speak to type, on this phone';

  @override
  String get homeTranslationSubtitle => 'Translate as you type, offline';

  @override
  String get homePrivacySubtitle =>
      'What is stored, incognito, app lock and backup';

  @override
  String get homeAboutSubtitle => 'Version, licences and source code';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(Object versionCode, Object versionName) {
    return 'Version $versionName ($versionCode)';
  }

  @override
  String aboutVersionDebug(Object versionCode, Object versionName) {
    return 'Version $versionName ($versionCode) · debug build';
  }

  @override
  String get aboutReadingVersion => 'Reading version…';

  @override
  String get aboutPrivacy => 'Privacy';

  @override
  String get aboutNoInternet => 'Kosha cannot use the internet';

  @override
  String get aboutNoInternetBody =>
      'Release builds have no internet permission, so nothing you type leaves this phone.';

  @override
  String get aboutLicence => 'Licence';

  @override
  String get aboutGplTitle => 'GNU General Public Licence v3 or later';

  @override
  String get aboutGplBody =>
      'Kosha is free software. You may study, change and share it under the GPL.';

  @override
  String get aboutSourceCode => 'Source code';

  @override
  String get aboutSourceBody =>
      'Kosha is GPL-3.0-or-later. Its source code is available from the project page.';

  @override
  String get aboutLicences => 'Licences';

  @override
  String get aboutOpenSource => 'Open-source licences';

  @override
  String get aboutOpenSourceBody =>
      'Flutter, material_ui and every package Kosha uses';

  @override
  String get aboutTextLoadFailed => 'This text could not be loaded.';

  @override
  String get languagesEnabledHeader => 'Enabled, first is the default';

  @override
  String get languagesActive => 'Active language';

  @override
  String get languagesAdd => 'Add a language';

  @override
  String get languagesAllEnabled => 'Every language is enabled';

  @override
  String get languagesAllEnabledBody => 'Remove one above to make room.';

  @override
  String get languagesMultilingual => 'Multilingual typing';

  @override
  String get languagesMultilingualBody =>
      'Suggest words from up to three enabled languages that share the layout\'s script. A word that any of them knows is never auto-corrected.';

  @override
  String get languagesNativeDigits => 'Native digits';

  @override
  String get languagesNativeDigitsBody =>
      'Type digits in the script of the active language where it has them (०१२, ٠١٢).';

  @override
  String get languagesOptions => 'Language options';

  @override
  String get languagesZhSubtitle =>
      'Pinyin, Traditional characters and dictionary packs';

  @override
  String get languagesJaSubtitle =>
      'Flick input, conversion and dictionary packs';

  @override
  String languagesReorderLabel(Object language) {
    return 'Drag to reorder $language';
  }

  @override
  String languageDefaultLabel(Object language) {
    return '$language, default';
  }

  @override
  String languageLayoutTooltip(Object language) {
    return 'Layout for $language';
  }

  @override
  String languageRemoveTooltip(Object language) {
    return 'Remove $language';
  }

  @override
  String get feelHaptics => 'Haptics';

  @override
  String get feelHapticFeedback => 'Haptic feedback';

  @override
  String get feelHapticFeedbackBody =>
      'A short vibration on each key, following the system setting';

  @override
  String get feelHapticStrength => 'Haptic strength';

  @override
  String get feelSounds => 'Sounds';

  @override
  String get feelKeySounds => 'Key sounds';

  @override
  String get feelKeySoundsBody => 'Clicks for keys, space, delete and enter';

  @override
  String get feelUseSystemVolume => 'Use system volume';

  @override
  String get feelKeySoundVolume => 'Key sound volume';

  @override
  String get feelHeight => 'Height';

  @override
  String get feelPortraitHeight => 'Portrait height';

  @override
  String get feelLandscapeHeight => 'Landscape height';

  @override
  String get feelOneHandedFloating => 'One-handed and floating';

  @override
  String get feelOneHandedSide => 'One-handed side';

  @override
  String get feelFloatingKeyboard => 'Floating keyboard';

  @override
  String get feelFloatingBody => 'Drag it anywhere on the screen';

  @override
  String get panelsClipboard => 'Clipboard';

  @override
  String get panelsClipboardHistory => 'Clipboard history';

  @override
  String get panelsClipboardHistoryBody =>
      'Keep what you copy, encrypted on this phone';

  @override
  String get panelsRecentChip => 'Recent-copy chip';

  @override
  String get panelsRecentChipBody =>
      'Offer your last copy in the suggestion bar for a minute';

  @override
  String get panelsKeepUnpinned => 'Keep unpinned copies for';

  @override
  String get panelsClipsToKeep => 'Clips to keep';

  @override
  String get panelsEmoji => 'Emoji';

  @override
  String get emojiSuggestions => 'Emoji suggestions';

  @override
  String get emojiSuggestionsPanelBody =>
      'Offer an emoji for some words in the suggestion bar';

  @override
  String get panelsPasswordsNeverSaved => 'Passwords are never saved';

  @override
  String get panelsSensitiveBody =>
      'Copies that Android marks as sensitive are never kept.';

  @override
  String get typingCorrections => 'Corrections';

  @override
  String get typingAutocorrect => 'Autocorrect';

  @override
  String get typingAutocorrectBody => 'Fix likely typos as you finish a word';

  @override
  String get typingAutoCapitalise => 'Auto-capitalise';

  @override
  String get typingAutoCapitaliseBody =>
      'Capital letters at the start of sentences';

  @override
  String get typingDoubleSpace => 'Double-space full stop';

  @override
  String get typingDoubleSpaceBody => 'Two taps of space write \". \"';

  @override
  String get typingSmartPunctuation => 'Smart punctuation';

  @override
  String get typingSmartPunctuationBody =>
      'Tidy spaces around punctuation and use local quotes';

  @override
  String get typingSuggestions => 'Suggestions';

  @override
  String get typingSuggestionsBody => 'Show words in the suggestion bar';

  @override
  String get typingNextWord => 'Next-word prediction';

  @override
  String get typingNextWordBody => 'Suggest the word that often follows';

  @override
  String get typingEmojiBody => 'Offer an emoji for some words';

  @override
  String get typingHideOffensive => 'Hide offensive words';

  @override
  String get typingHideOffensiveBody =>
      'Never suggest them unless you type them in full';

  @override
  String get typingKeys => 'Keys';

  @override
  String get typingKeyPopups => 'Key popups';

  @override
  String get typingKeyPopupsBody => 'Enlarge a key while you press it';

  @override
  String get typingLongPressDelay => 'Long-press delay';

  @override
  String get typingNumberRow => 'Number row';

  @override
  String get typingNumberRowBody => 'Show 0 to 9 above the letters';

  @override
  String get typingHintLabels => 'Hint labels';

  @override
  String get typingHintLabelsBody => 'Small symbols on keys, such as accents';

  @override
  String get typingLowercaseLabels => 'Lowercase labels';

  @override
  String get typingLowercaseLabelsBody =>
      'Keep key letters lowercase when shift is on';

  @override
  String get typingSwipe => 'Swipe';

  @override
  String get typingSwipeTyping => 'Swipe typing';

  @override
  String get typingSwipeTypingBody => 'Glide across letters to write a word';

  @override
  String get typingShowTrail => 'Show trail';

  @override
  String get typingTrailWidth => 'Trail width';

  @override
  String get typingTrailFade => 'Trail fade';

  @override
  String get typingLivePreview => 'Live preview';

  @override
  String get typingLivePreviewBody => 'Show the likely word while you glide';

  @override
  String get typingSpaceMovesCursor => 'Space bar moves the cursor';

  @override
  String get typingSpaceMovesCursorBody =>
      'Drag on the space bar to move the cursor';

  @override
  String get typingSwipeBackspace => 'Swipe backspace to delete words';

  @override
  String get typingSwipeBackspaceBody =>
      'Slide left on backspace to select and delete words';

  @override
  String get voiceTyping => 'Voice typing';

  @override
  String get voiceTypingBody =>
      'Speak to type. Recognition runs on this phone.';

  @override
  String get voiceRecognition => 'Recognition';

  @override
  String get voiceDetectLanguage => 'Detect language automatically';

  @override
  String get voiceDetectLanguageBody =>
      'Whisper works out which language you speak.';

  @override
  String get voiceModelPacksBody =>
      'Install or remove voice and translation packs';

  @override
  String get voiceAudioStays => 'Audio stays on this phone and is never saved.';

  @override
  String get voicePackAutomatic => 'Automatic';

  @override
  String get voicePackAutomaticSelected => 'Automatic (selected)';

  @override
  String get voicePack => 'Voice pack';

  @override
  String get voiceNoPack =>
      'No voice pack is installed. Install one under Model packs.';

  @override
  String get voiceLooking => 'Looking for installed packs';

  @override
  String voicePackItem(Object name, Object size) {
    return '$name · $size';
  }

  @override
  String voicePackItemSelected(Object name, Object size) {
    return '$name · $size (selected)';
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
  String get packsOpenFailed => 'Kosha could not open the file picker.';

  @override
  String packsInstalled(Object name) {
    return 'Installed $name.';
  }

  @override
  String packsDeleteTitle(Object name) {
    return 'Delete $name?';
  }

  @override
  String packsDeleted(Object name) {
    return 'Deleted $name.';
  }

  @override
  String packsDeleteFailed(Object name) {
    return 'Kosha could not delete $name. Try again.';
  }

  @override
  String get packsIntro =>
      'Packs are checked before they are installed. They contain data only, never code.';

  @override
  String get packsImport => 'Import';

  @override
  String get packsImportTitle => 'Import a pack file';

  @override
  String get packsChecking => 'Checking and installing…';

  @override
  String get packsImportBody => 'A .koshapack file, for example from Downloads';

  @override
  String get packsNoVoice => 'No voice packs installed';

  @override
  String get packsNoVoiceBody => 'Voice typing needs a voice pack.';

  @override
  String get packsNoTranslation => 'No translation packs installed';

  @override
  String get packsNoTranslationBody =>
      'Translation needs one pack for each direction.';

  @override
  String get packsDictionaries => 'Dictionaries';

  @override
  String get packsNoDictionary => 'No dictionary packs installed';

  @override
  String get packsNoDictionaryBody =>
      'Chinese and Japanese typing need a dictionary pack.';

  @override
  String get packsNothingStored => 'Nothing stored yet.';

  @override
  String packsInstalledUse(Object size) {
    return 'Installed packs use $size on this phone.';
  }

  @override
  String get packErrorBadSignature =>
      'This pack is not signed for Kosha, so nothing was installed.';

  @override
  String get packErrorBadFormat =>
      'This file is not a Kosha pack. Nothing was installed.';

  @override
  String get packErrorTooLarge =>
      'This pack is too large to install on this phone.';

  @override
  String get packErrorVersion => 'This pack needs a newer version of Kosha.';

  @override
  String get packErrorNoSpace =>
      'There is not enough free space to install this pack.';

  @override
  String get packErrorGeneric =>
      'The pack could not be installed. Nothing was changed.';

  @override
  String get translateDefaultPair => 'Default language pair';

  @override
  String translatePairName(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String get translateOffline => 'Offline translation';

  @override
  String get translateOfflineBody =>
      'Translate as you type in the keyboard, and selected text in any app.';

  @override
  String get translateDefaultPairTile => 'Default pair';

  @override
  String get translatePackInstalled => 'Pack installed';

  @override
  String get translatePackNotInstalled =>
      'Pack not installed. Get it in Model packs.';

  @override
  String get translateInstalled => 'Installed directions';

  @override
  String get translateInstalledBody =>
      'Each direction is one pack, for example English → Spanish.';

  @override
  String translatePackMeta(Object license, Object size) {
    return '$size · $license';
  }

  @override
  String get translateModelPacksBody => 'Install or delete translation packs';

  @override
  String get translateRunsOnPhone =>
      'Translation runs on this phone. Nothing you translate is saved.';
}
