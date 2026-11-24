// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T, redesigned 2026-11-24. The language-pair picker (PanelPlacement.keys). Every translation
// pack is English with one other language, so the picker is one list of pairs: a direction toggle (from
// English / to English), then one row per language with its own name, and on each row either "Installed"
// or a Get button that opens Model packs (IncogBoard never downloads anything itself). Installed pairs come
// first. Tapping a row saves the pair in settings.translate and goes straight back to the translate panel.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../app/routes.dart';
import '../../engine/lang/registry.dart';
import '../../keyboard/keyboard_session.dart';
import '../../keyboard/panels/keyboard_panel.dart';
import '../../packs/pack_catalog.dart';
import '../../settings/incogboard_settings.dart';
import '../../theme/keyboard_theme_data.dart';
import '../shared/panel_style.dart';
import 'translate_languages.dart';
import 'translate_panel.dart';

class TranslatePairPanel extends KeyboardPanel {
  TranslatePairPanel({
    required this.session,
    required this.from,
    required this.to,
    required this.installedPairs,
    this.source = '',
  });

  final KeyboardSession session;
  final String from;
  final String to;
  final Future<Set<String>> Function() installedPairs;

  /// The source text to carry back to the translate panel.
  final String source;

  @override
  String get id => 'translate_pair';

  @override
  PanelPlacement get placement => PanelPlacement.keys;

  @override
  Widget build(BuildContext context, PanelContext panel) => TranslatePairView(panel: panel, pickerState: this);
}

class TranslatePairView extends StatefulWidget {
  const TranslatePairView({super.key, required this.panel, required this.pickerState});

  final PanelContext panel;
  final TranslatePairPanel pickerState;

  @override
  State<TranslatePairView> createState() => _TranslatePairViewState();
}

class _TranslatePairViewState extends State<TranslatePairView> {
  /// True: English → other. False: other → English.
  late bool _fromEnglish = widget.pickerState.from == 'en';
  Set<String> _installed = const {};

  /// The non-English side of the current pair.
  late final String _current = widget.pickerState.from == 'en' ? widget.pickerState.to : widget.pickerState.from;

  @override
  void initState() {
    super.initState();
    unawaited(_loadInstalled());
  }

  Future<void> _loadInstalled() async {
    try {
      final keys = await widget.pickerState.installedPairs();
      if (mounted) setState(() => _installed = keys);
    } on Object {
      // Without the list every row offers Get.
    }
  }

  (String, String) _pair(String other) => _fromEnglish ? ('en', other) : (other, 'en');

  bool _isInstalled(String other) {
    final (f, t) = _pair(other);
    return _installed.contains(pairKey(f, t));
  }

  /// True when the pair's pack is published (Get leads somewhere); false for directions not released yet.
  bool _isPublished(String other) {
    final (f, t) = _pair(other);
    return catalogTranslation(pairKey(f, t)) != null;
  }

  /// The non-English languages, installed pairs first, otherwise in the usual order.
  List<String> get _languages {
    final others = [
      for (final id in translatableLanguages)
        if (id != 'en') id,
    ];
    final installed = others.where(_isInstalled).toList();
    final published = others.where((id) => !_isInstalled(id) && _isPublished(id)).toList();
    final later = others.where((id) => !_isInstalled(id) && !_isPublished(id)).toList();
    return [...installed, ...published, ...later];
  }

  Future<void> _choose(String other) async {
    final (from, to) = _pair(other);
    if (!isSupportedPair(from, to)) return;
    final session = widget.pickerState.session;
    await session.services.settings.update(
      (s) => s.copyWith(
        translate: s.translate.copyWith(from: from, to: to),
      ),
      sections: const [SettingsSection.translate],
    );
    if (!mounted) return;
    _openTranslate(from, to);
  }

  void _openTranslate(String from, String to) {
    final state = widget.pickerState;
    widget.panel.open(
      TranslatePanel(
        session: state.session,
        from: from,
        to: to,
        installedPairs: state.installedPairs,
        initialSource: state.source,
      ),
    );
  }

  void _back() => _openTranslate(widget.pickerState.from, widget.pickerState.to);

