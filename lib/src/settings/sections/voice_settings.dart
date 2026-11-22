// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:meta/meta.dart';

import '../json_util.dart';

@immutable
class VoiceSettings {
  const VoiceSettings({this.enabled = true, this.modelId = '', this.autoDetectLanguage = false});

  factory VoiceSettings.fromJson(Json j) => VoiceSettings(
    enabled: jBool(j, 'enabled', true),
    modelId: _packId(jString(j, 'modelId', '')),
    autoDetectLanguage: jBool(j, 'autoDetectLanguage', false),
  );

  /// Before Wave 3 the setting held a model size ('base', 'small') for a bundled model; models are packs
  /// now, so those old values mean "automatic".
  static String _packId(String v) => v == 'base' || v == 'small' ? '' : v;

  final bool enabled;

  /// Id of the installed voice pack to use ('voice-whisper-base', ...); empty = the first installed
  /// voice pack that covers the language. Models ship only as packs (Wave 3 decision).
  final String modelId;

  /// Otherwise the current keyboard language is used.
  final bool autoDetectLanguage;

  Json toJson() => {'enabled': enabled, 'modelId': modelId, 'autoDetectLanguage': autoDetectLanguage};

  VoiceSettings copyWith({bool? enabled, String? modelId, bool? autoDetectLanguage}) => VoiceSettings(
    enabled: enabled ?? this.enabled,
    modelId: modelId ?? this.modelId,
    autoDetectLanguage: autoDetectLanguage ?? this.autoDetectLanguage,
  );
}
