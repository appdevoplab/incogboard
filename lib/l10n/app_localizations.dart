import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('pt'),
  ];

  /// The app's name. Never translated; keep it as it is in every language
  ///
  /// In en, this message translates to:
  /// **'Kosha'**
  String get appName;

  /// Home screen header, under the app name. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Private typing, on this phone'**
  String get homeTagline;

  /// Home screen header: the privacy promise. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Kosha works offline and sends nothing anywhere.'**
  String get homeOfflinePromise;

  /// Dialog and sheet cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button and menu item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Confirms a picked colour or photo, button. Max 12 characters
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get useAction;

  /// Setting is off, short value label. Max 10 characters
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// Side choice for one-handed mode. Max 10 characters
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// Side choice for one-handed mode. Max 10 characters
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// Home row and section title for languages
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get settingsLanguages;

  /// Home row and section title for typing
  ///
  /// In en, this message translates to:
  /// **'Typing'**
  String get settingsTyping;

  /// Home row and title for the feel screen. Max 16 characters
  ///
  /// In en, this message translates to:
  /// **'Feel'**
  String get settingsFeel;

  /// Home row and title for themes. Max 16 characters
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get settingsThemes;

  /// Home row and title for panels. Max 16 characters
  ///
  /// In en, this message translates to:
  /// **'Panels'**
  String get settingsPanels;

  /// Home row and title for voice. Max 16 characters
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get settingsVoice;

  /// Home row and title for translation. Max 24 characters
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get settingsTranslation;

  /// Home row and title for privacy. Max 16 characters
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// Home row and title for About. Max 16 characters
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Title of the packs screen, and a row that opens it. Max 24 characters
  ///
  /// In en, this message translates to:
  /// **'Model packs'**
  String get settingsModelPacks;

  /// Home hint while Kosha is off. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Turn Kosha on in Android\'s keyboard list.'**
  String get homeSetupTurnOn;

  /// Home hint when Kosha is on but not chosen. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Choose Kosha as the keyboard you type with.'**
  String get homeSetupChoose;

  /// Home card title while setup is unfinished. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Finish setting up Kosha'**
  String get homeFinishSetup;

  /// Home row subtitle for typing. Max 60 characters
  ///
  /// In en, this message translates to:
  /// **'Corrections, suggestions, keys and swipe'**
  String get homeTypingSubtitle;

  /// Home row subtitle for feel. Max 60 characters
  ///
  /// In en, this message translates to:
  /// **'Haptics, sounds, height and one-handed mode'**
  String get homeFeelSubtitle;

  /// Home row subtitle for panels. Max 60 characters
  ///
  /// In en, this message translates to:
  /// **'Clipboard and emoji'**
  String get homePanelsSubtitle;

  /// Home row subtitle for voice. Max 60 characters
  ///
  /// In en, this message translates to:
  /// **'Speak to type, on this phone'**
  String get homeVoiceSubtitle;

  /// Home row subtitle for translation. Max 60 characters
  ///
  /// In en, this message translates to:
  /// **'Translate as you type, offline'**
  String get homeTranslationSubtitle;

  /// Home row subtitle for privacy. Max 60 characters
  ///
  /// In en, this message translates to:
  /// **'What is stored, incognito, app lock and backup'**
  String get homePrivacySubtitle;

  /// Home row subtitle for About. Max 60 characters
  ///
  /// In en, this message translates to:
  /// **'Version, licences and source code'**
  String get homeAboutSubtitle;

  /// Title of the About screen. Max 24 characters
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// About screen: app version under the name. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Version {versionName} ({versionCode})'**
  String aboutVersion(Object versionCode, Object versionName);

  /// About screen: version line in a debug build. Max 60 characters
  ///
  /// In en, this message translates to:
  /// **'Version {versionName} ({versionCode}) · debug build'**
  String aboutVersionDebug(Object versionCode, Object versionName);

  /// About screen: shown while the version loads
  ///
  /// In en, this message translates to:
  /// **'Reading version…'**
  String get aboutReadingVersion;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get aboutPrivacy;

  /// About privacy tile title. Max 50 characters
  ///
  /// In en, this message translates to:
  /// **'Kosha cannot use the internet'**
  String get aboutNoInternet;

  /// About privacy tile. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Release builds have no internet permission, so nothing you type leaves this phone.'**
  String get aboutNoInternetBody;

  /// About section title. British spelling, as in the app
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get aboutLicence;

  /// About licence tile title. Keep the licence name
  ///
  /// In en, this message translates to:
  /// **'GNU General Public Licence v3 or later'**
  String get aboutGplTitle;

  /// About licence tile. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Kosha is free software. You may study, change and share it under the GPL.'**
  String get aboutGplBody;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSourceCode;

  /// About source tile. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Kosha is GPL-3.0-or-later. Its source code is available from the project page.'**
  String get aboutSourceBody;

  /// About section title, for the open-source list
  ///
  /// In en, this message translates to:
  /// **'Licences'**
  String get aboutLicences;

  /// About tile title. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get aboutOpenSource;

  /// About tile subtitle. Lists the libraries. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Flutter, material_ui and every package Kosha uses'**
  String get aboutOpenSourceBody;

  /// About screen: a licence text failed to load
  ///
  /// In en, this message translates to:
  /// **'This text could not be loaded.'**
  String get aboutTextLoadFailed;

  /// Languages: list heading. The first language is the default. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Enabled, first is the default'**
  String get languagesEnabledHeader;

  /// Languages: the language the keyboard is using now. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Active language'**
  String get languagesActive;

  /// Languages: adds a language to the list. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Add a language'**
  String get languagesAdd;

  /// Languages: shown when all are on. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Every language is enabled'**
  String get languagesAllEnabled;

  /// Languages: hint under the message above. Max 50 characters
  ///
  /// In en, this message translates to:
  /// **'Remove one above to make room.'**
  String get languagesAllEnabledBody;

  /// Languages: title of the multilingual section. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Multilingual typing'**
  String get languagesMultilingual;

  /// Languages: explains multilingual typing. Three lines at most
  ///
  /// In en, this message translates to:
  /// **'Suggest words from up to three enabled languages that share the layout\'s script. A word that any of them knows is never auto-corrected.'**
  String get languagesMultilingualBody;

  /// Languages: title of the digits setting. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Native digits'**
  String get languagesNativeDigits;

  /// Languages: explains native digits. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Type digits in the script of the active language where it has them (०१२, ٠١٢).'**
  String get languagesNativeDigitsBody;

  /// Languages: section for Chinese and Japanese options. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Language options'**
  String get languagesOptions;

  /// Languages: Chinese row subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Pinyin, Traditional characters and dictionary packs'**
  String get languagesZhSubtitle;

  /// Languages: Japanese row subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Flick input, conversion and dictionary packs'**
  String get languagesJaSubtitle;

  /// Languages: accessibility label of the drag handle. {language} is a language name
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder {language}'**
  String languagesReorderLabel(Object language);

  /// Languages: label for the first language. {language} is a language name
  ///
  /// In en, this message translates to:
  /// **'{language}, default'**
  String languageDefaultLabel(Object language);

  /// Languages: tooltip on the layout button. {language} is a language name. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Layout for {language}'**
  String languageLayoutTooltip(Object language);

  /// Languages: tooltip on the remove button. {language} is a language name. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Remove {language}'**
  String languageRemoveTooltip(Object language);

  /// Feel: section title
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get feelHaptics;

  /// Feel: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get feelHapticFeedback;

  /// Feel: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'A short vibration on each key, following the system setting'**
  String get feelHapticFeedbackBody;

  /// Feel: slider title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Haptic strength'**
  String get feelHapticStrength;

  /// Feel: section title
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get feelSounds;

  /// Feel: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Key sounds'**
  String get feelKeySounds;

  /// Feel: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Clicks for keys, space, delete and enter'**
  String get feelKeySoundsBody;

  /// Feel: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Use system volume'**
  String get feelUseSystemVolume;

  /// Feel: slider title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Key sound volume'**
  String get feelKeySoundVolume;

  /// Feel: section title
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get feelHeight;

  /// Feel: slider title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Portrait height'**
  String get feelPortraitHeight;

  /// Feel: slider title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Landscape height'**
  String get feelLandscapeHeight;

  /// Feel: section title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'One-handed and floating'**
  String get feelOneHandedFloating;

  /// Feel: label above the side choice. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'One-handed side'**
  String get feelOneHandedSide;

  /// Feel: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Floating keyboard'**
  String get feelFloatingKeyboard;

  /// Feel: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Drag it anywhere on the screen'**
  String get feelFloatingBody;

  /// Panels: section title
  ///
  /// In en, this message translates to:
  /// **'Clipboard'**
  String get panelsClipboard;

  /// Panels: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Clipboard history'**
  String get panelsClipboardHistory;

  /// Panels: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Keep what you copy, encrypted on this phone'**
  String get panelsClipboardHistoryBody;

  /// Panels: switch title for the last-copy chip. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Recent-copy chip'**
  String get panelsRecentChip;

  /// Panels: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Offer your last copy in the suggestion bar for a minute'**
  String get panelsRecentChipBody;

  /// Panels: label above the duration choice. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Keep unpinned copies for'**
  String get panelsKeepUnpinned;

  /// Panels: slider title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Clips to keep'**
  String get panelsClipsToKeep;

  /// Panels: section title
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get panelsEmoji;

  /// Emoji suggestions switch title, in Panels and Typing. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Emoji suggestions'**
  String get emojiSuggestions;

  /// Panels: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Offer an emoji for some words in the suggestion bar'**
  String get emojiSuggestionsPanelBody;

  /// Panels: switch title. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Passwords are never saved'**
  String get panelsPasswordsNeverSaved;

  /// Panels: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Copies that Android marks as sensitive are never kept.'**
  String get panelsSensitiveBody;

  /// Typing: section title
  ///
  /// In en, this message translates to:
  /// **'Corrections'**
  String get typingCorrections;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Autocorrect'**
  String get typingAutocorrect;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Fix likely typos as you finish a word'**
  String get typingAutocorrectBody;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Auto-capitalise'**
  String get typingAutoCapitalise;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Capital letters at the start of sentences'**
  String get typingAutoCapitaliseBody;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Double-space full stop'**
  String get typingDoubleSpace;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Two taps of space write \". \"'**
  String get typingDoubleSpaceBody;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Smart punctuation'**
  String get typingSmartPunctuation;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Tidy spaces around punctuation and use local quotes'**
  String get typingSmartPunctuationBody;

  /// Typing: section and switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get typingSuggestions;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Show words in the suggestion bar'**
  String get typingSuggestionsBody;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Next-word prediction'**
  String get typingNextWord;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Suggest the word that often follows'**
  String get typingNextWordBody;

  /// Typing: emoji switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Offer an emoji for some words'**
  String get typingEmojiBody;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Hide offensive words'**
  String get typingHideOffensive;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Never suggest them unless you type them in full'**
  String get typingHideOffensiveBody;

  /// Typing: section title
  ///
  /// In en, this message translates to:
  /// **'Keys'**
  String get typingKeys;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Key popups'**
  String get typingKeyPopups;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Enlarge a key while you press it'**
  String get typingKeyPopupsBody;

  /// Typing: slider title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Long-press delay'**
  String get typingLongPressDelay;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Number row'**
  String get typingNumberRow;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Show 0 to 9 above the letters'**
  String get typingNumberRowBody;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Hint labels'**
  String get typingHintLabels;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Small symbols on keys, such as accents'**
  String get typingHintLabelsBody;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Lowercase labels'**
  String get typingLowercaseLabels;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Keep key letters lowercase when shift is on'**
  String get typingLowercaseLabelsBody;

  /// Typing: section title
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get typingSwipe;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Swipe typing'**
  String get typingSwipeTyping;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Glide across letters to write a word'**
  String get typingSwipeTypingBody;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Show trail'**
  String get typingShowTrail;

  /// Typing: slider title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Trail width'**
  String get typingTrailWidth;

  /// Typing: slider title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Trail fade'**
  String get typingTrailFade;

  /// Typing: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get typingLivePreview;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Show the likely word while you glide'**
  String get typingLivePreviewBody;

  /// Typing: switch title. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Space bar moves the cursor'**
  String get typingSpaceMovesCursor;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Drag on the space bar to move the cursor'**
  String get typingSpaceMovesCursorBody;

  /// Typing: switch title. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Swipe backspace to delete words'**
  String get typingSwipeBackspace;

  /// Typing: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Slide left on backspace to select and delete words'**
  String get typingSwipeBackspaceBody;

  /// Voice: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Voice typing'**
  String get voiceTyping;

  /// Voice: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Speak to type. Recognition runs on this phone.'**
  String get voiceTypingBody;

  /// Voice: section title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Recognition'**
  String get voiceRecognition;

  /// Voice: switch title. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Detect language automatically'**
  String get voiceDetectLanguage;

  /// Voice: switch subtitle. Two lines at most. Whisper is the product name of the speech model
  ///
  /// In en, this message translates to:
  /// **'Whisper works out which language you speak.'**
  String get voiceDetectLanguageBody;

  /// Voice and Translation: row subtitle for model packs. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Install or remove voice and translation packs'**
  String get voiceModelPacksBody;

  /// Voice: footnote under the mic. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Audio stays on this phone and is never saved.'**
  String get voiceAudioStays;

  /// Voice pack choice: the best installed pack. Max 20 characters
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get voicePackAutomatic;

  /// Voice pack choice when Automatic is in use. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Automatic (selected)'**
  String get voicePackAutomaticSelected;

  /// Voice pack picker title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Voice pack'**
  String get voicePack;

  /// Voice pack picker: shown when none is installed. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'No voice pack is installed. Install one under Model packs.'**
  String get voiceNoPack;

  /// Voice pack picker: shown while the packs load. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'Looking for installed packs'**
  String get voiceLooking;

  /// Voice pack picker: a pack with its size. {name} is the pack name, {size} is a size such as 120 MB
  ///
  /// In en, this message translates to:
  /// **'{name} · {size}'**
  String voicePackItem(Object name, Object size);

  /// Voice pack picker: the chosen pack with its size. {name} is the pack name, {size} a size
  ///
  /// In en, this message translates to:
  /// **'{name} · {size} (selected)'**
  String voicePackItemSelected(Object name, Object size);

  /// A size in megabytes, such as 120 MB. {count} is a number
  ///
  /// In en, this message translates to:
  /// **'{count} MB'**
  String megabytes(Object count);

  /// A duration in milliseconds. {count} is a number. Max 12 characters
  ///
  /// In en, this message translates to:
  /// **'{count} ms'**
  String milliseconds(Object count);

  /// A size in density-independent pixels. {count} is a number. Max 12 characters
  ///
  /// In en, this message translates to:
  /// **'{count} dp'**
  String dpValue(Object count);

  /// Packs: shown when the file picker fails
  ///
  /// In en, this message translates to:
  /// **'Kosha could not open the file picker.'**
  String get packsOpenFailed;

  /// Packs: snackbar after a pack installs. {name} is the pack name
  ///
  /// In en, this message translates to:
  /// **'Installed {name}.'**
  String packsInstalled(Object name);

  /// Packs: dialog title before a pack is deleted. {name} is the pack name
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String packsDeleteTitle(Object name);

  /// Packs: snackbar after a pack is deleted. {name} is the pack name
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}.'**
  String packsDeleted(Object name);

  /// Packs: shown when a delete fails. {name} is the pack name
  ///
  /// In en, this message translates to:
  /// **'Kosha could not delete {name}. Try again.'**
  String packsDeleteFailed(Object name);

  /// Packs: explains packs. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Packs are checked before they are installed. They contain data only, never code.'**
  String get packsIntro;

  /// Packs: section title
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get packsImport;

  /// Packs: row title for importing. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Import a pack file'**
  String get packsImportTitle;

  /// Packs: row subtitle while an import runs
  ///
  /// In en, this message translates to:
  /// **'Checking and installing…'**
  String get packsChecking;

  /// Packs: row subtitle. Two lines at most. .koshapack is a file extension
  ///
  /// In en, this message translates to:
  /// **'A .koshapack file, for example from Downloads'**
  String get packsImportBody;

  /// Packs: empty state in Voice. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'No voice packs installed'**
  String get packsNoVoice;

  /// Packs: empty state detail. Max 60 characters
  ///
  /// In en, this message translates to:
  /// **'Voice typing needs a voice pack.'**
  String get packsNoVoiceBody;

  /// Packs: empty state in Translation. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'No translation packs installed'**
  String get packsNoTranslation;

  /// Packs: empty state detail. Max 60 characters
  ///
  /// In en, this message translates to:
  /// **'Translation needs one pack for each direction.'**
  String get packsNoTranslationBody;

  /// Packs: section title
  ///
  /// In en, this message translates to:
  /// **'Dictionaries'**
  String get packsDictionaries;

  /// Packs: empty state in Dictionaries. Max 40 characters
  ///
  /// In en, this message translates to:
  /// **'No dictionary packs installed'**
  String get packsNoDictionary;

  /// Packs: empty state detail. Max 60 characters
  ///
  /// In en, this message translates to:
  /// **'Chinese and Japanese typing need a dictionary pack.'**
  String get packsNoDictionaryBody;

  /// Packs: footer when no pack is installed
  ///
  /// In en, this message translates to:
  /// **'Nothing stored yet.'**
  String get packsNothingStored;

  /// Packs: footer with the total size. {size} is a size such as 300 MB
  ///
  /// In en, this message translates to:
  /// **'Installed packs use {size} on this phone.'**
  String packsInstalledUse(Object size);

  /// Pack install error: the signature is wrong. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'This pack is not signed for Kosha, so nothing was installed.'**
  String get packErrorBadSignature;

  /// Pack install error: wrong file. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'This file is not a Kosha pack. Nothing was installed.'**
  String get packErrorBadFormat;

  /// Pack install error: too big. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'This pack is too large to install on this phone.'**
  String get packErrorTooLarge;

  /// Pack install error: version too old. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'This pack needs a newer version of Kosha.'**
  String get packErrorVersion;

  /// Pack install error: no storage. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'There is not enough free space to install this pack.'**
  String get packErrorNoSpace;

  /// Pack install error: any other failure. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'The pack could not be installed. Nothing was changed.'**
  String get packErrorGeneric;

  /// Translation: section title for the default pair. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Default language pair'**
  String get translateDefaultPair;

  /// Translation: a language pair. {from} and {to} are language names
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String translatePairName(Object from, Object to);

  /// Translation: switch title. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Offline translation'**
  String get translateOffline;

  /// Translation: switch subtitle. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Translate as you type in the keyboard, and selected text in any app.'**
  String get translateOfflineBody;

  /// Translation: row title for the default pair. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Default pair'**
  String get translateDefaultPairTile;

  /// Translation: status of a pair with its pack. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Pack installed'**
  String get translatePackInstalled;

  /// Translation: status of a pair without its pack. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Pack not installed. Get it in Model packs.'**
  String get translatePackNotInstalled;

  /// Translation: section title for installed packs. Max 30 characters
  ///
  /// In en, this message translates to:
  /// **'Installed directions'**
  String get translateInstalled;

  /// Translation: explains installed directions. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Each direction is one pack, for example English → Spanish.'**
  String get translateInstalledBody;

  /// Translation: a pack's size and licence. {size} is a size, {license} a licence name
  ///
  /// In en, this message translates to:
  /// **'{size} · {license}'**
  String translatePackMeta(Object license, Object size);

  /// Translation: row subtitle for model packs. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Install or delete translation packs'**
  String get translateModelPacksBody;

  /// Translation: footnote. Two lines at most
  ///
  /// In en, this message translates to:
  /// **'Translation runs on this phone. Nothing you translate is saved.'**
  String get translateRunsOnPhone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
