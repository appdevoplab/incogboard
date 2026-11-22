// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T. The translate panel (PanelPlacement.strip): the keyboard's own keys type the source
// into the strip, the strip shows the pair, the source tail and the translation, and Insert (or Enter)
// commits the translation. The typed source never goes into the app.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../app/routes.dart';
import '../../engine/lang/registry.dart';
import '../../keyboard/keyboard_session.dart';
import '../../keyboard/panels/keyboard_panel.dart';
import '../../theme/keyboard_theme_data.dart';
import '../shared/panel_style.dart';
import 'translate_controller.dart';
import 'translate_languages.dart';
import 'translate_pair_panel.dart';

/// Characters of source text shown at the end of the strip (the end stays visible).
const int sourceTailChars = 36;

/// The source text shown in the strip: the last [sourceTailChars] characters, with an ellipsis in front.
String sourceTail(String text) {
  final chars = text.characters;
  if (chars.length <= sourceTailChars) return text;
  return '…${chars.takeLast(sourceTailChars - 1).string}';
}

class TranslatePanel extends KeyboardPanel {
  TranslatePanel({
    required this.session,
    required this.from,
    required this.to,
    required this.installedPairs,
    this.initialSource = '',
  }) : controller = TranslateController(
         translate: (text, f, t) => session.services.host.translate(text, f, t),
         insert: session.input.insertText,
         from: from,
         to: to,
       ) {
    controller.setSource(initialSource);
    _keys = _TranslateKeys(controller);
  }

  final KeyboardSession session;

  /// Kosha language ids of the pair.
  final String from;
  final String to;

  /// Pair keys of the installed packs (see `installedPairKeys`), read when the picker opens.
  final Future<Set<String>> Function() installedPairs;

  /// Text to continue from (the picker keeps the source when the pair changes).
  final String initialSource;

  final TranslateController controller;
  late final _TranslateKeys _keys;

  @override
  String get id => 'translate';

  @override
  PanelPlacement get placement => PanelPlacement.strip;

  @override
  KeyRedirect? get keyRedirect => _keys;

  @override
  Widget build(BuildContext context, PanelContext panel) => TranslateStrip(
    controller: controller,
    theme: panel.theme,
    size: panel.size,
    from: from,
    to: to,
    onPair: () => panel.open(
      TranslatePairPanel(
        session: session,
        from: from,
        to: to,
        installedPairs: installedPairs,
        source: controller.source,
      ),
    ),
    onInsert: () => controller.insertTranslation(),
    onGetPack: () => unawaited(session.services.host.openSettings(KoshaRoutes.packs)),
    onClose: panel.close,
  );

  @override
  void onClosed() {
    controller.dispose();
    unawaited(session.services.host.releaseTranslator());
  }
}

/// The keyboard's keys while the strip is open: text builds the source, backspace shortens it, Enter inserts.
class _TranslateKeys implements KeyRedirect {
  _TranslateKeys(this.controller);

  final TranslateController controller;

  @override
  void onText(String text) => controller.append(text);

  @override
  void onSpace() => controller.append(' ');

  @override
  void onBackspace() => controller.backspace();

  @override
  void onEnter() => controller.insertTranslation();
}

/// The strip's contents for [controller]: pair chip, source tail, translation, Insert.
class TranslateStrip extends StatelessWidget {
  const TranslateStrip({
    super.key,
    required this.controller,
    required this.theme,
    required this.size,
    required this.from,
    required this.to,
    required this.onPair,
    required this.onInsert,
    required this.onGetPack,
    required this.onClose,
  });

  final TranslateController controller;
  final KeyboardThemeData theme;
  final Size size;
  final String from;
  final String to;
  final VoidCallback onPair;
  final VoidCallback onInsert;
  final VoidCallback onGetPack;

  /// Back to the normal strip and keys.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final style = PanelStyle(theme);
    final fill = theme.background;
    final pressed = theme.suggestionHighlightFill;
    final pairName = '${languageInfo(from).englishName} to ${languageInfo(to).englishName}';
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final noPack = controller.status == TranslateStatus.noPack;
        final waiting = controller.status == TranslateStatus.waiting;
        final ready = controller.canInsert;
        final translation = controller.translation;
        return SizedBox(
          width: size.width,
          height: size.height,
          child: Row(
            children: [
              PanelButton(
                semanticsLabel: 'Close translation',
                width: 44,
                height: size.height,
                fill: fill,
                pressedFill: pressed,
                radius: BorderRadius.zero,
                onTap: onClose,
                child: Icon(Icons.close, size: 20, color: theme.toolbarIcon),
              ),
              PanelButton(
                semanticsLabel: 'Language pair $pairName. Change languages',
                width: 80,
                height: size.height,
                fill: fill,
                pressedFill: pressed,
                radius: BorderRadius.zero,
                onTap: onPair,
                child: Text(
                  '${shortCode(from)} → ${shortCode(to)}',
                  maxLines: 1,
                  textScaler: TextScaler.noScaling,
                  style: style.text(size: 13, color: theme.suggestionText, weight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: noPack
                      ? _message(
                          'Get the ${languageInfo(from).englishName} → ${languageInfo(to).englishName} pack',
                          style,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _line(
                              controller.source.isEmpty ? 'Type to translate' : sourceTail(controller.source),
                              style.hint(size: 12),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _line(translation ?? '', style.text(size: 15, color: theme.suggestionText)),
                                ),
                                if (waiting) _progressDot(theme),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
              if (noPack)
                PanelButton(
                  semanticsLabel: 'Open model packs',
                  width: 64,
                  height: size.height,
                  fill: fill,
                  pressedFill: pressed,
                  radius: BorderRadius.zero,
                  onTap: onGetPack,
                  child: Text('Packs', style: style.text(size: 13, color: theme.suggestionText)),
                )
              else
                PanelButton(
                  semanticsLabel: 'Insert translation',
                  width: 64,
                  height: size.height,
                  fill: ready ? theme.actionKey.fill : fill,
                  pressedFill: pressed,
                  radius: BorderRadius.zero,
                  onTap: ready ? onInsert : null,
                  child: Text(
                    'Insert',
                    style: style.text(
                      size: 13,
                      color: ready ? theme.actionKey.label : theme.toolbarIcon,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _line(String text, TextStyle style) =>
      Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, textScaler: TextScaler.noScaling, style: style);

  Widget _message(String text, PanelStyle style) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.noScaling,
      style: style.text(size: 13, color: theme.suggestionText),
    ),
  );

  Widget _progressDot(KeyboardThemeData theme) => Padding(
    padding: const EdgeInsets.only(left: 6),
    child: SizedBox(
      width: 6,
      height: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: theme.suggestionText),
      ),
    ),
  );
}
