// SPDX-License-Identifier: GPL-3.0-or-later
//
// Layout engine: turns a [KeyboardLayoutDef] plus a size into key rectangles.
// Coordinates are keyboard-local logical pixels, origin at the top-left of the
// key area (the suggestion strip is not part of it).
import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:meta/meta.dart';

import '../../engine/contracts.dart';
import 'layout_model.dart';

/// One key with its geometry.
@immutable
class PlacedKey {
  const PlacedKey({
    required this.def,
    required this.index,
    required this.row,
    required this.column,
    required this.cell,
    required this.rect,
  });

  final KeyDef def;

  /// Position in [LaidOutKeyboard.keys].
  final int index;
  final int row;
  final int column;

  /// Full cell including the half gap on every side. Cells tile the keyboard,
  /// so hit-testing has no dead zones.
  final Rect cell;

  /// Visible key rect (gaps excluded).
  final Rect rect;
}

/// Vertical band of one row.
@immutable
class RowBand {
  const RowBand({required this.top, required this.bottom, required this.keys});

  final double top;
  final double bottom;
  final List<PlacedKey> keys;
}

class LaidOutKeyboard {
  LaidOutKeyboard({
    required this.layout,
    required this.size,
    required this.keyGap,
    required this.keys,
    required this.rows,
  });

  final KeyboardLayoutDef layout;
  final Size size;
  final double keyGap;
  final List<PlacedKey> keys;
  final List<RowBand> rows;

  /// The key under [p]: the row band is chosen by y (clamped to the first and
  /// last row), then the cell containing x, else the nearest key centre.
  /// Never returns null unless the layout is empty.
  PlacedKey? hitTest(Offset p) {
    if (rows.isEmpty) return null;
    var band = rows.last;
    if (p.dy < rows.first.bottom) {
      band = rows.first;
    } else {
      for (final r in rows) {
        if (p.dy < r.bottom) {
          band = r;
          break;
        }
      }
    }
    if (band.keys.isEmpty) return null;
    PlacedKey? best;
    var bestDist = double.infinity;
    for (final k in band.keys) {
      if (p.dx >= k.cell.left && p.dx < k.cell.right) return k;
      final d = (p.dx - k.cell.center.dx).abs();
      if (d < bestDist) {
        bestDist = d;
        best = k;
      }
    }
    return best;
  }

  /// Character keys whose lower-case output is a letter, for spatial
  /// autocorrect and gesture typing. Keyed by lower-case output.
  KeyboardGeometry toGeometry({String? layoutId}) {
    final map = <String, Rect>{};
    for (final k in keys) {
      final out = k.def.output;
      if (!k.def.isCharacter || out == null) continue;
      final lower = out.toLowerCase();
      if (!_letter.hasMatch(lower)) continue;
      map.putIfAbsent(lower, () => k.rect);
    }
    return KeyboardGeometry(layoutId: layoutId ?? layout.id, size: size, keys: map);
  }

  /// Median width of the character keys (used for the swipe-start threshold).
  double get keyWidth {
    final widths = [
      for (final k in keys)
        if (k.def.isCharacter) k.rect.width,
    ]..sort();
    return widths.isEmpty ? 1 : widths[widths.length ~/ 2];
  }

  static final RegExp _letter = RegExp(r'^\p{L}$', unicode: true);
}

abstract final class KeyboardLayoutEngine {
  /// Computes key rects for [layout] inside [size].
  ///
  /// Row heights are relative (`row.height`); key widths are in units. The unit
  /// width comes from the widest row; narrower rows are centred, so rows that
  /// declare `padding` and rows that don't both look right.
  static LaidOutKeyboard layout(KeyboardLayoutDef layout, Size size, {double keyGap = 6}) {
    final rows = layout.rows;
    final totalHeight = rows.fold<double>(0, (s, r) => s + r.height);
    final maxUnits = rows.fold<double>(0, (m, r) => math.max(m, r.totalUnits));
    final keys = <PlacedKey>[];
    final bands = <RowBand>[];
    if (rows.isEmpty || totalHeight <= 0 || maxUnits <= 0) {
      return LaidOutKeyboard(layout: layout, size: size, keyGap: keyGap, keys: keys, rows: bands);
    }
    final unitWidth = size.width / maxUnits;
    final half = keyGap / 2;
    var y = 0.0;
    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      final rowHeight = size.height * row.height / totalHeight;
      final top = y;
      final bottom = r == rows.length - 1 ? size.height : y + rowHeight;
      y += rowHeight;
      // Centre narrower rows.
      var x = (size.width - row.totalUnits * unitWidth) / 2 + row.padding * unitWidth;
      final rowKeys = <PlacedKey>[];
      for (var c = 0; c < row.keys.length; c++) {
        final def = row.keys[c];
        final w = def.width * unitWidth;
        final visual = Rect.fromLTRB(x, top, x + w, bottom);
        final inset = math.min(half, math.min(visual.width, visual.height) / 4);
        // The outer cells stretch over the row padding so edge touches still hit a key.
        final cell = Rect.fromLTRB(c == 0 ? 0 : x, top, c == row.keys.length - 1 ? size.width : x + w, bottom);
        final placed = PlacedKey(
          def: def,
          index: keys.length,
          row: r,
          column: c,
          cell: cell,
          rect: visual.deflate(inset),
        );
        keys.add(placed);
        rowKeys.add(placed);
        x += w;
      }
      bands.add(RowBand(top: top, bottom: bottom, keys: rowKeys));
    }
    return LaidOutKeyboard(layout: layout, size: size, keyGap: keyGap, keys: keys, rows: bands);
  }
}
