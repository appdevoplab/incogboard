// Pigeon contract between the Kotlin shell and Dart.
// Regenerate with:  dart run pigeon --input pigeons/messages.dart
//
// This file is a FROZEN CONTRACT for parallel work. Only the orchestrator edits it.
// Feature agents that need a new call describe it in their report instead.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/bridge/messages.g.dart',
    dartOptions: DartOptions(),
    kotlinOut: 'android/app/src/main/kotlin/app/myna/keyboard/bridge/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'app.myna.keyboard.bridge'),
    copyrightHeader: 'pigeons/copyright.txt',
    dartPackageName: 'myna',
  ),
)
// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------
/// Snapshot of android.view.inputmethod.EditorInfo (raw values; decode in Dart
/// with InputFieldInfo).
class EditorInfoMessage {
  EditorInfoMessage({
    required this.inputType,
    required this.imeOptions,
    required this.actionId,
    required this.fieldId,
    required this.initialSelStart,
    required this.initialSelEnd,
    required this.initialCapsMode,
  });
  int inputType;
  int imeOptions;
  int actionId;
  String? actionLabel;
  String? packageName;
  String? hintText;
  int fieldId;
  int initialSelStart;
  int initialSelEnd;
  int initialCapsMode;
  String? privateImeOptions;
  List<String>? contentMimeTypes;
}

class SelectionMessage {
  SelectionMessage({
    required this.oldSelStart,
    required this.oldSelEnd,
    required this.newSelStart,
    required this.newSelEnd,
    required this.candidatesStart,
    required this.candidatesEnd,
  });
  int oldSelStart;
  int oldSelEnd;
  int newSelStart;
  int newSelEnd;

  /// Composing region reported by the editor, -1 when none.
  int candidatesStart;
  int candidatesEnd;
}

class SurroundingTextMessage {
  SurroundingTextMessage({
    required this.text,
    required this.selectionStart,
    required this.selectionEnd,
    required this.offset,
  });
  String text;

  /// Relative to [text].
  int selectionStart;
  int selectionEnd;

  /// Absolute editor offset of text[0], -1 when unknown.
  int offset;
}

class ClipMessage {
  ClipMessage({required this.text, required this.timestampMillis, required this.isSensitive});
  String text;
  int timestampMillis;

  /// ClipDescription.EXTRA_IS_SENSITIVE (Android 13+). Never store these.
  bool isSensitive;
}

class WindowMetricsMessage {
  WindowMetricsMessage({
    required this.screenWidthPx,
    required this.screenHeightPx,
    required this.density,
    required this.navigationBarInsetPx,
    required this.isLandscape,
    required this.smallestScreenWidthDp,
    required this.fontScale,
    required this.isNightMode,
  });
  int screenWidthPx;
  int screenHeightPx;
  double density;
  int navigationBarInsetPx;
  bool isLandscape;
  int smallestScreenWidthDp;
  double fontScale;
  bool isNightMode;
}

/// Material You palettes (Android 12+): 5 palettes x 13 tones (ARGB), in
/// order accent1, accent2, accent3, neutral1, neutral2 and tones
/// 0,10,50,100,200,300,400,500,600,700,800,900,1000.
class SystemColorsMessage {
  SystemColorsMessage({required this.palettes, required this.isNightMode});
  List<int> palettes;
  bool isNightMode;
}

class RectMessage {
  RectMessage({required this.left, required this.top, required this.width, required this.height});

  /// Logical pixels (dp), relative to the keyboard content area.
  double left;
  double top;
  double width;
  double height;
}

enum WindowMode { docked, floating }

class WindowLayoutMessage {
  WindowLayoutMessage({required this.mode, required this.heightDp});
  WindowMode mode;

  /// Total height of the keyboard view in dp, INCLUDING the bottom inset
  /// (Dart adds MediaQuery.viewPadding.bottom: the gesture bar / IME
  /// navigation buttons live there). Kotlin applies it verbatim.
  double heightDp;

  /// Floating mode only: the visible keyboard rect inside the IME window.
  RectMessage? floatingRect;
}

