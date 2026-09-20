#!/usr/bin/env python3
"""
gen_ppt.py — Splitbo Brand Guidelines PowerPoint (19 slides)
Dark-first brand design matching actual Splitbo visual identity.
Output: docs/03-Brand/Splitbo_Brand_Guidelines.pptx
Uses Python stdlib only (zipfile, io).
"""
import os, zipfile
from io import BytesIO

# ── Brand tokens ──────────────────────────────────────────────
GREEN      = "9CD246"
GREEN_DK   = "7BA832"
GREEN_LT   = "EEF7D9"
BLACK      = "000000"
WHITE      = "FFFFFF"
NEAR_BLACK = "0D0D0D"
GRAY_DARK  = "222222"
GRAY_MID   = "666666"
GRAY_LITE  = "999999"
GRAY_LIGHT = "E0E0E0"
SURFACE    = "111111"
SURFACE2   = "1A1A1A"
SURFACE3   = "242424"
POSITIVE   = "22C55E"
NEGATIVE   = "F97316"
WARNING    = "F59E0B"
ERROR      = "DC2626"

# ── Slide dimensions 16:9 ─────────────────────────────────────
W = 12192000
H =  6858000
def inch(n):  return int(n * 914400)
def pw(p):    return int(W * p)
def ph(p):    return int(H * p)

def esc(t): return str(t).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")

# ── SID counter (reset per slide) ────────────────────────────
_sid = [2]
def nsid(): v=_sid[0]; _sid[0]+=1; return v
def rsid(): _sid[0]=2

# ── XML primitives ────────────────────────────────────────────
def sfill(c): return f'<a:solidFill><a:srgbClr val="{c}"/></a:solidFill>'
def nofill():  return '<a:noFill/>'
def noline():  return '<a:ln><a:noFill/></a:ln>'

def rpr(sz, bold=False, color=WHITE, font="Sora", italic=False):
    return (f'<a:rPr lang="en-US" sz="{sz*100}" b="{1 if bold else 0}" '
            f'i="{1 if italic else 0}" dirty="0">'
            f'{sfill(color)}<a:latin typeface="{font}"/></a:rPr>')

def run(t, sz, bold=False, color=WHITE, font="Sora", italic=False):
    return f'<a:r>{rpr(sz,bold,color,font,italic)}<a:t>{esc(t)}</a:t></a:r>'

def para(runs, align="l", spb=0, spa=0):
    sb = f'<a:spcBef><a:spcPts val="{spb}"/></a:spcBef>' if spb else ""
    sa = f'<a:spcAft><a:spcPts val="{spa}"/></a:spcAft>' if spa else ""
    body = "".join(runs) if isinstance(runs, list) else runs
    return f'<a:p><a:pPr algn="{align}">{sb}{sa}</a:pPr>{body}<a:endParaRPr lang="en-US" dirty="0"/></a:p>'

def txBody(ps, anchor="t"):
    return (f'<p:txBody>'
            f'<a:bodyPr wrap="square" anchor="{anchor}" lIns="0" tIns="0" rIns="0" bIns="0"><a:normAutofit/></a:bodyPr>'
            f'<a:lstStyle/>{"".join(ps) if isinstance(ps,list) else ps}</p:txBody>')

def rect(x, y, w, h, fill, lc=None, lw=9525):
    sid = nsid()
    ln = f'<a:ln w="{lw}">{sfill(lc)}</a:ln>' if lc else noline()
    return (f'<p:sp><p:nvSpPr><p:cNvPr id="{sid}" name="r{sid}"/>'
            f'<p:cNvSpPr><a:spLocks noGrp="1"/></p:cNvSpPr><p:nvPr/></p:nvSpPr>'
            f'<p:spPr><a:xfrm><a:off x="{x}" y="{y}"/><a:ext cx="{w}" cy="{h}"/></a:xfrm>'
            f'<a:prstGeom prst="rect"><a:avLst/></a:prstGeom>{sfill(fill)}{ln}</p:spPr>'
            f'<p:txBody><a:bodyPr><a:noAutofit/></a:bodyPr><a:lstStyle/>'
            f'<a:p><a:endParaRPr lang="en-US" dirty="0"/></a:p></p:txBody></p:sp>')

def txt(x, y, w, h, ps, fill=None, anchor="t"):
    sid = nsid()
    fx = sfill(fill) if fill else nofill()
    return (f'<p:sp><p:nvSpPr><p:cNvPr id="{sid}" name="t{sid}"/>'
            f'<p:cNvSpPr txBox="1"><a:spLocks noGrp="1"/></p:cNvSpPr><p:nvPr/></p:nvSpPr>'
            f'<p:spPr><a:xfrm><a:off x="{x}" y="{y}"/><a:ext cx="{w}" cy="{h}"/></a:xfrm>'
            f'<a:prstGeom prst="rect"><a:avLst/></a:prstGeom>{fx}{noline()}</p:spPr>'
            f'{txBody(ps, anchor=anchor)}</p:sp>')

def rrect(x, y, w, h, fill, adj=10000, lc=None, lw=9525):
    sid = nsid()
    ln = f'<a:ln w="{lw}">{sfill(lc)}</a:ln>' if lc else '<a:ln><a:noFill/></a:ln>'
    return (f'<p:sp><p:nvSpPr><p:cNvPr id="{sid}" name="rr{sid}"/>'
            f'<p:cNvSpPr><a:spLocks noGrp="1"/></p:cNvSpPr><p:nvPr/></p:nvSpPr>'
            f'<p:spPr><a:xfrm><a:off x="{x}" y="{y}"/><a:ext cx="{w}" cy="{h}"/></a:xfrm>'
            f'<a:prstGeom prst="roundRect"><a:avLst>'
            f'<a:gd name="adj" fmla="val {adj}"/>'
            f'</a:avLst></a:prstGeom>{sfill(fill)}{ln}</p:spPr>'
            f'<p:txBody><a:bodyPr><a:noAutofit/></a:bodyPr><a:lstStyle/>'
            f'<a:p><a:endParaRPr lang="en-US" dirty="0"/></a:p></p:txBody></p:sp>')

