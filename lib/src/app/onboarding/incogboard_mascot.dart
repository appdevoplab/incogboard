// SPDX-License-Identifier: GPL-3.0-or-later
//
// The IncogBoard mascot: the Aurora ghost of the app icon (since 2026-11-24; before that a treasure
// chest). Drawn with a CustomPainter in the brand colours on a circle in the theme's surface colour.
// The geometry is a hand port of the ghost in tool/brand/render.py (a 108-unit grid, the adaptive-icon
// canvas; the poses are `ghost_pose_*` there); keep the two in step when the shapes change.
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// The mascot's four moods.
enum IncogBoardPose {
  /// The ghost with two sparkles: welcome and onboarding.
  open,

  /// The ghost with a padlock badge: privacy and app lock.
  locked,

  /// An aurora glow behind the ghost: voice typing, translation and other work in progress.
  glowing,

  /// Muted, eyes closed: incognito and empty states.
  quiet,
}

class IncogBoardMascot extends StatelessWidget {
  const IncogBoardMascot({
    super.key,
    this.size = 96,
    this.label = 'IncogBoard mascot',
    this.pose = IncogBoardPose.open,
  });

  /// Width and height in logical pixels. Crisp from 24 to 160.
  final double size;

  /// Spoken by TalkBack.
  final String label;