enum HapticKind { keyTap, keyLongPress, repeatTick, gestureStart, gestureCommit, toggle, error }

enum KeySoundKind { standard, space, delete, enter }

class FeedbackConfigMessage {
  FeedbackConfigMessage({
    required this.hapticsEnabled,
    required this.hapticStrength,
    required this.soundsEnabled,
    required this.soundVolume,
  });
  bool hapticsEnabled;

  /// 0..1
  double hapticStrength;
  bool soundsEnabled;

  /// 0..1, or -1 for the system default volume.
  double soundVolume;
}

enum ContextMenuAction {
  selectAll,
  cut,
  copy,
  paste,
  pasteAsPlainText,
  undo,
  redo,
  startSelectingText,
  stopSelectingText,
}

/// One blob in the encrypted store (for the privacy center's "what is stored" list).
class SecureBlobInfo {
  SecureBlobInfo({required this.name, required this.sizeBytes, required this.modifiedMillis});

  /// The name passed to secureWrite.
  String name;

  /// Encrypted size on disk, including the last-good backup copy.
  int sizeBytes;
  int modifiedMillis;
}

class AppInfoMessage {
  AppInfoMessage({
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.sdkInt,
    required this.isDebugBuild,
  });
  String packageName;
  String versionName;
  int versionCode;
  int sdkInt;
  bool isDebugBuild;
}

// ---------------------------------------------------------------------------
// Dart -> Kotlin
// ---------------------------------------------------------------------------

/// Registered only on the keyboard (IME) engine.
@HostApi()
abstract class ImeHostApi {
  // InputConnection ---------------------------------------------------------
  bool commitText(String text, int newCursorPosition);
  bool setComposingText(String text, int newCursorPosition);
  bool setComposingRegion(int start, int end);
  bool finishComposingText();
  bool deleteSurroundingText(int beforeLength, int afterLength);
  bool deleteSurroundingTextInCodePoints(int beforeLength, int afterLength);
  bool sendDownUpKeyEvent(int keyCode, int metaState);
  bool performEditorAction(int actionId);
  bool performContextMenuAction(ContextMenuAction action);
  bool setSelection(int start, int end);
  String? getTextBeforeCursor(int length);
  String? getTextAfterCursor(int length);
  String? getSelectedText();
  SurroundingTextMessage? getSurroundingText(int beforeLength, int afterLength);
  int getCursorCapsMode(int reqModes);
  bool beginBatchEdit();
  bool endBatchEdit();

  // Keyboard window ---------------------------------------------------------
  void setWindowLayout(WindowLayoutMessage layout);
  void setSecureWindow(bool secure);
  void hideKeyboard();
  bool switchToPreviousInputMethod();
  bool switchToNextInputMethod(bool onlyCurrentIme);
  void showInputMethodPicker();
  void openSettings(String? route);

  /// The keyboard's background colour (ARGB) where it meets the navigation bar, so Kotlin can pick
  /// dark or light navigation-bar icons (API 30+). Call when the theme changes.
  void setNavigationBarStyle(int backgroundArgb);

  /// The user-visible name of the app the keyboard is typing into. The IME can see the app it is
  /// bound to without QUERY_ALL_PACKAGES. Null when unknown.
  String? getAppLabel(String packageName);

  /// Where the suggestion strip is, so Kotlin can overlay Android inline
  /// autofill suggestions there. null hides them.
  void setInlineSuggestionsArea(RectMessage? area);

  // Feedback ----------------------------------------------------------------
  void setFeedbackConfig(FeedbackConfigMessage config);
  void performHaptic(HapticKind kind);
  void playKeySound(KeySoundKind kind);

  // Clipboard ---------------------------------------------------------------
  ClipMessage? getPrimaryClip();
  void setPrimaryClip(String text, bool sensitive);
  void clearPrimaryClip();

  // State sync (Dart may start after Kotlin already received callbacks) ------
  WindowMetricsMessage getWindowMetrics();
  EditorInfoMessage? getCurrentEditorInfo();
  bool isInputViewShown();
}

