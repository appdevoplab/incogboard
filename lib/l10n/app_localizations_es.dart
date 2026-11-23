// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Kosha';

  @override
  String get homeTagline => 'Escritura privada, en este teléfono';

  @override
  String get homeOfflinePromise =>
      'Kosha funciona sin conexión y no envía nada a ningún sitio.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get useAction => 'Usar';

  @override
  String get off => 'Desactivado';

  @override
  String get left => 'Izquierda';

  @override
  String get right => 'Derecha';

  @override
  String get settingsLanguages => 'Idiomas';

  @override
  String get settingsTyping => 'Escritura';

  @override
  String get settingsFeel => 'Sensación';

  @override
  String get settingsThemes => 'Temas';

  @override
  String get settingsPanels => 'Paneles';

  @override
  String get settingsVoice => 'Voz';

  @override
  String get settingsTranslation => 'Traducción';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsModelPacks => 'Paquetes de modelos';

  @override
  String get homeSetupTurnOn =>
      'Activa Kosha en la lista de teclados de Android.';

  @override
  String get homeSetupChoose =>
      'Elige Kosha como el teclado con el que escribes.';

  @override
  String get homeFinishSetup => 'Termina de configurar Kosha';

  @override
  String get homeTypingSubtitle =>
      'Correcciones, sugerencias, teclas y deslizar';

  @override
  String get homeFeelSubtitle =>
      'Vibración, sonidos, altura y modo de una mano';

  @override
  String get homePanelsSubtitle => 'Portapapeles y emoji';

  @override
  String get homeVoiceSubtitle => 'Habla para escribir, en este teléfono';

  @override
  String get homeTranslationSubtitle =>
      'Traduce mientras escribes, sin conexión';

  @override
  String get homePrivacySubtitle =>
      'Qué se guarda, incógnito, bloqueo de la app y copia de seguridad';

  @override
  String get homeAboutSubtitle => 'Versión, licencias y código fuente';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String aboutVersion(Object versionCode, Object versionName) {
    return 'Versión $versionName ($versionCode)';
  }

  @override
  String aboutVersionDebug(Object versionCode, Object versionName) {
    return 'Versión $versionName ($versionCode) · compilación de depuración';
  }

  @override
  String get aboutReadingVersion => 'Leyendo la versión…';

  @override
  String get aboutPrivacy => 'Privacidad';

  @override
  String get aboutNoInternet => 'Kosha no puede usar Internet';

  @override
  String get aboutNoInternetBody =>
      'Las versiones publicadas no tienen permiso de Internet, así que nada de lo que escribes sale de este teléfono.';

  @override
  String get aboutLicence => 'Licencia';

  @override
  String get aboutGplTitle => 'Licencia Pública General GNU v3 o posterior';

  @override
  String get aboutGplBody =>
      'Kosha es software libre. Puedes estudiarlo, modificarlo y compartirlo bajo la GPL.';

  @override
  String get aboutSourceCode => 'Código fuente';

  @override
  String get aboutSourceBody =>
      'Kosha es GPL-3.0-or-later. Su código fuente está disponible en la página del proyecto.';

  @override
  String get aboutLicences => 'Licencias';

  @override
  String get aboutOpenSource => 'Licencias de código abierto';

  @override
  String get aboutOpenSourceBody =>
      'Flutter, material_ui y cada paquete que usa Kosha';

  @override
  String get aboutTextLoadFailed => 'No se pudo cargar este texto.';

  @override
  String get languagesEnabledHeader =>
      'Activados; el primero es el predeterminado';

  @override
  String get languagesActive => 'Idioma activo';

  @override
  String get languagesAdd => 'Añadir un idioma';

  @override
  String get languagesAllEnabled => 'Todos los idiomas están activados';

  @override
  String get languagesAllEnabledBody =>
      'Quita uno de arriba para dejar espacio.';

  @override
  String get languagesMultilingual => 'Escritura multilingüe';

  @override
  String get languagesMultilingualBody =>
      'Sugiere palabras de hasta tres idiomas activados que comparten la escritura del teclado. Una palabra que cualquiera de ellos conoce nunca se corrige automáticamente.';

  @override
  String get languagesNativeDigits => 'Dígitos nativos';

  @override
  String get languagesNativeDigitsBody =>
      'Escribe dígitos en la escritura del idioma activo cuando lo tenga (०१२, ٠١٢).';

  @override
  String get languagesOptions => 'Opciones de idioma';

  @override
  String get languagesZhSubtitle =>
      'Pinyin, caracteres tradicionales y paquetes de diccionario';

  @override
  String get languagesJaSubtitle =>
      'Entrada por deslizamiento, conversión y paquetes de diccionario';

  @override
  String languagesReorderLabel(Object language) {
    return 'Arrastra para reordenar $language';
  }

  @override
  String languageDefaultLabel(Object language) {
    return '$language, predeterminado';
  }

  @override
  String languageLayoutTooltip(Object language) {
    return 'Distribución para $language';
  }

  @override
  String languageRemoveTooltip(Object language) {
    return 'Quitar $language';
  }

  @override
  String get feelHaptics => 'Háptica';

  @override
  String get feelHapticFeedback => 'Respuesta háptica';

  @override
  String get feelHapticFeedbackBody =>
      'Una vibración corta en cada tecla, según el ajuste del sistema';

  @override
  String get feelHapticStrength => 'Intensidad háptica';

  @override
  String get feelSounds => 'Sonidos';

  @override
  String get feelKeySounds => 'Sonidos de tecla';

  @override
  String get feelKeySoundsBody => 'Clics para teclas, espacio, borrar e intro';

  @override
  String get feelUseSystemVolume => 'Usar el volumen del sistema';

  @override
  String get feelKeySoundVolume => 'Volumen de sonido de tecla';

  @override
  String get feelHeight => 'Altura';

  @override
  String get feelPortraitHeight => 'Altura en vertical';

  @override
  String get feelLandscapeHeight => 'Altura en horizontal';

  @override
  String get feelOneHandedFloating => 'Una mano y flotante';

  @override
  String get feelOneHandedSide => 'Lado del modo de una mano';

  @override
  String get feelFloatingKeyboard => 'Teclado flotante';

  @override
  String get feelFloatingBody => 'Arrástralo a cualquier parte de la pantalla';

  @override
  String get panelsClipboard => 'Portapapeles';

  @override
  String get panelsClipboardHistory => 'Historial del portapapeles';

  @override
  String get panelsClipboardHistoryBody =>
      'Guarda lo que copias, cifrado en este teléfono';

  @override
  String get panelsRecentChip => 'Chip de copia reciente';

  @override
  String get panelsRecentChipBody =>
      'Ofrece tu última copia en la barra de sugerencias durante un minuto';

  @override
  String get panelsKeepUnpinned => 'Guardar copias no fijadas durante';

  @override
  String get panelsClipsToKeep => 'Clips que conservar';

  @override
  String get panelsEmoji => 'Emoji';

  @override
  String get emojiSuggestions => 'Sugerencias de emoji';

  @override
  String get emojiSuggestionsPanelBody =>
      'Ofrece un emoji para algunas palabras en la barra de sugerencias';

  @override
  String get panelsPasswordsNeverSaved => 'Las contraseñas nunca se guardan';

  @override
  String get panelsSensitiveBody =>
      'Las copias que Android marca como sensibles nunca se guardan.';

  @override
  String get typingCorrections => 'Correcciones';

  @override
  String get typingAutocorrect => 'Autocorrección';

  @override
  String get typingAutocorrectBody =>
      'Corrige las erratas probables al terminar una palabra';

  @override
  String get typingAutoCapitalise => 'Mayúscula automática';

  @override
  String get typingAutoCapitaliseBody =>
      'Mayúsculas al inicio de las oraciones';

  @override
  String get typingDoubleSpace => 'Espacio doble para punto';

  @override
  String get typingDoubleSpaceBody =>
      'Dos toques en la barra espaciadora escriben \". \"';

  @override
  String get typingSmartPunctuation => 'Puntuación inteligente';

  @override
  String get typingSmartPunctuationBody =>
      'Ordena los espacios alrededor de los signos y usa comillas locales';

  @override
  String get typingSuggestions => 'Sugerencias';

  @override
  String get typingSuggestionsBody =>
      'Muestra palabras en la barra de sugerencias';

  @override
  String get typingNextWord => 'Predicción de la siguiente palabra';

  @override
  String get typingNextWordBody => 'Sugiere la palabra que suele seguir';

  @override
  String get typingEmojiBody => 'Ofrece un emoji para algunas palabras';

  @override
  String get typingHideOffensive => 'Ocultar palabras ofensivas';

  @override
  String get typingHideOffensiveBody =>
      'Nunca los sugiere, salvo que los escribas completos';

  @override
  String get typingKeys => 'Teclas';

  @override
  String get typingKeyPopups => 'Ventanas emergentes de tecla';

  @override
  String get typingKeyPopupsBody => 'Agranda una tecla mientras la pulsas';

  @override
  String get typingLongPressDelay => 'Retardo de pulsación larga';

  @override
  String get typingNumberRow => 'Fila de números';

  @override
  String get typingNumberRowBody => 'Muestra del 0 al 9 encima de las letras';

  @override
  String get typingHintLabels => 'Etiquetas de ayuda';

  @override
  String get typingHintLabelsBody =>
      'Símbolos pequeños en las teclas, como los acentos';

  @override
  String get typingLowercaseLabels => 'Etiquetas en minúscula';

  @override
  String get typingLowercaseLabelsBody =>
      'Mantiene las letras en minúscula con Mayús activado';

  @override
  String get typingSwipe => 'Deslizar';

  @override
  String get typingSwipeTyping => 'Escritura por deslizamiento';

  @override
  String get typingSwipeTypingBody =>
      'Desliza sobre las letras para escribir una palabra';

  @override
  String get typingShowTrail => 'Mostrar el rastro';

  @override
  String get typingTrailWidth => 'Ancho del rastro';

  @override
  String get typingTrailFade => 'Desvanecimiento del rastro';

  @override
  String get typingLivePreview => 'Vista previa en vivo';

  @override
  String get typingLivePreviewBody =>
      'Muestra la palabra probable mientras deslizas';

  @override
  String get typingSpaceMovesCursor => 'La barra espaciadora mueve el cursor';

  @override
  String get typingSpaceMovesCursorBody =>
      'Arrastra sobre la barra espaciadora para mover el cursor';

  @override
  String get typingSwipeBackspace =>
      'Deslizar en borrar para eliminar palabras';

  @override
  String get typingSwipeBackspaceBody =>
      'Desliza a la izquierda en borrar para seleccionar y eliminar palabras';

  @override
  String get voiceTyping => 'Escritura por voz';

  @override
  String get voiceTypingBody =>
      'Habla para escribir. El reconocimiento se hace en este teléfono.';

  @override
  String get voiceRecognition => 'Reconocimiento';

  @override
  String get voiceDetectLanguage => 'Detectar el idioma automáticamente';

  @override
  String get voiceDetectLanguageBody => 'Whisper detecta en qué idioma hablas.';

  @override
  String get voiceModelPacksBody =>
      'Instala o quita paquetes de voz y traducción';

  @override
  String get voiceAudioStays =>
      'El audio se queda en este teléfono y nunca se guarda.';

  @override
  String get voicePackAutomatic => 'Automático';

  @override
  String get voicePackAutomaticSelected => 'Automático (seleccionado)';

  @override
  String get voicePack => 'Paquete de voz';

  @override
  String get voiceNoPack =>
      'No hay ningún paquete de voz instalado. Instala uno en Paquetes de modelos.';

  @override
  String get voiceLooking => 'Buscando paquetes instalados';

  @override
  String voicePackItem(Object name, Object size) {
    return '$name · $size';
  }

  @override
  String voicePackItemSelected(Object name, Object size) {
    return '$name · $size (seleccionado)';
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
  String get packsOpenFailed => 'Kosha no pudo abrir el selector de archivos.';

  @override
  String packsInstalled(Object name) {
    return 'Se instaló $name.';
  }

  @override
  String packsDeleteTitle(Object name) {
    return '¿Eliminar $name?';
  }

  @override
  String packsDeleted(Object name) {
    return 'Se eliminó $name.';
  }

  @override
  String packsDeleteFailed(Object name) {
    return 'Kosha no pudo eliminar $name. Inténtalo de nuevo.';
  }

  @override
  String get packsIntro =>
      'Los paquetes se verifican antes de instalarse. Contienen solo datos, nunca código.';

  @override
  String get packsImport => 'Importar';

  @override
  String get packsImportTitle => 'Importar un archivo de paquete';

  @override
  String get packsChecking => 'Comprobando e instalando…';

  @override
  String get packsImportBody =>
      'Un archivo .koshapack, por ejemplo de Descargas';

  @override
  String get packsNoVoice => 'No hay paquetes de voz instalados';

  @override
  String get packsNoVoiceBody =>
      'La escritura por voz necesita un paquete de voz.';

  @override
  String get packsNoTranslation => 'No hay paquetes de traducción instalados';

  @override
  String get packsNoTranslationBody =>
      'La traducción necesita un paquete por cada dirección.';

  @override
  String get packsDictionaries => 'Diccionarios';

  @override
  String get packsNoDictionary => 'No hay paquetes de diccionario instalados';

  @override
  String get packsNoDictionaryBody =>
      'La escritura en chino y japonés necesita un paquete de diccionario.';

  @override
  String get packsNothingStored => 'Todavía no hay nada guardado.';

  @override
  String packsInstalledUse(Object size) {
    return 'Los paquetes instalados usan $size en este teléfono.';
  }

  @override
  String get packErrorBadSignature =>
      'Este paquete no está firmado para Kosha, así que no se instaló nada.';

  @override
  String get packErrorBadFormat =>
      'Este archivo no es un paquete de Kosha. No se instaló nada.';

  @override
  String get packErrorTooLarge =>
      'Este paquete es demasiado grande para instalarlo en este teléfono.';

  @override
  String get packErrorVersion =>
      'Este paquete necesita una versión más nueva de Kosha.';

  @override
  String get packErrorNoSpace =>
      'No hay suficiente espacio libre para instalar este paquete.';

  @override
  String get packErrorGeneric =>
      'No se pudo instalar el paquete. No se cambió nada.';

  @override
  String get translateDefaultPair => 'Par de idiomas predeterminado';

  @override
  String translatePairName(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String get translateOffline => 'Traducción sin conexión';

  @override
  String get translateOfflineBody =>
      'Traduce mientras escribes en el teclado y el texto seleccionado en cualquier app.';

  @override
  String get translateDefaultPairTile => 'Par predeterminado';

  @override
  String get translatePackInstalled => 'Paquete instalado';

  @override
  String get translatePackNotInstalled =>
      'Paquete no instalado. Consíguelo en Paquetes de modelos.';

  @override
  String get translateInstalled => 'Direcciones instaladas';

  @override
  String get translateInstalledBody =>
      'Cada dirección es un paquete, por ejemplo inglés → español.';

  @override
  String translatePackMeta(Object license, Object size) {
    return '$size · $license';
  }

  @override
  String get translateModelPacksBody =>
      'Instala o elimina paquetes de traducción';

  @override
  String get translateRunsOnPhone =>
      'La traducción se hace en este teléfono. Nada de lo que traduces se guarda.';
}
