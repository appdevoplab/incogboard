// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T. The language-pair picker (PanelPlacement.keys): From and To chips over the Myna
// languages that translate with English, a swap button, and a mark on the pairs whose pack is installed.
// Done saves the pair in settings.translate and goes back to the translate panel.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../engine/lang/registry.dart';
import '../../keyboard/keyboard_session.dart';
import '../../keyboard/panels/keyboard_panel.dart';
import '../../settings/myna_settings.dart';
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
  late String _from = widget.pickerState.from;
  late String _to = widget.pickerState.to;
  Set<String> _installed = const {};

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
      // Without the list the pairs simply carry no mark.
    }
  }

  bool get _valid => isSupportedPair(_from, _to);

  bool _installedPair(String from, String to) => _installed.contains(pairKey(from, to));

  void _pickFrom(String id) => setState(() => _from = id);

  void _pickTo(String id) => setState(() => _to = id);

  void _swap() => setState(() {
    final f = _from;
    _from = _to;
    _to = f;
  });

  Future<void> _done() async {
    if (!_valid) return;
    final session = widget.pickerState.session;
    final from = _from;
    final to = _to;
    await session.services.settings.update(
      (s) => s.copyWith(
        translate: s.translate.copyWith(from: from, to: to),
      ),
      sections: const [SettingsSection.translate],
    );
    if (!mounted) return;
    widget.panel.open(
      TranslatePanel(
        session: session,
        from: from,
        to: to,
        installedPairs: widget.pickerState.installedPairs,
        initialSource: widget.pickerState.source,
      ),
    );
  }

  void _back() {
    final state = widget.pickerState;
    widget.panel.open(
      TranslatePanel(
        session: state.session,
        from: state.from,
        to: state.to,
        installedPairs: state.installedPairs,
        initialSource: state.source,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.panel.theme;
    final style = PanelStyle(theme);
    final size = widget.panel.size;
    final fill = theme.background;
    final pressed = theme.suggestionHighlightFill;
    final valid = _valid;
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
                  width: 64,
                  height: 48,
                  fill: fill,
                  pressedFill: pressed,
                  radius: BorderRadius.zero,
                  onTap: _back,
                  child: Icon(Icons.arrow_back, size: 22, color: theme.toolbarIcon),
                ),
                Expanded(
                  child: Text(
                    'Translate between',
                    textAlign: TextAlign.center,
                    style: style.text(size: 15, color: theme.suggestionText, weight: FontWeight.w600),
                  ),
                ),
                PanelButton(
                  semanticsLabel: 'Swap languages',
                  width: 64,
                  height: 48,
                  fill: fill,
                  pressedFill: pressed,
                  radius: BorderRadius.zero,
                  onTap: _swap,
                  child: Icon(Icons.swap_horiz, size: 24, color: theme.toolbarIcon),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _caption('From', style),
                  _chips(
                    selected: _from,
                    enabledFor: (id) => isSupportedPair(id, _to),
                    mark: (id) => isSupportedPair(id, _to) && _installedPair(id, _to),
                    onPick: _pickFrom,
                  ),
                  const SizedBox(height: 8),
                  _caption('To', style),
                  _chips(
                    selected: _to,
                    enabledFor: (id) => isSupportedPair(_from, id),
                    mark: (id) => isSupportedPair(_from, id) && _installedPair(_from, id),
                    onPick: _pickTo,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          valid
                              ? (_installedPair(_from, _to)
                                    ? 'Pack installed. Works offline.'
                                    : 'Pack not installed. Get it in Model packs.')
                              : 'Pick English on one side.',
                          style: style.hint(size: 12),
                        ),
                      ),
                      PanelButton(
                        semanticsLabel: 'Use this language pair',
                        width: 88,
                        height: 40,
                        fill: valid ? theme.actionKey.fill : fill,
                        pressedFill: pressed,
                        radius: style.radius(40),
                        onTap: valid ? () => unawaited(_done()) : null,
                        child: Text(
                          'Done',
                          style: style.text(
                            size: 14,
                            color: valid ? theme.actionKey.label : theme.toolbarIcon,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _caption(String text, PanelStyle style) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 4),
    child: Text(text, style: style.hint(size: 12)),
  );

  Widget _chips({
    required String selected,
    required bool Function(String id) enabledFor,
    required bool Function(String id) mark,
    required void Function(String id) onPick,
  }) {
    final theme = widget.panel.theme;
    final style = PanelStyle(theme);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final id in translatableLanguages)
          _Chip(
            label: languageInfo(id).englishName,
            marked: mark(id),
            selected: id == selected,
            enabled: enabledFor(id),
            theme: theme,
            style: style,
            onTap: () => onPick(id),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.marked,
    required this.selected,
    required this.enabled,
    required this.theme,
    required this.style,
    required this.onTap,
  });

  final String label;
  final bool marked;
  final bool selected;
  final bool enabled;
  final KeyboardThemeData theme;
  final PanelStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = marked ? '$label ✓' : label;
    return PanelButton(
      semanticsLabel: marked ? '$label, pack installed' : label,
      height: 40,
      width: null,
      fill: selected ? theme.actionKey.fill : theme.background,
      pressedFill: theme.suggestionHighlightFill,
      radius: style.radius(40),
      selected: selected,
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          text,
          maxLines: 1,
          textScaler: TextScaler.noScaling,
          style: style.text(
            size: 13,
            color: !enabled ? theme.toolbarIcon : (selected ? theme.actionKey.label : theme.suggestionText),
          ),
        ),
      ),
    );
  }
}