def slide(shapes, bg=BLACK):
    inner = "\n".join(shapes)
    return (f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            f'<p:sld xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"'
            f' xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"'
            f' xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
            f'<p:cSld><p:bg><p:bgPr>{sfill(bg)}<a:effectLst/></p:bgPr></p:bg>'
            f'<p:spTree>'
            f'<p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>'
            f'<p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="{W}" cy="{H}"/>'
            f'<a:chOff x="0" y="0"/><a:chExt cx="{W}" cy="{H}"/></a:xfrm></p:grpSpPr>'
            f'{inner}</p:spTree></p:cSld>'
            f'<p:clrMapOvr><a:masterClr/></p:clrMapOvr></p:sld>')

# ── Layout constants ──────────────────────────────────────────
MARGIN_X  = inch(0.55)
CONTENT_Y = inch(1.02)
CONTENT_H = H - inch(1.48)
CONTENT_W = W - inch(1.1)
FOOTER_Y  = H - inch(0.38)

# ── Composite helpers ─────────────────────────────────────────

def logo_mark(x, y, size):
    """Brand Z/slash mark approximation: dark rounded square + accent line + % symbol."""
    return [
        rrect(x, y, size, size, SURFACE2, adj=13000),
        rect(x, y, size, inch(0.04), GREEN),
        txt(x, y, size, size,
            [para(run("%", int(size / 914400 * 46), bold=True, color=GREEN, font="Sora"), align="c")],
            anchor="c"),
    ]

def wordmark_para(sz, split_color=WHITE, bo_color=GREEN):
    """'SplitBo' two-tone wordmark: Split=split_color, Bo=bo_color."""
    return para([run("Split", sz, bold=True, color=split_color, font="Sora"),
                 run("Bo",    sz, bold=True, color=bo_color,    font="Sora")])

# ── Dark chrome (header + footer for content slides) ─────────
def chrome(title, pg):
    return [
        rect(0, 0, W, inch(0.048), GREEN),
        txt(MARGIN_X, inch(0.055), W - inch(2.0), inch(0.84),
            [para(run(title, 22, bold=True, color=WHITE, font="Sora"))], anchor="c"),
        txt(W - inch(1.4), inch(0.055), inch(1.2), inch(0.84),
            [para(run(str(pg), 13, bold=True, color=GREEN, font="Sora"), align="r")], anchor="c"),
        rect(MARGIN_X, inch(0.9), CONTENT_W, inch(0.005), GRAY_DARK),
        txt(MARGIN_X, FOOTER_Y, inch(4.5), inch(0.35),
            [para(run("SplitBo  ·  Brand Guidelines v1.0", 9, color=GRAY_MID, font="Sora"))], anchor="c"),
        txt(W - inch(2.5), FOOTER_Y, inch(2.3), inch(0.35),
            [para(run("splitbo.in  ·  splitbo.app", 9, color=GRAY_MID, font="Sora"), align="r")], anchor="c"),
    ]

# ── Section divider ───────────────────────────────────────────
def sec(num, title):
    rsid()
    lw = pw(0.38)
    s = [
        rect(0, 0, W, H, BLACK),
        rect(0, 0, lw, H, GREEN),
        txt(0, 0, lw, H,
            [para(run(num, 120, bold=True, color=BLACK, font="Sora"), align="c")], anchor="c"),
        txt(lw + inch(0.5), ph(0.25), W - lw - inch(0.65), inch(0.38),
            [para(run("SPLITBO  ·  BRAND GUIDELINES", 9, color=GRAY_MID, font="Sora"))]),
        rect(lw + inch(0.5), ph(0.38), inch(0.6), inch(0.032), GREEN),
        txt(lw + inch(0.5), ph(0.42), W - lw - inch(0.65), inch(2.0),
            [para(run(title, 40, bold=True, color=WHITE, font="Sora"))], anchor="t"),
    ]
    return slide(s, bg=BLACK)


# ══════════════════════════════════════════════════════════════
# SLIDE BUILDERS — dark brand theme
# ══════════════════════════════════════════════════════════════

def s_cover():
    rsid()
    s = [
        rect(0, 0, W, H, BLACK),
        # Bottom green strip
        rect(0, H - inch(0.95), W, inch(0.95), GREEN),
        # Logo mark — top-left area
        *logo_mark(inch(0.55), inch(0.75), inch(1.55)),
        # "SplitBo" large wordmark
        txt(inch(0.55), inch(2.6), pw(0.55), inch(1.6),
            [wordmark_para(80)], anchor="t"),
        # Tagline
        txt(inch(0.55), inch(4.48), pw(0.52), inch(0.55),
            [para(run("Split bills. Keep friends.", 19, italic=True, color=GRAY_LITE, font="Sora"))], anchor="t"),
        # Short green accent line
        rect(inch(0.55), inch(5.18), inch(1.1), inch(0.032), GREEN),
        # Right panel: brand meta
        txt(pw(0.62), inch(1.0), pw(0.32), inch(1.6),
            [para(run("Brand Guidelines", 13, color=GRAY_MID, font="Sora")),
             para(run("v1.0  ·  September 2026", 11, color=GRAY_MID, font="Sora"), spb=140)], anchor="t"),
        # Right panel: tagline / value prop
        txt(pw(0.62), inch(3.0), pw(0.33), inch(2.8),
            [para(run("SIMPLE", 11, bold=True, color=GRAY_DARK, font="Sora")),
             para(run("FAIR",   11, bold=True, color=GRAY_DARK, font="Sora"), spb=120),
             para(run("TOGETHER", 11, bold=True, color=GRAY_DARK, font="Sora"), spb=120)], anchor="t"),
        # Bottom strip content
        txt(inch(0.55), H - inch(0.82), pw(0.5), inch(0.72),
            [para(run("splitbo.in  ·  splitbo.app  ·  splitbo.com", 13, bold=True, color=BLACK, font="Sora"))],
            anchor="c"),
        txt(W - inch(2.8), H - inch(0.82), inch(2.5), inch(0.72),
            [para(run("CONFIDENTIAL", 11, bold=True, color=BLACK, font="Sora"), align="r")], anchor="c"),
    ]
    return slide(s, bg=BLACK)


