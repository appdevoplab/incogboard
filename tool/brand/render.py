#!/usr/bin/env python3
"""Renders the IncogBoard brand: SVG sources, Android vector drawables, launcher PNGs and store art.

The app icon is the Aurora ghost (see "the ghost" below); the launcher icons, the themed icon, the legacy
PNGs, the Play icon and icon-masks.png use it. The treasure chest is defined once below on a 108 x 108 grid (the adaptive-icon canvas; the
safe zone is the inner 66 x 66 square). Every output is generated from these shapes:

  assets/brand/*.svg                             SVG sources (icon, monochrome, poses)
  android/app/src/main/res/drawable/ic_launcher_foreground.xml
  android/app/src/main/res/drawable/ic_launcher_monochrome.xml
  android/app/src/main/res/drawable/splash_chest.xml
  android/app/src/main/res/mipmap-*dpi/ic_launcher.png  legacy launcher icons
  docs/brand/play_icon_512.png                   Play Store icon (opaque)
  docs/brand/feature_graphic_1024x500.png        Play feature graphic
  docs/brand/screenshot_frame.svg                store screenshot template with caption space
  docs/brand/icon-masks.png                      preview: masks, themed icon, 48 px

The Dart poses in lib/src/app/onboarding/incogboard_mascot.dart are a hand port of the same layout
(drawn with the theme's colour scheme). Keep the two in step when the geometry changes.

Run from anywhere:  python tool/brand/render.py
Needs Pillow on the dev machine only. The app has no dependency on it.
"""

import math
import os

from PIL import Image, ImageChops, ImageDraw, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
SS = 4  # supersampling factor for anti-aliased rasters

# Palette. Gold is the seed colour of the brand scheme (incogboardYellow); brown is incogboardBrown.
GOLD = '#EFB33A'
GOLD_LIGHT = '#FFE3A1'
GOLD_GLOW = '#FFF1C7'
BROWN = '#3E2723'
MUTE = '#B9A98F'
MUTE_LIGHT = '#E3D8C8'
MUTE_DARK = '#6B5B52'
CREAM = '#FFF6E3'
NIGHT = '#211714'
TONAL_LIGHT = '#E8DEF8'
TONAL_INK = '#4A4458'
WALL_LIGHT = '#F4F1EA'
WALL_DARK = '#1C1B1F'


# ---------------------------------------------------------------- geometry

def rrect(x, y, w, h, r, seg=12):
    """Rounded rectangle as a closed polygon (clockwise on screen)."""
    r = min(r, w / 2, h / 2)
    corners = [
        (x + w - r, y + r, -90, 0),
        (x + w - r, y + h - r, 0, 90),
        (x + r, y + h - r, 90, 180),
        (x + r, y + r, 180, 270),
    ]
    pts = []
    for cx, cy, a0, a1 in corners:
        for i in range(seg + 1):
            a = math.radians(a0 + (a1 - a0) * i / seg)
            pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def rect(x, y, w, h):
    return [(x, y), (x + w, y), (x + w, y + h), (x, y + h)]


def circle(cx, cy, r, n=120):
    return [(cx + r * math.cos(2 * math.pi * i / n), cy + r * math.sin(2 * math.pi * i / n)) for i in range(n)]


def sparkle(cx, cy, r):
    """Four-point star with straight sides."""
    pts = []
    for i in range(8):
        a = math.radians(-90 + 45 * i)
        rad = r if i % 2 == 0 else r * 0.22
        pts.append((cx + rad * math.cos(a), cy + rad * math.sin(a)))
    return pts


def rotate(pts, cx, cy, deg):
    a = math.radians(deg)
    c, s = math.cos(a), math.sin(a)
    return [(cx + (x - cx) * c - (y - cy) * s, cy + (x - cx) * s + (y - cy) * c) for x, y in pts]


