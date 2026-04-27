"""
CampusAI App Icon Generator
Produces a 1024x1024 PNG icon:
- White background with very subtle warm tint
- Maroon (#8B1A2B) shield shape (CU brand)
- Gold (#C9922A) AI spark/circuit accent inside shield
- No text
"""

from PIL import Image, ImageDraw
import math
import os

SIZE = 1024
OUT  = os.path.join(os.path.dirname(__file__), "icon.png")

# Brand colors
WHITE   = (255, 255, 252)        # slightly warm white background
MAROON  = (139, 26,  43)         # #8B1A2B
MAROON2 = (94,  15,  26)         # #5E0F1A  darker maroon for depth
GOLD    = (201, 146, 42)         # #C9922A
GOLD2   = (232, 180, 85)         # #E8B455  lighter gold highlight
WHITE_S = (255, 255, 255, 220)   # semi-transparent white for inner highlight

img  = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# ── Background: white rounded square ──────────────────────────────────────────
radius = 220
bg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
bg_draw = ImageDraw.Draw(bg)
bg_draw.rounded_rectangle([0, 0, SIZE, SIZE], radius=radius, fill=WHITE + (255,))
img = Image.alpha_composite(img, bg)
draw = ImageDraw.Draw(img)

# ── Shield path ───────────────────────────────────────────────────────────────
# Shield: centered, occupies roughly 55% width x 65% height
sw = int(SIZE * 0.52)   # shield width
sh = int(SIZE * 0.62)   # shield height
sx = (SIZE - sw) // 2   # left edge
sy = int(SIZE * 0.17)   # top edge

def shield_polygon(sx, sy, sw, sh):
    """
    Classic heater shield:
    flat top, gentle curves on sides, tapers to a point at bottom.
    Returns a list of (x,y) points approximating the shield outline.
    """
    pts = []
    cx = sx + sw // 2

    # Top-left corner arc (small radius)
    cr = sw * 0.08
    # Top edge (flat)
    pts.append((sx + cr, sy))
    pts.append((sx + sw - cr, sy))

    # Top-right rounded corner
    for i in range(0, 10):
        a = math.radians(90 - i * 9)
        pts.append((sx + sw - cr + cr * math.cos(a),
                    sy + cr - cr * math.sin(a)))

    # Right side — slight inward curve in upper half, then taper
    # Upper-right straight-ish
    mid_y = sy + sh * 0.52
    pts.append((sx + sw, sy + sh * 0.38))

    # Right taper toward point — bezier approximated with segments
    steps = 20
    for i in range(steps + 1):
        t = i / steps
        # Cubic bezier: P0=(sx+sw, mid_y), P1=(sx+sw, sy+sh*0.82),
        #               P2=(cx+sw*0.15, sy+sh*0.92), P3=(cx, sy+sh)
        p0x, p0y = sx + sw, mid_y
        p1x, p1y = sx + sw, sy + sh * 0.82
        p2x, p2y = cx + sw * 0.15, sy + sh * 0.92
        p3x, p3y = cx, sy + sh
        x = ((1-t)**3*p0x + 3*(1-t)**2*t*p1x +
             3*(1-t)*t**2*p2x + t**3*p3x)
        y = ((1-t)**3*p0y + 3*(1-t)**2*t*p1y +
             3*(1-t)*t**2*p2y + t**3*p3y)
        pts.append((x, y))

    # Left taper — mirror
    for i in range(steps, -1, -1):
        t = i / steps
        p0x, p0y = sx, mid_y
        p1x, p1y = sx, sy + sh * 0.82
        p2x, p2y = cx - sw * 0.15, sy + sh * 0.92
        p3x, p3y = cx, sy + sh
        x = ((1-t)**3*p0x + 3*(1-t)**2*t*p1x +
             3*(1-t)*t**2*p2x + t**3*p3x)
        y = ((1-t)**3*p0y + 3*(1-t)**2*t*p1y +
             3*(1-t)*t**2*p2y + t**3*p3y)
        pts.append((x, y))

    # Left side back up
    pts.append((sx, sy + sh * 0.38))

    # Top-left rounded corner
    for i in range(9, -1, -1):
        a = math.radians(180 - i * 9)
        pts.append((sx + cr + cr * math.cos(a),
                    sy + cr - cr * math.sin(a)))

    return [(int(x), int(y)) for x, y in pts]