def s_toc():
    rsid()
    ch = chrome("Table of Contents", 2)
    items = [
        ("01", "Brand Essence & Voice"),
        ("02", "Color System"),
        ("03", "Typography"),
        ("04", "Logo & Wordmark"),
        ("05", "Iconography"),
        ("06", "Components"),
        ("07", "Do / Don't"),
    ]
    col_w = pw(0.44)
    rh = inch(0.64)
    for ci, col in enumerate([items[:4], items[4:]]):
        bx = MARGIN_X + ci * (col_w + inch(0.25))
        for ri, (num, lbl) in enumerate(col):
            y = CONTENT_Y + inch(0.04) + ri * rh
            ch.append(txt(bx, y, inch(0.56), rh,
                [para(run(num, 15, bold=True, color=GREEN, font="Sora"))], anchor="c"))
            ch.append(txt(bx + inch(0.62), y, col_w - inch(0.7), rh,
                [para(run(lbl, 17, color=WHITE, font="Sora"))], anchor="c"))
            if ri < len(col) - 1:
                ch.append(rect(bx, y + rh - inch(0.005), col_w, inch(0.005), GRAY_DARK))
    return slide(ch, BLACK)


def s_brand_essence():
    rsid()
    ch = chrome("01  Brand Essence & Personality", 4)
    cards = [
        (SURFACE2,  "Trustworthy", "Clear numbers,\nno hidden complexity.\nMath first, design second."),
        (SURFACE3,  "Friendly",    "Approachable UI,\nwarm micro-copy.\nUsers, not transactions."),
        (SURFACE2,  "Precise",     "Balances always\ncorrect to the paisa.\nZero tolerance for drift."),
        (SURFACE3,  "Modern",      "Clean, fast,\nworks everywhere.\niOS · Android · Web."),
    ]
    cw = pw(0.215); ch2 = inch(3.6); gap = inch(0.1); cy = CONTENT_Y + inch(0.05)
    for i, (fill, attr, desc) in enumerate(cards):
        cx = MARGIN_X + i * (cw + gap)
        ch.append(rect(cx, cy, cw, ch2, fill))
        ch.append(rect(cx, cy, cw, inch(0.05), GREEN))
        ch.append(txt(cx + inch(0.22), cy + inch(0.18), cw - inch(0.44), inch(0.9),
            [para(run(attr, 21, bold=True, color=WHITE, font="Sora"))], anchor="t"))
        ch.append(rect(cx + inch(0.22), cy + inch(1.22), cw - inch(0.44), inch(0.008), GRAY_DARK))
        ch.append(txt(cx + inch(0.22), cy + inch(1.38), cw - inch(0.44), inch(2.0),
            [para(run(desc, 13, color=GRAY_LITE, font="Sora"))], anchor="t"))
    vy = cy + ch2 + inch(0.18)
    ch.append(rect(MARGIN_X, vy, CONTENT_W, inch(0.52), GREEN))
    ch.append(txt(MARGIN_X + inch(0.22), vy, CONTENT_W - inch(0.44), inch(0.52),
        [para(run("Voice: Lead with clarity  ·  Be human  ·  Never alarming  ·  Always brief",
               13, bold=True, color=BLACK, font="Sora"))], anchor="c"))
    return slide(ch, BLACK)


def s_color_primary():
    rsid()
    ch = chrome("02  Color System — Primary Palette", 6)
    gw = pw(0.44); gy = CONTENT_Y; gh = CONTENT_H
    rx = MARGIN_X + gw + inch(0.2); rw = W - rx - inch(0.55)
    bh = int(gh * 0.52); wh = gh - bh - inch(0.08); wy = gy + bh + inch(0.08)
    ch.append(rect(MARGIN_X, gy, gw, gh, GREEN))
    ch.append(txt(MARGIN_X + inch(0.28), gy + inch(0.25), gw - inch(0.4), inch(1.5),
        [para(run("Splitbo\nGreen", 34, bold=True, color=BLACK, font="Sora"))], anchor="t"))
    ch.append(txt(MARGIN_X + inch(0.28), gy + gh - inch(1.3), gw - inch(0.4), inch(1.2),
        [para(run("#9CD246", 26, bold=True, color=BLACK, font="Sora")),
         para(run("RGB  156 · 210 · 70", 11, color=BLACK, font="Sora"), spb=100),
         para(run("Primary — CTAs, active states, logo mark", 11, italic=True, color=BLACK, font="Sora"), spb=70)],
        anchor="t"))
    ch.append(rect(rx, gy, rw, bh, SURFACE2, lc=GRAY_DARK, lw=9525))
    ch.append(txt(rx + inch(0.2), gy + inch(0.2), rw - inch(0.28), inch(0.85),
        [para(run("Black", 23, bold=True, color=WHITE, font="Sora"))], anchor="t"))
    ch.append(txt(rx + inch(0.2), gy + bh - inch(0.82), rw - inch(0.28), inch(0.8),
        [para(run("#000000", 17, bold=True, color=WHITE, font="Sora")),
         para(run("Backgrounds · dark mode · headlines", 11, color=GRAY_MID, font="Sora"), spb=70)],
        anchor="t"))
    ch.append(rect(rx, wy, rw, wh, WHITE, lc=GRAY_LIGHT, lw=9525))
    ch.append(txt(rx + inch(0.2), wy + inch(0.18), rw - inch(0.28), inch(0.85),
        [para(run("White", 23, bold=True, color=NEAR_BLACK, font="Sora"))], anchor="t"))
    ch.append(txt(rx + inch(0.2), wy + wh - inch(0.82), rw - inch(0.28), inch(0.8),
        [para(run("#FFFFFF", 17, bold=True, color=NEAR_BLACK, font="Sora")),
         para(run("Backgrounds · reversed text · light surfaces", 11, color=GRAY_MID, font="Sora"), spb=70)],
        anchor="t"))
    return slide(ch, BLACK)


