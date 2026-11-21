// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. The Myna mascot as a vector placeholder: a geometric dark-brown myna with a
// yellow beak and eye patch, whose wing is a keycap, on a warm yellow circle. Wave 3-E draws the
// real artwork; swap the body of [MynaMascot] then and keep the constructor.
import 'package:material_ui/material_ui.dart';

import '../../theme/presets.dart';

class MynaMascot extends StatelessWidget {
  const MynaMascot({super.key, this.size = 96, this.label = 'Myna mascot'});

  /// Width and height in logical pixels.
  final double size;

  /// Spoken by TalkBack.
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      image: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primaryContainer),
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _MynaPainter(
              body: const Color(mynaBrown),
              wingFace: const Color(0xFF6D4C41),
              beak: const Color(mynaYellow),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws on a 120 x 120 grid, scaled to the widget.
class _MynaPainter extends CustomPainter {
  const _MynaPainter({required this.body, required this.wingFace, required this.beak});

  final Color body;
  final Color wingFace;
  final Color beak;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 120);
    final bodyPaint = Paint()..color = body;
    final beakPaint = Paint()..color = beak;

    // Tail.
    canvas.drawPath(
      Path()
        ..moveTo(34, 72)
        ..lineTo(14, 100)
        ..lineTo(26, 104)
        ..lineTo(46, 84)
        ..close(),
      bodyPaint,
    );
    // Body and head.
    canvas.drawOval(const Rect.fromLTWH(24, 46, 70, 50), bodyPaint);
    canvas.drawCircle(const Offset(70, 40), 24, bodyPaint);
    // Beak.
    canvas.drawPath(
      Path()
        ..moveTo(88, 32)
        ..lineTo(112, 41)
        ..lineTo(88, 50)
        ..close(),
      beakPaint,
    );
    // Yellow eye patch with a dark eye and a highlight.
    canvas.drawCircle(const Offset(73, 36), 9, beakPaint);
    canvas.drawCircle(const Offset(75, 36), 4.2, bodyPaint);
    canvas.drawCircle(const Offset(76.4, 34.6), 1.3, Paint()..color = const Color(0xFFFFFFFF));
    // Legs.
    final legPaint = Paint()
      ..color = beak
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(58, 92), const Offset(56, 106), legPaint);
    canvas.drawLine(const Offset(72, 92), const Offset(74, 106), legPaint);
    // Wing: a keycap, with a darker lip underneath and a lighter face on top.
    final cap = RRect.fromRectAndRadius(const Rect.fromLTWH(40, 56, 42, 32), const Radius.circular(10));
    canvas.drawRRect(cap.shift(const Offset(0, 4)), Paint()..color = Color.lerp(body, const Color(0xFF000000), 0.35)!);
    canvas.drawRRect(cap, Paint()..color = wingFace);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MynaPainter oldDelegate) =>
      oldDelegate.body != body || oldDelegate.wingFace != wingFace || oldDelegate.beak != beak;
}