# The chest. Lid and body are separated by a 4-unit gap; the keycap is the lock.
LID = rrect(24, 30, 60, 20, 10)
BODY = rrect(24, 54, 60, 24, 4)
SHINE = rrect(34, 34, 40, 3, 1.5)
STRAPS = [rect(36, 30, 5, 48), rect(67, 30, 5, 48)]
KEY_OUTER = rrect(44, 59, 20, 15, 4)
KEY_FACE = rrect(47.5, 62, 13, 9, 2.5)


def layer(color, *subs, alpha=1.0):
    return {'color': color, 'subs': list(subs), 'alpha': alpha}


def closed_chest(body, shine, detail, key_face):
    return [
        layer(body, LID),
        layer(body, BODY),
        layer(shine, SHINE),
        layer(detail, *STRAPS),
        layer(detail, KEY_OUTER),
        layer(key_face, KEY_FACE),
    ]


FULL = dict(body=GOLD, shine=GOLD_LIGHT, detail=BROWN, key_face=GOLD_LIGHT)


def background_layers():
    return [layer(BROWN, rect(0, 0, 108, 108))]


def foreground_layers():
    """The chest alone, on a transparent canvas: the adaptive foreground and the splash icon."""
    return closed_chest(**FULL)


def monochrome_layers(color='#000000'):
    """Silhouette for themed icons. The keycap is negative space (a hole with its face filled back in)."""
    return [layer(color, LID, BODY, KEY_OUTER, KEY_FACE)]


def icon_layers():
    return background_layers() + foreground_layers()


def open_layers():
    hinge = (24, 50)
    lid = rotate(LID, *hinge, -24)
    lid_shine = rotate(SHINE, *hinge, -24)
    lid_straps = [rotate(rect(36, 30, 5, 20), *hinge, -24), rotate(rect(67, 30, 5, 20), *hinge, -24)]
    return [
        layer(GOLD, BODY),
        layer(BROWN, rect(26, 54, 56, 6)),
        layer(BROWN, rect(36, 54, 5, 24), rect(67, 54, 5, 24)),
        layer(GOLD, lid),
        layer(GOLD_LIGHT, lid_shine),
        layer(BROWN, *lid_straps),
        layer(GOLD_LIGHT, sparkle(90, 14, 5), sparkle(98, 36, 3.6)),
    ]


def glowing_layers():
    return [
        layer(GOLD, circle(54, 54, 46), alpha=0.16),
        layer(GOLD, circle(54, 54, 38), alpha=0.22),
        *closed_chest(body=GOLD, shine=GOLD_GLOW, detail=BROWN, key_face=GOLD_GLOW),
        layer(GOLD_GLOW, sparkle(14, 26, 5), sparkle(94, 22, 4.5), sparkle(96, 80, 3.5)),
    ]


def quiet_layers():
    return [
        *closed_chest(body=MUTE, shine=MUTE_LIGHT, detail=MUTE_DARK, key_face=MUTE_LIGHT),
        layer(MUTE_DARK, circle(44, 20, 2.8), circle(54, 20, 2.8), circle(64, 20, 2.8)),
    ]


# ---------------------------------------------------------------- the ghost (app icon since 2026-11-24)
#
# "Aurora" ghost: a white ghost with big eyes glancing to the side and pink blush cheeks, a dark gap ring and
# a violet -> blue -> green outline, on a near-black tile. The shape is a round head, straight sides and a hem
# of three full round lobes; every outline below is that shape grown by a fixed distance, built exactly from
# circle arcs (the union of grown circles is the grown union), so the rings keep an even width.
# The chest above stays for the splash, the mascot poses and the store art until those move to the ghost too.

GHOST_TILE = '#17141F'
GHOST_WHITE = '#FFFFFF'
GHOST_INK = '#17141F'
GHOST_BLUSH = '#FF8FD1'
AURORA = [(0.0, '#B57BFF'), (0.5, '#6E8BFF'), (1.0, '#9CF86A')]