def s_color_semantic():
    rsid()
    ch = chrome("02  Color System — Semantic Palette", 7)
    sd = [(POSITIVE, WHITE, "Positive", "#22C55E", "You are owed"),
          (NEGATIVE, WHITE, "Negative", "#F97316", "You owe"),
          (WARNING,  BLACK, "Warning",  "#F59E0B", "Pending / partial"),
          (ERROR,    WHITE, "Error",    "#DC2626",  "Destructive only")]
    sw = pw(0.215); sh = inch(3.5); gap = inch(0.1); cy = CONTENT_Y + inch(0.08)
    for i, (hc, tc, nm, hx, ds) in enumerate(sd):
        cx = MARGIN_X + i * (sw + gap)
        ch.append(rect(cx, cy, sw, sh, hc))
        ch.append(txt(cx + inch(0.2), cy + inch(0.2), sw - inch(0.4), inch(0.82),
            [para(run(nm, 22, bold=True, color=tc, font="Sora"))], anchor="t"))
        ch.append(txt(cx + inch(0.2), cy + sh - inch(1.1), sw - inch(0.4), inch(1.0),
            [para(run(hx, 17, bold=True, color=tc, font="Sora")),
             para(run(ds, 12, italic=True, color=tc, font="Sora"), spb=90)], anchor="t"))
    ry = cy + sh + inch(0.18)
    ch.append(rect(MARGIN_X, ry, CONTENT_W, inch(0.58), GREEN))
    ch.append(txt(MARGIN_X + inch(0.22), ry, CONTENT_W - inch(0.44), inch(0.58),
        [para(run("Rule: NEVER use red for 'you owe'. Use Negative orange — warm, not alarming.",
               15, bold=True, color=BLACK, font="Sora"))], anchor="c"))
    return slide(ch, BLACK)


def s_color_dark():
    rsid()
    ch = chrome("02  Color System — Dark Mode Neutrals", 8)
    dark_swatches = [
        ("000000", WHITE,      "BG",        "Pure black app background"),
        ("141414", WHITE,      "Surface",   "Cards, bottom sheets"),
        ("1E1E1E", WHITE,      "Surface 2", "Elevated cards, modals"),
        ("2A2A2A", WHITE,      "Border",    "Dividers, input strokes"),
        ("999999", NEAR_BLACK, "Muted",     "Captions, subtitles"),
    ]
    sw = (CONTENT_W - inch(0.4)) // 5; sh = inch(2.9); cy = CONTENT_Y + inch(0.05)
    for i, (hc, tc, nm, ds) in enumerate(dark_swatches):
        cx = MARGIN_X + i * (sw + inch(0.1))
        ch.append(rect(cx, cy, sw, sh, hc, lc=GRAY_DARK, lw=9525))
        ch.append(txt(cx + inch(0.15), cy + inch(0.18), sw - inch(0.3), inch(0.75),
            [para(run(nm, 16, bold=True, color=tc, font="Sora"))], anchor="t"))
        ch.append(txt(cx + inch(0.15), cy + sh - inch(1.1), sw - inch(0.3), inch(1.05),
            [para(run(f"#{hc}", 13, bold=True, color=tc, font="Sora")),
             para(run(ds, 10, italic=True, color=tc, font="Sora"), spb=80)], anchor="t"))
    ny = cy + sh + inch(0.2)
    ch.append(rect(MARGIN_X, ny, CONTENT_W, inch(0.56), SURFACE2))
    ch.append(rect(MARGIN_X, ny, inch(0.05), inch(0.56), GREEN))
    ch.append(txt(MARGIN_X + inch(0.18), ny, CONTENT_W - inch(0.28), inch(0.56),
        [para(run("Light Mode  →  BG #F5F5F5  ·  Surface #FFFFFF  ·  Border #E0E0E0  ·  Text #0D0D0D  ·  Muted #666666",
               12, color=GRAY_LITE, font="Sora"))], anchor="c"))
    return slide(ch, BLACK)


def s_typography():
    rsid()
    ch = chrome("03  Typography — Font Families", 10)
    hw = pw(0.455); fh = CONTENT_H; fy = CONTENT_Y; gap = inch(0.12); rx2 = MARGIN_X + hw + gap
    ch.append(rect(MARGIN_X, fy, hw, fh, SURFACE2))
    ch.append(rect(MARGIN_X, fy, hw, inch(0.05), GREEN))
    ch.append(txt(MARGIN_X + inch(0.28), fy + inch(0.18), hw - inch(0.45), inch(1.55),
        [para(run("Sora", 70, bold=True, color=WHITE, font="Sora"))], anchor="t"))
    ch.append(txt(MARGIN_X + inch(0.28), fy + inch(1.85), hw - inch(0.45), inch(0.48),
        [para(run("Display / Headings", 15, bold=True, color=GREEN, font="Sora"))], anchor="t"))
    ch.append(txt(MARGIN_X + inch(0.28), fy + inch(2.45), hw - inch(0.45), inch(0.5),
        [para(run("Aa Bb Cc 1 2 3 ₹ %", 19, color=GREEN_LT, font="Sora"))], anchor="t"))
    ch.append(txt(MARGIN_X + inch(0.28), fy + inch(3.1), hw - inch(0.45), inch(0.4),
        [para(run("ExtraBold 800  ·  Hero, section titles, numerals", 12, color=GRAY_MID, font="Sora"))], anchor="t"))
    ch.append(txt(MARGIN_X + inch(0.28), fy + inch(3.6), hw - inch(0.45), inch(0.4),
        [para(run("Google Fonts — free, open licence", 12, color=GRAY_MID, font="Sora"))], anchor="t"))
    ch.append(rect(rx2, fy, hw, fh, SURFACE3))
    ch.append(rect(rx2, fy, hw, inch(0.05), GREEN_DK))
    ch.append(txt(rx2 + inch(0.28), fy + inch(0.18), hw - inch(0.45), inch(1.55),
        [para(run("Inter", 70, bold=True, color=WHITE, font="Inter"))], anchor="t"))
    ch.append(txt(rx2 + inch(0.28), fy + inch(1.85), hw - inch(0.45), inch(0.48),
        [para(run("UI / Body / Labels", 15, bold=True, color=GREEN, font="Inter"))], anchor="t"))
    ch.append(txt(rx2 + inch(0.28), fy + inch(2.45), hw - inch(0.45), inch(0.5),
        [para(run("Aa Bb Cc 1 2 3 ₹ %", 19, color=WHITE, font="Inter"))], anchor="t"))
    ch.append(txt(rx2 + inch(0.28), fy + inch(3.1), hw - inch(0.45), inch(0.4),
        [para(run("400 · 500 · 600 · 700  ·  Body, labels, amounts", 12, color=GRAY_MID, font="Inter"))], anchor="t"))
    ch.append(txt(rx2 + inch(0.28), fy + inch(3.6), hw - inch(0.45), inch(0.4),
        [para(run("Google Fonts — free, open licence", 12, color=GRAY_MID, font="Inter"))], anchor="t"))
    return slide(ch, BLACK)


