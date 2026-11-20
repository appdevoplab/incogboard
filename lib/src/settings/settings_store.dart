// SPDX-License-Identifier: GPL-3.0-or-later
//
// CONTRACT (Wave 0). One JSON file shared by the keyboard and settings
// engines. Writes are atomic (temp file + rename); the other engine is told
// which sections changed and reloads.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/log.dart';
import 'myna_settings.dart';

/// Announces changed sections to the other engine (PlatformHostApi in prod).
typedef SettingsChangeNotifier = Future<void> Function(List<String> sections);

class SettingsStore extends ChangeNotifier {
  SettingsStore._(this._file, this._notifyOther, this._value);

  /// Opens (or creates) `settings.json` in [directory].
  static Future<SettingsStore> open({required String directory, SettingsChangeNotifier? notifyOther}) async {
    final file = File('$directory${Platform.pathSeparator}settings.json');
    final value = await _read(file);
    return SettingsStore._(file, notifyOther, value);
  }

  /// In-memory store for tests and previews.
  @visibleForTesting
  factory SettingsStore.memory([MynaSettings value = const MynaSettings()]) => SettingsStore._(null, null, value);

  final File? _file;
  final SettingsChangeNotifier? _notifyOther;
  MynaSettings _value;
  Future<void> _writeChain = Future.value();

  MynaSettings get value => _value;

  /// Applies [change], persists it, notifies listeners here and the other engine.
  Future<void> update(MynaSettings Function(MynaSettings current) change, {required List<String> sections}) {
    _value = change(_value);
    notifyListeners();
    final snapshot = _value;
    _writeChain = _writeChain.then((_) async {
      await _write(snapshot);
      await _notifyOther?.call(sections);
    });
    return _writeChain;
  }

  /// Re-reads the file (called when the other engine changed it).
  Future<void> reload() async {
    final file = _file;
    if (file == null) return;
    _value = await _read(file);
    notifyListeners();
  }

  static Future<MynaSettings> _read(File file) async {
    try {
      if (!file.existsSync()) return const MynaSettings();
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, Object?>) return MynaSettings.fromJson(json);
    } on Object catch (e) {
      MynaLog.w('Settings', 'settings file unreadable, using defaults', e.runtimeType);
    }
    return const MynaSettings();
  }

  Future<void> _write(MynaSettings settings) async {
    final file = _file;
    if (file == null) return;
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(settings.toJson()), flush: true);
    await tmp.rename(file.path);
  }
}
