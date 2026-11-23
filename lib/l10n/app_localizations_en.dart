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
  String get homeOfflinePromise => 'Kosha works offline and sends nothing anywhere.';

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
  String get homePrivacySubtitle => 'What is stored, incognito, app lock and backup';

  @override
  String get homeAboutSubtitle => 'Version, licences and source code';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String versionCode, String versionName) {
    return 'Version $versionName ($versionCode)';
  }

  @override
  String aboutVersionDebug(String versionCode, String versionName) {
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
  String get aboutGplBody => 'Kosha is free software. You may study, change and share it under the GPL.';

  @override
  String get aboutSourceCode => 'Source code';

  @override
  String get aboutSourceBody => 'Kosha is GPL-3.0-or-later. Its source code is available from the project page.';

  @override
  String get aboutLicences => 'Licences';

  @override
  String get aboutOpenSource => 'Open-source licences';

  @override
  String get aboutOpenSourceBody => 'Flutter, material_ui and every package Kosha uses';

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
  String get languagesZhSubtitle => 'Pinyin, Traditional characters and dictionary packs';

  @override
  String get languagesJaSubtitle => 'Flick input, conversion and dictionary packs';

  @override
  String languagesReorderLabel(String language) {
    return 'Drag to reorder $language';
  }

  @override
  String languageDefaultLabel(String language) {
    return '$language, default';
  }

  @override
  String languageLayoutTooltip(String language) {
    return 'Layout for $language';
  }

  @override
  String languageRemoveTooltip(String language) {
    return 'Remove $language';
  }

  @override
  String get feelHaptics => 'Haptics';

  @override
  String get feelHapticFeedback => 'Haptic feedback';

  @override
  String get feelHapticFeedbackBody => 'A short vibration on each key, following the system setting';

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
  String get panelsClipboardHistoryBody => 'Keep what you copy, encrypted on this phone';

  @override
  String get panelsRecentChip => 'Recent-copy chip';

  @override
  String get panelsRecentChipBody => 'Offer your last copy in the suggestion bar for a minute';

  @override
  String get panelsKeepUnpinned => 'Keep unpinned copies for';

  @override
  String get panelsClipsToKeep => 'Clips to keep';

  @override
  String get panelsEmoji => 'Emoji';

  @override
  String get emojiSuggestions => 'Emoji suggestions';

  @override
  String get emojiSuggestionsPanelBody => 'Offer an emoji for some words in the suggestion bar';

  @override
  String get panelsPasswordsNeverSaved => 'Passwords are never saved';

  @override
  String get panelsSensitiveBody => 'Copies that Android marks as sensitive are never kept.';

  @override
  String get typingCorrections => 'Corrections';

  @override
  String get typingAutocorrect => 'Autocorrect';

  @override
  String get typingAutocorrectBody => 'Fix likely typos as you finish a word';

  @override
  String get typingAutoCapitalise => 'Auto-capitalise';

  @override
  String get typingAutoCapitaliseBody => 'Capital letters at the start of sentences';

  @override
  String get typingDoubleSpace => 'Double-space full stop';

  @override
  String get typingDoubleSpaceBody => 'Two taps of space write \". \"';

  @override
  String get typingSmartPunctuation => 'Smart punctuation';

  @override
  String get typingSmartPunctuationBody => 'Tidy spaces around punctuation and use local quotes';

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
  String get typingHideOffensiveBody => 'Never suggest them unless you type them in full';

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
  String get typingLowercaseLabelsBody => 'Keep key letters lowercase when shift is on';

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
  String get typingSpaceMovesCursorBody => 'Drag on the space bar to move the cursor';

  @override
  String get typingSwipeBackspace => 'Swipe backspace to delete words';

  @override
  String get typingSwipeBackspaceBody => 'Slide left on backspace to select and delete words';

  @override
  String get voiceTyping => 'Voice typing';

  @override
  String get voiceTypingBody => 'Speak to type. Recognition runs on this phone.';

  @override
  String get voiceRecognition => 'Recognition';

  @override
  String get voiceDetectLanguage => 'Detect language automatically';

  @override
  String get voiceDetectLanguageBody => 'Whisper works out which language you speak.';

  @override
  String get voiceModelPacksBody => 'Install or remove voice and translation packs';

  @override
  String get voiceAudioStays => 'Audio stays on this phone and is never saved.';

  @override
  String get voicePackAutomatic => 'Automatic';

  @override
  String get voicePackAutomaticSelected => 'Automatic (selected)';

  @override
  String get voicePack => 'Voice pack';

  @override
  String get voiceNoPack => 'No voice pack is installed. Install one under Model packs.';

  @override
  String get voiceLooking => 'Looking for installed packs';

  @override
  String voicePackItem(String name, String size) {
    return '$name · $size';
  }

  @override
  String voicePackItemSelected(String name, String size) {
    return '$name · $size (selected)';
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
  String get packsOpenFailed => 'Kosha could not open the file picker.';

  @override
  String packsInstalled(String name) {
    return 'Installed $name.';
  }

  @override
  String packsDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get packsDeleteBody =>
      'Its files are removed from this phone. You can import the pack again later from its file.';

  @override
  String packsDeleted(String name) {
    return 'Deleted $name.';
  }

  @override
  String packsDeleteFailed(String name) {
    return 'Kosha could not delete $name. Try again.';
  }

  @override
  String get packsIntro => 'Packs are checked before they are installed. They contain data only, never code.';

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
  String get packsNoTranslationBody => 'Translation needs one pack for each direction.';

  @override
  String get packsDictionaries => 'Dictionaries';

  @override
  String get packsNoDictionary => 'No dictionary packs installed';

  @override
  String get packsNoDictionaryBody => 'Chinese and Japanese typing need a dictionary pack.';

  @override
  String get packsNothingStored => 'Nothing stored yet.';

  @override
  String packsInstalledUse(String size) {
    return 'Installed packs use $size on this phone.';
  }

  @override
  String get packErrorBadSignature => 'This pack is not signed for Kosha, so nothing was installed.';

  @override
  String get packErrorBadFormat => 'This file is not a Kosha pack. Nothing was installed.';

  @override
  String get packErrorTooLarge => 'This pack is too large to install on this phone.';

  @override
  String get packErrorVersion => 'This pack needs a newer version of Kosha.';

  @override
  String get packErrorNoSpace => 'There is not enough free space to install this pack.';

  @override
  String get packErrorGeneric => 'The pack could not be installed. Nothing was changed.';

  @override
  String get translateDefaultPair => 'Default language pair';

  @override
  String translatePairName(String from, String to) {
    return '$from → $to';
  }

  @override
  String get translateOffline => 'Offline translation';

  @override
  String get translateOfflineBody => 'Translate as you type in the keyboard, and selected text in any app.';

  @override
  String get translateDefaultPairTile => 'Default pair';

  @override
  String get translatePackInstalled => 'Pack installed';

  @override
  String get translatePackNotInstalled => 'Pack not installed. Get it in Model packs.';

  @override
  String get translateInstalled => 'Installed directions';

  @override
  String get translateInstalledBody => 'Each direction is one pack, for example English → Spanish.';

  @override
  String translatePackMeta(String license, String size) {
    return '$size · $license';
  }

  @override
  String get translateModelPacksBody => 'Install or delete translation packs';

  @override
  String get translateRunsOnPhone => 'Translation runs on this phone. Nothing you translate is saved.';

  @override
  String get privacyUnlockReason => 'Unlock Kosha to see your settings and data';

  @override
  String get privacyLockUnavailable => 'Your device lock is not available right now. Try again in a moment.';

  @override
  String get privacyLockedTitle => 'Kosha is locked';

  @override
  String get privacyLockedBody => 'Unlock with your fingerprint or your device PIN to continue.';

  @override
  String get privacyUnlock => 'Unlock';

  @override
  String backupSaved(String size) {
    return 'Backup saved ($size). Keep your passphrase safe.';
  }

  @override
  String get backupUnlockRetrySaved => 'Unlock your phone, then try again. Nothing was saved.';

  @override
  String get backupSaveFailed => 'The backup could not be saved. Nothing was changed.';

  @override
  String get backupWrongPassphrase => 'Wrong passphrase, or the file is damaged. Nothing was changed.';

  @override
  String get backupInvalidFile => 'This file is not a valid Kosha backup. Nothing was changed.';

  @override
  String get backupTooLarge => 'This file is too large to be a Kosha backup.';

  @override
  String get backupNewerVersion => 'This backup was made by a newer version of Kosha. Update Kosha to restore it.';

  @override
  String get backupBusy => 'Finish the other file window first, then try again.';

  @override
  String get backupOpenFailed => 'The backup could not be opened. Nothing was changed.';

  @override
  String get backupEmpty => 'This backup has nothing in it.';

  @override
  String get backupRestoreTitle => 'Restore backup';

  @override
  String backupMadeBy(String date, String version) {
    return 'Made $date by Kosha $version.';
  }

  @override
  String get backupMerge => 'Merge';

  @override
  String get backupMergeBody => 'Keep what is on this phone and add what is in the backup.';

  @override
  String get backupReplace => 'Replace';

  @override
  String get backupReplaceBody => 'Make the chosen sections match the backup. Data here is deleted first.';

  @override
  String get commonContinue => 'Continue';

  @override
  String get backupReplaceTitle => 'Replace data on this phone?';

  @override
  String get backupReplaceConfirm =>
      'The chosen sections on this phone are deleted and replaced. This cannot be undone.';

  @override
  String get backupUnlockRetryChanged => 'Unlock your phone, then try again. Nothing was changed.';

  @override
  String get backupRestoreFailed => 'Kosha could not finish the restore. Some data may not have been written.';

  @override
  String get restoreNothingNew => 'Restored nothing new.';

  @override
  String restoreSummary(String items) {
    return 'Restored $items.';
  }

  @override
  String restoreSummarySkipped(String added, String skipped) {
    return '$added Skipped: $skipped.';
  }

  @override
  String restoreLearnedFor(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count languages', one: '1 language');
    return 'learned words for $_temp0';
  }

  @override
  String countFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count files', one: '1 file');
    return '$_temp0';
  }

  @override
  String countWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count words', one: '1 word');
    return '$_temp0';
  }

  @override
  String countLanguages(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count languages', one: '1 language');
    return '$_temp0';
  }

  @override
  String countShortcuts(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count shortcuts', one: '1 shortcut');
    return '$_temp0';
  }

  @override
  String countClipboardItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clipboard items',
      one: '1 clipboard item',
    );
    return '$_temp0';
  }

  @override
  String countThemeFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count theme files', one: '1 theme file');
    return '$_temp0';
  }

  @override
  String countPinnedItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pinned items',
      one: '1 pinned item',
    );
    return '$_temp0';
  }

  @override
  String countPacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count packs', one: '1 pack');
    return '$_temp0';
  }

  @override
  String countBlockedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocked words',
      one: '1 blocked word',
    );
    return '$_temp0';
  }

  @override
  String countTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count times', one: '1 time');
    return '$_temp0';
  }

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count minutes ago', one: '1 minute ago');
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count hours ago', one: '1 hour ago');
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count days ago', one: '1 day ago');
    return '$_temp0';
  }

  @override
  String get timeJustNow => 'just now';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String packMeta(String languages, String license, String size) {
    return '$languages · $size · $license';
  }

  @override
  String privacyLearnedWordsTitle(String language) {
    return 'Learned words ($language)';
  }

  @override
  String privacyClearLanguageTitle(String language) {
    return 'Clear $language words?';
  }

  @override
  String get privacyClearLanguageBody =>
      'This deletes every word learned in this language, and the words you blocked. It cannot be undone.';

  @override
  String get privacyClear => 'Clear';

  @override
  String get privacySaveFailed => 'Could not save the change. Try again.';

  @override
  String get privacyCouldNotReadWords => 'Kosha could not read these words.';

  @override
  String get privacyCannotReadWordsNow => 'Kosha cannot read these words right now. Unlock your phone, then try again.';

  @override
  String get privacyNoWordsLanguage =>
      'No words learned in this language yet. Kosha learns a word after you type it a few times.';

  @override
  String privacyBlockedWordsTooltip(num count) {
    return 'Blocked words ($count)';
  }

  @override
  String get privacySortTooltip => 'Sort';

  @override
  String get privacySortMostUsed => 'Most used first';

  @override
  String get privacySortAZ => 'A to Z';

  @override
  String get privacyMoreTooltip => 'More';

  @override
  String get privacyClearThisLanguage => 'Clear this language';

  @override
  String get privacySearchWords => 'Search words';

  @override
  String privacyWordsSummary(String blocked, String words) {
    return '$words · $blocked';
  }

  @override
  String get privacyNoWordsYet => 'No words yet.';

  @override
  String privacyNoWordsMatch(String query) {
    return 'No words match \"$query\".';
  }

  @override
  String get privacyNeverSuggested => 'Never suggested';

  @override
  String get privacyBlockedExplain => 'Kosha will not suggest or correct to these words.';

  @override
  String get privacyNoBlockedWords => 'No blocked words.';

  @override
  String get privacyAllowAgain => 'Allow again';

  @override
  String privacyWordLastUsed(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count times', one: '1 time');
    return 'Typed $_temp0 · last $when';
  }

  @override
  String privacyWordNotYetSuggested(String when) {
    return 'Typed once so far, not suggested yet · last $when';
  }

  @override
  String get privacyToday => 'today';

  @override
  String get privacyYesterday => 'yesterday';

  @override
  String privacyActionsFor(String word) {
    return 'Actions for $word';
  }

  @override
  String get privacyForgetWord => 'Forget this word';

  @override
  String get privacyNeverSuggestWord => 'Never suggest this word';

  @override
  String get privacyTryAgain => 'Try again';

  @override
  String get privacyCenterLoadFailed => 'Kosha could not read its privacy data. Try again later.';

  @override
  String get privacyDevBuildNetwork =>
      'This build requests internet access. Kosha should never do that. Please report it.';

  @override
  String get privacyNoInternetPermission => 'Kosha has no internet permission. It cannot send anything.';

  @override
  String get privacyDevBuildNote =>
      'This is a development build. Its network permission is for development tools only.';

  @override
  String get privacyDevBuildShort => 'Development build. Kosha still has no internet permission.';

  @override
  String privacyStorageSize(String size, String when) {
    return '$size · changed $when';
  }

  @override
  String get privacyCustomThemes => 'Custom themes';

  @override
  String get privacyNoPacks => 'None installed. Voice and translation packs appear here.';

  @override
  String privacyPacksSize(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count packs', one: '1 pack');
    return '$_temp0 · $size';
  }

  @override
  String get privacyWhatKoshaStores => 'What Kosha stores';

  @override
  String get privacyShowsSizesOnly =>
      'Kosha shows only sizes here, never what is inside. Sizes include the last saved copy, which keeps your data safe if a save is interrupted.';

  @override
  String get privacyTypingPrivacy => 'Typing privacy';

  @override
  String get privacyLearnNewWords => 'Learn new words';

  @override
  String get privacyLearnNewWordsBody =>
      'Learn words and phrases from what you type. Never in password fields or incognito.';

  @override
  String get privacyIncognito => 'Incognito';

  @override
  String get privacyIncognitoBody =>
      'Learn and remember nothing while on. Browser incognito tabs turn this on by themselves.';

  @override
  String get privacyHideScreenshots => 'Hide from screenshots';

  @override
  String get privacyHideScreenshotsBody =>
      'Stop screenshots and screen recordings of the keyboard in every app. Password fields are always hidden.';

  @override
  String get privacyAutoOffApps => 'Turned off automatically in these apps';

  @override
  String get privacyAutoOffAppsBody =>
      'Kosha keeps app names only to fill this list. They are encrypted, never recorded while incognito, and you can clear them below.';

  @override
  String get privacyNoAppsYet => 'No apps yet';

  @override
  String get privacyNoAppsYetBody => 'Apps you type in will appear here.';

  @override
  String get privacyAlwaysIncognitoApps => 'Always incognito apps';

  @override
  String get privacyPersonalShortcuts => 'Personal shortcuts';

  @override
  String get privacyOfferShortcuts => 'Offer shortcuts';

  @override
  String get privacyOfferShortcutsBody => 'Show your short forms, such as \"omw\", as the first suggestion.';

  @override
  String get privacyEditShortcuts => 'Edit shortcuts';

  @override
  String get privacyNoShortcutsYet => 'None yet';

  @override
  String get privacyLearnedAndClipboard => 'Learned words and clipboard';

  @override
  String get privacyNoWordsLearnedYet => 'No words learned yet';

  @override
  String get privacyWordsLearnedBody => 'Words you type are learned here once Kosha has seen them a few times.';

  @override
  String privacyReviewWords(String when) {
    return 'Review, remove or block words · $when';
  }

  @override
  String get privacyClipboardHistoryEmpty => 'History is empty. Change clipboard settings in Panels.';

  @override
  String privacyClipboardInHistory(String size) {
    return '$size in history. Change clipboard settings in Panels.';
  }

  @override
  String get privacyAppLock => 'App lock';

  @override
  String get privacyLockKosha => 'Lock Kosha';

  @override
  String get privacyLockKoshaBody =>
      'Ask for your fingerprint or device PIN when the app opens, or after it was in the background.';

  @override
  String get privacyLockAfter => 'Lock after';

  @override
  String get privacySetScreenLockFirst => 'Set a screen lock first';

  @override
  String get privacySetScreenLockBody =>
      'App lock uses your fingerprint or device PIN. Set a PIN, pattern or password in Android\'s security settings, then come back.';

  @override
  String get privacyTurnOnAppLockReason => 'Turn on app lock for Kosha';

  @override
  String get privacyNotAvailable => 'Not available right now';

  @override
  String get privacyNotAvailableBody => 'Your device lock could not be used. App lock stays off.';

  @override
  String get privacyBackupTitle => 'Backup';

  @override
  String get privacyBackupRestore => 'Backup and restore';

  @override
  String get privacyBackupRestoreBody => 'An encrypted .koshabackup file you keep. You choose what goes in it.';

  @override
  String get privacyDeleteData => 'Delete data';

  @override
  String get privacyEraseEverything => 'Erase everything';

  @override
  String get privacyEraseEverythingBody => 'Every category above, your custom themes, and the key that protects them.';

  @override
  String privacyDeleteTitle(String category) {
    return 'Delete $category?';
  }

  @override
  String get privacyEraseTitle => 'Erase everything?';

  @override
  String get privacyWillDelete => 'This will permanently delete:';

  @override
  String get privacyResetSettings => 'Also reset all settings to their defaults';

  @override
  String get privacyCannotBeUndone => 'This cannot be undone.';

  @override
  String get privacyDeleted => 'Deleted.';

  @override
  String get privacyDeleteFailed => 'Kosha could not delete everything. Try again.';

  @override
  String get privacyOk => 'OK';

  @override
  String get backupMakeTitle => 'Make a backup';

  @override
  String get backupIncludeImages => 'Include background images';

  @override
  String get backupPhotosLarger => 'Photos make the file much larger.';

  @override
  String get backupCreateButton => 'Create encrypted backup';

  @override
  String get backupRestoreSection => 'Restore';

  @override
  String get backupRestoreFromFile => 'Restore from a backup file';

  @override
  String get backupRestoreFromFileBody => 'Open a .koshabackup file, check what is in it, then merge or replace.';

  @override
  String get backupChoosePassphrase => 'Choose a passphrase';

  @override
  String get backupEnterPassphrase => 'Enter the passphrase';

  @override
  String get backupWriteItDown => 'Write it down somewhere safe. A lost passphrase cannot be recovered.';

  @override
  String get backupPassphrase => 'Passphrase';

  @override
  String get backupTypeAgain => 'Type it again';

  @override
  String get backupMismatch => 'The passphrases do not match';

  @override
  String backupStrength(String strength) {
    return 'Passphrase strength: $strength';
  }

  @override
  String get strengthTooShort => 'Use at least 8 characters';

  @override
  String get strengthWeak => 'Weak';

  @override
  String get strengthFair => 'Fair';

  @override
  String get strengthGood => 'Good';

  @override
  String get strengthStrong => 'Strong';

  @override
  String get backupOpen => 'Open';

  @override
  String get backupNothingYet => 'Nothing yet';

  @override
  String get backupSettingsSummary => 'Theme, languages, typing and privacy choices';

  @override
  String backupLearnedSummary(String languages, String words) {
    return '$words in $languages';
  }

  @override
  String backupPinnedOff(String items) {
    return '$items. Off unless you turn it on.';
  }

  @override
  String backupAlreadyHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shortcuts already here',
      one: '1 shortcut already here',
    );
    return '$_temp0';
  }

  @override
  String backupThemesAlreadyHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count theme files already here',
      one: '1 theme file already here',
    );
    return '$_temp0';
  }

  @override
  String get backupClipboardKept => 'clipboard left alone (unknown layout)';

  @override
  String get backupEmojiKept => 'emoji recents kept';

  @override
  String get backupSettingsApplied => 'settings';

  @override
  String backupLearnedAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count languages', one: '1 language');
    return 'learned words for $_temp0';
  }

  @override
  String shortcutDeleteTitle(String trigger) {
    return 'Delete \"$trigger\"?';
  }

  @override
  String get shortcutDeleteBody => 'This removes the shortcut. It cannot be undone.';

  @override
  String get shortcutAdd => 'Add shortcut';

  @override
  String get shortcutSearch => 'Search shortcuts';

  @override
  String get shortcutNoMatch => 'No shortcuts match your search.';

  @override
  String shortcutDeleteTooltip(String trigger) {
    return 'Delete $trigger';
  }

  @override
  String get shortcutNoneYet => 'No shortcuts yet';

  @override
  String get shortcutExplain => 'A shortcut turns a short form into longer text. Examples:';

  @override
  String shortcutExamples(String first, String second) {
    return '$first\n$second';
  }

  @override
  String get shortcutEncrypted => 'Shortcuts are encrypted on this phone, like your learned words.';

  @override
  String get shortcutNew => 'New shortcut';

  @override
  String get shortcutEdit => 'Edit shortcut';

  @override
  String get shortcutShortForm => 'Short form';

  @override
  String get shortcutExpandsTo => 'Expands to';

  @override
  String get privacyMascotLabel => 'Kosha privacy mascot';

  @override
  String get privacyStoredEmoji => 'Emoji recents';

  @override
  String get privacyStoredApps => 'Apps list';

  @override
  String get privacyStoredOther => 'Other stored data';

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
  String get shortcutProblemEmptyTrigger => 'Type the short form you want to expand.';

  @override
  String shortcutProblemTriggerTooLong(num count) {
    return 'The short form can be at most $count characters.';
  }

  @override
  String get shortcutProblemTriggerCharacters => 'Use only letters, digits and apostrophes in the short form.';

  @override
  String get shortcutProblemEmptyExpansion => 'Type what the short form should expand to.';

  @override
  String shortcutProblemExpansionTooLong(num count) {
    return 'The expansion can be at most $count characters.';
  }

  @override
  String get shortcutProblemDuplicate => 'You already have a shortcut with this short form.';

  @override
  String shortcutProblemTooMany(num count) {
    return 'You can keep at most $count shortcuts.';
  }

  @override
  String get onboardingTurnOnTitle => 'Turn on Kosha';

  @override
  String get onboardingTurnOnBody =>
      'Android keeps a list of the keyboards you have turned on. Turn Kosha on in that list, then come back here. Kosha notices the change by itself.';

  @override
  String get onboardingKeyboardOn => 'Kosha is turned on.';

  @override
  String get onboardingKeyboardOff => 'Kosha is not turned on yet.';

  @override
  String get onboardingOpenKeyboardSettings => 'Open keyboard settings';

  @override
  String get onboardingSwitchTitle => 'Switch to Kosha';

  @override
  String get onboardingSwitchBody =>
      'Choose Kosha as the keyboard you type with. Android may show a short list first. This screen updates by itself.';

  @override
  String get onboardingKeyboardIsYours => 'Kosha is your keyboard.';

  @override
  String get onboardingKeyboardNotYours => 'Kosha is not your keyboard yet.';

  @override
  String get onboardingTurnOnFirst => 'Turn Kosha on in the previous step first.';

  @override
  String get onboardingChooseKeyboard => 'Choose keyboard';

  @override
  String get onboardingCheckingPermissions => 'Checking the app permissions…';

  @override
  String get onboardingDebugInternet =>
      'This debug build can reach the internet. Debug builds have that permission for development only.';

  @override
  String get onboardingReleaseInternet => 'This build can reach the internet.';

  @override
  String get onboardingNoInternet => 'Kosha has no internet permission, so it cannot send anything anywhere.';

  @override
  String get onboardingWarningTitle => 'Why the warning does not apply';

  @override
  String get onboardingWarningBody =>
      'Android warns that any keyboard may collect what you type. That warning is about keyboards that can reach the internet. Kosha cannot.';

  @override
  String get onboardingInternetAccess => 'Internet access';

  @override
  String get onboardingEverythingHere => 'Everything stays on this phone';

  @override
  String get onboardingEverythingHereBody =>
      'Learned words, clipboard and settings are encrypted with a key in Android Keystore.';

  @override
  String get onboardingLanguagesTitle => 'Pick languages and a theme';

  @override
  String get onboardingLanguagesBody =>
      'Choose the languages you type in. Several can be on at once, and you can change them later in Languages.';

  @override
  String get onboardingThemeTitle => 'Theme';

  @override
  String get onboardingMoreThemes => 'More themes';

  @override
  String get onboardingTryTyping => 'Type a sentence';

  @override
  String get onboardingTrySwipe => 'Swipe a word: glide from letter to letter';

  @override
  String get onboardingTryAccents => 'Long-press a letter to see its accents';

  @override
  String get onboardingTryTitle => 'Try it';

  @override
  String get onboardingTryBody =>
      'Tap the box below. The keyboard appears, and you can try each thing on the checklist.';

  @override
  String get onboardingTryField => 'Try typing here';

  @override
  String get onboardingChecklist => 'Checklist';

  @override
  String get onboardingAllSetTitle => 'You are all set';

  @override
  String get onboardingAllSetBody =>
      'Kosha is ready. Everything can be changed later in Settings: languages, typing, feel, panels and themes. Tap Done to finish.';

  @override
  String get onboardingSetUp => 'Set up Kosha';

  @override
  String onboardingStepOf(String step, String total) {
    return 'Step $step of $total';
  }

  @override
  String onboardingStepFraction(String step, String total) {
    return '$step/$total';
  }

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingDone => 'Done';

  @override
  String get onboardingSearchLanguages => 'Search languages';

  @override
  String onboardingSelected(String languages) {
    return 'Selected: $languages';
  }

  @override
  String get onboardingNoLanguageMatch => 'No language matches that search.';

  @override
  String get themeCreate => 'Create theme';

  @override
  String themeSelectedLabel(String name) {
    return '$name, selected';
  }

  @override
  String themeCardOptions(String name) {
    return 'Options for $name';
  }

  @override
  String get themeEdit => 'Edit';

  @override
  String get themeDuplicate => 'Duplicate';

  @override
  String get themeRename => 'Rename';

  @override
  String get themeDeleteAction => 'Delete';

  @override
  String get themeTryTyping => 'Try typing';

  @override
  String get themeTryLabel => 'Type here to try the theme';

  @override
  String get themeTryHelper => 'The keyboard appears here when Kosha is selected.';

  @override
  String get themeRenameTitle => 'Rename theme';

  @override
  String get themeNameField => 'Name';

  @override
  String get themeEditTitle => 'Edit theme';

  @override
  String get themeNewTitle => 'New theme';

  @override
  String get themeEditorTitle => 'Theme';

  @override
  String get themeOpenFailed => 'This theme could not be opened.';

  @override
  String get themeSaveFailed => 'Could not save the theme.';

  @override
  String get themePhotoPickerFailed => 'The photo picker could not open.';

  @override
  String get themeDiscardTitle => 'Discard changes?';

  @override
  String get themeDiscardBody => 'Your changes to this theme will be lost.';

  @override
  String get themeKeepEditing => 'Keep editing';

  @override
  String get themeDiscard => 'Discard';

  @override
  String get themeSave => 'Save';

  @override
  String get themeNameRequired => 'A name is required';

  @override
  String get themeNameLabel => 'Theme name';

  @override
  String get themeDefaultName => 'My theme';

  @override
  String get themeSectionName => 'Name';

  @override
  String get themeSectionLook => 'Look';

  @override
  String get themeDarkMode => 'Dark mode';

  @override
  String get themeChoiceSystem => 'System';

  @override
  String get themeChoiceLight => 'Light';

  @override
  String get themeChoiceDark => 'Dark';

  @override
  String get themePureBlack => 'Pure black';

  @override
  String get themePureBlackBody => 'Black background';

  @override
  String get themePureBlackOnlyDark => 'Only in dark mode';

  @override
  String get themeGalleryPureBlackDark => 'Black background in dark mode';

  @override
  String get themeContrast => 'Contrast';

  @override
  String get themeChoiceStandard => 'Standard';

  @override
  String get themeChoiceMedium => 'Medium';

  @override
  String get themeChoiceHigh => 'High';

  @override
  String get themeKeyboardHeight => 'Keyboard height';

  @override
  String get themeSectionColours => 'Colours';

  @override
  String get themeSource => 'Source';

  @override
  String get themeSourceWallpaper => 'Wallpaper';

  @override
  String get themeSourceSeed => 'Seed';

  @override
  String get themeSourcePerRole => 'Per role';

  @override
  String get themeWallpaperNeedsAndroid12 => 'Wallpaper colours need Android 12 or newer.';

  @override
  String get themeSeedColour => 'Seed colour';

  @override
  String get themeScheme => 'Scheme';

  @override
  String get themeColourRoles => 'Colour roles';

  @override
  String themeEditingColours(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'dark': 'Editing the dark colours',
      'other': 'Editing the light colours',
    });
    return '$_temp0';
  }

  @override
  String get themeResetRoles => 'Reset all roles';

  @override
  String get themeKeys => 'Keys';

  @override
  String get themeShape => 'Shape';

  @override
  String get themeShapePill => 'Pill';

  @override
  String get themeShapeRounded => 'Rounded';

  @override
  String get themeShapeSquare => 'Square';

  @override
  String get themeKeyBorders => 'Key borders';

  @override
  String get themeBorderWidth => 'Border width';

  @override
  String get themeKeyGap => 'Key gap';

  @override
  String get themeFontWeight => 'Font weight';

  @override
  String get themeFontSize => 'Font size';

  @override
  String get themeHintCharacters => 'Hint characters';

  @override
  String get themeHintCharactersBody => 'Small characters on long press';

  @override
  String get themeBackground => 'Background';

  @override
  String get themeBackgroundType => 'Type';

  @override
  String get themeTypeSolid => 'Solid';

  @override
  String get themeTypeGradient => 'Gradient';

  @override
  String get themeTypePhoto => 'Photo';

  @override
  String get themeNoPhotoYet => 'No photo yet. Choose one to crop it to the keyboard.';

  @override
  String get themeChoosePhoto => 'Choose photo';

  @override
  String get themeEditCrop => 'Edit crop and blur';

  @override
  String get themeDim => 'Dim';

  @override
  String get themeSectionPopups => 'Popups and trail';

  @override
  String get themeSolidPopups => 'Solid popups';

  @override
  String get themeSolidPopupsBodyWallpaper => 'Not with wallpaper colours';

  @override
  String get themeSolidPopupsBodyPrimary => 'Popups in the primary colour';

  @override
  String get themeSwipeTrail => 'Swipe trail';

  @override
  String get themeTrailWidth => 'Trail width';

  @override
  String get themeTrailFade => 'Trail fade';

  @override
  String get themeTrailInstant => 'Instant';

  @override
  String get themeTrailColours => 'Trail colours';

  @override
  String get themeTrailStart => 'Start';

  @override
  String get themeTrailEnd => 'End';

  @override
  String get themeTrailStartTitle => 'Trail start';

  @override
  String get themeTrailEndTitle => 'Trail end';

  @override
  String get themeAutomatic => 'Automatic';

  @override
  String get themeSectionMotion => 'Motion';

  @override
  String get themeKeyPressAnimation => 'Key press animation';

  @override
  String get themeReduceMotion => 'Remove animations is on in system settings, so keys do not animate.';

  @override
  String get themeMotionOff => 'Off';

  @override
  String get themeMotionSubtle => 'Subtle';

  @override
  String get themeMotionStandard => 'Standard';

  @override
  String get themeMotionBouncy => 'Bouncy';

  @override
  String get themeSchemeTonalSpot => 'Tonal spot';

  @override
  String get themeSchemeVibrant => 'Vibrant';

  @override
  String get themeSchemeExpressive => 'Expressive';

  @override
  String get themeSchemeFidelity => 'Fidelity';

  @override
  String get themeSchemeContent => 'Content';

  @override
  String get themeSchemeMonochrome => 'Monochrome';

  @override
  String get themeSchemeNeutral => 'Neutral';

  @override
  String get themeSchemeRainbow => 'Rainbow';

  @override
  String get themeSchemeFruitSalad => 'Fruit salad';

  @override
  String themeCustomColourHex(String hex) {
    return 'Custom colour #$hex';
  }

  @override
  String get themeCustomColour => 'Custom colour';

  @override
  String themeSwatchLabel(String hex, String label) {
    return '$label colour, #$hex';
  }

  @override
  String themeUseSchemeColour(String label) {
    return 'Use the scheme colour for $label';
  }

  @override
  String get themeFromScheme => 'From the scheme';

  @override
  String get themeOverridden => 'Set';

  @override
  String themeStopLabel(String n) {
    return 'Stop $n';
  }

  @override
  String themePickStopTitle(String n) {
    return 'Stop $n';
  }

  @override
  String get themeAddStop => 'Add stop';

  @override
  String get themeRemoveStop => 'Remove stop';

  @override
  String get themeAngle => 'Angle';

  @override
  String get themeUseSchemeTooltipLabel => 'Use the scheme colour';

  @override
  String get themeCropTitle => 'Crop photo';

  @override
  String get themeUsePhoto => 'Use photo';

  @override
  String get themeCropSaveFailed => 'The photo could not be saved.';

  @override
  String get themeCropSemantics => 'Photo crop. Drag to move the photo and pinch or use the zoom slider to zoom.';

  @override
  String get themeCropZoom => 'Zoom';

  @override
  String get themeCropBlur => 'Blur';

  @override
  String get themeCropBlurOff => 'Off';

  @override
  String get themeCropNote => 'The blur is saved into the picture. The dim is set in the editor and applied live.';

  @override
  String get themeHexLabel => 'Hex';

  @override
  String get themeHexError => 'Use six hex digits, such as F5B700';

  @override
  String get themeHue => 'Hue';

  @override
  String get themeSaturation => 'Saturation';

  @override
  String get themeBrightness => 'Brightness';

  @override
  String get themePickShadeHint => 'Pick a shade, then tap Use.';

  @override
  String get themePickColourUse => 'Use';

  @override
  String get themeCopySuffix => ' copy';

  @override
  String themeCopyName(String name) {
    return '$name copy';
  }

  @override
  String themeDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get themeDeleteSelectedBody =>
      'This theme is selected. Kosha Dynamic will be used instead. This cannot be undone.';

  @override
  String get themeDeleteBody => 'This cannot be undone.';

  @override
  String get themeDeleteFailed => 'Could not delete the theme.';

  @override
  String get themeRenameFailed => 'Could not rename the theme.';

  @override
  String get themeDuplicateFailed => 'Could not copy the theme.';

  @override
  String get themeSettingFailed => 'Could not save the setting.';

  @override
  String get themeSystemColoursUnavailable => 'System colours are unavailable.';

  @override
  String get themeKoshaDynamicFollows => 'Kosha Dynamic follows your wallpaper';

  @override
  String get themeKoshaDynamicBody => 'Its colours update when the wallpaper changes';

  @override
  String get themeSectionPresets => 'Presets';

  @override
  String get themeSectionMyThemes => 'My themes';

  @override
  String get themeSectionTry => 'Try typing';

  @override
  String get themeAppearance => 'Appearance';

  @override
  String get themesTitle => 'Themes';

  @override
  String privacyThemesSize(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count theme files', one: '1 theme file');
    return '$_temp0 · $size';
  }

  @override
  String get backupUnlockToSeeCount => 'Unlock your phone to see the count';

  @override
  String get shortcutHelp =>
      'A shortcut turns a short form into longer text. Examples:\nomw → on my way\naddr → your address';

  @override
  String privacyStoredLearned(String language) {
    return 'Learned words ($language)';
  }

  @override
  String get settingsComingLater => 'Coming in a later update';

  @override
  String get backupExplainer =>
      'A backup is one file, encrypted with a passphrase you choose. Only that passphrase opens it. If you forget the passphrase, nobody can recover the backup, including Kosha.';

  @override
  String privacyCategoryLine(String detail, String title) {
    return '$title: $detail';
  }

  @override
  String get shortcutShortFormHint => 'omw';

  @override
  String get shortcutExpansionHint => 'on my way';

  @override
  String get durationMinutes15 => '15 minutes';

  @override
  String get durationHour => '1 hour';

  @override
  String get durationDay => '1 day';

  @override
  String get durationWeek => '1 week';

  @override
  String get onboardingCloseSetup => 'Close setup';

  @override
  String get packsCouldNotRead => 'Kosha could not read its packs';

  @override
  String packsDeleteTooltip(String name) {
    return 'Delete $name';
  }

  @override
  String get privacyNothingStored => 'Nothing stored yet';

  @override
  String privacyRemoveAppTooltip(String app) {
    return 'Remove $app from the list';
  }

  @override
  String get chineseTitle => 'Chinese';

  @override
  String get chineseTraditional => 'Traditional characters';

  @override
  String get chineseTraditionalBody => 'Show candidates in Traditional characters (Taiwan standard).';

  @override
  String get chineseFuzzy => 'Fuzzy pinyin';

  @override
  String get chineseFuzzyBody =>
      'Also accept z and zh, c and ch, s and sh, n and l, an and ang, en and eng, in and ing.';

  @override
  String get cjkDictionary => 'Dictionary';

  @override
  String get chineseClearPhrases => 'Clear learned phrases';

  @override
  String get chineseClearPhrasesBody => 'Forget the words you picked. The dictionary stays.';

  @override
  String get chineseFooter => 'Chinese is typed on this phone. Learned phrases are encrypted and never leave it.';

  @override
  String get chineseClearTitle => 'Clear learned phrases?';

  @override
  String get chineseClearBody => 'The words you picked for Chinese are removed. This cannot be undone.';

  @override
  String get cjkClear => 'Clear';

  @override
  String get chinesePhrasesCleared => 'Learned phrases cleared';

  @override
  String get chineseLooking => 'Looking for the dictionary';

  @override
  String get chineseDictName => 'Chinese dictionary';

  @override
  String get chinesePackMissing => 'Not installed. Chinese typing needs it; install it under Model packs.';

  @override
  String chinesePackInstalled(String license) {
    return 'Installed. $license';
  }

  @override
  String get japaneseTitle => 'Japanese';

  @override
  String get japaneseLayout => 'Layout';

  @override
  String get japaneseLayout12 => '12-key (flick)';

  @override
  String get japaneseLayoutRomaji => 'Romaji (QWERTY)';

  @override
  String get japaneseTyping => 'Typing';

  @override
  String get japaneseFlickOnly => 'Flick only';

  @override
  String get japaneseFlickOnlyBody => 'No multi-tap: tapping あ twice types ああ, not い';

  @override
  String get japaneseHalfWidth => 'Half-width space';

  @override
  String get japaneseHalfWidthBody =>
      'Space types a normal space when nothing is being typed. Off types a full-width space.';

  @override
  String get japaneseDictPack => 'Dictionary pack';

  @override
  String get japaneseChecking => 'Checking...';

  @override
  String japaneseInstalled(String name) {
    return '$name is installed. Kanji conversion is on.';
  }

  @override
  String get japaneseNotInstalled => 'Not installed. Kana still types; kanji need the pack.';

  @override
  String get japaneseClearWords => 'Clear learned words';

  @override
  String get japaneseClearWordsBody => 'Forgets the Japanese words you picked. Stored encrypted on this phone.';

  @override
  String get japaneseClearTitle => 'Clear learned Japanese words?';

  @override
  String get japaneseClearBody => 'This deletes every Japanese word you picked. It cannot be undone.';

  @override
  String get privacyStoredChinesePhrases => 'Chinese phrases';

  @override
  String get privacyStoredJapaneseWords => 'Japanese words';
}
