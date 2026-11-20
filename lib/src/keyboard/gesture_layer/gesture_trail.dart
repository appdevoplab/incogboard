// SPDX-License-Identifier: GPL-3.0-or-later
//
// CONTRACT (Wave 0) for the swipe trail; implementation owned by Wave 1-C.
// The keyboard view (Wave 1-A) feeds points into [GestureTrailController]
// and stacks [GestureTrailLayer] above the keys. Keep these constructor and
// method signatures stable.
import 'package:flutter/widgets.dart';

import '../../engine/contracts.dart';
import '../../theme/keyboard_theme_data.dart';

class GestureTrailController extends ChangeNotifier {
  final List<TouchPoint> _points = [];
  String? _preview;
  bool _active = false;

  List<TouchPoint> get points => List.unmodifiable(_points);
  bool get isActive => _active;

  /// Live top candidate shown while swiping (set by the gesture engine).
  String? get preview => _preview;

  void begin(TouchPoint p) {
    _points
      ..clear()
      ..add(p);
    _active = true;
    _preview = null;
    notifyListeners();
  }

  void add(TouchPoint p) {
    if (!_active) return;
    _points.add(p);
    notifyListeners();
  }

  set preview(String? value) {
    if (value == _preview) return;
    _preview = value;
    notifyListeners();
  }

  /// Finger lifted: the trail fades out (painter decides how).
  void end() {
    _active = false;
    notifyListeners();
  }

  void clear() {
    _points.clear();
    _active = false;
    _preview = null;
    notifyListeners();
  }

  GesturePath get path => GesturePath(List.unmodifiable(_points));
}

/// Paints the swipe trail. Placeholder: a plain polyline.
class GestureTrailLayer extends StatelessWidget {
  const GestureTrailLayer({
    super.key,
    required this.controller,
    required this.theme,
    this.trailWidth = 6,
    this.fadeMs = 300,
    this.showTrail = true,
    this.showPreview = true,
  });

  final GestureTrailController controller;
  final KeyboardThemeData theme;

  /// From SwipeSettings.
  final double trailWidth;
  final int fadeMs;
  final bool showTrail;
  final bool showPreview;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(painter: _TrailPainter(controller, theme), size: Size.infinite),
  );
}

class _TrailPainter extends CustomPainter {
  _TrailPainter(this.controller, this.theme) : super(repaint: controller);

  final GestureTrailController controller;
  final KeyboardThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final pts = controller.points;
    if (pts.length < 2 || !controller.isActive) return;
    final paint = Paint()
      ..color = theme.trailStart
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(pts.first.x, pts.first.y);
    for (final p in pts.skip(1)) {
      path.lineTo(p.x, p.y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) => oldDelegate.theme != theme;
}