shield_pts = shield_polygon(sx, sy, sw, sh)

# Draw shadow (slightly offset, darker)
shadow_pts = [(x+6, y+8) for x, y in shield_pts]
draw.polygon(shadow_pts, fill=(60, 5, 12, 80))

# Draw main shield
draw.polygon(shield_pts, fill=MAROON + (255,))

# Draw shield inner highlight (lighter maroon band at top)
inner_sx = sx + int(sw * 0.12)
inner_sy = sy + int(sh * 0.04)
inner_sw = int(sw * 0.76)
inner_sh = int(sh * 0.28)
inner_pts = shield_polygon(inner_sx, inner_sy, inner_sw, inner_sh)
draw.polygon(inner_pts, fill=MAROON2 + (255,))

# ── Gold AI spark / circuit accent ────────────────────────────────────────────
# Centered inside the shield: a stylised spark / neural node pattern
# Central node + 6 radiating lines + small dots at tips

cx  = SIZE // 2
cy  = sy + int(sh * 0.50)   # slightly above center of shield

# --- Outer glow ring (very subtle) ---
for r, alpha in [(110, 25), (90, 45), (72, 70)]:
    glow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow_layer)
    gd.ellipse([cx-r, cy-r, cx+r, cy+r], fill=GOLD + (alpha,))
    img = Image.alpha_composite(img, glow_layer)
draw = ImageDraw.Draw(img)

# --- 6 radiating "circuit" lines ---
arm_len  = 148   # length of each arm
arm_w    = 11    # line width
node_r   = 14    # tip dot radius
angles   = [i * 60 for i in range(6)]   # hexagonal symmetry
elbow_at = 0.55  # fraction along arm where elbow bends

for deg in angles:
    rad = math.radians(deg)
    # Primary arm
    ex = cx + arm_len * math.cos(rad)
    ey = cy + arm_len * math.sin(rad)
    draw.line([(cx, cy), (ex, ey)], fill=GOLD, width=arm_w)

    # Small perpendicular branch at elbow
    mid_x = cx + arm_len * elbow_at * math.cos(rad)
    mid_y = cy + arm_len * elbow_at * math.sin(rad)
    perp  = math.radians(deg + 90)
    branch_len = arm_len * 0.28
    bx = mid_x + branch_len * math.cos(perp)
    by = mid_y + branch_len * math.sin(perp)
    draw.line([(mid_x, mid_y), (bx, by)], fill=GOLD2, width=7)
    # Branch tip dot
    br = 8
    draw.ellipse([bx-br, by-br, bx+br, by+br], fill=GOLD2)

    # Tip dot
    draw.ellipse([ex-node_r, ey-node_r, ex+node_r, ey+node_r], fill=GOLD)

# --- Central node ---
# Outer gold ring
cn_r = 44
draw.ellipse([cx-cn_r, cy-cn_r, cx+cn_r, cy+cn_r], fill=GOLD)
# Inner white circle (gives the "hollow ring" look)
cn_inner = 26
draw.ellipse(
    [cx-cn_inner, cy-cn_inner, cx+cn_inner, cy+cn_inner],
    fill=(255, 255, 255, 255)
)
# Tiny gold center dot
draw.ellipse([cx-9, cy-9, cx+9, cy+9], fill=GOLD)

# ── White inner shield highlight (top arc, subtle) ────────────────────────────
highlight_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
hd = ImageDraw.Draw(highlight_layer)
h_sx = sx + int(sw * 0.20)
h_sy = sy + int(sh * 0.06)
h_sw = int(sw * 0.60)
h_sh = int(sh * 0.14)
hd.ellipse([h_sx, h_sy, h_sx + h_sw, h_sy + h_sh],
           fill=(255, 255, 255, 38))
img = Image.alpha_composite(img, highlight_layer)

# ── Save ──────────────────────────────────────────────────────────────────────
img = img.convert("RGB")   # flatten alpha for PNG (white bg already set)
img.save(OUT, "PNG", quality=100)
print(f"Icon saved → {OUT}  ({SIZE}x{SIZE}px)")
