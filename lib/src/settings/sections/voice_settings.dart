// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:meta/meta.dart';

import '../json_util.dart';

@immutable
class VoiceSettings {
  const VoiceSettings({this.enabled = true, this.modelId = 'base', this.autoDetectLanguage = false});

  factory VoiceSettings.fromJson(Json j) => VoiceSettings(
    enabled: jBool(j, 'enabled', true),
    modelId: jString(j, 'modelId', 'base'),
    autoDetectLanguage: jBool(j, 'autoDetectLanguage', false),
  );

  final bool enabled;

  /// 'base' (bundled) or an imported model id such as 'small'.
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