/// Registered on both engines.
@HostApi()
abstract class PlatformHostApi {
  SystemColorsMessage? getSystemColors();

  /// Encrypted (AES-256-GCM, Android Keystore key) blob storage in no-backup
  /// app storage. [name] must match [a-z0-9_.-]{1,64}.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  Uint8List? secureRead(String name);
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void secureWrite(String name, Uint8List data);
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void secureDelete(String name);
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void secureWipeAll();

  /// Every blob currently stored, with sizes. Never returns contents.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  List<SecureBlobInfo> secureList();

  /// True if the installed package requests android.permission.INTERNET
  /// (expected: false for release builds).
  bool hasInternetPermission();
  AppInfoMessage getAppInfo();

  /// Whether the device font can render each string (emoji filtering).
  List<bool> hasGlyphs(List<String> texts);

  /// Absolute path of app-private, no-backup storage for plain data files.
  String getDataDirectory();

  /// Tell the other engine that these settings sections changed on disk.
  void notifySettingsChanged(List<String> sections);
}

/// Registered only on the settings-app engine.
@HostApi()
abstract class AppHostApi {
  bool isMynaEnabled();
  bool isMynaSelected();
  void openInputMethodSettings();
  void showInputMethodPicker();

  /// FLAG_SECURE + no recents thumbnail for sensitive screens.
  void setSecureScreen(bool secure);

  /// The settings route the activity was started with (from the keyboard's toolbar or a
  /// notification), or null. Returns it once, then null. Later routes arrive via
  /// AppFlutterApi.onOpenRoute.
  String? takeLaunchRoute();

  // Backup files (Storage Access Framework, no storage permission) -- Wave 2-B ------

  /// ACTION_CREATE_DOCUMENT. Returns the content URI, or null if the user cancelled.
  @async
  String? createDocument(String suggestedName, String mimeType);

  /// ACTION_OPEN_DOCUMENT. Returns the content URI, or null if the user cancelled.
  @async
  String? openDocument(List<String> mimeTypes);

  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void writeDocument(String uri, Uint8List data);

  /// Throws (code `too_large`) when the document is bigger than [maxBytes].
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  Uint8List readDocument(String uri, int maxBytes);

  // Backup crypto (.mynabackup): PBKDF2-HMAC-SHA256, 600k iterations, random salt,
  // AES-256-GCM -- Wave 2-B ------------------------------------------------------

  /// Encrypts [plain] into the complete .mynabackup file bytes.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  Uint8List sealBackup(Uint8List plain, String passphrase);

  /// Decrypts a .mynabackup file. Returns null for a wrong passphrase or a damaged file;
  /// throws (code `unsupported_version`) for a newer format.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  Uint8List? openBackup(Uint8List sealed, String passphrase);
}

// ---------------------------------------------------------------------------
// Kotlin -> Dart
// ---------------------------------------------------------------------------

@FlutterApi()
abstract class ImeFlutterApi {
  @asyncCallback
  void onStartInput(EditorInfoMessage info, bool restarting);
  @asyncCallback
  void onStartInputView(EditorInfoMessage info, bool restarting);
  @asyncCallback
  void onFinishInputView(bool finishingInput);
  @asyncCallback
  void onFinishInput();
  @asyncCallback
  void onUpdateSelection(SelectionMessage selection);
  @asyncCallback
  void onWindowShown();
  @asyncCallback
  void onWindowHidden();
  @asyncCallback
  void onClipboardChanged(ClipMessage clip);
  @asyncCallback
  void onConfigurationChanged(WindowMetricsMessage metrics);
  @asyncCallback
  void onSystemColorsChanged();
  @asyncCallback
  void onTrimMemory(int level);
  @asyncCallback
  void onSettingsChanged(List<String> sections);
  @asyncCallback
  void onInlineSuggestionsChanged(int count);
}

@FlutterApi()
abstract class AppFlutterApi {
  @asyncCallback
  void onSettingsChanged(List<String> sections);

  /// The running settings activity was asked to show [route] (onNewIntent).
  @asyncCallback
  void onOpenRoute(String route);
}