def s_type_scale():
    rsid()
    ch = chrome("03  Typography — Type Scale", 11)
    lw = pw(0.48); rw_col = CONTENT_W - lw - inch(0.2)
    rx2 = MARGIN_X + lw + inch(0.2)
    rows = [("Display XL", "48", "800", "Sora"),
            ("Display L",  "36", "700", "Sora"),
            ("H1",         "28", "700", "Sora"),
            ("H2",         "22", "600", "Sora"),
            ("H3",         "18", "600", "Inter"),
            ("Body L",     "16", "400", "Inter"),
            ("Body M",     "14", "400", "Inter"),
            ("Label",      "13", "500", "Inter"),
            ("Caption",    "11", "400", "Inter")]
    hdrs = ["Name", "px", "Wt", "Font"]
    hcx = [MARGIN_X, MARGIN_X + inch(1.5), MARGIN_X + inch(2.3), MARGIN_X + inch(3.2)]
    hcw = [inch(1.4), inch(0.75), inch(0.85), inch(0.85)]
    rh = inch(0.44)
    ch.append(rect(MARGIN_X, CONTENT_Y, lw, rh, GREEN))
    for j, hdr in enumerate(hdrs):
        ch.append(txt(hcx[j] + inch(0.08), CONTENT_Y, hcw[j], rh,
            [para(run(hdr, 12, bold=True, color=BLACK, font="Sora"))], anchor="c"))
    for i, (nm, sz, wt, font) in enumerate(rows):
        ry = CONTENT_Y + (i + 1) * rh
        bg = SURFACE if i % 2 == 0 else SURFACE2
        ch.append(rect(MARGIN_X, ry, lw, rh, bg))
        ch.append(rect(MARGIN_X, ry, inch(0.04), rh, GREEN if i % 2 == 0 else GREEN_DK))
        for j, cell in enumerate([nm, sz, wt, font]):
            fc = GREEN if j == 1 else (GRAY_MID if j in (2, 3) else WHITE)
            ch.append(txt(hcx[j] + inch(0.08), ry, hcw[j], rh,
                [para(run(cell, 12, bold=(j == 0), color=fc, font="Sora"))], anchor="c"))
    ch.append(rect(rx2, CONTENT_Y, rw_col, CONTENT_H, SURFACE2))
    ch.append(rect(rx2, CONTENT_Y, inch(0.05), CONTENT_H, GREEN))
    ch.append(txt(rx2 + inch(0.2), CONTENT_Y + inch(0.1), rw_col - inch(0.3), inch(0.45),
        [para(run("Type Specimens", 11, bold=True, color=GRAY_MID, font="Sora"))], anchor="t"))
    specimens = [
        (48, True,  "Sora",  "splitbo",                          GREEN,     inch(0.88)),
        (28, True,  "Sora",  "Split bills.",                     WHITE,     inch(0.66)),
        (18, True,  "Sora",  "Section Header",                   WHITE,     inch(0.52)),
        (14, False, "Inter", "Body text — clear at any size.", GRAY_LITE, inch(0.46)),
        (11, False, "Inter", "Caption  ·  Sep 2026  ·  ₹1,500", GRAY_MID,  inch(0.38)),
    ]
    sy = CONTENT_Y + inch(0.65)
    for fsize, bold, font, text, color, lh in specimens:
        ch.append(txt(rx2 + inch(0.2), sy, rw_col - inch(0.3), lh,
            [para(run(text, fsize, bold=bold, color=color, font=font))], anchor="c"))
        sy += lh + inch(0.06)
    return slide(ch, BLACK)


