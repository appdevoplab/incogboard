// SPDX-License-Identifier: GPL-3.0-or-later
//
// Paints every key from KeyboardThemeData in one pass. Text layouts are
// cached, so a repaint (a press spring tick, a shift change) is a few dozen
// rounded rectangles and cached paragraphs.
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../core/input_field_info.dart';
import '../../settings/sections/typing_settings.dart';
import '../../theme/keyboard_theme_data.dart';
import '../input/input_controller.dart';
import '../input/keyboard_page.dart';
import '../layout/layout_engine.dart';
import 'key_press_animator.dart';
import 'key_visuals.dart';

/// Caches laid-out text so painting does not re-run text layout.
class KeyTextCache {
  final Map<(String, double, int, bool), TextPainter> _map = {};

  TextPainter get(
    KeyboardThemeData theme,
    String text,
    double size,
    Color color, {
    bool icon = false,
    IconData? glyph,
  }) {
    final key = (text, size, color.toARGB32(), icon);
    final cached = _map[key];
    if (cached != null) return cached;
    final style = icon
        ? TextStyle(fontFamily: glyph!.fontFamily, package: glyph.fontPackage, fontSize: size, color: color, height: 1)
        : TextStyle(
            fontFamily: theme.fontFamily,
            fontWeight: theme.labelWeight,
            fontVariations: theme.labelFontVariations,
            fontSize: size,
            color: color,
            height: 1.1,
          );
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return _map[key] = tp;
  }

  void clear() {
    for (final tp in _map.values) {
      tp.dispose();
    }
    _map.clear();
  }
}

class KeysPainter extends CustomPainter {
  KeysPainter({
    required this.laid,
    required this.theme,
    required this.shift,
    required this.page,
    required this.field,
    required this.typing,
    required this.animator,
    required this.textCache,
    this.onActivate,
  }) : super(repaint: animator);

  final LaidOutKeyboard laid;
  final KeyboardThemeData theme;
  final ShiftState shift;
  final KeyboardPage page;
  final InputFieldInfo field;
  final TypingSettings typing;
  final KeyPressAnimator animator;
  final KeyTextCache textCache;

  /// Accessibility "tap" on a key.
  final void Function(PlacedKey key)? onActivate;

  late final List<KeyVisual> _visuals = [
    for (final k in laid.keys)
      resolveKeyVisual(k.def, shift: shift, page: page, field: field, typing: typing, showHints: theme.showHints),
  ];

  List<KeyVisual> _resolve() => _visuals;

  @override
  void paint(Canvas canvas, Size size) {
    final visuals = _resolve();
    final motion = theme.motion;
    final fill = Paint()..isAntiAlias = true;
    final border = theme.borderWidth > 0
        ? (Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.stroke
            ..strokeWidth = theme.borderWidth)
        : null;

    for (final key in laid.keys) {
      final v = visuals[key.index];
      final style = v.styleOf(theme);
      final p = animator.progress(key.index);
      final rect = key.rect;
      final pressed = p.clamp(0.0, 1.0);
      final shorter = math.min(rect.width, rect.height);
      final radiusFraction = (theme.keyCornerRadius * (1 + 0.25 * pressed)).clamp(0.0, 0.5);

      final animating = motion.enabled && p != 0;
      if (animating) {
        final scale = 1 + (motion.pressScale - 1) * p;
        canvas
          ..save()
          ..translate(rect.center.dx, rect.center.dy)
          ..scale(scale)
          ..translate(-rect.center.dx, -rect.center.dy);
      }

      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radiusFraction * shorter));
      fill.color = pressed == 0 ? style.fill : Color.lerp(style.fill, style.pressedFill, pressed)!;
      canvas.drawRRect(rrect, fill);
      if (border != null) {
        border.color = style.border ?? style.label.withValues(alpha: 0.25);
        canvas.drawRRect(rrect, border);
      }
      _paintContent(canvas, rect, v, style);

