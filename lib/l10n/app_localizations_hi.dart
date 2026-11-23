// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Kosha';

  @override
  String get homeTagline => 'निजी टाइपिंग, इसी फ़ोन पर';

  @override
  String get homeOfflinePromise =>
      'Kosha ऑफ़लाइन काम करता है और कहीं कुछ नहीं भेजता।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get save => 'सहेजें';

  @override
  String get useAction => 'उपयोग करें';

  @override
  String get off => 'बंद';

  @override
  String get left => 'बाएँ';

  @override
  String get right => 'दाएँ';

  @override
  String get settingsLanguages => 'भाषाएँ';

  @override
  String get settingsTyping => 'टाइपिंग';

  @override
  String get settingsFeel => 'अनुभव';

  @override
  String get settingsThemes => 'थीम';

  @override
  String get settingsPanels => 'पैनल';

  @override
  String get settingsVoice => 'वॉइस';

  @override
  String get settingsTranslation => 'अनुवाद';

  @override
  String get settingsPrivacy => 'गोपनीयता';

  @override
  String get settingsAbout => 'के बारे में';

  @override
  String get settingsModelPacks => 'मॉडल पैक';

  @override
  String get homeSetupTurnOn =>
      'Android के कीबोर्ड की सूची में Kosha चालू करें।';

  @override
  String get homeSetupChoose =>
      'जिस कीबोर्ड से आप टाइप करते हैं, उसके रूप में Kosha चुनें।';

  @override
  String get homeFinishSetup => 'Kosha का सेटअप पूरा करें';

  @override
  String get homeTypingSubtitle => 'सुधार, सुझाव, कुंजियाँ और स्वाइप';

  @override
  String get homeFeelSubtitle => 'हैप्टिक्स, ध्वनि, ऊँचाई और एक-हाथ मोड';

  @override
  String get homePanelsSubtitle => 'क्लिपबोर्ड और इमोजी';

  @override
  String get homeVoiceSubtitle => 'बोलकर टाइप करें, इसी फ़ोन पर';

  @override
  String get homeTranslationSubtitle => 'टाइप करते समय अनुवाद करें, ऑफ़लाइन';

  @override
  String get homePrivacySubtitle =>
      'क्या सहेजा जाता है, इनकॉग्निटो, ऐप लॉक और बैकअप';

  @override
  String get homeAboutSubtitle => 'संस्करण, लाइसेंस और स्रोत कोड';

  @override
  String get aboutTitle => 'के बारे में';

  @override
  String aboutVersion(Object versionCode, Object versionName) {
    return 'संस्करण $versionName ($versionCode)';
  }

  @override
  String aboutVersionDebug(Object versionCode, Object versionName) {
    return 'संस्करण $versionName ($versionCode) · डीबग बिल्ड';
  }

  @override
  String get aboutReadingVersion => 'संस्करण पढ़ा जा रहा है…';

  @override
  String get aboutPrivacy => 'गोपनीयता';

  @override
  String get aboutNoInternet => 'Kosha इंटरनेट का उपयोग नहीं कर सकता';

  @override
  String get aboutNoInternetBody =>
      'रिलीज़ बिल्ड में इंटरनेट की अनुमति नहीं होती, इसलिए आप जो टाइप करते हैं वह इस फ़ोन से बाहर नहीं जाता।';

  @override
  String get aboutLicence => 'लाइसेंस';

  @override
  String get aboutGplTitle => 'GNU General Public License v3 या बाद का';

  @override
  String get aboutGplBody =>
      'Kosha मुक्त सॉफ़्टवेयर है। आप इसे GPL के तहत पढ़, बदल और साझा कर सकते हैं।';

  @override
  String get aboutSourceCode => 'स्रोत कोड';

  @override
  String get aboutSourceBody =>
      'Kosha GPL-3.0-or-later के तहत है। इसका स्रोत कोड प्रोजेक्ट पेज पर उपलब्ध है।';

  @override
  String get aboutLicences => 'लाइसेंस';

  @override
  String get aboutOpenSource => 'ओपन-सोर्स लाइसेंस';

  @override
  String get aboutOpenSourceBody =>
      'Flutter, material_ui और Kosha द्वारा उपयोग किए गए हर पैकेज';

  @override
  String get aboutTextLoadFailed => 'यह पाठ लोड नहीं हो सका।';

  @override
  String get languagesEnabledHeader => 'सक्षम, पहली भाषा डिफ़ॉल्ट है';

  @override
  String get languagesActive => 'सक्रिय भाषा';

  @override
  String get languagesAdd => 'भाषा जोड़ें';

  @override
  String get languagesAllEnabled => 'सभी भाषाएँ सक्षम हैं';

  @override
  String get languagesAllEnabledBody => 'जगह बनाने के लिए ऊपर से कोई एक हटाएँ।';

  @override
  String get languagesMultilingual => 'बहुभाषी टाइपिंग';

  @override
  String get languagesMultilingualBody =>
      'सक्षम तीन भाषाओं तक से शब्द सुझाता है, जिनकी लिपि कीबोर्ड की लिपि से मिलती है। जिस शब्द को उनमें से कोई भी जानती है, उसे कभी अपने-आप नहीं सुधारा जाता।';

  @override
  String get languagesNativeDigits => 'स्थानीय अंक';

  @override
  String get languagesNativeDigitsBody =>
      'जहाँ सक्रिय भाषा की अपनी लिपि में अंक हों, वहाँ उसी लिपि में अंक टाइप करता है (०१२, ٠١٢)।';

  @override
  String get languagesOptions => 'भाषा विकल्प';

  @override
  String get languagesZhSubtitle => 'पिनयिन, परंपरागत अक्षर और शब्दकोश पैक';

  @override
  String get languagesJaSubtitle => 'फ़्लिक इनपुट, रूपांतरण और शब्दकोश पैक';

  @override
  String languagesReorderLabel(Object language) {
    return '$language को क्रम बदलने के लिए खींचें';
  }

  @override
  String languageDefaultLabel(Object language) {
    return '$language, डिफ़ॉल्ट';
  }

  @override
  String languageLayoutTooltip(Object language) {
    return '$language का लेआउट';
  }

  @override
  String languageRemoveTooltip(Object language) {
    return '$language हटाएँ';
  }

  @override
  String get feelHaptics => 'हैप्टिक्स';

  @override
  String get feelHapticFeedback => 'हैप्टिक फ़ीडबैक';

  @override
  String get feelHapticFeedbackBody =>
      'हर कुंजी पर एक छोटा कंपन, सिस्टम सेटिंग के अनुसार';

  @override
  String get feelHapticStrength => 'हैप्टिक तीव्रता';

  @override
  String get feelSounds => 'ध्वनियाँ';

  @override
  String get feelKeySounds => 'कुंजी ध्वनियाँ';

  @override
  String get feelKeySoundsBody => 'कुंजी, स्पेस, हटाने और एंटर के लिए क्लिक';

  @override
  String get feelUseSystemVolume => 'सिस्टम वॉल्यूम का उपयोग करें';

  @override
  String get feelKeySoundVolume => 'कुंजी ध्वनि का वॉल्यूम';

  @override
  String get feelHeight => 'ऊँचाई';

  @override
  String get feelPortraitHeight => 'पोर्ट्रेट ऊँचाई';

  @override
  String get feelLandscapeHeight => 'लैंडस्केप ऊँचाई';

  @override
  String get feelOneHandedFloating => 'एक-हाथ और फ़्लोटिंग';

  @override
  String get feelOneHandedSide => 'एक-हाथ मोड की ओर';

  @override
  String get feelFloatingKeyboard => 'फ़्लोटिंग कीबोर्ड';

  @override
  String get feelFloatingBody => 'स्क्रीन पर कहीं भी खींचें';

  @override
  String get panelsClipboard => 'क्लिपबोर्ड';

  @override
  String get panelsClipboardHistory => 'क्लिपबोर्ड इतिहास';

  @override
  String get panelsClipboardHistoryBody =>
      'आप जो कॉपी करते हैं, वह इसी फ़ोन पर एन्क्रिप्ट करके रखा जाता है';

  @override
  String get panelsRecentChip => 'हाल की कॉपी चिप';

  @override
  String get panelsRecentChipBody =>
      'आपकी आखिरी कॉपी एक मिनट तक सुझाव पट्टी में दिखती है';

  @override
  String get panelsKeepUnpinned => 'बिना पिन की कॉपी इतने समय तक रखें';

  @override
  String get panelsClipsToKeep => 'रखने वाली क्लिप';

  @override
  String get panelsEmoji => 'इमोजी';

  @override
  String get emojiSuggestions => 'इमोजी सुझाव';

  @override
  String get emojiSuggestionsPanelBody =>
      'कुछ शब्दों के लिए सुझाव पट्टी में इमोजी दिखाता है';

  @override
  String get panelsPasswordsNeverSaved => 'पासवर्ड कभी सहेजे नहीं जाते';

  @override
  String get panelsSensitiveBody =>
      'Android जिन कॉपी को संवेदनशील बताता है, उन्हें कभी नहीं रखा जाता।';

  @override
  String get typingCorrections => 'सुधार';

  @override
  String get typingAutocorrect => 'स्वतः सुधार';

  @override
  String get typingAutocorrectBody =>
      'शब्द पूरा होने पर संभावित टाइपो ठीक करता है';

  @override
  String get typingAutoCapitalise => 'स्वतः बड़े अक्षर';

  @override
  String get typingAutoCapitaliseBody => 'वाक्य की शुरुआत में बड़े अक्षर';

  @override
  String get typingDoubleSpace => 'डबल स्पेस से पूर्ण विराम';

  @override
  String get typingDoubleSpaceBody =>
      'स्पेस दो बार दबाने पर \". \" लिखा जाता है';

  @override
  String get typingSmartPunctuation => 'स्मार्ट विराम चिह्न';

  @override
  String get typingSmartPunctuationBody =>
      'विराम चिह्नों के आसपास की जगह ठीक करता है और स्थानीय उद्धरण चिह्न लगाता है';

  @override
  String get typingSuggestions => 'सुझाव';

  @override
  String get typingSuggestionsBody => 'सुझाव पट्टी में शब्द दिखाता है';

  @override
  String get typingNextWord => 'अगला शब्द अनुमान';

  @override
  String get typingNextWordBody => 'वह शब्द सुझाता है जो अक्सर आता है';

  @override
  String get typingEmojiBody => 'कुछ शब्दों के लिए इमोजी सुझाता है';

  @override
  String get typingHideOffensive => 'अपमानजनक शब्द छिपाएँ';

  @override
  String get typingHideOffensiveBody =>
      'पूरे रूप में टाइप करने पर ही सुझाए जाते हैं';

  @override
  String get typingKeys => 'कुंजियाँ';

  @override
  String get typingKeyPopups => 'कुंजी पॉपअप';

  @override
  String get typingKeyPopupsBody => 'दबाते समय कुंजी को बड़ा करता है';

  @override
  String get typingLongPressDelay => 'लंबे दबाव की देरी';

  @override
  String get typingNumberRow => 'अंक पंक्ति';

  @override
  String get typingNumberRowBody => 'अक्षरों के ऊपर 0 से 9 दिखाता है';

  @override
  String get typingHintLabels => 'संकेत लेबल';

  @override
  String get typingHintLabelsBody =>
      'कुंजियों पर छोटे चिह्न, जैसे मात्राएँ या स्वर चिह्न';

  @override
  String get typingLowercaseLabels => 'छोटे अक्षरों के लेबल';

  @override
  String get typingLowercaseLabelsBody =>
      'शिफ़्ट चालू होने पर भी कुंजी के अक्षर छोटे रखता है';

  @override
  String get typingSwipe => 'स्वाइप';

  @override
  String get typingSwipeTyping => 'स्वाइप टाइपिंग';

  @override
  String get typingSwipeTypingBody =>
      'कोई शब्द लिखने के लिए अक्षरों पर फिसलाएँ';

  @override
  String get typingShowTrail => 'पथ दिखाएँ';

  @override
  String get typingTrailWidth => 'पथ की चौड़ाई';

  @override
  String get typingTrailFade => 'पथ धुंधलापन';

  @override
  String get typingLivePreview => 'लाइव पूर्वावलोकन';

  @override
  String get typingLivePreviewBody => 'फिसलते समय संभावित शब्द दिखाता है';

  @override
  String get typingSpaceMovesCursor => 'स्पेस बार कर्सर को हिलाता है';

  @override
  String get typingSpaceMovesCursorBody =>
      'कर्सर हिलाने के लिए स्पेस बार पर खींचें';

  @override
  String get typingSwipeBackspace => 'हटाएँ कुंजी पर स्वाइप करके शब्द हटाएँ';

  @override
  String get typingSwipeBackspaceBody =>
      'शब्द चुनने और हटाने के लिए हटाएँ कुंजी को बाईं ओर स्वाइप करें';

  @override
  String get voiceTyping => 'वॉइस टाइपिंग';

  @override
  String get voiceTypingBody => 'बोलकर टाइप करें। पहचान इसी फ़ोन पर होती है।';

  @override
  String get voiceRecognition => 'पहचान';

  @override
  String get voiceDetectLanguage => 'भाषा अपने-आप पहचानें';

  @override
  String get voiceDetectLanguageBody =>
      'Whisper पता लगाता है कि आप कौन सी भाषा बोलते हैं।';

  @override
  String get voiceModelPacksBody => 'वॉइस और अनुवाद पैक इंस्टॉल या हटाएँ';

  @override
  String get voiceAudioStays =>
      'ऑडियो इसी फ़ोन पर रहता है और कभी सहेजा नहीं जाता।';

  @override
  String get voicePackAutomatic => 'स्वचालित';

  @override
  String get voicePackAutomaticSelected => 'स्वचालित (चुना गया)';

  @override
  String get voicePack => 'वॉइस पैक';

  @override
  String get voiceNoPack =>
      'कोई वॉइस पैक इंस्टॉल नहीं है। मॉडल पैक के अंतर्गत एक इंस्टॉल करें।';

  @override
  String get voiceLooking => 'इंस्टॉल किए गए पैक खोजे जा रहे हैं';

  @override
  String voicePackItem(Object name, Object size) {
    return '$name · $size';
  }

  @override
  String voicePackItemSelected(Object name, Object size) {
    return '$name · $size (चुना गया)';
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
  String get packsOpenFailed => 'Kosha फ़ाइल चुनने वाला टूल नहीं खोल सका।';

  @override
  String packsInstalled(Object name) {
    return '$name इंस्टॉल किया गया।';
  }

  @override
  String packsDeleteTitle(Object name) {
    return '$name हटाएँ?';
  }

  @override
  String packsDeleted(Object name) {
    return '$name हटाया गया।';
  }

  @override
  String packsDeleteFailed(Object name) {
    return 'Kosha $name हटा नहीं सका। फिर से कोशिश करें।';
  }

  @override
  String get packsIntro =>
      'पैक इंस्टॉल होने से पहले जाँचे जाते हैं। इनमें केवल डेटा होता है, कोड कभी नहीं।';

  @override
  String get packsImport => 'आयात करें';

  @override
  String get packsImportTitle => 'पैक फ़ाइल आयात करें';

  @override
  String get packsChecking => 'जाँच और इंस्टॉल हो रहा है…';

  @override
  String get packsImportBody => 'एक .koshapack फ़ाइल, जैसे डाउनलोड से';

  @override
  String get packsNoVoice => 'कोई वॉइस पैक इंस्टॉल नहीं है';

  @override
  String get packsNoVoiceBody => 'वॉइस टाइपिंग के लिए वॉइस पैक चाहिए।';

  @override
  String get packsNoTranslation => 'कोई अनुवाद पैक इंस्टॉल नहीं है';

  @override
  String get packsNoTranslationBody => 'अनुवाद के लिए हर दिशा का एक पैक चाहिए।';

  @override
  String get packsDictionaries => 'शब्दकोश';

  @override
  String get packsNoDictionary => 'कोई शब्दकोश पैक इंस्टॉल नहीं है';

  @override
  String get packsNoDictionaryBody =>
      'चीनी और जापानी टाइपिंग के लिए शब्दकोश पैक चाहिए।';

  @override
  String get packsNothingStored => 'अभी कुछ सहेजा नहीं गया है।';

  @override
  String packsInstalledUse(Object size) {
    return 'इंस्टॉल पैक इस फ़ोन पर $size लेते हैं।';
  }

  @override
  String get packErrorBadSignature =>
      'यह पैक Kosha के लिए हस्ताक्षरित नहीं है, इसलिए कुछ भी इंस्टॉल नहीं हुआ।';

  @override
  String get packErrorBadFormat =>
      'यह फ़ाइल Kosha पैक नहीं है। कुछ भी इंस्टॉल नहीं हुआ।';

  @override
  String get packErrorTooLarge =>
      'यह पैक इस फ़ोन पर इंस्टॉल करने के लिए बहुत बड़ा है।';

  @override
  String get packErrorVersion => 'इस पैक के लिए Kosha का नया संस्करण चाहिए।';

  @override
  String get packErrorNoSpace =>
      'इस पैक को इंस्टॉल करने के लिए पर्याप्त खाली जगह नहीं है।';

  @override
  String get packErrorGeneric =>
      'पैक इंस्टॉल नहीं हो सका। कुछ भी नहीं बदला गया।';

  @override
  String get translateDefaultPair => 'डिफ़ॉल्ट भाषा जोड़ी';

  @override
  String translatePairName(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String get translateOffline => 'ऑफ़लाइन अनुवाद';

  @override
  String get translateOfflineBody =>
      'कीबोर्ड में टाइप करते समय और किसी भी ऐप में चुने गए टेक्स्ट का अनुवाद करता है।';

  @override
  String get translateDefaultPairTile => 'डिफ़ॉल्ट जोड़ी';

  @override
  String get translatePackInstalled => 'पैक इंस्टॉल है';

  @override
  String get translatePackNotInstalled =>
      'पैक इंस्टॉल नहीं है। इसे मॉडल पैक में पाएँ।';

  @override
  String get translateInstalled => 'इंस्टॉल की गई दिशाएँ';

  @override
  String get translateInstalledBody =>
      'हर दिशा एक पैक है, जैसे अंग्रेज़ी → स्पेनिश।';

  @override
  String translatePackMeta(Object license, Object size) {
    return '$size · $license';
  }

  @override
  String get translateModelPacksBody => 'अनुवाद पैक इंस्टॉल या हटाएँ';

  @override
  String get translateRunsOnPhone =>
      'अनुवाद इसी फ़ोन पर होता है। आप जो अनुवाद करते हैं, वह सहेजा नहीं जाता।';
}
