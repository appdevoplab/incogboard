// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Kosha';

  @override
  String get homeTagline => 'Pengetikan pribadi, di ponsel ini';

  @override
  String get homeOfflinePromise =>
      'Kosha berfungsi luring dan tidak mengirim apa pun ke mana pun.';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get save => 'Simpan';

  @override
  String get useAction => 'Gunakan';

  @override
  String get off => 'Nonaktif';

  @override
  String get left => 'Kiri';

  @override
  String get right => 'Kanan';

  @override
  String get settingsLanguages => 'Bahasa';

  @override
  String get settingsTyping => 'Pengetikan';

  @override
  String get settingsFeel => 'Rasa';

  @override
  String get settingsThemes => 'Tema';

  @override
  String get settingsPanels => 'Panel';

  @override
  String get settingsVoice => 'Suara';

  @override
  String get settingsTranslation => 'Terjemahan';

  @override
  String get settingsPrivacy => 'Privasi';

  @override
  String get settingsAbout => 'Tentang';

  @override
  String get settingsModelPacks => 'Paket model';

  @override
  String get homeSetupTurnOn => 'Aktifkan Kosha di daftar keyboard Android.';

  @override
  String get homeSetupChoose => 'Pilih Kosha sebagai keyboard untuk mengetik.';

  @override
  String get homeFinishSetup => 'Selesaikan pengaturan Kosha';

  @override
  String get homeTypingSubtitle => 'Koreksi, saran, tombol, dan geser';

  @override
  String get homeFeelSubtitle => 'Getaran, suara, tinggi, dan mode satu tangan';

  @override
  String get homePanelsSubtitle => 'Papan klip dan emoji';

  @override
  String get homeVoiceSubtitle => 'Bicara untuk mengetik, di ponsel ini';

  @override
  String get homeTranslationSubtitle => 'Terjemahkan saat mengetik, luring';

  @override
  String get homePrivacySubtitle =>
      'Apa yang disimpan, penyamaran, kunci aplikasi, dan cadangan';

  @override
  String get homeAboutSubtitle => 'Versi, lisensi, dan kode sumber';

  @override
  String get aboutTitle => 'Tentang';

  @override
  String aboutVersion(Object versionCode, Object versionName) {
    return 'Versi $versionName ($versionCode)';
  }

  @override
  String aboutVersionDebug(Object versionCode, Object versionName) {
    return 'Versi $versionName ($versionCode) · build debug';
  }

  @override
  String get aboutReadingVersion => 'Membaca versi…';

  @override
  String get aboutPrivacy => 'Privasi';

  @override
  String get aboutNoInternet => 'Kosha tidak dapat menggunakan internet';

  @override
  String get aboutNoInternetBody =>
      'Build rilis tidak punya izin internet, jadi tidak ada yang Anda ketik yang keluar dari ponsel ini.';

  @override
  String get aboutLicence => 'Lisensi';

  @override
  String get aboutGplTitle => 'GNU General Public License v3 atau lebih baru';

  @override
  String get aboutGplBody =>
      'Kosha adalah perangkat lunak bebas. Anda boleh mempelajari, mengubah, dan membagikannya di bawah GPL.';

  @override
  String get aboutSourceCode => 'Kode sumber';

  @override
  String get aboutSourceBody =>
      'Kosha adalah GPL-3.0-or-later. Kode sumbernya tersedia di halaman proyek.';

  @override
  String get aboutLicences => 'Lisensi';

  @override
  String get aboutOpenSource => 'Lisensi sumber terbuka';

  @override
  String get aboutOpenSourceBody =>
      'Flutter, material_ui, dan setiap paket yang dipakai Kosha';

  @override
  String get aboutTextLoadFailed => 'Teks ini tidak dapat dimuat.';

  @override
  String get languagesEnabledHeader => 'Aktif, yang pertama adalah default';

  @override
  String get languagesActive => 'Bahasa aktif';

  @override
  String get languagesAdd => 'Tambah bahasa';

  @override
  String get languagesAllEnabled => 'Semua bahasa aktif';

  @override
  String get languagesAllEnabledBody =>
      'Hapus salah satu di atas untuk memberi ruang.';

  @override
  String get languagesMultilingual => 'Pengetikan multibahasa';

  @override
  String get languagesMultilingualBody =>
      'Menyarankan kata dari hingga tiga bahasa aktif yang memakai aksara yang sama. Kata yang dikenali salah satunya tidak pernah dikoreksi otomatis.';

  @override
  String get languagesNativeDigits => 'Angka asli';

  @override
  String get languagesNativeDigitsBody =>
      'Mengetik angka dalam aksara bahasa aktif jika bahasa itu memilikinya (०१२, ٠١٢).';

  @override
  String get languagesOptions => 'Opsi bahasa';

  @override
  String get languagesZhSubtitle =>
      'Pinyin, karakter tradisional, dan paket kamus';

  @override
  String get languagesJaSubtitle => 'Input flick, konversi, dan paket kamus';

  @override
  String languagesReorderLabel(Object language) {
    return 'Seret untuk mengurutkan ulang $language';
  }

  @override
  String languageDefaultLabel(Object language) {
    return '$language, default';
  }

  @override
  String languageLayoutTooltip(Object language) {
    return 'Tata letak untuk $language';
  }

  @override
  String languageRemoveTooltip(Object language) {
    return 'Hapus $language';
  }

  @override
  String get feelHaptics => 'Haptik';

  @override
  String get feelHapticFeedback => 'Umpan balik haptik';

  @override
  String get feelHapticFeedbackBody =>
      'Getaran singkat di setiap tombol, mengikuti pengaturan sistem';

  @override
  String get feelHapticStrength => 'Kekuatan haptik';

  @override
  String get feelSounds => 'Suara';

  @override
  String get feelKeySounds => 'Suara tombol';

  @override
  String get feelKeySoundsBody => 'Klik untuk tombol, spasi, hapus, dan enter';

  @override
  String get feelUseSystemVolume => 'Gunakan volume sistem';

  @override
  String get feelKeySoundVolume => 'Volume suara tombol';

  @override
  String get feelHeight => 'Tinggi';

  @override
  String get feelPortraitHeight => 'Tinggi potret';

  @override
  String get feelLandscapeHeight => 'Tinggi lanskap';

  @override
  String get feelOneHandedFloating => 'Satu tangan dan mengambang';

  @override
  String get feelOneHandedSide => 'Sisi mode satu tangan';

  @override
  String get feelFloatingKeyboard => 'Keyboard mengambang';

  @override
  String get feelFloatingBody => 'Seret ke mana saja di layar';

  @override
  String get panelsClipboard => 'Papan klip';

  @override
  String get panelsClipboardHistory => 'Riwayat papan klip';

  @override
  String get panelsClipboardHistoryBody =>
      'Simpan yang Anda salin, terenkripsi di ponsel ini';

  @override
  String get panelsRecentChip => 'Chip salinan terbaru';

  @override
  String get panelsRecentChipBody =>
      'Tawarkan salinan terakhir Anda di bilah saran selama semenit';

  @override
  String get panelsKeepUnpinned =>
      'Simpan salinan yang tidak disematkan selama';

  @override
  String get panelsClipsToKeep => 'Klip yang disimpan';

  @override
  String get panelsEmoji => 'Emoji';

  @override
  String get emojiSuggestions => 'Saran emoji';

  @override
  String get emojiSuggestionsPanelBody =>
      'Tawarkan emoji untuk beberapa kata di bilah saran';

  @override
  String get panelsPasswordsNeverSaved => 'Kata sandi tidak pernah disimpan';

  @override
  String get panelsSensitiveBody =>
      'Salinan yang ditandai Android sebagai sensitif tidak pernah disimpan.';

  @override
  String get typingCorrections => 'Koreksi';

  @override
  String get typingAutocorrect => 'Koreksi otomatis';

  @override
  String get typingAutocorrectBody =>
      'Memperbaiki salah ketik yang mungkin saat kata selesai';

  @override
  String get typingAutoCapitalise => 'Kapitalisasi otomatis';

  @override
  String get typingAutoCapitaliseBody => 'Huruf kapital di awal kalimat';

  @override
  String get typingDoubleSpace => 'Spasi ganda untuk titik';

  @override
  String get typingDoubleSpaceBody => 'Dua ketukan spasi menulis \". \"';

  @override
  String get typingSmartPunctuation => 'Tanda baca cerdas';

  @override
  String get typingSmartPunctuationBody =>
      'Merapikan spasi di sekitar tanda baca dan memakai tanda kutip lokal';

  @override
  String get typingSuggestions => 'Saran';

  @override
  String get typingSuggestionsBody => 'Menampilkan kata di bilah saran';

  @override
  String get typingNextWord => 'Prediksi kata berikutnya';

  @override
  String get typingNextWordBody => 'Menyarankan kata yang sering mengikuti';

  @override
  String get typingEmojiBody => 'Tawarkan emoji untuk beberapa kata';

  @override
  String get typingHideOffensive => 'Sembunyikan kata kasar';

  @override
  String get typingHideOffensiveBody =>
      'Tidak pernah disarankan kecuali diketik lengkap';

  @override
  String get typingKeys => 'Tombol';

  @override
  String get typingKeyPopups => 'Popup tombol';

  @override
  String get typingKeyPopupsBody => 'Memperbesar tombol saat ditekan';

  @override
  String get typingLongPressDelay => 'Jeda tekan lama';

  @override
  String get typingNumberRow => 'Baris angka';

  @override
  String get typingNumberRowBody => 'Menampilkan 0 sampai 9 di atas huruf';

  @override
  String get typingHintLabels => 'Label petunjuk';

  @override
  String get typingHintLabelsBody => 'Simbol kecil di tombol, misalnya aksen';

  @override
  String get typingLowercaseLabels => 'Label huruf kecil';

  @override
  String get typingLowercaseLabelsBody => 'Tetap huruf kecil saat shift aktif';

  @override
  String get typingSwipe => 'Geser';

  @override
  String get typingSwipeTyping => 'Mengetik dengan geser';

  @override
  String get typingSwipeTypingBody => 'Geser di atas huruf untuk menulis kata';

  @override
  String get typingShowTrail => 'Tampilkan jejak';

  @override
  String get typingTrailWidth => 'Lebar jejak';

  @override
  String get typingTrailFade => 'Pudar jejak';

  @override
  String get typingLivePreview => 'Pratinjau langsung';

  @override
  String get typingLivePreviewBody =>
      'Menampilkan kata yang mungkin saat meluncur';

  @override
  String get typingSpaceMovesCursor => 'Bilah spasi memindahkan kursor';

  @override
  String get typingSpaceMovesCursorBody =>
      'Seret di bilah spasi untuk memindahkan kursor';

  @override
  String get typingSwipeBackspace => 'Geser hapus untuk menghapus kata';

  @override
  String get typingSwipeBackspaceBody =>
      'Geser ke kiri pada hapus untuk memilih dan menghapus kata';

  @override
  String get voiceTyping => 'Mengetik dengan suara';

  @override
  String get voiceTypingBody =>
      'Bicara untuk mengetik. Pengenalan berjalan di ponsel ini.';

  @override
  String get voiceRecognition => 'Pengenalan';

  @override
  String get voiceDetectLanguage => 'Deteksi bahasa otomatis';

  @override
  String get voiceDetectLanguageBody =>
      'Whisper mengenali bahasa yang Anda ucapkan.';

  @override
  String get voiceModelPacksBody =>
      'Pasang atau hapus paket suara dan terjemahan';

  @override
  String get voiceAudioStays =>
      'Audio tetap di ponsel ini dan tidak pernah disimpan.';

  @override
  String get voicePackAutomatic => 'Otomatis';

  @override
  String get voicePackAutomaticSelected => 'Otomatis (dipilih)';

  @override
  String get voicePack => 'Paket suara';

  @override
  String get voiceNoPack =>
      'Tidak ada paket suara terpasang. Pasang satu di Paket model.';

  @override
  String get voiceLooking => 'Mencari paket yang terpasang';

  @override
  String voicePackItem(Object name, Object size) {
    return '$name · $size';
  }

  @override
  String voicePackItemSelected(Object name, Object size) {
    return '$name · $size (dipilih)';
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
  String get packsOpenFailed => 'Kosha tidak dapat membuka pemilih file.';

  @override
  String packsInstalled(Object name) {
    return '$name dipasang.';
  }

  @override
  String packsDeleteTitle(Object name) {
    return 'Hapus $name?';
  }

  @override
  String packsDeleted(Object name) {
    return '$name dihapus.';
  }

  @override
  String packsDeleteFailed(Object name) {
    return 'Kosha tidak dapat menghapus $name. Coba lagi.';
  }

  @override
  String get packsIntro =>
      'Paket diperiksa sebelum dipasang. Isinya hanya data, tidak pernah kode.';

  @override
  String get packsImport => 'Impor';

  @override
  String get packsImportTitle => 'Impor file paket';

  @override
  String get packsChecking => 'Memeriksa dan memasang…';

  @override
  String get packsImportBody => 'File .koshapack, misalnya dari Unduhan';

  @override
  String get packsNoVoice => 'Tidak ada paket suara terpasang';

  @override
  String get packsNoVoiceBody =>
      'Mengetik dengan suara memerlukan paket suara.';

  @override
  String get packsNoTranslation => 'Tidak ada paket terjemahan terpasang';

  @override
  String get packsNoTranslationBody =>
      'Terjemahan memerlukan satu paket untuk setiap arah.';

  @override
  String get packsDictionaries => 'Kamus';

  @override
  String get packsNoDictionary => 'Tidak ada paket kamus terpasang';

  @override
  String get packsNoDictionaryBody =>
      'Mengetik bahasa Mandarin dan Jepang memerlukan paket kamus.';

  @override
  String get packsNothingStored => 'Belum ada yang disimpan.';

  @override
  String packsInstalledUse(Object size) {
    return 'Paket terpasang memakai $size di ponsel ini.';
  }

  @override
  String get packErrorBadSignature =>
      'Paket ini tidak ditandatangani untuk Kosha, jadi tidak ada yang dipasang.';

  @override
  String get packErrorBadFormat =>
      'File ini bukan paket Kosha. Tidak ada yang dipasang.';

  @override
  String get packErrorTooLarge =>
      'Paket ini terlalu besar untuk dipasang di ponsel ini.';

  @override
  String get packErrorVersion =>
      'Paket ini memerlukan versi Kosha yang lebih baru.';

  @override
  String get packErrorNoSpace =>
      'Ruang kosong tidak cukup untuk memasang paket ini.';

  @override
  String get packErrorGeneric =>
      'Paket tidak dapat dipasang. Tidak ada yang diubah.';

  @override
  String get translateDefaultPair => 'Pasangan bahasa default';

  @override
  String translatePairName(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String get translateOffline => 'Terjemahan luring';

  @override
  String get translateOfflineBody =>
      'Menerjemahkan saat mengetik di keyboard, dan teks yang dipilih di aplikasi mana pun.';

  @override
  String get translateDefaultPairTile => 'Pasangan default';

  @override
  String get translatePackInstalled => 'Paket terpasang';

  @override
  String get translatePackNotInstalled =>
      'Paket belum terpasang. Dapatkan di Paket model.';

  @override
  String get translateInstalled => 'Arah yang terpasang';

  @override
  String get translateInstalledBody =>
      'Setiap arah adalah satu paket, misalnya Inggris → Spanyol.';

  @override
  String translatePackMeta(Object license, Object size) {
    return '$size · $license';
  }

  @override
  String get translateModelPacksBody => 'Pasang atau hapus paket terjemahan';

  @override
  String get translateRunsOnPhone =>
      'Terjemahan berjalan di ponsel ini. Tidak ada yang Anda terjemahkan yang disimpan.';
}