  void _getPack() => unawaited(widget.pickerState.session.services.host.openSettings(IncogBoardRoutes.packs));

  @override
  Widget build(BuildContext context) {
    final theme = widget.panel.theme;
    final style = PanelStyle(theme);
    final size = widget.panel.size;
    final fill = theme.background;
    final pressed = theme.suggestionHighlightFill;
    final languages = _languages;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                PanelButton(
                  semanticsLabel: 'Back to translation',
                  width: 56,
                  height: 48,
                  fill: fill,
                  pressedFill: pressed,
                  radius: BorderRadius.zero,
                  onTap: _back,
                  child: Icon(Icons.arrow_back, size: 22, color: theme.toolbarIcon),
                ),
                Expanded(
                  child: Text(
                    'Translate',
                    style: style.text(size: 16, color: theme.suggestionText, weight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: theme.toolbarIcon),
                      const SizedBox(width: 4),
                      Text('Offline', style: style.hint(size: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Row(
              children: [
                Expanded(child: _directionButton('From English', true, theme, style)),
                const SizedBox(width: 6),
                Expanded(child: _directionButton('To English', false, theme, style)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              children: [
                for (final id in languages) _row(id, theme, style),
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                  child: Text(
                    'Packs run on this phone. Get opens IncogBoard, and your browser downloads the pack: '
                    'IncogBoard itself never goes online.',
                    style: style.hint(size: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _directionButton(String label, bool fromEnglish, KeyboardThemeData theme, PanelStyle style) {
    final selected = _fromEnglish == fromEnglish;
    return PanelButton(
      semanticsLabel: selected ? '$label, selected' : label,
      height: 40,
      fill: selected ? theme.actionKey.fill : theme.functionKey.fill,
      // A selected PanelButton paints its pressedFill, so the selected one keeps the action colour there too.
      pressedFill: selected ? theme.actionKey.fill : theme.suggestionHighlightFill,
      radius: style.radius(40),
      selected: selected,
      onTap: () => setState(() => _fromEnglish = fromEnglish),
      child: Text(
        label,
        maxLines: 1,
        textScaler: TextScaler.noScaling,
        style: style.text(
          size: 14,
          color: selected ? theme.actionKey.label : theme.functionKey.label,
          weight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _row(String other, KeyboardThemeData theme, PanelStyle style) {
    final info = languageInfo(other);
    final installed = _isInstalled(other);
    final published = _isPublished(other);
    final current = other == _current && _fromEnglish == (widget.pickerState.from == 'en');
    final (from, to) = _pair(other);
    final pairName = '${languageInfo(from).englishName} to ${languageInfo(to).englishName}';
    final direction = _fromEnglish ? 'English → ${info.nativeName}' : '${info.nativeName} → English';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: PanelButton(
              semanticsLabel: [
                pairName,
                installed ? 'pack installed' : (published ? 'pack not installed' : 'pack not published yet'),
                if (current) 'selected',
              ].join(', '),
              height: 52,
              fill: current ? theme.suggestionHighlightFill : theme.functionKey.fill,
              pressedFill: theme.suggestionHighlightFill,
              radius: style.radius(52),
              selected: current,
              onTap: () => unawaited(_choose(other)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            direction,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textScaler: TextScaler.noScaling,
                            style: style.text(
                              size: 15,
                              color: current ? theme.suggestionHighlightText : theme.suggestionText,
                              weight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            installed
                                ? '${info.englishName} · installed, works offline'
                                : (published ? info.englishName : '${info.englishName} · pack not published yet'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textScaler: TextScaler.noScaling,
                            style: style.hint(size: 12),
                          ),
                        ],
                      ),
                    ),
                    if (installed) Icon(Icons.check_circle, size: 20, color: theme.actionKey.fill),
                  ],
                ),
              ),
            ),
          ),
          if (!installed && published) ...[
            const SizedBox(width: 6),
            PanelButton(
              semanticsLabel: 'Get the $pairName pack',
              width: 64,
              height: 52,
              fill: theme.actionKey.fill,
              pressedFill: theme.suggestionHighlightFill,
              radius: style.radius(52),
              onTap: _getPack,
              child: Text(
                'Get',
                style: style.text(size: 14, color: theme.actionKey.label, weight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