# Unscaled design grid (the same as the previews): head circle, straight sides, three lobes.
_G_CX, _G_TOP, _G_W, _G_BOTTOM, _G_LOBES = 54.0, 25.0, 48.0, 82.0, 3
_G_GAP, _G_HALO = 3.6, 7.4  # ring widths outside the body


def _ghost_outline(grow, arc_steps=48):
    """Closed outline of the ghost grown by [grow] units (0 = the body), clockwise on screen."""
    r = _G_W / 2
    head_cy = _G_TOP + r
    lobe_r = _G_W / (2 * _G_LOBES)
    lobe_cy = _G_BOTTOM - lobe_r
    R_head, R_lobe = r + grow, lobe_r + grow
    pts = []
    # Head: left side point, over the top, to the right side point.
    for i in range(arc_steps + 1):
        a = math.pi + math.pi * i / arc_steps
        pts.append((_G_CX + R_head * math.cos(a), head_cy + R_head * math.sin(a)))
    # Hem: lobes from right to left. Neighbours meet where their grown circles cross (a small notch).
    h = math.sqrt(max(R_lobe ** 2 - lobe_r ** 2, 0.0))
    meet_right = math.atan2(h, lobe_r)   # angle (y down) of the crossing with the right neighbour
    meet_left = math.atan2(h, -lobe_r)   # ... with the left neighbour
    for i in reversed(range(_G_LOBES)):
        lx = _G_CX - r + lobe_r * (2 * i + 1)
        a0 = 0.0 if i == _G_LOBES - 1 else meet_right
        a1 = math.pi if i == 0 else meet_left
        for j in range(arc_steps + 1):
            a = a0 + (a1 - a0) * j / arc_steps
            pts.append((lx + R_lobe * math.cos(a), lobe_cy + R_lobe * math.sin(a)))
    return pts


def _ellipse(cx, cy, rx, ry, n=72):
    return [(cx + rx * math.cos(2 * math.pi * i / n), cy + ry * math.sin(2 * math.pi * i / n)) for i in range(n)]


def _ghost_fit():
    """Scale and offset that put the whole ghost (outline included) inside the adaptive-icon safe zone:
    a circle of radius 33 around the canvas centre, with a little room to spare."""
    halo = _ghost_outline(_G_HALO)
    xs, ys = [p[0] for p in halo], [p[1] for p in halo]
    cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
    reach = max(math.hypot(x - cx, y - cy) for x, y in halo)
    s = 32.0 / reach
    return s, cx, cy


def _place(pts):
    s, cx, cy = _ghost_fit()
    return [(54 + (x - cx) * s, 54 + (y - cy) * s) for x, y in pts]


def _ghost_eyes():
    eyes, shines = [], []
    for ex in (45.0, 63.0):
        cx, cy = ex + 1.2, 49.0  # +1.2: the eyes glance to the side
        eyes.append(_ellipse(cx, cy, 5.4, 7.6))
        shines.append(_ellipse(cx + 5.4 * 0.35, cy - 7.6 * 0.45, 1.9, 1.9, n=36))
    return eyes, shines


def _ghost_cheeks():
    return [_ellipse(bx, 59.5, 3.2, 1.7, n=48) for bx in (39.5, 68.5)]


def ghost_foreground_layers():
    """The adaptive-icon foreground: halo (gradient), gap ring, body, eyes, shines, cheeks."""
    halo = _place(_ghost_outline(_G_HALO))
    ys = [p[1] for p in halo]
    xs = [p[0] for p in halo]
    gradient = {  # top right (violet) to bottom left (green), across the halo's box
        'x1': max(xs), 'y1': min(ys), 'x2': min(xs), 'y2': max(ys), 'stops': AURORA,
    }
    eyes, shines = _ghost_eyes()
    return [
        dict(layer(AURORA[0][1], halo), gradient=gradient),
        layer(GHOST_INK, _place(_ghost_outline(_G_GAP))),
        layer(GHOST_WHITE, _place(_ghost_outline(0))),
        layer(GHOST_BLUSH, *[_place(c) for c in _ghost_cheeks()]),
        layer(GHOST_INK, *[_place(e) for e in eyes]),
        layer(GHOST_WHITE, *[_place(s) for s in shines]),
    ]