  /// Which drawing to show. Changing it springs between poses unless animations are disabled.
  final IncogBoardPose pose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      image: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.surfaceContainerHigh),
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
            // AnimatedSwitcher lays its children out loosely, and a CustomPaint without a child would
            // then size itself to zero, so the painted box states its size.
            child: KeyedSubtree(
              key: ValueKey<IncogBoardPose>(pose),
              child: SizedBox.square(
                dimension: size,
                child: CustomPaint(painter: _GhostPainter(pose: pose)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Brand colours (render.py: GHOST_*, AURORA, GHOST_MUTE_*). The ghost keeps them in light and dark mode.
const Color _white = Color(0xFFFFFFFF);
const Color _ink = Color(0xFF17141F);
const Color _blush = Color(0xFFFF8FD1);
const Color _violet = Color(0xFFB57BFF);
const Color _blue = Color(0xFF6E8BFF);
const Color _green = Color(0xFF9CF86A);
const Color _muteHalo = Color(0xFF9E98AE);
const Color _muteBody = Color(0xFFE6E3EE);
const Color _muteInk = Color(0xFF6B6680);

/// The ghost's shape on its own design grid, and the transform that fits it into the 108 grid.
abstract final class _Ghost {
  static const double cx = 54, top = 25, width = 48, bottom = 82;
  static const int lobes = 3;
  static const double gap = 3.6, halo = 7.4;

  /// Closed outline grown by [grow] units (0 = the body): head arc, then the hem lobes right to left.
  static Path outline(double grow, {int steps = 48}) {
    final r = width / 2;
    final headCy = top + r;
    final lobeR = width / (2 * lobes);
    final lobeCy = bottom - lobeR;
    final rHead = r + grow, rLobe = lobeR + grow;
    final pts = <Offset>[];
    for (var i = 0; i <= steps; i++) {
      final a = math.pi + math.pi * i / steps;
      pts.add(Offset(cx + rHead * math.cos(a), headCy + rHead * math.sin(a)));
    }
    final h = math.sqrt(math.max(rLobe * rLobe - lobeR * lobeR, 0.0));
    final meetRight = math.atan2(h, lobeR);
    final meetLeft = math.atan2(h, -lobeR);
    for (var i = lobes - 1; i >= 0; i--) {
      final lx = cx - r + lobeR * (2 * i + 1);
      final a0 = i == lobes - 1 ? 0.0 : meetRight;
      final a1 = i == 0 ? math.pi : meetLeft;
      for (var j = 0; j <= steps; j++) {
        final a = a0 + (a1 - a0) * j / steps;
        pts.add(Offset(lx + rLobe * math.cos(a), lobeCy + rLobe * math.sin(a)));
      }
    }
    return Path()..addPolygon(pts, true);
  }

  static final Path haloPath = outline(halo);
  static final Path gapPath = outline(gap);
  static final Path bodyPath = outline(0);

  /// Scale and centre that fit the halo inside a circle of radius 32 around the canvas centre.
  static final (double, Offset) fit = () {
    final b = haloPath.getBounds();
    final c = b.center;
    var reach = 0.0;
    for (final m in haloPath.computeMetrics()) {
      for (var d = 0.0; d <= m.length; d += 0.5) {
        final p = m.getTangentForOffset(d)!.position;
        reach = math.max(reach, (p - c).distance);
      }
    }
    return (32.0 / reach, c);
  }();

  /// Moves the canvas from the 108 grid into the ghost's design grid.
  static void enter(Canvas canvas) {
    final (s, c) = fit;
    canvas.translate(54, 54);
    canvas.scale(s);
    canvas.translate(-c.dx, -c.dy);
  }

  static const List<double> eyeX = [45.0, 63.0];
}

/// Draws on a 108 x 108 grid, scaled to the widget.
class _GhostPainter extends CustomPainter {
  const _GhostPainter({required this.pose});

  final IncogBoardPose pose;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 108);
    switch (pose) {
      case IncogBoardPose.open:
        _ghost(canvas);
        _sparkles(canvas, const [(90, 18, 6, _violet), (98, 38, 4, _green)]);
      case IncogBoardPose.locked:
        canvas.save();
        canvas.translate(49, 49);
        canvas.scale(0.9);
        canvas.translate(-54, -54);
        _ghost(canvas);
        canvas.restore();
        _padlockBadge(canvas, const Offset(80, 80));
      case IncogBoardPose.glowing:
        canvas.drawCircle(const Offset(54, 54), 52, Paint()..color = _blue.withValues(alpha: 0.14));
        canvas.drawCircle(const Offset(54, 54), 44, Paint()..color = _violet.withValues(alpha: 0.18));
        _ghost(canvas);
        _sparkles(canvas, const [(14, 24, 5, _green), (96, 20, 4.5, _violet), (96, 84, 3.5, _blue)]);
      case IncogBoardPose.quiet:
        _quietGhost(canvas);
        final dots = Paint()..color = _muteHalo;
        for (final x in const [46.0, 54.0, 62.0]) {
          canvas.drawCircle(Offset(x, 8), 2.4, dots);
        }
    }
    canvas.restore();
  }

  /// Halo (aurora gradient), gap ring, body, cheeks, eyes and their shines.
  void _ghost(Canvas canvas) {
    canvas.save();
    _Ghost.enter(canvas);
    final haloBounds = _Ghost.haloPath.getBounds();
    canvas.drawPath(
      _Ghost.haloPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_violet, _blue, _green],
          stops: [0, 0.5, 1],
        ).createShader(haloBounds),
    );
    canvas.drawPath(_Ghost.gapPath, Paint()..color = _ink);
    canvas.drawPath(_Ghost.bodyPath, Paint()..color = _white);
    final blush = Paint()..color = _blush;
    for (final bx in const [39.5, 68.5]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(bx, 59.5), width: 6.4, height: 3.4), blush);
    }
    final ink = Paint()..color = _ink;
    final shine = Paint()..color = _white;
    for (final ex in _Ghost.eyeX) {
      final c = Offset(ex + 1.2, 49);
      canvas.drawOval(Rect.fromCenter(center: c, width: 10.8, height: 15.2), ink);
      canvas.drawCircle(c + const Offset(5.4 * 0.35, -7.6 * 0.45), 1.9, shine);
    }
    canvas.restore();
  }

  void _quietGhost(Canvas canvas) {
    canvas.save();
    _Ghost.enter(canvas);
    canvas.drawPath(_Ghost.haloPath, Paint()..color = _muteHalo);
    canvas.drawPath(_Ghost.gapPath, Paint()..color = _muteInk);
    canvas.drawPath(_Ghost.bodyPath, Paint()..color = _muteBody);
    final lid = Paint()
      ..color = _muteInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (final ex in _Ghost.eyeX) {
      final rect = Rect.fromCircle(center: Offset(ex + 1.2, 48), radius: 4.6);
      canvas.drawArc(rect, 20 * math.pi / 180, 140 * math.pi / 180, false, lid);
    }
    canvas.restore();
  }

  void _padlockBadge(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 15, Paint()..color = _ink);
    canvas.drawCircle(c, 13, Paint()..color = _blue);
    final white = Paint()..color = _white;
    final shackle = Paint()
      ..color = _white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawArc(Rect.fromCircle(center: c + const Offset(0, -3.5), radius: 4.6), math.pi, math.pi, false, shackle);
    canvas.drawRect(Rect.fromLTWH(c.dx - 5.8, c.dy - 3.6, 1.2, 3.2), white);
    canvas.drawRect(Rect.fromLTWH(c.dx + 4.6, c.dy - 3.6, 1.2, 3.2), white);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(c.dx - 7, c.dy - 1, 14, 10), const Radius.circular(2.2)),
      white,
    );
    canvas.drawCircle(c + const Offset(0, 3.5), 1.6, Paint()..color = _blue);
  }

  /// Four-point sparkles at (x, y) with radius r.
  void _sparkles(Canvas canvas, List<(double, double, double, Color)> stars) {
    for (final (x, y, r, color) in stars) {
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
      canvas.drawPath(path, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_GhostPainter oldDelegate) => oldDelegate.pose != pose;
}
