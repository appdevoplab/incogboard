// SPDX-License-Identifier: GPL-3.0-or-later
//
// Boots the keyboard (IME) engine. Called from keyboardMain() in main.dart,
// which MynaImeService starts as a separate Flutter engine.
// OWNER: orchestrator. Features are attached in this order; for each hook the
// first feature that provides it wins.
import 'package:flutter/widgets.dart';

import 'src/core/keyboard_services.dart';
import 'src/core/log.dart';
import 'src/features/features.dart';
import 'src/features/shortcuts/shortcuts_feature.dart';
import 'src/keyboard/keyboard_app.dart';
import 'src/keyboard/modes/modes.dart';

Future<void> runKeyboard() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sw = Stopwatch()..start();
  final services = await KeyboardServices.create();
  MynaLog.d('Boot', 'services ready in ${sw.elapsedMilliseconds} ms');
  runApp(
    KeyboardApp(services: services, features: [createPanelsFeature(), createShortcutsFeature(), createModesFeature()]),
  );
}