def ghost_background_layers():
    return [layer(GHOST_TILE, rect(0, 0, 108, 108))]


def ghost_monochrome_layers(color='#000000'):
    """Themed icon: the ghost's silhouette with the eyes as holes (even-odd), shines filled back in."""
    eyes, shines = _ghost_eyes()
    return [
        layer(color, _place(_ghost_outline(0)), *[_place(e) for e in eyes]),
        layer(color, *[_place(s) for s in shines]),
    ]


def ghost_icon_layers():
    return ghost_background_layers() + ghost_foreground_layers()


POSES = {
    'pose_open': open_layers,
    'pose_locked': foreground_layers,
    'pose_glowing': glowing_layers,
    'pose_quiet': quiet_layers,
}


# ---------------------------------------------------------------- output formats

def fmt(v):
    s = f'{v:.2f}'.rstrip('0').rstrip('.')
    return '0' if s in ('-0', '') else s


def path_d(subs):
    return ''.join('M' + 'L'.join(f'{fmt(x)},{fmt(y)}' for x, y in pts) + 'Z' for pts in subs)


def to_svg(layers, comment):
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<!-- {comment}. Generated by tool/brand/render.py; edit the geometry there. -->',
        '<svg xmlns="http://www.w3.org/2000/svg" width="108" height="108" viewBox="0 0 108 108">',
    ]
    for n, lay in enumerate(layers):
        opacity = '' if lay['alpha'] >= 1 else f' fill-opacity="{fmt(lay["alpha"])}"'
        fill = lay['color']
        g = lay.get('gradient')
        if g:
            gid = f'g{n}'
            lines.append(
                f'  <defs><linearGradient id="{gid}" gradientUnits="userSpaceOnUse" x1="{fmt(g["x1"])}" '
                f'y1="{fmt(g["y1"])}" x2="{fmt(g["x2"])}" y2="{fmt(g["y2"])}">'
                + ''.join(f'<stop offset="{fmt(o)}" stop-color="{c}"/>' for o, c in g['stops'])
                + '</linearGradient></defs>'
            )
            fill = f'url(#{gid})'
        lines.append(
            f'  <path fill="{fill}"{opacity} fill-rule="evenodd" d="{path_d(lay["subs"])}"/>'
        )
    lines.append('</svg>')
    return '\n'.join(lines) + '\n'


def to_vector_drawable(layers, comment):
    gradients = any(lay.get('gradient') for lay in layers)
    lines = [
        '<?xml version="1.0" encoding="utf-8"?>',
        f'<!-- {comment}. Generated by tool/brand/render.py; edit the geometry there. -->',
        '<vector xmlns:android="http://schemas.android.com/apk/res/android"',
        *(['    xmlns:aapt="http://schemas.android.com/aapt"'] if gradients else []),
        '    android:width="108dp"',
        '    android:height="108dp"',
        '    android:viewportWidth="108"',
        '    android:viewportHeight="108">',
    ]
    for lay in layers:
        alpha = '' if lay['alpha'] >= 1 else f'\n        android:fillAlpha="{fmt(lay["alpha"])}"'
        g = lay.get('gradient')
        lines.append('    <path')
        if not g:
            lines.append(f'        android:fillColor="{lay["color"]}"{alpha}')
        elif alpha:
            lines.append(f'       {alpha.strip()}')
        lines.append('        android:fillType="evenOdd"')
        if not g:
            lines.append(f'        android:pathData="{path_d(lay["subs"])}" />')
            continue
        # Gradient fills (API 24+; the adaptive icon needs 26) go in an aapt:attr block.
        lines.append(f'        android:pathData="{path_d(lay["subs"])}">')
        lines.append('        <aapt:attr name="android:fillColor">')
        lines.append(
            f'            <gradient android:type="linear" android:startX="{fmt(g["x1"])}" '
            f'android:startY="{fmt(g["y1"])}" android:endX="{fmt(g["x2"])}" android:endY="{fmt(g["y2"])}">'
        )
        for o, c in g['stops']:
            lines.append(f'                <item android:offset="{fmt(o)}" android:color="{c}" />')
        lines.append('            </gradient>')
        lines.append('        </aapt:attr>')
        lines.append('    </path>')
    lines.append('</vector>')
    return '\n'.join(lines) + '\n'