      if (animating) canvas.restore();
    }
  }

  void _paintContent(Canvas canvas, Rect rect, KeyVisual v, KeyStyle style) {
    final h = rect.height;
    if (v.shiftGlyph != null) {
      _paintShift(canvas, rect, v.shiftGlyph!, style.label);
      return;
    }
    final scale = theme.labelScale;
    if (v.icon != null) {
      final tp = textCache.get(
        theme,
        String.fromCharCode(v.icon!.codePoint),
        (h * 0.42).clamp(16, 28) * scale,
        style.label,
        icon: true,
        glyph: v.icon,
      );
      tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
      return;
    }
    final label = v.label;
    if (label != null && label.isNotEmpty) {
      final size = (v.smallLabel ? (h * 0.27).clamp(12, 17) : (h * 0.40).clamp(16, 26)) * scale;
      final tp = textCache.get(theme, label, size.toDouble(), style.label);
      final maxW = rect.width - 4;
      if (tp.width > maxW && maxW > 0) {
        canvas
          ..save()
          ..translate(rect.center.dx, rect.center.dy)
          ..scale(maxW / tp.width)
          ..translate(-tp.width / 2, -tp.height / 2);
        tp.paint(canvas, Offset.zero);
        canvas.restore();
      } else {
        tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
      }
    }
    final hint = v.hint;
    if (hint != null && hint.isNotEmpty) {
      final tp = textCache.get(theme, hint, (h * 0.20).clamp(9, 13) * scale, style.hint.withValues(alpha: 0.75));
      tp.paint(canvas, Offset(rect.right - tp.width - 5, rect.top + 3));
    }
  }

  void _paintShift(Canvas canvas, Rect rect, ShiftGlyph glyph, Color color) {
    final s = math.min(rect.height * 0.21, 12.0);
    final c = rect.center + (glyph == ShiftGlyph.caps ? Offset(0, -s * 0.18) : Offset.zero);
    Offset pt(double x, double y) => Offset(c.dx + x * s, c.dy + y * s);
    final path = Path()
      ..moveTo(pt(0, -1).dx, pt(0, -1).dy)
      ..lineTo(pt(1, -0.05).dx, pt(1, -0.05).dy)
      ..lineTo(pt(0.45, -0.05).dx, pt(0.45, -0.05).dy)
      ..lineTo(pt(0.45, 0.75).dx, pt(0.45, 0.75).dy)
      ..lineTo(pt(-0.45, 0.75).dx, pt(-0.45, 0.75).dy)
      ..lineTo(pt(-0.45, -0.05).dx, pt(-0.45, -0.05).dy)
      ..lineTo(pt(-1, -0.05).dx, pt(-1, -0.05).dy)
      ..close();
    final paint = Paint()
      ..isAntiAlias = true
      ..color = color
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2
      ..style = glyph == ShiftGlyph.outline ? PaintingStyle.stroke : PaintingStyle.fill;
    canvas.drawPath(path, paint);
    if (glyph == ShiftGlyph.caps) {
      final bar = RRect.fromRectAndRadius(
        Rect.fromLTRB(pt(-0.45, 1.05).dx, pt(0, 1.05).dy, pt(0.45, 1.05).dx, pt(0, 1.05).dy + 2.2),
        const Radius.circular(1),
      );
      canvas.drawRRect(
        bar,
        Paint()
          ..color = color
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant KeysPainter oldDelegate) =>
      oldDelegate.shift != shift ||
      oldDelegate.laid != laid ||
      oldDelegate.theme != theme ||
      oldDelegate.page != page ||
      oldDelegate.field != field ||
      oldDelegate.typing != typing ||
      oldDelegate.animator != animator;

  @override
  SemanticsBuilderCallback get semanticsBuilder => (Size size) {
    final visuals = _resolve();
    return [
      for (final k in laid.keys)
        CustomPainterSemantics(
          rect: k.cell,
          properties: SemanticsProperties(
            label: visuals[k.index].semantics,
            button: true,
            onTap: onActivate == null ? null : () => onActivate!(k),
            textDirection: TextDirection.ltr,
          ),
        ),
    ];
  };

  @override
  bool shouldRebuildSemantics(covariant KeysPainter oldDelegate) =>
      oldDelegate.laid != laid || oldDelegate.page != page || oldDelegate.field != field || oldDelegate.shift != shift;
}
