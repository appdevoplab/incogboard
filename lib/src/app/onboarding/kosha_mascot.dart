// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 4-E (brand). The Kosha treasure chest, the app's mascot. It replaces the Wave 2-A
// myna placeholder. The chest is drawn with a CustomPainter in the theme's colour scheme, so it
// follows Material You and dark mode. The geometry is a hand port of tool/brand/render.py (a
// 108-unit grid, the adaptive-icon canvas); keep the two in step when the shapes change.
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// The chest's four moods.
enum KoshaPose {
  /// Lid raised with light inside: welcome and onboarding.
  open,

  /// Closed, with the keycap as its lock: privacy and app lock.
  locked,

  /// Haloed: voice typing, translation and other work in progress.
  glowing,

  /// Closed and muted: incognito and empty states.
  quiet,
}

class KoshaMascot extends StatelessWidget {
  const KoshaMascot({super.key, this.size = 96, this.label = 'Kosha mascot', this.pose = KoshaPose.open});

  /// Width and height in logical pixels. Crisp from 24 to 160.
  final double size;

  /// Spoken by TalkBack.
  final String label;

  /// Which drawing to show. Changing it springs between poses unless animations are disabled.
  final KoshaPose pose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      image: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primaryContainer),
        child: SizedBox.square(
          dimension: size,
          child: AnimatedSwitcher(
            duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 460),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: KeyedSubtree(
              key: ValueKey<KoshaPose>(pose),
              child: CustomPaint(
                painter: _KoshaPainter(pose: pose, scheme: scheme),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws on a 108 x 108 grid, scaled to the widget.
class _KoshaPainter extends CustomPainter {
  const _KoshaPainter({required this.pose, required this.scheme});

  final KoshaPose pose;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 108);
    switch (pose) {
      case KoshaPose.open:
        _paintOpen(canvas);
      case KoshaPose.locked:
        _paintClosed(canvas, _gold, _shine, _detail, _shine);
      case KoshaPose.glowing:
        _paintHalo(canvas);
        final glow = _shine;
        _paintClosed(canvas, _gold, glow, _detail, _lighten(glow));
        _sparkles(canvas, [(14, 26, 5), (94, 22, 4.5), (96, 80, 3.5)], _lighten(glow));
      case KoshaPose.quiet:
        final body = scheme.onSurfaceVariant.withValues(alpha: 0.5);
        final shine = _lighten(body);
        _paintClosed(canvas, body, shine, scheme.onSurfaceVariant, shine);
        final dots = Paint()..color = scheme.onSurfaceVariant;
        for (final x in const [44.0, 54.0, 64.0]) {
          canvas.drawCircle(Offset(x, 20), 2.8, dots);
        }
    }
    canvas.restore();
  }

  Color get _gold => scheme.primary;
  Color get _shine => _lighten(scheme.primary);
  Color get _detail => scheme.brightness == Brightness.dark ? scheme.primaryContainer : scheme.onPrimaryContainer;

  static Color _lighten(Color c) => Color.lerp(c, const Color(0xFFFFFFFF), 0.55)!;

  void _rect(Canvas canvas, Rect rect, Color color, {double radius = 0}) {
    final paint = Paint()..color = color;
    if (radius == 0) {
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), paint);
    }
  }

  /// The closed chest: lid, body, straps and the keycap lock.
  void _paintClosed(Canvas canvas, Color body, Color shine, Color detail, Color keyFace) {
    _rect(canvas, const Rect.fromLTWH(24, 30, 60, 20), body, radius: 10);
    _rect(canvas, const Rect.fromLTWH(24, 54, 60, 24), body, radius: 4);
    _rect(canvas, const Rect.fromLTWH(34, 34, 40, 3), shine, radius: 1.5);
    _rect(canvas, const Rect.fromLTWH(36, 30, 5, 48), detail);
    _rect(canvas, const Rect.fromLTWH(67, 30, 5, 48), detail);
    _rect(canvas, const Rect.fromLTWH(44, 59, 20, 15), detail, radius: 4);
    _rect(canvas, const Rect.fromLTWH(47.5, 62, 13, 9), keyFace, radius: 2.5);
  }

  /// The chest with its lid tipped back on the left hinge, and the dark opening showing.
  void _paintOpen(Canvas canvas) {
    _rect(canvas, const Rect.fromLTWH(24, 54, 60, 24), _gold, radius: 4);
    _rect(canvas, const Rect.fromLTWH(26, 54, 56, 6), _detail);
    _rect(canvas, const Rect.fromLTWH(36, 54, 5, 24), _detail);
    _rect(canvas, const Rect.fromLTWH(67, 54, 5, 24), _detail);

    canvas.save();
    canvas.translate(24, 50);
    canvas.rotate(-24 * math.pi / 180);
    // Local origin is the hinge: the lid spans x 0..60 and y -20..0.
    _rect(canvas, const Rect.fromLTWH(0, -20, 60, 20), _gold, radius: 10);
    _rect(canvas, const Rect.fromLTWH(10, -16, 40, 3), _shine, radius: 1.5);
    _rect(canvas, const Rect.fromLTWH(12, -20, 5, 20), _detail);
    _rect(canvas, const Rect.fromLTWH(43, -20, 5, 20), _detail);
    canvas.restore();

    _sparkles(canvas, [(90, 14, 5), (98, 36, 3.6)], _shine);
  }

  void _paintHalo(Canvas canvas) {
    final halo = Paint()..color = _gold.withValues(alpha: 0.16);
    canvas.drawCircle(const Offset(54, 54), 46, halo);
    halo.color = _gold.withValues(alpha: 0.22);
    canvas.drawCircle(const Offset(54, 54), 38, halo);
  }

  /// Four-point sparkles at (x, y) with radius r.
  void _sparkles(Canvas canvas, List<(double, double, double)> stars, Color color) {
    final paint = Paint()..color = color;
    for (final (x, y, r) in stars) {
      final path = Path();
      for (var i = 0; i < 8; i++) {
        final a = (-90 + 45 * i) * math.pi / 180;
        final rad = i.isEven ? r : r * 0.22;
        final px = x + rad * math.cos(a);
        final py = y + rad * math.sin(a);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_KoshaPainter oldDelegate) => oldDelegate.pose != pose || oldDelegate.scheme != scheme;
}