def hex_rgba(h):
    h = h.lstrip('#')
    if len(h) == 6:
        h = 'FF' + h
    return tuple(int(h[i:i + 2], 16) for i in (2, 4, 6, 0))


def linear_gradient(big, scale, g):
    """A big x big RGBA image of the layer gradient [g] (coordinates on the 108 grid, clamped at the ends)."""
    small = 216
    k = small / 108.0
    x1, y1, x2, y2 = g['x1'] * k, g['y1'] * k, g['x2'] * k, g['y2'] * k
    dx, dy = x2 - x1, y2 - y1
    length2 = dx * dx + dy * dy or 1.0
    stops = [(o, hex_rgba(c)) for o, c in g['stops']]
    img = Image.new('RGBA', (small, small))
    px = img.load()
    for y in range(small):
        for x in range(small):
            t = min(max(((x - x1) * dx + (y - y1) * dy) / length2, 0.0), 1.0)
            for i in range(len(stops) - 1):
                (o0, c0), (o1, c1) = stops[i], stops[i + 1]
                if o0 <= t <= o1:
                    f = (t - o0) / (o1 - o0) if o1 > o0 else 0.0
                    px[x, y] = tuple(int(round(c0[j] + (c1[j] - c0[j]) * f)) for j in range(4))
                    break
    return img.resize((big, big), Image.BILINEAR)


def raster(layers, px, supersample=SS):
    """Rasterises layers (painter's order) onto a transparent px x px RGBA image."""
    big = px * supersample
    scale = big / 108.0
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    for lay in layers:
        mask = Image.new('L', (big, big), 0)
        for pts in lay['subs']:
            m = Image.new('L', (big, big), 0)
            ImageDraw.Draw(m).polygon([(x * scale, y * scale) for x, y in pts], fill=255)
            mask = ImageChops.difference(mask, m)  # even-odd: overlapping subpaths cancel
        if lay['alpha'] < 1:
            mask = mask.point(lambda v, a=lay['alpha']: int(round(v * a)))
        g = lay.get('gradient')
        colour = linear_gradient(big, scale, g) if g else Image.new('RGBA', (big, big), hex_rgba(lay['color']))
        colour.putalpha(mask)
        img = Image.alpha_composite(img, colour)
    return img.resize((px, px), Image.LANCZOS)


def write_text(path, text):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)


def save_png(img, path):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    img.save(full, optimize=True)


# ---------------------------------------------------------------- store art