def s_logo():
    rsid()
    ch = chrome("04  Logo & Wordmark", 13)
    hw = pw(0.455); lh = CONTENT_H; ly = CONTENT_Y; gap = inch(0.12); rx2 = MARGIN_X + hw + gap
    logo_sz = inch(1.3)
    lm_cx = MARGIN_X + (hw - logo_sz) // 2
    # Dark variant (primary)
    ch.append(rect(MARGIN_X, ly, hw, lh, BLACK, lc=GRAY_DARK, lw=9525))
    ch.append(rect(MARGIN_X, ly, hw, inch(0.05), GREEN))
    for shape in logo_mark(lm_cx, ly + inch(0.22), logo_sz):
        ch.append(shape)
    ch.append(txt(MARGIN_X, ly + inch(1.72), hw, inch(1.0),
        [wordmark_para(40)], anchor="c"))
    ch.append(rect(MARGIN_X + inch(0.4), ly + inch(2.88), hw - inch(0.8), inch(0.01), GRAY_DARK))
    ch.append(txt(MARGIN_X + inch(0.18), ly + inch(3.05), hw - inch(0.36), inch(0.48),
        [para(run("Primary — Dark Background", 13, bold=True, color=WHITE, font="Sora"), align="c")]))
    ch.append(txt(MARGIN_X + inch(0.18), ly + inch(3.58), hw - inch(0.36), inch(0.42),
        [para(run("White + Green two-tone wordmark", 12, italic=True, color=GRAY_MID, font="Sora"), align="c")]))
    # Light variant
    ch.append(rect(rx2, ly, hw, lh, "F8F8F8", lc=GRAY_LIGHT, lw=9525))
    ch.append(rect(rx2, ly, hw, inch(0.05), GREEN))
    for shape in logo_mark(rx2 + (hw - logo_sz) // 2, ly + inch(0.22), logo_sz):
        ch.append(shape)
    ch.append(txt(rx2, ly + inch(1.72), hw, inch(1.0),
        [wordmark_para(40, split_color=NEAR_BLACK)], anchor="c"))
    ch.append(rect(rx2 + inch(0.4), ly + inch(2.88), hw - inch(0.8), inch(0.01), GRAY_LIGHT))
    ch.append(txt(rx2 + inch(0.18), ly + inch(3.05), hw - inch(0.36), inch(0.48),
        [para(run("Reversed — Light Background", 13, bold=True, color=NEAR_BLACK, font="Sora"), align="c")]))
    ch.append(txt(rx2 + inch(0.18), ly + inch(3.58), hw - inch(0.36), inch(0.42),
        [para(run("Black + Green two-tone wordmark", 12, italic=True, color=GRAY_MID, font="Sora"), align="c")]))
    return slide(ch, BLACK)


def s_iconography():
    rsid()
    ch = chrome("05  Iconography", 15)
    rows = [("Regular", "20 / 24 px", "Lists, form fields, inline UI"),
            ("Bold",    "24 / 28 px", "Tab bar, FAB, primary actions"),
            ("Fill",    "24 px",      "Selected / active states only")]
    hdrs = ["Style", "Size", "Usage"]
    col_x = [MARGIN_X, MARGIN_X + inch(2.5), MARGIN_X + inch(5.1)]
    cw = [inch(2.4), inch(2.5), inch(6.8)]
    rh = inch(0.62)
    ch.append(rect(MARGIN_X, CONTENT_Y, CONTENT_W, rh, GREEN))
    for j, hdr in enumerate(hdrs):
        ch.append(txt(col_x[j] + inch(0.14), CONTENT_Y, cw[j], rh,
            [para(run(hdr, 14, bold=True, color=BLACK, font="Sora"))], anchor="c"))
    for i, (st, sz, us) in enumerate(rows):
        ry = CONTENT_Y + (i + 1) * rh
        bg = SURFACE if i % 2 == 0 else SURFACE2
        ch.append(rect(MARGIN_X, ry, CONTENT_W, rh, bg))
        ch.append(rect(MARGIN_X, ry, inch(0.04), rh, GREEN))
        for j, cell in enumerate([st, sz, us]):
            ch.append(txt(col_x[j] + inch(0.14), ry, cw[j], rh,
                [para(run(cell, 13, color=WHITE, font="Sora"))], anchor="c"))
    rules_y = CONTENT_Y + 4 * rh + inch(0.22)
    rules = [(GREEN, "Active/selected"), (GRAY_MID, "Inactive (muted)"), (POSITIVE, "Positive balance"),
             (NEGATIVE, "Negative balance"), (ERROR, "Destructive only")]
    for i, (hc, lbl) in enumerate(rules):
        rx3 = MARGIN_X + i * inch(2.2)
        ch.append(rrect(rx3, rules_y, inch(0.42), inch(0.42), hc, adj=8000))
        ch.append(txt(rx3 + inch(0.52), rules_y, inch(1.65), inch(0.42),
            [para(run(lbl, 12, color=WHITE, font="Sora"))], anchor="c"))
    ch.append(txt(MARGIN_X, rules_y + inch(0.55), CONTENT_W, inch(0.4),
        [para(run("Library: Phosphor Icons  ·  react-native-phosphor-icons  ·  phosphoricons.com",
               12, italic=True, color=GRAY_MID, font="Sora"))]))
    return slide(ch, BLACK)


def s_components():
    rsid()
    ch = chrome("06  Components — Buttons & Balance Chips", 17)
    btns = [(GREEN,    BLACK, "Primary",   "primary",   "Add Expense · Settle Up"),
            (SURFACE2, WHITE, "Secondary", "secondary", "Share Link · View All"),
            (SURFACE3, WHITE, "Ghost",     "ghost",     "Cancel · Skip"),
            (ERROR,    WHITE, "Danger",    "danger",    "Delete Expense")]
    bw = pw(0.217); bh = inch(0.7); gap = inch(0.1)
    by = CONTENT_Y + inch(0.1)
    for i, (bg, tc, label, token, usage) in enumerate(btns):
        bx = MARGIN_X + i * (bw + gap)
        bord = GRAY_DARK if bg == SURFACE3 else None
        ch.append(rrect(bx, by, bw, bh, bg, adj=8000, lc=bord))
        ch.append(txt(bx, by, bw, bh,
            [para(run(label, 17, bold=True, color=tc, font="Sora"), align="c")], anchor="c"))
        ch.append(txt(bx, by + bh + inch(0.15), bw, inch(0.38),
            [para(run(label, 13, bold=True, color=WHITE, font="Sora"))]))
        ch.append(txt(bx, by + bh + inch(0.55), bw, inch(0.32),
            [para(run(f"variant='{token}'", 11, color=GREEN, font="Sora"))]))
        ch.append(txt(bx, by + bh + inch(0.9), bw, inch(0.32),
            [para(run(usage, 11, italic=True, color=GRAY_MID, font="Sora"))]))
    div_y = by + bh + inch(1.35)
    ch.append(rect(MARGIN_X, div_y, CONTENT_W, inch(0.008), GRAY_DARK))
    chip_label_y = div_y + inch(0.16)
    ch.append(txt(MARGIN_X, chip_label_y, inch(4), inch(0.44),
        [para(run("Balance Chips", 18, bold=True, color=WHITE, font="Sora"))]))
    chips = [(POSITIVE, "1C3528", f"You are owed  ₹1,500", "background: semantic.positive / 15%"),
             (NEGATIVE, "3A2010", f"You owe  ₹750",        "background: semantic.negative / 15%"),
             ("888888", "1E1E1E", "Settled",                    "background: text.muted / 10%")]
    chip_y = chip_label_y + inch(0.55); chip_w = inch(3.42)
    for i, (tc, bg, lbl, spec) in enumerate(chips):
        cx = MARGIN_X + i * (chip_w + inch(0.22))
        ch.append(rrect(cx, chip_y, chip_w, inch(0.57), bg, adj=50000))
        ch.append(txt(cx + inch(0.22), chip_y, chip_w - inch(0.3), inch(0.57),
            [para(run(lbl, 15, bold=True, color=tc, font="Sora"))], anchor="c"))
        ch.append(txt(cx, chip_y + inch(0.66), chip_w, inch(0.32),
            [para(run(spec, 10, italic=True, color=GRAY_MID, font="Sora"))]))
    return slide(ch, BLACK)


def s_do_dont():
    rsid()
    ch = chrome("07  Do / Don't", 19)
    dos = ["Use #9CD246 as the primary action color on all screens",
           "Use semantic.positive (green) for 'owed to you'",
           "Use Sora for headings, Inter for all UI text",
           "Apply 4px grid for all spacing decisions",
           "Test both light and dark mode for every screen"]
    donts = ["Mix brand colors outside the token system",
             "Use red for 'you owe' — always use orange (Negative)",
             "Mix in Barlow, JetBrains, or other font families",
             "Use arbitrary spacing values outside the scale",
             "Design only for light mode — dark mode is first-class"]
    cw = pw(0.455); rh = inch(0.68); gap = inch(0.12)
    hdr_y = CONTENT_Y; dx = MARGIN_X + cw + gap
    ch.append(rect(MARGIN_X, hdr_y, cw, inch(0.5), GREEN))
    ch.append(txt(MARGIN_X + inch(0.18), hdr_y, cw, inch(0.5),
        [para(run("DO", 18, bold=True, color=BLACK, font="Sora"))], anchor="c"))
    ch.append(rect(dx, hdr_y, cw, inch(0.5), SURFACE2))
    ch.append(rect(dx, hdr_y, inch(0.04), inch(0.5), ERROR))
    ch.append(txt(dx + inch(0.18), hdr_y, cw, inch(0.5),
        [para(run("DON'T", 18, bold=True, color=WHITE, font="Sora"))], anchor="c"))
    for i, (d, nd) in enumerate(zip(dos, donts)):
        ry = hdr_y + inch(0.5) + i * rh
        bg = SURFACE if i % 2 == 0 else SURFACE2
        ch.append(rect(MARGIN_X, ry, cw, rh, bg))
        ch.append(rect(dx, ry, cw, rh, bg))
        ch.append(rect(MARGIN_X, ry, inch(0.05), rh, GREEN))
        ch.append(txt(MARGIN_X + inch(0.15), ry, cw - inch(0.22), rh,
            [para(run(d, 13, color=WHITE, font="Sora"))], anchor="c"))
        ch.append(rect(dx, ry, inch(0.05), rh, ERROR))
        ch.append(txt(dx + inch(0.15), ry, cw - inch(0.22), rh,
            [para(run(nd, 13, color=WHITE, font="Sora"))], anchor="c"))
    return slide(ch, BLACK)


def s_back():
    rsid()
    s = [
        rect(0, 0, W, H, BLACK),
        rect(0, 0, W, inch(0.05), GREEN),
        # Large SplitBo wordmark centred in upper 70% of slide
        txt(0, 0, W, ph(0.72),
            [wordmark_para(96)], anchor="c"),
        # Green bottom strip
        rect(0, ph(0.72), W, ph(0.28), GREEN),
        txt(0, ph(0.73), W, ph(0.14),
            [para(run("Split bills. Keep friends.", 28, italic=True, color=BLACK, font="Sora"), align="c")],
            anchor="c"),
        txt(0, ph(0.87), W, ph(0.09),
            [para(run("splitbo.in  ·  splitbo.app  ·  splitbo.com", 16, color=BLACK, font="Sora"), align="c")],
            anchor="c"),
        txt(0, ph(0.94), W, ph(0.05),
            [para(run("© 2026 Splitbo. All rights reserved.", 10, color=BLACK, font="Sora"), align="c")],
            anchor="c"),
    ]
    return slide(s, bg=BLACK)


# ══════════════════════════════════════════════════════════════
# PPTX INFRASTRUCTURE
# ══════════════════════════════════════════════════════════════

def _content_types(n):
    ovr = "\n".join(
        f'<Override PartName="/ppt/slides/slide{i+1}.xml" '
        f'ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>'
        for i in range(n))
    return f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="xml" ContentType="application/xml"/>
<Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>
<Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>
<Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
<Override PartName="/ppt/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
{ovr}
<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>'''

_ROOT_RELS = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>'''

def _pres(n):
    ids = "\n".join(f'<p:sldId id="{256+i}" r:id="rId{i+3}"/>' for i in range(n))
    return f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:presentation xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
<p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId1"/></p:sldMasterIdLst>
<p:sldIdLst>{ids}</p:sldIdLst>
<p:sldSz cx="{W}" cy="{H}" type="custom"/>
<p:notesSz cx="6858000" cy="9144000"/>
<p:defaultTextStyle><a:defPPr><a:defRPr lang="en-US"/></a:defPPr></p:defaultTextStyle>
</p:presentation>'''

def _pres_rels(n):
    srs = "\n".join(
        f'<Relationship Id="rId{i+3}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide{i+1}.xml"/>'
        for i in range(n))
    return f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="slideMasters/slideMaster1.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>
{srs}
</Relationships>'''

_MASTER = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sldMaster xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
<p:cSld><p:bg><p:bgPr><a:solidFill><a:srgbClr val="000000"/></a:solidFill></p:bgPr></p:bg>
<p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
<p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="{W}" cy="{H}"/><a:chOff x="0" y="0"/><a:chExt cx="{W}" cy="{H}"/></a:xfrm></p:grpSpPr>
</p:spTree></p:cSld>
<p:clrMap bg1="lt1" tx1="dk1" bg2="lt2" tx2="dk2" accent1="accent1" accent2="accent2" accent3="accent3" accent4="accent4" accent5="accent5" accent6="accent6" hlink="hlink" folHlink="folHlink"/>
<p:sldLayoutIdLst><p:sldLayoutId id="2147483649" r:id="rId1"/></p:sldLayoutIdLst>
<p:txStyles>
<p:titleStyle><a:lvl1pPr><a:defRPr sz="2800" b="1"><a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill><a:latin typeface="Sora"/></a:defRPr></a:lvl1pPr></p:titleStyle>
<p:bodyStyle><a:lvl1pPr><a:defRPr sz="1400"><a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill><a:latin typeface="Sora"/></a:defRPr></a:lvl1pPr></p:bodyStyle>
<p:otherStyle><a:lvl1pPr><a:defRPr><a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill><a:latin typeface="Sora"/></a:defRPr></a:lvl1pPr></p:otherStyle>
</p:txStyles></p:sldMaster>'''

_MASTER_RELS = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="../theme/theme1.xml"/>
</Relationships>'''

_LAYOUT = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sldLayout xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" type="blank" preserve="1">
<p:cSld name="Blank"><p:spTree>
<p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
<p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="{W}" cy="{H}"/><a:chOff x="0" y="0"/><a:chExt cx="{W}" cy="{H}"/></a:xfrm></p:grpSpPr>
</p:spTree></p:cSld><p:clrMapOvr><a:masterClr/></p:clrMapOvr></p:sldLayout>'''

_LAYOUT_RELS = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="../slideMasters/slideMaster1.xml"/>
</Relationships>'''

_THEME = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Splitbo">
<a:themeElements>
<a:clrScheme name="Splitbo">
<a:dk1><a:srgbClr val="000000"/></a:dk1><a:lt1><a:srgbClr val="FFFFFF"/></a:lt1>
<a:dk2><a:srgbClr val="0D0D0D"/></a:dk2><a:lt2><a:srgbClr val="F5F5F5"/></a:lt2>
<a:accent1><a:srgbClr val="9CD246"/></a:accent1><a:accent2><a:srgbClr val="7BA832"/></a:accent2>
<a:accent3><a:srgbClr val="22C55E"/></a:accent3><a:accent4><a:srgbClr val="F97316"/></a:accent4>
<a:accent5><a:srgbClr val="F59E0B"/></a:accent5><a:accent6><a:srgbClr val="DC2626"/></a:accent6>
<a:hlink><a:srgbClr val="9CD246"/></a:hlink><a:folHlink><a:srgbClr val="7BA832"/></a:folHlink>
</a:clrScheme>
<a:fontScheme name="Splitbo">
<a:majorFont><a:latin typeface="Sora"/></a:majorFont>
<a:minorFont><a:latin typeface="Inter"/></a:minorFont>
</a:fontScheme>
<a:fmtScheme name="Splitbo">
<a:fillStyleLst>
<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
</a:fillStyleLst>
<a:lnStyleLst>
<a:ln w="9525"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:ln>
<a:ln w="25400"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:ln>
<a:ln w="38100"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:ln>
</a:lnStyleLst>
<a:effectStyleLst>
<a:effectStyle><a:effectLst/></a:effectStyle>
<a:effectStyle><a:effectLst/></a:effectStyle>
<a:effectStyle><a:effectLst/></a:effectStyle>
</a:effectStyleLst>
<a:bgFillStyleLst>
<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
<a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
</a:bgFillStyleLst>
</a:fmtScheme>
</a:themeElements></a:theme>'''

_SLD_RELS = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>
</Relationships>'''

_CORE = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/">
<dc:title>Splitbo Brand Guidelines</dc:title><dc:creator>Vikas Chauhan</dc:creator>
</cp:coreProperties>'''

_APP = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">
<Application>Splitbo gen_ppt.py</Application></Properties>'''


def write_pptx(path, slides):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    buf = BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", _content_types(len(slides)))
        z.writestr("_rels/.rels", _ROOT_RELS)
        z.writestr("ppt/presentation.xml", _pres(len(slides)))
        z.writestr("ppt/_rels/presentation.xml.rels", _pres_rels(len(slides)))
        z.writestr("ppt/theme/theme1.xml", _THEME)
        z.writestr("ppt/slideMasters/slideMaster1.xml", _MASTER)
        z.writestr("ppt/slideMasters/_rels/slideMaster1.xml.rels", _MASTER_RELS)
        z.writestr("ppt/slideLayouts/slideLayout1.xml", _LAYOUT)
        z.writestr("ppt/slideLayouts/_rels/slideLayout1.xml.rels", _LAYOUT_RELS)
        z.writestr("docProps/core.xml", _CORE)
        z.writestr("docProps/app.xml", _APP)
        for i, xml in enumerate(slides):
            z.writestr(f"ppt/slides/slide{i+1}.xml", xml)
            z.writestr(f"ppt/slides/_rels/slide{i+1}.xml.rels", _SLD_RELS)
    with open(path, "wb") as f:
        f.write(buf.getvalue())
    print(f"  ✓  {path}")


if __name__ == "__main__":
    print("\nGenerating Splitbo Brand Guidelines PPT...")
    slides = [
        s_cover(),
        s_toc(),
        sec("01", "Brand Essence & Voice"),
        s_brand_essence(),
        sec("02", "Color System"),
        s_color_primary(),
        s_color_semantic(),
        s_color_dark(),
        sec("03", "Typography"),
        s_typography(),
        s_type_scale(),
        sec("04", "Logo & Wordmark"),
        s_logo(),
        sec("05", "Iconography"),
        s_iconography(),
        sec("06", "Components"),
        s_components(),
        sec("07", "Do / Don't"),
        s_do_dont(),
        s_back(),
    ]
    write_pptx("docs/03-Brand/Splitbo_Brand_Guidelines.pptx", slides)
    print(f"  {len(slides)} slides")
    print("Done.")
