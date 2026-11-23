// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Kosha';

  @override
  String get homeTagline => 'Digitação privada, neste celular';

  @override
  String get homeOfflinePromise =>
      'O Kosha funciona offline e não envia nada a lugar nenhum.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get save => 'Salvar';

  @override
  String get useAction => 'Usar';

  @override
  String get off => 'Desativado';

  @override
  String get left => 'Esquerda';

  @override
  String get right => 'Direita';

  @override
  String get settingsLanguages => 'Idiomas';

  @override
  String get settingsTyping => 'Digitação';

  @override
  String get settingsFeel => 'Sensação';

  @override
  String get settingsThemes => 'Temas';

  @override
  String get settingsPanels => 'Painéis';

  @override
  String get settingsVoice => 'Voz';

  @override
  String get settingsTranslation => 'Tradução';

  @override
  String get settingsPrivacy => 'Privacidade';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsModelPacks => 'Pacotes de modelos';

  @override
  String get homeSetupTurnOn =>
      'Ative o Kosha na lista de teclados do Android.';

  @override
  String get homeSetupChoose => 'Escolha o Kosha como o teclado que você usa.';

  @override
  String get homeFinishSetup => 'Concluir a configuração do Kosha';

  @override
  String get homeTypingSubtitle => 'Correções, sugestões, teclas e deslizar';

  @override
  String get homeFeelSubtitle => 'Vibração, sons, altura e modo de uma mão';

  @override
  String get homePanelsSubtitle => 'Área de transferência e emoji';

  @override
  String get homeVoiceSubtitle => 'Fale para digitar, neste celular';

  @override
  String get homeTranslationSubtitle => 'Traduz enquanto você digita, offline';

  @override
  String get homePrivacySubtitle =>
      'O que é guardado, incógnito, bloqueio do app e backup';

  @override
  String get homeAboutSubtitle => 'Versão, licenças e código-fonte';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String aboutVersion(Object versionCode, Object versionName) {
    return 'Versão $versionName ($versionCode)';
  }

  @override
  String aboutVersionDebug(Object versionCode, Object versionName) {
    return 'Versão $versionName ($versionCode) · build de depuração';
  }

  @override
  String get aboutReadingVersion => 'Lendo a versão…';

  @override
  String get aboutPrivacy => 'Privacidade';

  @override
  String get aboutNoInternet => 'O Kosha não pode usar a internet';

  @override
  String get aboutNoInternetBody =>
      'As versões de lançamento não têm permissão de internet, então nada do que você digita sai deste celular.';

  @override
  String get aboutLicence => 'Licença';

  @override
  String get aboutGplTitle => 'Licença Pública Geral GNU v3 ou posterior';

  @override
  String get aboutGplBody =>
      'O Kosha é software livre. Você pode estudá-lo, alterá-lo e compartilhá-lo sob a GPL.';

  @override
  String get aboutSourceCode => 'Código-fonte';

  @override
  String get aboutSourceBody =>
      'O Kosha é GPL-3.0-or-later. O código-fonte está disponível na página do projeto.';

  @override
  String get aboutLicences => 'Licenças';

  @override
  String get aboutOpenSource => 'Licenças de código aberto';

  @override
  String get aboutOpenSourceBody =>
      'Flutter, material_ui e todos os pacotes que o Kosha usa';

  @override
  String get aboutTextLoadFailed => 'Não foi possível carregar este texto.';

  @override
  String get languagesEnabledHeader => 'Ativados; o primeiro é o padrão';

  @override
  String get languagesActive => 'Idioma ativo';

  @override
  String get languagesAdd => 'Adicionar um idioma';

  @override
  String get languagesAllEnabled => 'Todos os idiomas estão ativados';

  @override
  String get languagesAllEnabledBody => 'Remova um acima para abrir espaço.';

  @override
  String get languagesMultilingual => 'Digitação multilíngue';

  @override
  String get languagesMultilingualBody =>
      'Sugere palavras de até três idiomas ativados que usam a mesma escrita do teclado. Uma palavra que qualquer um deles conheça nunca é corrigida automaticamente.';

  @override
  String get languagesNativeDigits => 'Dígitos nativos';

  @override
  String get languagesNativeDigitsBody =>
      'Digita números na escrita do idioma ativo quando ele os tem (०१२, ٠١٢).';

  @override
  String get languagesOptions => 'Opções de idioma';

  @override
  String get languagesZhSubtitle =>
      'Pinyin, caracteres tradicionais e pacotes de dicionário';

  @override
  String get languagesJaSubtitle =>
      'Entrada por deslize, conversão e pacotes de dicionário';

  @override
  String languagesReorderLabel(Object language) {
    return 'Arraste para reordenar $language';
  }

  @override
  String languageDefaultLabel(Object language) {
    return '$language, padrão';
  }

  @override
  String languageLayoutTooltip(Object language) {
    return 'Layout para $language';
  }

  @override
  String languageRemoveTooltip(Object language) {
    return 'Remover $language';
  }

  @override
  String get feelHaptics => 'Háptica';

  @override
  String get feelHapticFeedback => 'Retorno tátil';

  @override
  String get feelHapticFeedbackBody =>
      'Uma vibração curta em cada tecla, seguindo a configuração do sistema';

  @override
  String get feelHapticStrength => 'Intensidade tátil';

  @override
  String get feelSounds => 'Sons';

  @override
  String get feelKeySounds => 'Sons das teclas';

  @override
  String get feelKeySoundsBody => 'Cliques para teclas, espaço, apagar e enter';

  @override
  String get feelUseSystemVolume => 'Usar o volume do sistema';

  @override
  String get feelKeySoundVolume => 'Volume dos sons das teclas';

  @override
  String get feelHeight => 'Altura';

  @override
  String get feelPortraitHeight => 'Altura em retrato';

  @override
  String get feelLandscapeHeight => 'Altura em paisagem';

  @override
  String get feelOneHandedFloating => 'Uma mão e flutuante';

  @override
  String get feelOneHandedSide => 'Lado do modo de uma mão';

  @override
  String get feelFloatingKeyboard => 'Teclado flutuante';

  @override
  String get feelFloatingBody => 'Arraste para qualquer parte da tela';

  @override
  String get panelsClipboard => 'Área de transferência';

  @override
  String get panelsClipboardHistory => 'Histórico da área de transferência';

  @override
  String get panelsClipboardHistoryBody =>
      'Guarda o que você copia, criptografado neste celular';

  @override
  String get panelsRecentChip => 'Chip de cópia recente';

  @override
  String get panelsRecentChipBody =>
      'Oferece sua última cópia na barra de sugestões por um minuto';

  @override
  String get panelsKeepUnpinned => 'Manter cópias não fixadas por';

  @override
  String get panelsClipsToKeep => 'Clipes a manter';

  @override
  String get panelsEmoji => 'Emoji';

  @override
  String get emojiSuggestions => 'Sugestões de emoji';

  @override
  String get emojiSuggestionsPanelBody =>
      'Oferece um emoji para algumas palavras na barra de sugestões';

  @override
  String get panelsPasswordsNeverSaved => 'Senhas nunca são salvas';

  @override
  String get panelsSensitiveBody =>
      'Cópias que o Android marca como sensíveis nunca são mantidas.';

  @override
  String get typingCorrections => 'Correções';

  @override
  String get typingAutocorrect => 'Autocorreção';

  @override
  String get typingAutocorrectBody =>
      'Corrige prováveis erros de digitação ao terminar uma palavra';

  @override
  String get typingAutoCapitalise => 'Maiúscula automática';

  @override
  String get typingAutoCapitaliseBody => 'Maiúsculas no início das frases';

  @override
  String get typingDoubleSpace => 'Espaço duplo para ponto';

  @override
  String get typingDoubleSpaceBody =>
      'Dois toques na barra de espaço escrevem “. ”';

  @override
  String get typingSmartPunctuation => 'Pontuação inteligente';

  @override
  String get typingSmartPunctuationBody =>
      'Ajusta espaços ao redor da pontuação e usa aspas locais';

  @override
  String get typingSuggestions => 'Sugestões';

  @override
  String get typingSuggestionsBody => 'Mostra palavras na barra de sugestões';

  @override
  String get typingNextWord => 'Previsão da próxima palavra';

  @override
  String get typingNextWordBody => 'Sugere a palavra que costuma vir depois';

  @override
  String get typingEmojiBody => 'Oferece um emoji para algumas palavras';

  @override
  String get typingHideOffensive => 'Ocultar palavras ofensivas';

  @override
  String get typingHideOffensiveBody =>
      'Nunca sugere, a menos que você os digite por completo';

  @override
  String get typingKeys => 'Teclas';

  @override
  String get typingKeyPopups => 'Pop-ups das teclas';

  @override
  String get typingKeyPopupsBody => 'Aumenta a tecla enquanto você a pressiona';

  @override
  String get typingLongPressDelay => 'Atraso do toque longo';

  @override
  String get typingNumberRow => 'Linha de números';

  @override
  String get typingNumberRowBody => 'Mostra de 0 a 9 acima das letras';

  @override
  String get typingHintLabels => 'Rótulos de dica';

  @override
  String get typingHintLabelsBody =>
      'Pequenos símbolos nas teclas, como acentos';

  @override
  String get typingLowercaseLabels => 'Rótulos em minúsculas';

  @override
  String get typingLowercaseLabelsBody =>
      'Mantém as letras em minúscula com Shift ativado';

  @override
  String get typingSwipe => 'Deslizar';

  @override
  String get typingSwipeTyping => 'Digitação por deslize';

  @override
  String get typingSwipeTypingBody =>
      'Deslize sobre as letras para escrever uma palavra';

  @override
  String get typingShowTrail => 'Mostrar o rastro';

  @override
  String get typingTrailWidth => 'Largura do rastro';

  @override
  String get typingTrailFade => 'Desvanecimento do rastro';

  @override
  String get typingLivePreview => 'Visualização ao vivo';

  @override
  String get typingLivePreviewBody =>
      'Mostra a palavra provável enquanto você desliza';

  @override
  String get typingSpaceMovesCursor => 'A barra de espaço move o cursor';

  @override
  String get typingSpaceMovesCursorBody =>
      'Arraste na barra de espaço para mover o cursor';

  @override
  String get typingSwipeBackspace => 'Deslizar em apagar para excluir palavras';

  @override
  String get typingSwipeBackspaceBody =>
      'Deslize para a esquerda em apagar para selecionar e excluir palavras';

  @override
  String get voiceTyping => 'Digitação por voz';

  @override
  String get voiceTypingBody =>
      'Fale para digitar. O reconhecimento roda neste celular.';

  @override
  String get voiceRecognition => 'Reconhecimento';

  @override
  String get voiceDetectLanguage => 'Detectar o idioma automaticamente';

  @override
  String get voiceDetectLanguageBody =>
      'O Whisper descobre em qual idioma você fala.';

  @override
  String get voiceModelPacksBody =>
      'Instalar ou remover pacotes de voz e tradução';

  @override
  String get voiceAudioStays => 'O áudio fica neste celular e nunca é salvo.';

  @override
  String get voicePackAutomatic => 'Automático';

  @override
  String get voicePackAutomaticSelected => 'Automático (selecionado)';

  @override
  String get voicePack => 'Pacote de voz';

  @override
  String get voiceNoPack =>
      'Nenhum pacote de voz está instalado. Instale um em Pacotes de modelos.';

  @override
  String get voiceLooking => 'Procurando pacotes instalados';

  @override
  String voicePackItem(Object name, Object size) {
    return '$name · $size';
  }

  @override
  String voicePackItemSelected(Object name, Object size) {
    return '$name · $size (selecionado)';
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
  String get packsOpenFailed =>
      'O Kosha não conseguiu abrir o seletor de arquivos.';

  @override
  String packsInstalled(Object name) {
    return '$name instalado.';
  }

  @override
  String packsDeleteTitle(Object name) {
    return 'Excluir $name?';
  }

  @override
  String packsDeleted(Object name) {
    return '$name excluído.';
  }

  @override
  String packsDeleteFailed(Object name) {
    return 'O Kosha não conseguiu excluir $name. Tente de novo.';
  }

  @override
  String get packsIntro =>
      'Os pacotes são verificados antes de serem instalados. Contêm apenas dados, nunca código.';

  @override
  String get packsImport => 'Importar';

  @override
  String get packsImportTitle => 'Importar um arquivo de pacote';

  @override
  String get packsChecking => 'Verificando e instalando…';

  @override
  String get packsImportBody =>
      'Um arquivo .koshapack, por exemplo dos Downloads';

  @override
  String get packsNoVoice => 'Nenhum pacote de voz instalado';

  @override
  String get packsNoVoiceBody =>
      'A digitação por voz precisa de um pacote de voz.';

  @override
  String get packsNoTranslation => 'Nenhum pacote de tradução instalado';

  @override
  String get packsNoTranslationBody =>
      'A tradução precisa de um pacote para cada direção.';

  @override
  String get packsDictionaries => 'Dicionários';

  @override
  String get packsNoDictionary => 'Nenhum pacote de dicionário instalado';

  @override
  String get packsNoDictionaryBody =>
      'A digitação em chinês e japonês precisa de um pacote de dicionário.';

  @override
  String get packsNothingStored => 'Nada guardado ainda.';

  @override
  String packsInstalledUse(Object size) {
    return 'Os pacotes instalados usam $size neste celular.';
  }

  @override
  String get packErrorBadSignature =>
      'Este pacote não está assinado para o Kosha, então nada foi instalado.';

  @override
  String get packErrorBadFormat =>
      'Este arquivo não é um pacote do Kosha. Nada foi instalado.';

  @override
  String get packErrorTooLarge =>
      'Este pacote é grande demais para este celular.';

  @override
  String get packErrorVersion =>
      'Este pacote precisa de uma versão mais nova do Kosha.';

  @override
  String get packErrorNoSpace =>
      'Não há espaço livre suficiente para instalar este pacote.';

  @override
  String get packErrorGeneric =>
      'Não foi possível instalar o pacote. Nada foi alterado.';

  @override
  String get translateDefaultPair => 'Par de idiomas padrão';

  @override
  String translatePairName(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String get translateOffline => 'Tradução offline';

  @override
  String get translateOfflineBody =>
      'Traduz enquanto você digita no teclado e o texto selecionado em qualquer app.';

  @override
  String get translateDefaultPairTile => 'Par padrão';

  @override
  String get translatePackInstalled => 'Pacote instalado';

  @override
  String get translatePackNotInstalled =>
      'Pacote não instalado. Obtenha-o em Pacotes de modelos.';

  @override
  String get translateInstalled => 'Direções instaladas';

  @override
  String get translateInstalledBody =>
      'Cada direção é um pacote, por exemplo inglês → espanhol.';

  @override
  String translatePackMeta(Object license, Object size) {
    return '$size · $license';
  }

  @override
  String get translateModelPacksBody =>
      'Instalar ou excluir pacotes de tradução';

  @override
  String get translateRunsOnPhone =>
      'A tradução roda neste celular. Nada do que você traduz é salvo.';
}