def screenshot_frame_svg():
    chest = path_d([p for lay in foreground_layers() for p in lay['subs']])
    body_paths = []
    for lay in foreground_layers():
        body_paths.append(f'    <path fill="{lay["color"]}" fill-rule="evenodd" d="{path_d(lay["subs"])}"/>')
    return '\n'.join([
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<!-- Store screenshot frame (1080 x 1920). Generated by tool/brand/render.py. -->',
        '<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="1920" viewBox="0 0 1080 1920">',
        f'  <rect width="1080" height="1920" fill="{BROWN}"/>',
        '  <!-- Chest mark, top left. Keep it small: it is a sign-off, not the hero. -->',
        '  <g transform="translate(80,80) scale(1.5)">',
        *body_paths,
        '  </g>',
        '  <!-- Caption: one short line, large. Replace the placeholder text. -->',
        f'  <text x="80" y="420" font-family="Google Sans Flex, Roboto, sans-serif" font-size="96" '
        f'font-weight="600" fill="{GOLD_LIGHT}">Your caption goes here</text>',
        f'  <text x="80" y="500" font-family="Google Sans Flex, Roboto, sans-serif" font-size="48" '
        f'fill="{MUTE_LIGHT}">One supporting line, if needed</text>',
        '  <!-- Screenshot slot: 920 x 1200 at 3:4, rounded. Place the device capture here. -->',
        f'  <rect x="80" y="620" width="920" height="1200" rx="56" fill="{NIGHT}" stroke="{GOLD}" '
        'stroke-width="6" stroke-dasharray="24 16"/>',
        f'  <text x="540" y="1230" text-anchor="middle" font-family="Google Sans Flex, Roboto, sans-serif" '
        f'font-size="44" fill="{MUTE}">Screenshot</text>',
        '</svg>',
        '',
    ])


def feature_graphic():
    img = Image.new('RGBA', (1024, 500), hex_rgba(BROWN))
    mark = raster(icon_layers(), 340)
    img.alpha_composite(mark, (90, 80))
    font_path = os.path.join(ROOT, 'assets', 'fonts', 'GoogleSansFlex.ttf')
    title = ImageFont.truetype(font_path, 168)
    sub = ImageFont.truetype(font_path, 44)
    small = ImageFont.truetype(font_path, 28)
    draw = ImageDraw.Draw(img)
    draw.text((440, 96), 'IncogBoard', font=title, fill=hex_rgba(GOLD))
    draw.text((446, 300), 'Your words, kept with you.', font=sub, fill=hex_rgba(CREAM))
    draw.text((446, 362), 'Works offline. Nothing leaves your phone.', font=small, fill=hex_rgba(MUTE_LIGHT))
    return img.convert('RGB').convert('RGBA')


def mask_points(kind, tile):
    """Polygon for a launcher mask filling a tile (in tile pixels)."""
    c = tile / 2
    if kind == 'circle':
        return circle(c, c, c * 0.999, n=240)
    if kind == 'squircle':
        n = 5.0
        r = c * 0.999
        pts = []
        for i in range(360):
            t = 2 * math.pi * i / 360
            cs, sn = math.cos(t), math.sin(t)
            x = r * math.copysign(abs(cs) ** (2 / n), cs)
            y = r * math.copysign(abs(sn) ** (2 / n), sn)
            pts.append((c + x, c + y))
        return pts
    # Approximate 4-lobed "cookie" mask.
    base = c * 0.88
    pts = []
    for i in range(360):
        t = 2 * math.pi * i / 360
        rr = base * (1 - 0.07 * math.cos(4 * t))
        pts.append((c + rr * math.cos(t), c + rr * math.sin(t)))
    return pts


def masked_tile(icon_img, kind, tile, fill):
    """Composites an icon (or a flat colour when icon_img is None) through a launcher mask."""
    big = tile * SS
    mask = Image.new('L', (big, big), 0)
    ImageDraw.Draw(mask).polygon([(x * SS, y * SS) for x, y in mask_points(kind, tile)], fill=255)
    mask = mask.resize((tile, tile), Image.LANCZOS)
    base = Image.new('RGBA', (tile, tile), hex_rgba(fill))
    if icon_img is not None:
        base.alpha_composite(icon_img.resize((tile, tile), Image.LANCZOS))
    out = Image.new('RGBA', (tile, tile), (0, 0, 0, 0))
    out.paste(base, (0, 0), mask)
    return out


