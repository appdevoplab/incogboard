// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Kosha';

  @override
  String get homeTagline => 'Saisie privée, sur ce téléphone';

  @override
  String get homeOfflinePromise =>
      'Kosha fonctionne hors ligne et n\'envoie rien nulle part.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get useAction => 'Utiliser';

  @override
  String get off => 'Désactivé';

  @override
  String get left => 'Gauche';

  @override
  String get right => 'Droite';

  @override
  String get settingsLanguages => 'Langues';

  @override
  String get settingsTyping => 'Saisie';

  @override
  String get settingsFeel => 'Ressenti';

  @override
  String get settingsThemes => 'Thèmes';

  @override
  String get settingsPanels => 'Panneaux';

  @override
  String get settingsVoice => 'Voix';

  @override
  String get settingsTranslation => 'Traduction';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsModelPacks => 'Packs de modèles';

  @override
  String get homeSetupTurnOn =>
      'Activez Kosha dans la liste des claviers d\'Android.';

  @override
  String get homeSetupChoose => 'Choisissez Kosha comme clavier de saisie.';

  @override
  String get homeFinishSetup => 'Terminer la configuration de Kosha';

  @override
  String get homeTypingSubtitle =>
      'Corrections, suggestions, touches et glissement';

  @override
  String get homeFeelSubtitle => 'Vibrations, sons, hauteur et mode une main';

  @override
  String get homePanelsSubtitle => 'Presse-papiers et emoji';

  @override
  String get homeVoiceSubtitle => 'Parlez pour écrire, sur ce téléphone';

  @override
  String get homeTranslationSubtitle => 'Traduit pendant la frappe, hors ligne';

  @override
  String get homePrivacySubtitle =>
      'Ce qui est stocké, incognito, verrouillage et sauvegarde';

  @override
  String get homeAboutSubtitle => 'Version, licences et code source';

  @override
  String get aboutTitle => 'À propos';

  @override
  String aboutVersion(Object versionCode, Object versionName) {
    return 'Version $versionName ($versionCode)';
  }

  @override
  String aboutVersionDebug(Object versionCode, Object versionName) {
    return 'Version $versionName ($versionCode) · version de débogage';
  }

  @override
  String get aboutReadingVersion => 'Lecture de la version…';

  @override
  String get aboutPrivacy => 'Confidentialité';

  @override
  String get aboutNoInternet => 'Kosha ne peut pas utiliser Internet';

  @override
  String get aboutNoInternetBody =>
      'Les versions publiées n\'ont pas l\'autorisation Internet : rien de ce que vous saisissez ne quitte ce téléphone.';

  @override
  String get aboutLicence => 'Licence';

  @override
  String get aboutGplTitle => 'Licence publique générale GNU v3 ou ultérieure';

  @override
  String get aboutGplBody =>
      'Kosha est un logiciel libre. Vous pouvez l\'étudier, le modifier et le partager selon la GPL.';

  @override
  String get aboutSourceCode => 'Code source';

  @override
  String get aboutSourceBody =>
      'Kosha est sous GPL-3.0-or-later. Son code source est disponible sur la page du projet.';

  @override
  String get aboutLicences => 'Licences';

  @override
  String get aboutOpenSource => 'Licences open source';

  @override
  String get aboutOpenSourceBody =>
      'Flutter, material_ui et chaque paquet utilisé par Kosha';

  @override
  String get aboutTextLoadFailed => 'Ce texte n\'a pas pu être chargé.';

  @override
  String get languagesEnabledHeader =>
      'Activées ; la première est celle par défaut';

  @override
  String get languagesActive => 'Langue active';

  @override
  String get languagesAdd => 'Ajouter une langue';

  @override
  String get languagesAllEnabled => 'Toutes les langues sont activées';

  @override
  String get languagesAllEnabledBody =>
      'Retirez-en une ci-dessus pour faire de la place.';

  @override
  String get languagesMultilingual => 'Saisie multilingue';

  @override
  String get languagesMultilingualBody =>
      'Suggère des mots issus d\'au plus trois langues activées qui partagent l\'écriture du clavier. Un mot connu de l\'une d\'elles n\'est jamais corrigé automatiquement.';

  @override
  String get languagesNativeDigits => 'Chiffres natifs';

  @override
  String get languagesNativeDigitsBody =>
      'Saisit les chiffres dans l\'écriture de la langue active lorsqu\'elle en a (०१२, ٠١٢).';

  @override
  String get languagesOptions => 'Options de langue';

  @override
  String get languagesZhSubtitle =>
      'Pinyin, caractères traditionnels et paquets de dictionnaires';

  @override
  String get languagesJaSubtitle =>
      'Saisie par glissement, conversion et paquets de dictionnaires';

  @override
  String languagesReorderLabel(Object language) {
    return 'Faites glisser pour réordonner $language';
  }

  @override
  String languageDefaultLabel(Object language) {
    return '$language, par défaut';
  }

  @override
  String languageLayoutTooltip(Object language) {
    return 'Disposition pour $language';
  }

  @override
  String languageRemoveTooltip(Object language) {
    return 'Retirer $language';
  }

  @override
  String get feelHaptics => 'Haptique';

  @override
  String get feelHapticFeedback => 'Retour haptique';

  @override
  String get feelHapticFeedbackBody =>
      'Une courte vibration à chaque touche, selon le réglage du système';

  @override
  String get feelHapticStrength => 'Intensité haptique';

  @override
  String get feelSounds => 'Sons';

  @override
  String get feelKeySounds => 'Sons des touches';

  @override
  String get feelKeySoundsBody =>
      'Clics pour les touches, espace, effacer et entrée';

  @override
  String get feelUseSystemVolume => 'Utiliser le volume du système';

  @override
  String get feelKeySoundVolume => 'Volume des sons de touche';

  @override
  String get feelHeight => 'Hauteur';

  @override
  String get feelPortraitHeight => 'Hauteur en portrait';

  @override
  String get feelLandscapeHeight => 'Hauteur en paysage';

  @override
  String get feelOneHandedFloating => 'Une main et flottant';

  @override
  String get feelOneHandedSide => 'Côté du mode une main';

  @override
  String get feelFloatingKeyboard => 'Clavier flottant';

  @override
  String get feelFloatingBody => 'Faites-le glisser n\'importe où sur l\'écran';

  @override
  String get panelsClipboard => 'Presse-papiers';

  @override
  String get panelsClipboardHistory => 'Historique du presse-papiers';

  @override
  String get panelsClipboardHistoryBody =>
      'Garde ce que vous copiez, chiffré sur ce téléphone';

  @override
  String get panelsRecentChip => 'Pastille de copie récente';

  @override
  String get panelsRecentChipBody =>
      'Propose votre dernière copie dans la barre de suggestions pendant une minute';

  @override
  String get panelsKeepUnpinned => 'Garder les copies non épinglées pendant';

  @override
  String get panelsClipsToKeep => 'Clips à conserver';

  @override
  String get panelsEmoji => 'Emoji';

  @override
  String get emojiSuggestions => 'Suggestions d\'emoji';

  @override
  String get emojiSuggestionsPanelBody =>
      'Propose un emoji pour certains mots dans la barre de suggestions';

  @override
  String get panelsPasswordsNeverSaved =>
      'Les mots de passe ne sont jamais enregistrés';

  @override
  String get panelsSensitiveBody =>
      'Les copies qu\'Android marque comme sensibles ne sont jamais conservées.';

  @override
  String get typingCorrections => 'Corrections';

  @override
  String get typingAutocorrect => 'Correction automatique';

  @override
  String get typingAutocorrectBody =>
      'Corrige les fautes probables à la fin d\'un mot';

  @override
  String get typingAutoCapitalise => 'Majuscules automatiques';

  @override
  String get typingAutoCapitaliseBody => 'Majuscules au début des phrases';

  @override
  String get typingDoubleSpace => 'Double espace pour le point';

  @override
  String get typingDoubleSpaceBody => 'Deux appuis sur espace écrivent « . »';

  @override
  String get typingSmartPunctuation => 'Ponctuation intelligente';

  @override
  String get typingSmartPunctuationBody =>
      'Ajuste les espaces autour de la ponctuation et utilise les guillemets locaux';

  @override
  String get typingSuggestions => 'Suggestions';

  @override
  String get typingSuggestionsBody =>
      'Affiche des mots dans la barre de suggestions';

  @override
  String get typingNextWord => 'Prédiction du mot suivant';

  @override
  String get typingNextWordBody => 'Suggère le mot qui suit souvent';

  @override
  String get typingEmojiBody => 'Propose un emoji pour certains mots';

  @override
  String get typingHideOffensive => 'Masquer les mots offensants';

  @override
  String get typingHideOffensiveBody =>
      'Ne jamais les suggérer, sauf si vous les tapez en entier';

  @override
  String get typingKeys => 'Touches';

  @override
  String get typingKeyPopups => 'Bulles des touches';

  @override
  String get typingKeyPopupsBody => 'Agrandit une touche pendant l\'appui';

  @override
  String get typingLongPressDelay => 'Délai d\'appui long';

  @override
  String get typingNumberRow => 'Rangée de chiffres';

  @override
  String get typingNumberRowBody => 'Affiche de 0 à 9 au-dessus des lettres';

  @override
  String get typingHintLabels => 'Indications sur les touches';

  @override
  String get typingHintLabelsBody =>
      'Petits symboles sur les touches, comme les accents';

  @override
  String get typingLowercaseLabels => 'Étiquettes en minuscules';

  @override
  String get typingLowercaseLabelsBody =>
      'Garde les lettres en minuscules quand Maj est activé';

  @override
  String get typingSwipe => 'Glissement';

  @override
  String get typingSwipeTyping => 'Saisie par glissement';

  @override
  String get typingSwipeTypingBody =>
      'Glissez sur les lettres pour écrire un mot';

  @override
  String get typingShowTrail => 'Afficher la trace';

  @override
  String get typingTrailWidth => 'Largeur de la trace';

  @override
  String get typingTrailFade => 'Estompage de la trace';

  @override
  String get typingLivePreview => 'Aperçu en direct';

  @override
  String get typingLivePreviewBody =>
      'Affiche le mot probable pendant le glissement';

  @override
  String get typingSpaceMovesCursor => 'La barre d\'espace déplace le curseur';

  @override
  String get typingSpaceMovesCursorBody =>
      'Faites glisser sur la barre d\'espace pour déplacer le curseur';

  @override
  String get typingSwipeBackspace =>
      'Glisser sur effacer pour supprimer des mots';

  @override
  String get typingSwipeBackspaceBody =>
      'Glissez vers la gauche sur effacer pour sélectionner et supprimer des mots';

  @override
  String get voiceTyping => 'Saisie vocale';

  @override
  String get voiceTypingBody =>
      'Parlez pour écrire. La reconnaissance se fait sur ce téléphone.';

  @override
  String get voiceRecognition => 'Reconnaissance';

  @override
  String get voiceDetectLanguage => 'Détecter la langue automatiquement';

  @override
  String get voiceDetectLanguageBody =>
      'Whisper détermine la langue que vous parlez.';

  @override
  String get voiceModelPacksBody =>
      'Installer ou supprimer les packs de voix et de traduction';

  @override
  String get voiceAudioStays =>
      'L\'audio reste sur ce téléphone et n\'est jamais enregistré.';

  @override
  String get voicePackAutomatic => 'Automatique';

  @override
  String get voicePackAutomaticSelected => 'Automatique (sélectionné)';

  @override
  String get voicePack => 'Pack de voix';

  @override
  String get voiceNoPack =>
      'Aucun pack de voix installé. Installez-en un dans Packs de modèles.';

  @override
  String get voiceLooking => 'Recherche des packs installés';

  @override
  String voicePackItem(Object name, Object size) {
    return '$name · $size';
  }

  @override
  String voicePackItemSelected(Object name, Object size) {
    return '$name · $size (sélectionné)';
  }

  @override
  String megabytes(Object count) {
    return '$count Mo';
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
  String get packsOpenFailed =>
      'Kosha n\'a pas pu ouvrir le sélecteur de fichiers.';

  @override
  String packsInstalled(Object name) {
    return '$name installé.';
  }

  @override
  String packsDeleteTitle(Object name) {
    return 'Supprimer $name ?';
  }

  @override
  String packsDeleted(Object name) {
    return '$name supprimé.';
  }

  @override
  String packsDeleteFailed(Object name) {
    return 'Kosha n\'a pas pu supprimer $name. Réessayez.';
  }

  @override
  String get packsIntro =>
      'Les packs sont vérifiés avant d\'être installés. Ils ne contiennent que des données, jamais du code.';

  @override
  String get packsImport => 'Importer';

  @override
  String get packsImportTitle => 'Importer un fichier de pack';

  @override
  String get packsChecking => 'Vérification et installation…';

  @override
  String get packsImportBody =>
      'Un fichier .koshapack, par exemple depuis Téléchargements';

  @override
  String get packsNoVoice => 'Aucun pack de voix installé';

  @override
  String get packsNoVoiceBody => 'La saisie vocale nécessite un pack de voix.';

  @override
  String get packsNoTranslation => 'Aucun pack de traduction installé';

  @override
  String get packsNoTranslationBody =>
      'La traduction nécessite un pack par sens.';

  @override
  String get packsDictionaries => 'Dictionnaires';

  @override
  String get packsNoDictionary => 'Aucun pack de dictionnaire installé';

  @override
  String get packsNoDictionaryBody =>
      'La saisie en chinois et en japonais nécessite un pack de dictionnaire.';

  @override
  String get packsNothingStored => 'Rien n\'est encore stocké.';

  @override
  String packsInstalledUse(Object size) {
    return 'Les packs installés occupent $size sur ce téléphone.';
  }

  @override
  String get packErrorBadSignature =>
      'Ce pack n\'est pas signé pour Kosha : rien n\'a été installé.';

  @override
  String get packErrorBadFormat =>
      'Ce fichier n\'est pas un pack Kosha. Rien n\'a été installé.';

  @override
  String get packErrorTooLarge =>
      'Ce pack est trop volumineux pour ce téléphone.';

  @override
  String get packErrorVersion =>
      'Ce pack nécessite une version plus récente de Kosha.';

  @override
  String get packErrorNoSpace =>
      'Il n\'y a pas assez d\'espace libre pour installer ce pack.';

  @override
  String get packErrorGeneric =>
      'Le pack n\'a pas pu être installé. Rien n\'a été modifié.';

  @override
  String get translateDefaultPair => 'Paire de langues par défaut';

  @override
  String translatePairName(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String get translateOffline => 'Traduction hors ligne';

  @override
  String get translateOfflineBody =>
      'Traduit pendant la frappe au clavier, et le texte sélectionné dans toute appli.';

  @override
  String get translateDefaultPairTile => 'Paire par défaut';

  @override
  String get translatePackInstalled => 'Pack installé';

  @override
  String get translatePackNotInstalled =>
      'Pack non installé. Obtenez-le dans Packs de modèles.';

  @override
  String get translateInstalled => 'Sens installés';

  @override
  String get translateInstalledBody =>
      'Chaque sens est un pack, par exemple anglais → espagnol.';

  @override
  String translatePackMeta(Object license, Object size) {
    return '$size · $license';
  }

  @override
  String get translateModelPacksBody =>
      'Installer ou supprimer les packs de traduction';

  @override
  String get translateRunsOnPhone =>
      'La traduction se fait sur ce téléphone. Rien de ce que vous traduisez n\'est enregistré.';
}
