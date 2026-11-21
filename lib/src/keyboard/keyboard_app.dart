// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 1-A (keyboard view). The keyboard UI shown in the IME window.
// Keep the KeyboardApp constructor compatible (keyboard_main.dart depends on it).
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../bridge/messages.g.dart';
import '../core/keyboard_services.dart';
import '../core/log.dart';
import '../settings/myna_settings.dart';
import '../theme/keyboard_theme_data.dart';
import '../theme/theme_resolver.dart';
import 'keyboard_session.dart';
import 'view/keyboard_hooks.dart';
import 'view/keyboard_metrics.dart';
import 'view/keyboard_view.dart';

export 'view/keyboard_hooks.dart' show KeyboardHooks;
export 'view/keyboard_metrics.dart' show KeyboardMetrics;

class KeyboardApp extends StatefulWidget {
  const KeyboardApp({super.key, required this.services, this.hooks = const KeyboardHooks()});

  final KeyboardServices services;

  /// Wave 2 attaches panels (emoji, clipboard, themes) and drag gestures here.
  final KeyboardHooks hooks;

  @override
  State<KeyboardApp> createState() => _KeyboardAppState();
}

class _KeyboardAppState extends State<KeyboardApp> {
  late final KeyboardSession _session;
  double? _requestedHeight;

  // Theme cache: resolving can be expensive, so only redo it when an input changed.
  KeyboardThemeData? _theme;
  AppearanceSettings? _themeAppearance;
  SystemColorsMessage? _themeColors;
  bool? _themeDark;
  bool? _themeReduce;

  KeyboardServices get s => widget.services;

  @override
  void initState() {
    super.initState();
    _session = KeyboardSession(s);
    s.settings.addListener(_rebuild);
    s.events.metrics.addListener(_rebuild);
    _session.systemColors.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    s.settings.removeListener(_rebuild);
    s.events.metrics.removeListener(_rebuild);
    _session.systemColors.removeListener(_rebuild);
    _session.dispose();
    super.dispose();
  }

  KeyboardThemeData _resolveTheme(BuildContext context) {
    final appearance = s.settings.value.appearance;
    final colors = _session.systemColors.value;
    final metrics = s.events.metrics.value;
    final dark = metrics?.isNightMode ?? MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final cached = _theme;
    if (cached != null &&
        identical(appearance, _themeAppearance) &&
        identical(colors, _themeColors) &&
        dark == _themeDark &&
        reduce == _themeReduce) {
      return cached;
    }
    _themeAppearance = appearance;
    _themeColors = colors;
    _themeDark = dark;
    _themeReduce = reduce;
    return _theme = resolveKeyboardTheme(
      appearance: appearance,
      systemColors: colors,
      systemDark: dark,
      disableAnimations: reduce,
    );
  }

  /// Dart owns the total window height: content plus the bottom inset Flutter applies.
  void _syncWindowHeight(double total) {
    if (total == _requestedHeight) return;
    _requestedHeight = total;
    try {
      unawaited(
        s.host
            .setWindowLayout(WindowLayoutMessage(mode: WindowMode.docked, heightDp: total))
            .catchError((Object e) => MynaLog.w('Keyboard', 'window layout failed', e.runtimeType)),
      );
    } on Object catch (e) {
      MynaLog.w('Keyboard', 'window layout failed', e.runtimeType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = s.settings.value;
    final theme = _resolveTheme(context);
    final landscape = s.events.metrics.value?.isLandscape ?? false;
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    _syncWindowHeight(KeyboardMetrics.totalHeight(settings, landscape: landscape, bottomInset: inset));
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextStyle(
        style: const TextStyle(decoration: TextDecoration.none),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Background(theme: theme),
            Padding(
              padding: EdgeInsets.only(bottom: inset),
              child: Align(
                alignment: Alignment.topCenter,
                child: KeyboardView(session: _session, theme: theme, settings: settings, hooks: widget.hooks),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Solid colour, gradient or image (with dim). Also fills the area under the navigation bar.
class _Background extends StatelessWidget {
  const _Background({required this.theme});

  final KeyboardThemeData theme;

  @override
  Widget build(BuildContext context) {
    final path = theme.backgroundImagePath;
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.background, gradient: theme.backgroundGradient),
      child: path == null
          ? null
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
                if (theme.backgroundImageDim > 0)
                  ColoredBox(color: Color.fromRGBO(0, 0, 0, theme.backgroundImageDim.clamp(0.0, 1.0))),
              ],
            ),
    );
  }
}