def masks_sheet():
    tile = 216
    small = 48
    gap = 40
    cols = ['circle', 'squircle', 'cookie', 'themed']
    width = gap + len(cols) * (tile + gap)
    height = gap + 2 * (tile + gap) + (small + gap) * 2 + 40
    sheet = Image.new('RGBA', (width, height), hex_rgba(WALL_LIGHT))
    big_icon = raster(ghost_icon_layers(), tile)
    mono_dark = raster(ghost_monochrome_layers(TONAL_INK), tile)
    mono_light = raster(ghost_monochrome_layers(TONAL_LIGHT), tile)
    rows = [
        (gap, WALL_LIGHT, big_icon, mono_dark, TONAL_LIGHT, tile),
        (gap * 2 + tile, WALL_DARK, big_icon, mono_light, TONAL_INK, tile),
    ]
    for kind_idx, kind in enumerate(cols):
        x = gap + kind_idx * (tile + gap)
        for y, wall, icon, mono, tonal, _ in rows[:2]:
            if kind == 'themed':
                tile_img = masked_tile(mono, 'circle', tile, tonal)
            else:
                tile_img = masked_tile(icon, kind, tile, wall)
            sheet.alpha_composite(tile_img, (x, y))
    # 48 px actual size, each mask on the light and dark wallpaper.
    y48 = gap * 3 + 2 * tile
    icon48 = raster(ghost_icon_layers(), small)
    for kind_idx, kind in enumerate(cols[:3]):
        x = gap + kind_idx * (tile + gap)
        sheet.alpha_composite(masked_tile(icon48, kind, small, WALL_LIGHT), (x, y48))
        sheet.alpha_composite(masked_tile(icon48, kind, small, WALL_DARK), (x, y48 + small + gap))
    sheet.alpha_composite(masked_tile(raster(ghost_monochrome_layers(TONAL_INK), small), 'circle', small, TONAL_LIGHT),
                          (gap + 3 * (tile + gap), y48))
    return sheet.convert('RGB')


def main():
    # SVG sources.
    write_text('assets/brand/icon_background.svg', to_svg(ghost_background_layers(), 'IncogBoard icon background'))
    write_text('assets/brand/icon_foreground.svg', to_svg(ghost_foreground_layers(), 'IncogBoard icon foreground (ghost)'))
    write_text('assets/brand/icon_monochrome.svg', to_svg(ghost_monochrome_layers(), 'IncogBoard themed (monochrome) icon'))
    write_text('assets/brand/incogboard_icon.svg', to_svg(ghost_icon_layers(), 'IncogBoard icon, full colour (ghost)'))
    for name, make in POSES.items():
        write_text(f'assets/brand/{name}.svg', to_svg(make(), f'IncogBoard chest pose: {name[5:]}'))
    write_text('docs/brand/screenshot_frame.svg', screenshot_frame_svg())

    # Android vector drawables.
    res = 'android/app/src/main/res/drawable'
    write_text(f'{res}/ic_launcher_foreground.xml',
               to_vector_drawable(ghost_foreground_layers(), 'IncogBoard adaptive icon foreground (ghost)'))
    write_text(f'{res}/ic_launcher_monochrome.xml',
               to_vector_drawable(ghost_monochrome_layers(), 'IncogBoard themed icon (Android 13+), eyes as negative space'))
    write_text(f'{res}/splash_chest.xml',
               to_vector_drawable(foreground_layers(), 'IncogBoard splash chest (SplashScreen API and launch background)'))

    # Legacy launcher PNGs (pre-Android 8 and fallback).
    for density, px in (('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)):
        save_png(raster(ghost_icon_layers(), px),
                 f'android/app/src/main/res/mipmap-{density}/ic_launcher.png')

    # Store art.
    save_png(raster(ghost_icon_layers(), 512).convert('RGB').convert('RGBA'), 'docs/brand/play_icon_512.png')
    save_png(feature_graphic().convert('RGB'), 'docs/brand/feature_graphic_1024x500.png')
    save_png(masks_sheet(), 'docs/brand/icon-masks.png')


if __name__ == '__main__':
    main()
