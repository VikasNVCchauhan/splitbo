"""
Splitbo Document Generator
Generates PRD, Architecture, and Brand Guidelines as .docx files.
Uses only Python stdlib — no external packages required.
Run: python3 scripts/gen_docs.py
"""

import zipfile
import os
from datetime import date

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ─────────────────────────────────────────────────────────────
# SPLITBO BRAND TOKENS  (single source of truth — used in docs
# and mirrored in src/constants/theme.ts for the app)
# ─────────────────────────────────────────────────────────────
BRAND = {
    # ── PRIMARY (confirmed from Splitbo logo / brand sheet) ──────────
    "green":         "9CD246",   # Splitbo Green — primary brand color (logo, icon, "Bo" wordmark)
    "green_dark":    "7BA832",   # Splitbo Dark Green — hover / pressed
    "green_light":   "EEF7D9",   # Splitbo Light Green — badge fills, tinted backgrounds

    # ── CORE NEUTRAL ─────────────────────────────────────────────────
    "black":         "000000",   # Pure black — backgrounds, text, table headers
    "white":         "FFFFFF",   # Pure white — text on dark, cards on light

    # ── SEMANTIC (distinct from brand green) ─────────────────────────
    "positive":      "22C55E",   # You are owed (emerald — distinct from brand lime)
    "negative":      "F97316",   # You owe (orange — warm, not alarming)
    "warning":       "F59E0B",   # Pending / partial
    "error":         "DC2626",   # Destructive actions

    # ── NEUTRALS — light mode ────────────────────────────────────────
    "bg_light":      "F5F5F5",
    "surface_light": "FFFFFF",
    "border_light":  "E0E0E0",
    "text_primary_light":  "0D0D0D",
    "text_muted_light":    "666666",

    # ── NEUTRALS — dark mode ─────────────────────────────────────────
    "bg_dark":       "000000",   # Pure black app background
    "surface_dark":  "141414",   # Cards on dark
    "surface2_dark": "1E1E1E",   # Elevated cards
    "border_dark":   "2A2A2A",
    "text_primary_dark":   "FFFFFF",
    "text_muted_dark":     "999999",

    # ── DOC HEADING COLOURS ──────────────────────────────────────────
    "doc_h1":        "9CD246",   # Splitbo Green H1 (primary brand color)
    "doc_h2":        "1A1A1A",   # Near-black H2
    "doc_h3":        "333333",   # Dark charcoal H3 (professional)
    "doc_table_hdr": "000000",   # Black table header with white text
    "doc_accent":    "9CD246",   # Green for callout blocks / borders
}

# ─────────────────────────────────────────────────────────────
# XML / DOCX HELPERS
# ─────────────────────────────────────────────────────────────

def esc(s):
    return (str(s)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace('"', "&quot;"))

def heading(text, level=1):
    style = f"Heading{level}"
    return (f'<w:p><w:pPr><w:pStyle w:val="{style}"/></w:pPr>'
            f'<w:r><w:t xml:space="preserve">{esc(text)}</w:t></w:r></w:p>')

def para(text, bold=False, italic=False, color=None, size=None, center=False, muted=False):
    c = color or (BRAND["text_muted_light"] if muted else BRAND["text_primary_light"])
    sz = size or 12
    rpr = (f'<w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>'
           + ("<w:b/>" if bold else "")
           + ("<w:i/>" if italic else "")
           + f'<w:color w:val="{c}"/>'
           + f'<w:sz w:val="{sz*2}"/><w:szCs w:val="{sz*2}"/></w:rPr>')
    align = "center" if center else "both"
    ppr = f'<w:pPr><w:jc w:val="{align}"/><w:spacing w:after="140"/></w:pPr>'
    return f'<w:p>{ppr}<w:r>{rpr}<w:t xml:space="preserve">{esc(text)}</w:t></w:r></w:p>'

def color_block(text, fill_hex, text_hex="FFFFFF", bold=True):
    """Full-width colored paragraph block — use sparingly for key insights."""
    b = "<w:b/>" if bold else ""
    return (f'<w:p><w:pPr><w:shd w:val="clear" w:color="auto" w:fill="{fill_hex}"/>'
            f'<w:spacing w:before="180" w:after="180"/>'
            f'<w:ind w:left="240" w:right="240"/></w:pPr>'
            f'<w:r><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>{b}'
            f'<w:color w:val="{text_hex}"/>'
            f'<w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr>'
            f'<w:t xml:space="preserve">{esc(text)}</w:t></w:r></w:p>')

def callout(text):
    """Professional left-accent callout — green border, tinted bg, italic body text."""
    return (f'<w:p><w:pPr>'
            f'<w:pBdr><w:left w:val="single" w:sz="24" w:space="8" w:color="{BRAND["green"]}"/></w:pBdr>'
            f'<w:shd w:val="clear" w:color="auto" w:fill="{BRAND["green_light"]}"/>'
            f'<w:spacing w:before="160" w:after="160"/>'
            f'<w:ind w:left="280" w:right="280"/></w:pPr>'
            f'<w:r><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>'
            f'<w:i/><w:color w:val="{BRAND["text_primary_light"]}"/>'
            f'<w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr>'
            f'<w:t xml:space="preserve">{esc(text)}</w:t></w:r></w:p>')

def section_rule():
    """Thin green horizontal rule — use before heading() to separate major sections."""
    return (f'<w:p><w:pPr>'
            f'<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="{BRAND["green"]}"/></w:pBdr>'
            f'<w:spacing w:before="0" w:after="120"/></w:pPr><w:r><w:t> </w:t></w:r></w:p>')

def bullet(text, level=0):
    return (f'<w:p>'
            f'<w:pPr><w:pStyle w:val="ListParagraph"/>'
            f'<w:numPr><w:ilvl w:val="{level}"/><w:numId w:val="1"/></w:numPr>'
            f'<w:spacing w:after="80"/></w:pPr>'
            f'<w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/>'
            f'<w:color w:val="0D0D0D"/></w:rPr>'
            f'<w:t xml:space="preserve">{esc(text)}</w:t></w:r></w:p>')

def mono(text, size=10):
    """Monospace code line — Courier New, light gray background, zero spacing."""
    return (f'<w:p><w:pPr>'
            f'<w:shd w:val="clear" w:color="auto" w:fill="F5F5F5"/>'
            f'<w:spacing w:before="0" w:after="0"/>'
            f'<w:ind w:left="180" w:right="180"/></w:pPr>'
            f'<w:r><w:rPr>'
            f'<w:rFonts w:ascii="Courier New" w:hAnsi="Courier New"/>'
            f'<w:sz w:val="{size*2}"/><w:szCs w:val="{size*2}"/>'
            f'<w:color w:val="0D0D0D"/></w:rPr>'
            f'<w:t xml:space="preserve">{esc(text)}</w:t></w:r></w:p>')

def empty():
    return "<w:p/>"

def page_break():
    return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'

def table(*rows, col_widths=None):
    body = ""
    for i, row in enumerate(rows):
        is_hdr = (i == 0)
        tcs = ""
        for j, cell in enumerate(row):
            w = str(int(5000 / len(row)))
            if col_widths and j < len(col_widths):
                w = str(col_widths[j])
            shd = f'<w:shd w:val="clear" w:color="auto" w:fill="{BRAND["doc_table_hdr"]}"/>' if is_hdr else ''
            fc = "FFFFFF" if is_hdr else "0D0D0D"
            bld = "<w:b/>" if is_hdr else ""
            sz = "<w:sz w:val=\"22\"/><w:szCs w:val=\"22\"/>" if not is_hdr else ""
            tcs += (f'<w:tc><w:tcPr>{shd}'
                    f'<w:tcW w:type="pct" w:w="{w}"/></w:tcPr>'
                    f'<w:p><w:r><w:rPr>{bld}<w:color w:val="{fc}"/>{sz}</w:rPr>'
                    f'<w:t xml:space="preserve">{esc(cell)}</w:t></w:r></w:p></w:tc>')
        tr_shd = ''
        if i % 2 == 1:
            tr_shd = '<w:trPr><w:shd w:val="clear" w:color="auto" w:fill="F5F5F5"/></w:trPr>'
        body += f"<w:tr>{tr_shd}{tcs}</w:tr>"

    return (f'<w:tbl>'
            f'<w:tblPr>'
            f'<w:tblStyle w:val="TableGrid"/>'
            f'<w:tblW w:type="pct" w:w="5000"/>'
            f'<w:tblBorders>'
            f'<w:top w:val="single" w:sz="4" w:color="{BRAND["border_light"]}"/>'
            f'<w:left w:val="single" w:sz="4" w:color="{BRAND["border_light"]}"/>'
            f'<w:bottom w:val="single" w:sz="4" w:color="{BRAND["border_light"]}"/>'
            f'<w:right w:val="single" w:sz="4" w:color="{BRAND["border_light"]}"/>'
            f'<w:insideH w:val="single" w:sz="4" w:color="{BRAND["border_light"]}"/>'
            f'<w:insideV w:val="single" w:sz="4" w:color="{BRAND["border_light"]}"/>'
            f'</w:tblBorders></w:tblPr>'
            f'{body}'
            f'</w:tbl>')

def _is_light_color(hex_val):
    r = int(hex_val[0:2], 16); g = int(hex_val[2:4], 16); b = int(hex_val[4:6], 16)
    return (0.299*r + 0.587*g + 0.114*b) > 160

def color_swatch_table(*swatches):
    """Renders a row of color swatches: [(name, hex, description), ...]"""
    tcs = ""
    for name, hex_val, desc in swatches:
        tc = "000000" if _is_light_color(hex_val) else "FFFFFF"
        tcs += (f'<w:tc><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="{hex_val}"/>'
                f'<w:tcW w:type="pct" w:w="{int(5000/len(swatches))}"/></w:tcPr>'
                f'<w:p><w:pPr><w:spacing w:before="480" w:after="60"/></w:pPr></w:p>'
                f'<w:p><w:r><w:rPr><w:b/><w:color w:val="{tc}"/><w:sz w:val="18"/></w:rPr>'
                f'<w:t>{esc(name)}</w:t></w:r></w:p>'
                f'<w:p><w:r><w:rPr><w:color w:val="{tc}"/><w:sz w:val="16"/></w:rPr>'
                f'<w:t>#{hex_val}</w:t></w:r></w:p>'
                f'<w:p><w:pPr><w:spacing w:after="120"/></w:pPr>'
                f'<w:r><w:rPr><w:color w:val="{tc}"/><w:sz w:val="16"/><w:i/></w:rPr>'
                f'<w:t>{esc(desc)}</w:t></w:r></w:p>'
                f'</w:tc>')
    return f'<w:tbl><w:tblPr><w:tblW w:type="pct" w:w="5000"/></w:tblPr><w:tr>{tcs}</w:tr></w:tbl>'

def cover_title(text, color=None):
    c = color or BRAND["green"]
    return (f'<w:p><w:pPr><w:jc w:val="left"/><w:spacing w:before="720" w:after="120"/></w:pPr>'
            f'<w:r><w:rPr><w:b/><w:color w:val="{c}"/>'
            f'<w:sz w:val="72"/><w:szCs w:val="72"/>'
            f'<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/></w:rPr>'
            f'<w:t>{esc(text)}</w:t></w:r></w:p>')

def cover_subtitle(text):
    return (f'<w:p><w:pPr><w:spacing w:after="60"/></w:pPr>'
            f'<w:r><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>'
            f'<w:color w:val="{BRAND["text_muted_light"]}"/>'
            f'<w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr>'
            f'<w:t>{esc(text)}</w:t></w:r></w:p>')

def status_badge(text, fill):
    return (f'<w:p><w:pPr><w:spacing w:after="320"/></w:pPr>'
            f'<w:r><w:rPr><w:b/><w:color w:val="FFFFFF"/>'
            f'<w:highlight w:val="none"/>'
            f'<w:shd w:val="clear" w:color="auto" w:fill="{fill}"/>'
            f'<w:sz w:val="18"/></w:rPr>'
            f'<w:t xml:space="preserve">  {esc(text)}  </w:t></w:r></w:p>')

# ─────────────────────────────────────────────────────────────
# DOCX FILE STRUCTURE
# ─────────────────────────────────────────────────────────────

CONTENT_TYPES = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml"  ContentType="application/xml"/>
  <Override PartName="/word/document.xml"
    ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml"
    ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/word/numbering.xml"
    ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"/>
  <Override PartName="/docProps/core.xml"
    ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
</Types>"""

RELS = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
</Relationships>"""

DOC_RELS = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering" Target="numbering.xml"/>
</Relationships>"""

NUMBERING = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:numbering xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:abstractNum w:abstractNumId="0">
    <w:multiLevelType w:val="multilevel"/>
    <w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="bullet"/>
      <w:lvlText w:val="&#x2022;"/><w:lvlJc w:val="left"/>
      <w:pPr><w:ind w:left="360" w:hanging="240"/></w:pPr>
      <w:rPr><w:color w:val="9CD246"/><w:sz w:val="18"/></w:rPr></w:lvl>
    <w:lvl w:ilvl="1"><w:start w:val="1"/><w:numFmt w:val="bullet"/>
      <w:lvlText w:val="&#x25E6;"/><w:lvlJc w:val="left"/>
      <w:pPr><w:ind w:left="720" w:hanging="240"/></w:pPr>
      <w:rPr><w:color w:val="666666"/><w:sz w:val="16"/></w:rPr></w:lvl>
    <w:lvl w:ilvl="2"><w:start w:val="1"/><w:numFmt w:val="bullet"/>
      <w:lvlText w:val="&#x2212;"/><w:lvlJc w:val="left"/>
      <w:pPr><w:ind w:left="1080" w:hanging="240"/></w:pPr>
      <w:rPr><w:color w:val="999999"/><w:sz w:val="14"/></w:rPr></w:lvl>
  </w:abstractNum>
  <w:num w:numId="1"><w:abstractNumId w:val="0"/></w:num>
</w:numbering>"""

def styles_xml():
    h1 = BRAND["doc_h1"]
    h2 = BRAND["doc_h2"]
    h3 = BRAND["doc_h3"]
    # Font stack: prefer Inter/Sora if installed, fall back to Calibri (always available in MS Office)
    body_font = "Calibri"
    head_font = "Calibri"
    return f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault><w:rPr>
      <w:rFonts w:ascii="{body_font}" w:hAnsi="{body_font}" w:cs="{body_font}"/>
      <w:sz w:val="24"/><w:szCs w:val="24"/>
      <w:color w:val="{BRAND['text_primary_light']}"/>
      <w:lang w:val="en-US"/>
    </w:rPr></w:rPrDefault>
    <w:pPrDefault><w:pPr>
      <w:spacing w:after="140" w:line="288" w:lineRule="auto"/>
    </w:pPr></w:pPrDefault>
  </w:docDefaults>

  <w:style w:type="paragraph" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:rPr>
      <w:rFonts w:ascii="{body_font}" w:hAnsi="{body_font}"/>
      <w:sz w:val="24"/><w:szCs w:val="24"/>
      <w:color w:val="{BRAND['text_primary_light']}"/>
    </w:rPr>
  </w:style>

  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:pPr>
      <w:spacing w:before="480" w:after="160"/>
      <w:pBdr><w:bottom w:val="single" w:sz="6" w:space="6" w:color="{BRAND["green"]}"/></w:pBdr>
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="{head_font}" w:hAnsi="{head_font}"/>
      <w:b/><w:color w:val="{h1}"/>
      <w:sz w:val="40"/><w:szCs w:val="40"/>
    </w:rPr>
  </w:style>

  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/>
    <w:pPr><w:spacing w:before="320" w:after="100"/></w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="{head_font}" w:hAnsi="{head_font}"/>
      <w:b/><w:color w:val="{h2}"/>
      <w:sz w:val="30"/><w:szCs w:val="30"/>
    </w:rPr>
  </w:style>

  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/>
    <w:pPr><w:spacing w:before="200" w:after="80"/></w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="{head_font}" w:hAnsi="{head_font}"/>
      <w:b/><w:color w:val="{h3}"/>
      <w:sz w:val="26"/><w:szCs w:val="26"/>
    </w:rPr>
  </w:style>

  <w:style w:type="paragraph" w:styleId="ListParagraph">
    <w:name w:val="List Paragraph"/>
    <w:rPr>
      <w:rFonts w:ascii="{body_font}" w:hAnsi="{body_font}"/>
      <w:sz w:val="22"/><w:szCs w:val="22"/>
      <w:color w:val="{BRAND['text_primary_light']}"/>
    </w:rPr>
  </w:style>

  <w:style w:type="table" w:styleId="TableGrid">
    <w:name w:val="Table Grid"/>
    <w:tcPr><w:tcMar>
      <w:top w:w="100" w:type="dxa"/><w:left w:w="160" w:type="dxa"/>
      <w:bottom w:w="100" w:type="dxa"/><w:right w:w="160" w:type="dxa"/>
    </w:tcMar></w:tcPr>
  </w:style>
</w:styles>"""

def doc_xml(body_parts):
    body = "\n".join(body_parts)
    return f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <w:body>
{body}
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1440" w:right="1080" w:bottom="1440" w:left="1080"/>
    </w:sectPr>
  </w:body>
</w:document>"""

def core_xml(title, author="Vikas Chauhan"):
    today = date.today().isoformat()
    return f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>{esc(title)}</dc:title>
  <dc:creator>{esc(author)}</dc:creator>
  <dcterms:created xsi:type="dcterms:W3CDTF">{today}T00:00:00Z</dcterms:created>
</cp:coreProperties>"""

def write_docx(rel_path, body_parts, title, author="Vikas Chauhan"):
    path = os.path.join(BASE, rel_path)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", CONTENT_TYPES)
        z.writestr("_rels/.rels", RELS)
        z.writestr("word/_rels/document.xml.rels", DOC_RELS)
        z.writestr("word/styles.xml", styles_xml())
        z.writestr("word/numbering.xml", NUMBERING)
        z.writestr("word/document.xml", doc_xml(body_parts))
        z.writestr("docProps/core.xml", core_xml(title, author))
    print(f"  ✓  {rel_path}")

def meta_header(fields):
    """Renders the standard doc metadata table with brand styling."""
    rows = [["Field", "Value"]] + [[k, v] for k, v in fields]
    return table(*rows)

# ═════════════════════════════════════════════════════════════
# 1. PRD  (FAANG format)
# ═════════════════════════════════════════════════════════════

def build_prd():
    b = []
    b += [
        cover_title("Splitbo"),
        cover_subtitle("Product Requirements Document"),
        empty(),
        meta_header([
            ("Status",    "DRAFT — For Review"),
            ("Version",   "1.0"),
            ("Date",      "September 18, 2026"),
            ("Author / PM", "Vikas Chauhan"),
            ("Reviewers", "TBD"),
            ("Domain",    "splitbo.in / splitbo.com / splitbo.app"),
        ]),
        page_break(),
    ]

    # TOC
    b += [heading("Table of Contents")]
    toc = ["1. TL;DR", "2. Problem Statement", "3. Goals & Success Metrics",
           "4. Non-Goals", "5. Background & Context", "6. User Personas",
           "7. User Stories", "8. Feature Requirements (P0/P1/P2)",
           "9. Non-Functional Requirements", "10. Out of Scope",
           "11. Milestones & Timeline", "12. Open Questions", "13. Appendix"]
    for t in toc:
        b.append(para(t))
    b.append(page_break())

    # 1 TL;DR
    b += [heading("1. TL;DR"),
          para("Splitbo is a free, cross-platform expense-splitting app — one codebase, three targets: "
               "iOS (App Store), Android (Play Store), and Web (PWA). Firebase is the real-time backend. "
               "The product competes directly with Splitwise by shipping all essential features for free, "
               "targeting India-first users who split trip, household, and friend expenses in INR."),
          empty(),
          color_block("Core Insight: Splitwise's most-used features are locked behind ₹1,399/year. "
                      "Splitbo ships them free, with better INR support and UPI settlement notes.",
                      BRAND["green"]),
          empty()]

    # 2 Problem Statement
    b += [heading("2. Problem Statement"),
          heading("2.1 User Pain", 2),
          bullet("Splitwise free tier is capped: no charts, limited expenses, ad-heavy experience."),
          bullet("Indian users pay ₹1,399/year just to see spending trends — a feature that should be free."),
          bullet("No native UPI reference support; users resort to WhatsApp to share transaction IDs."),
          bullet("App feels sluggish on mid-range Android; no proper web experience for desktop users."),
          empty(),
          heading("2.2 Market Opportunity", 2),
          bullet("200M+ smartphone users in India actively splitting expenses (trips, PGs, roommates)."),
          bullet("Splitwise India MAU growing ~40% YoY but free-to-Pro conversion is friction-heavy."),
          bullet("No dominant free competitor offering full feature parity in the Indian market."),
          empty()]

    # 3 Goals
    b += [heading("3. Goals & Success Metrics"),
          heading("3.1 Business Goals", 2),
          bullet("Launch on App Store + Google Play + Web simultaneously at v1.0."),
          bullet("Acquire 500 registered users within 30 days of launch."),
          bullet("Grow to 5,000 MAU by month 6."),
          empty(),
          heading("3.2 Success Metrics (OKRs)", 2),
          table(
              ["Metric", "Target", "Measurement"],
              ["D7 Retention", "> 40%", "Firebase Analytics"],
              ["Crash-free sessions", "> 99%", "Firebase Crashlytics"],
              ["App Store Rating", "≥ 4.2 ★", "App Store Connect"],
              ["Avg groups/user (first 30 days)", "≥ 3", "Firestore analytics"],
              ["Expense add time (P90)", "< 30 sec end-to-end", "Firebase Performance"],
              ["Cold-start time", "< 2 sec", "Firebase Performance"],
          ), empty()]

    # 4 Non-Goals
    b += [heading("4. Non-Goals (Explicitly Out of Scope for v1)"),
          bullet("In-app UPI / payment processing — Splitbo records settlements; it does NOT move money."),
          bullet("AI receipt OCR or itemization scanning."),
          bullet("Multi-currency FX conversion (groups pick one currency; no conversion)."),
          bullet("Recurring / subscription expense tracking."),
          bullet("Business or corporate expense reporting."),
          bullet("Group chat / messaging feature."),
          bullet("Desktop-native app (web PWA covers desktop use case)."),
          empty()]

    # 5 Background
    b += [heading("5. Background & Context"),
          para("Splitwise (est. 2011) is the category leader in expense splitting with ~50M global users. "
               "It charges $3.99/month or ₹116/month for Pro. India is its fastest-growing segment, but "
               "the free-to-Pro conversion is blocked by cultural resistance to paying for social finance tools."),
          empty(),
          para("Splitbo enters as a fully-free product, funded initially by the founders. "
               "Monetization (Pro tier, white-label for travel agencies) is a post-v1 concern.", italic=True),
          empty()]

    # 6 Personas
    b += [heading("6. User Personas"),
          table(
              ["Persona", "Description", "Primary Need"],
              ["Vikas — Trip Organizer", "Travels 3-4x/year. Pays upfront, collects later.", "Track who owes how much; one-tap settle up."],
              ["Nikki — Flat-mate", "Shares rent / electricity / groceries with 2 roommates.", "Running balance per person; monthly summary."],
              ["Rashmi — Occasional User", "Joins groups for specific trips only.", "Simple 'what do I owe?' view, no learning curve."],
              ["Group Admin", "Creates groups, adds members, manages settings.", "Member management, export, simplify debts."],
          ), empty()]

    # 7 User Stories
    b += [heading("7. User Stories"),
          heading("7.1 Authentication", 2),
          bullet("As a new user, I can sign up with email+password, Google OAuth, or phone OTP in < 60 sec."),
          bullet("As a returning user, I can log in with biometric (FaceID/fingerprint)."),
          empty(),
          heading("7.2 Friends", 2),
          bullet("I can add friends by email, phone, or from device contacts."),
          bullet("I see a net balance per friend (Splitbo Green = they owe me, orange = I owe them)."),
          bullet("I can tap a friend to see every shared expense and the running balance history."),
          bullet("I can record a 'settle up' with an optional UPI reference note."),
          empty(),
          heading("7.3 Groups", 2),
          bullet("I can create a group (Trip / Home / Couple / Other) with a cover photo."),
          bullet("I can invite members via a shareable link that works on iOS, Android, and Web."),
          bullet("I see group tabs: Expenses, Balances, Totals, Whiteboard."),
          bullet("I can toggle 'Simplify Debts' to minimize the number of transactions required."),
          empty(),
          heading("7.4 Expenses", 2),
          bullet("I can add an expense: description, amount (INR default), date, category, notes, receipt photo."),
          bullet("I can choose who paid — a single person or multiple payers."),
          bullet("I can split equally, by exact amounts, by percentage, by shares, or with +/- adjustments."),
          bullet("I see a live tracker '₹30 of ₹3,000 · ₹2,970 left' while entering amounts."),
          bullet("I can edit or delete an expense; all balances update automatically."),
          empty(),
          heading("7.5 Activity & Notifications", 2),
          bullet("I see a global activity feed across all my groups and friends."),
          bullet("I receive a push notification when someone adds/edits an expense that includes me."),
          empty()]

    # 8 Feature Requirements
    b += [heading("8. Feature Requirements"),
          para("Priority: P0 = must ship at launch | P1 = ship within 30 days | P2 = post-launch roadmap"),
          empty(),
          table(
              ["Feature", "Priority", "Notes"],
              ["Email / Google / Phone OTP auth", "P0", "Firebase Auth"],
              ["Friends list with net balance", "P0", ""],
              ["Create / join groups (4 types)", "P0", ""],
              ["Add expense — equal split", "P0", "Most common split method"],
              ["Add expense — exact / % / shares / adjustment", "P0", ""],
              ["Single or multiple payers", "P0", ""],
              ["Group balances view", "P0", ""],
              ["Settle up (record payment + UPI note)", "P0", ""],
              ["Activity feed", "P0", ""],
              ["Push notifications (FCM)", "P0", ""],
              ["Offline support (read + queued writes)", "P0", "Firestore persistence"],
              ["Dark / Light theme (Splitbo brand)", "P0", ""],
              ["Expense charts by category", "P1", "Free — no paywall"],
              ["Simplify debts algorithm", "P1", ""],
              ["Group whiteboard", "P1", ""],
              ["Export group expenses as CSV", "P1", ""],
              ["Biometric lock", "P1", ""],
              ["Receipt photo upload", "P1", "Firebase Storage"],
              ["Invite via dynamic link", "P1", "Firebase Dynamic Links"],
              ["Multi-currency per group", "P2", "Post-launch"],
              ["Recurring expenses", "P2", "Post-launch"],
          ), empty()]

    # 9 NFRs
    b += [heading("9. Non-Functional Requirements"),
          table(
              ["Requirement", "Target"],
              ["Cold start time", "< 2 seconds on mid-range Android"],
              ["Expense save latency", "< 1 second (good connection)"],
              ["Offline reads", "Full history accessible with no network"],
              ["Platform support", "iOS 16+, Android 8+, Chrome/Safari/Firefox (modern)"],
              ["Data consistency", "Firestore transactions for balance updates — no drift"],
              ["Push notification delivery", "< 5 sec after trigger"],
              ["Accessibility", "WCAG AA contrast; screen-reader labels on all interactive elements"],
              ["GDPR / data deletion", "User can delete account + all data on request"],
          ), empty()]

    # 10 Out of Scope
    b += [heading("10. Out of Scope (Post-v1 Roadmap)"),
          bullet("AI receipt scan & itemization"),
          bullet("In-app UPI payment integration"),
          bullet("Multi-currency with live FX rates"),
          bullet("Recurring expenses (rent, subscriptions)"),
          bullet("Group chat"),
          bullet("Bank statement auto-import"),
          bullet("Business / team expense reports"),
          empty()]

    # 11 Milestones
    b += [heading("11. Milestones & Timeline"),
          table(
              ["Milestone", "Target Date", "Owner"],
              ["PRD + Architecture approved", "Sept 28, 2026", "Vikas"],
              ["Brand guidelines approved", "Oct 1, 2026", "Vikas"],
              ["Firebase project setup + Auth", "Oct 10, 2026", "Vikas"],
              ["Core screens: Friends, Groups, Expenses", "Oct 31, 2026", "Vikas"],
              ["Balance engine + Cloud Functions", "Nov 10, 2026", "Vikas"],
              ["Activity feed + Notifications", "Nov 20, 2026", "Vikas"],
              ["Internal alpha (TestFlight + Play internal)", "Nov 25, 2026", "Vikas"],
              ["Beta with 20 real users", "Dec 5, 2026", "Vikas"],
              ["App Store + Play Store + Web launch (v1.0)", "Dec 20, 2026", "Vikas"],
          ), empty()]

    # 12 Open Questions
    b += [heading("12. Open Questions"),
          table(
              ["#", "Question", "Owner", "Due"],
              ["1", "Register splitbo.in or splitbo.com first?", "Vikas", "Sept 25"],
              ["2", "Free forever or introduce a Pro tier post-launch?", "Vikas", "Oct 1"],
              ["3", "Support ghost accounts (non-registered users) like Splitwise does?", "Vikas", "Oct 5"],
              ["4", "Firebase Dynamic Links deprecated Aug 2025 — use Branch.io or custom?", "Vikas", "Oct 5"],
              ["5", "Default currency: INR or device locale?", "Vikas", "Oct 1"],
          ), empty()]

    # 13 Appendix
    b += [heading("13. Appendix"),
          heading("13.1 Reference Screenshots", 2),
          para("22 Splitwise screenshots (Sep 18, 2026) stored in assets/screenshots/ — "
               "used as UX reference for flows: onboarding, groups, expense entry, split options, "
               "balances, activity, account settings. Splitbo does NOT copy these designs; "
               "they are inspiration-only."),
          empty(),
          heading("13.2 Competitive Analysis", 2),
          table(
              ["Feature", "Splitwise Free", "Splitwise Pro", "Splitbo v1"],
              ["Unlimited expenses", "No (limited)", "Yes", "Yes"],
              ["Charts & graphs", "No", "Yes", "Yes"],
              ["Currency conversion", "No", "Yes (100+ currencies)", "No (v2)"],
              ["Receipt scan (OCR)", "No", "Yes", "No (v2)"],
              ["Price", "Free (ads)", "₹1,399/year", "Free"],
              ["Cross-platform (iOS/Android/Web)", "Yes", "Yes", "Yes — single codebase"],
              ["Offline support", "Partial", "Partial", "Full"],
          ), empty(),
          heading("13.3 Revision History", 2),
          table(
              ["Version", "Date", "Author", "Changes"],
              ["1.0", "Sept 18, 2026", "Vikas Chauhan", "Initial draft"],
          )]
    return b


# ═════════════════════════════════════════════════════════════
# 2. ARCHITECTURE
# ═════════════════════════════════════════════════════════════

def build_arch():
    b = []
    b += [
        cover_title("Splitbo"),
        cover_subtitle("Technical Architecture Document"),
        empty(),
        meta_header([
            ("Status",    "DRAFT"),
            ("Version",   "1.0"),
            ("Date",      "September 18, 2026"),
            ("Author",    "Vikas Chauhan"),
            ("Companion", "Splitbo PRD v1.0 · Brand Guidelines v1.0"),
        ]),
        page_break(),
    ]

    # Core Principle
    b += [heading("1. Core Principle — One App, All Platforms"),
          callout("RULE: There is ONE repository, ONE TypeScript codebase, ONE release cycle. NO separate iOS app, Android app, or web app."),
          empty(),
          para("The same source code compiles to:"),
          bullet("Native iOS binary (.ipa)  →  App Store"),
          bullet("Native Android binary (.aab)  →  Google Play"),
          bullet("Progressive Web App (PWA)  →  Firebase Hosting (splitbo.app / splitbo.in)"),
          empty(),
          para("All three targets share 100% of business logic, state management, and Firebase calls. "
               "Platform-specific surface area (StatusBar, biometrics, file picker) is handled by "
               "Expo's cross-platform abstraction — zero forked code paths.", italic=True),
          empty()]

    # Tech Stack
    b += [heading("2. Technology Stack"),
          table(
              ["Layer", "Technology", "Rationale"],
              ["Single codebase", "React Native + Expo SDK 52", "One JS/TS repo → iOS, Android, Web via EAS"],
              ["Web rendering", "react-native-web", "Same RN components render to DOM — no rewrites"],
              ["Navigation", "Expo Router (file-based)", "Routes = URLs on web + deep links on mobile"],
              ["State", "Zustand", "Minimal boilerplate; clean with Firestore onSnapshot listeners"],
              ["Styling", "NativeWind (Tailwind CSS)", "Splitbo tokens in tailwind.config.ts; same class on native + web"],
              ["Database", "Cloud Firestore", "Real-time sync, offline-first, scales to millions of docs"],
              ["Auth", "Firebase Auth", "Email, Google OAuth, Phone OTP — same SDK, all platforms"],
              ["Server logic", "Cloud Functions (Node.js 20)", "Balance recalc, push, invite validation"],
              ["File storage", "Firebase Storage", "Profile photos, receipt images"],
              ["Push notifications", "Firebase Cloud Messaging", "iOS APNs + Android FCM, single API"],
              ["Web hosting", "Firebase Hosting + PWA", "CDN, HTTPS, offline shell via service worker"],
              ["Store builds", "Expo EAS Build + EAS Submit", "CI/CD for App Store and Play Store"],
          ), empty()]

    # Folder structure
    b += [heading("3. Repository Structure  (Senior-Engineer Grade)"),
          para("Feature-first layout. Every feature is a self-contained slice: screen, store hook, service call, and types co-located. "
               "Nothing leaks across slices except shared ui/ and utils/."),
          empty(),
          mono("splitbo/"),
          mono("  app/                         Expo Router — one file = one route"),
          mono("  app/(auth)/                  login  signup  phone-verify  welcome"),
          mono("  app/(tabs)/                  main app with bottom tab bar"),
          mono("    app/(tabs)/friends/         Friends list + [friendId] detail"),
          mono("    app/(tabs)/groups/          Groups list + [groupId]/ subtree"),
          mono("    app/(tabs)/groups/[id]/     Tabs: expenses / balances / totals"),
          mono("    app/(tabs)/activity.tsx     Global activity feed"),
          mono("    app/(tabs)/account/         Profile  notifications  security"),
          mono("  app/_layout.tsx               Root layout + AuthGuard"),
          mono(""),
          mono("  src/features/                One folder per feature slice"),
          mono("    src/features/expenses/      AddExpenseModal  SplitOptions  expenseStore"),
          mono("    src/features/groups/        GroupCard  BalanceRow  groupStore"),
          mono("    src/features/friends/       FriendCard  AddFriendSheet  friendStore"),
          mono("    src/features/settlements/   SettleUpModal  settlementStore"),
          mono("    src/features/activity/      ActivityFeed  activityStore"),
          mono("    src/features/auth/          AuthGuard  authStore  auth service"),
          mono(""),
          mono("  src/shared/"),
          mono("    src/shared/ui/              Button  Avatar  Badge  OfflineBanner"),
          mono("    src/shared/services/        firebase.ts  groups.ts  expenses.ts"),
          mono("    src/shared/utils/           splitCalculator.ts  simplifyDebts.ts"),
          mono("    src/shared/hooks/           useCurrentUser  useGroupBalances"),
          mono("    src/shared/constants/       theme.ts (brand tokens)  currencies.ts"),
          mono("    src/shared/types/           User  Group  Expense  Settlement"),
          mono(""),
          mono("  functions/src/               Cloud Functions — Node.js 20 TypeScript"),
          mono("    onExpenseWrite.ts           Recalculates balance cache on expense change"),
          mono("    onSettlementWrite.ts        Updates balances + dispatches notification"),
          mono("    sendNotification.ts         FCM push dispatcher"),
          mono("    validateInviteLink.ts       Group invite link verification"),
          mono(""),
          mono("  docs/                        PRD  Architecture  Brand  KPI docs"),
          mono("  assets/                      Screenshots  brand assets"),
          mono("  scripts/                     gen_docs.py  gen_ppt.py"),
          mono(""),
          mono("  app.json                     Expo config — bundle IDs  icons  splash"),
          mono("  eas.json                     EAS Build profiles — dev / preview / prod"),
          mono("  firebase.json                Hosting + Functions deploy config"),
          mono("  firestore.rules              Security rules"),
          mono("  tailwind.config.ts           Splitbo brand tokens"),
          empty()]

    # Firestore Data Model
    b += [heading("4. Firestore Data Model"),
          heading("4.1 Collections", 2),
          table(
              ["Collection Path", "Description"],
              ["/users/{userId}", "Profile, FCM tokens, default currency"],
              ["/users/{userId}/friends/{friendId}", "Friendship (pending/accepted)"],
              ["/groups/{groupId}", "Group metadata, members[], settings"],
              ["/expenses/{expenseId}", "Expense with paidBy map + splits map"],
              ["/settlements/{settlementId}", "Recorded payments between users"],
              ["/balances/{userId}/friends/{friendId}", "Denormalized cache — Cloud Functions ONLY write this"],
              ["/balances/{userId}/groups/{groupId}", "Denormalized group balance cache"],
              ["/activity/{activityId}", "Feed events with denormalized snapshot"],
              ["/invites/{code}", "Group invite links (7-day expiry)"],
          ), empty(),
          heading("4.2 Expense Document — Key Fields", 2),
          bullet("groupId: string | null  — null = friend-to-friend expense"),
          bullet("amount: number  — always positive, total"),
          bullet("paidBy: { [userId]: amount }  — who paid how much"),
          bullet("splits: { [userId]: amount }  — how much each person OWES (source of truth)"),
          bullet("splitMethod: 'equal' | 'exact' | 'percent' | 'shares' | 'adjustment'"),
          bullet("participants: string[]  — indexed for Firestore queries ('show expenses involving me')"),
          empty(),
          heading("4.3 Balance Cache — Architecture Note", 2),
          color_block(
              "Clients NEVER recalculate balances from raw expenses. "
              "They read from /balances/ cache only. "
              "Cloud Functions update this atomically via Firestore transactions on every expense write. "
              "This prevents race conditions when multiple users modify the same group concurrently.",
              BRAND["green"], BRAND["text_primary_light"]),
          empty()]

    # Cloud Functions
    b += [heading("5. Cloud Functions"),
          table(
              ["Function", "Trigger", "Responsibility"],
              ["onExpenseWrite", "Firestore onCreate/onUpdate/onDelete /expenses/{id}", "Recalculate balances; write /balances/; create /activity/ doc; trigger notification"],
              ["onSettlementWrite", "Firestore onCreate /settlements/{id}", "Adjust balances for two parties; create /activity/ doc; trigger notification"],
              ["sendNotification", "Called internally by above functions", "Look up FCM tokens; send via Firebase Admin SDK"],
              ["validateInviteLink", "HTTPS Callable", "Validate invite code; add caller to group.members; mark invite used"],
          ), empty()]

    # Split Calculator
    b += [heading("6. Split Calculator Logic"),
          para("All split methods reduce to a final map of { [userId]: amountOwed }. "
               "Invariant: sum of all values equals the total expense amount. "
               "Rounding remainder is assigned to the payer."),
          table(
              ["Method", "Behaviour"],
              ["Equal", "total / N participants; remainder → payer"],
              ["Exact", "User enters each amount; UI validates sum == total"],
              ["Percent", "User enters % per person; amounts calculated; remainder → payer"],
              ["Shares", "amount = (user_shares / total_shares) * total"],
              ["Adjustment (+/-)", "Start from equal; apply per-person delta"],
          ), empty()]

    # Simplify Debts
    b += [heading("7. Simplify Debts Algorithm"),
          para("Greedy minimum cash flow — works well for groups < 20 people:"),
          bullet("Calculate net balance per member (sum owed minus sum paid)."),
          bullet("Pick the max creditor (most owed) and max debtor (owes most)."),
          bullet("Record one transaction for min(|creditor|, |debtor|). Reduce both."),
          bullet("Repeat until all balances reach zero."),
          para("Result: minimum number of transactions to settle the entire group.", italic=True),
          empty()]

    # Security
    b += [heading("8. Firestore Security Rules (Approach)"),
          bullet("Users: read/write own /users/{uid} only."),
          bullet("Expenses: only participants[] can read; only group members can create/edit/delete."),
          bullet("Groups: only members[] can read; createdBy can delete."),
          bullet("Balances: owner can read their /balances/{uid} subtree. Client writes are BLOCKED."),
          bullet("Activity: users read only events where their uid is in affectedUsers[]."),
          empty()]

    # Deployment
    b += [heading("9. Deployment Pipeline"),
          heading("9.1 Mobile — Expo EAS", 2),
          bullet("eas build --platform all --profile production  →  .ipa + .aab"),
          bullet("eas submit --platform ios  →  App Store Connect"),
          bullet("eas submit --platform android  →  Google Play"),
          empty(),
          heading("9.2 Web — Firebase Hosting", 2),
          bullet("npx expo export --platform web  →  generates static PWA"),
          bullet("firebase deploy --only hosting  →  splitbo.app"),
          empty(),
          heading("9.3 Cloud Functions", 2),
          bullet("cd functions && npm run build  →  compiles TypeScript"),
          bullet("firebase deploy --only functions"),
          empty(),
          heading("9.4 CI/CD (GitHub Actions)", 2),
          bullet("pr.yml  →  tsc + eslint + unit tests on every PR"),
          bullet("deploy-web.yml  →  build + deploy web on merge to main"),
          bullet("deploy-functions.yml  →  deploy functions on merge to main"),
          bullet("eas-build.yml  →  trigger EAS Build on version tag (v1.0.0)"),
          empty()]

    # Key Decisions
    b += [heading("10. Key Architecture Decisions"),
          table(
              ["Decision", "Chosen", "Rationale"],
              ["Single codebase for all platforms", "React Native + Expo", "iOS + Android + Web from one repo; no divergence; one release cycle"],
              ["Navigation", "Expo Router (file-based)", "Routes = browser URLs on web + deep links on mobile, automatically"],
              ["Balance updates", "Cloud Functions (server-side)", "Prevents client race conditions when multiple users modify the same group simultaneously"],
              ["Split storage", "Final amounts per user (not ratios)", "Immutable source of truth; prevents recalculation drift over time"],
              ["Offline", "Firestore offline persistence + optimistic UI", "Users add expenses on a plane; auto-syncs on reconnect"],
              ["State management", "Zustand", "Clean API; tiny bundle; great with Firestore listeners"],
              ["Theming", "NativeWind + Splitbo brand tokens", "Single tailwind.config.ts drives colors on native AND web"],
          )]
    return b


# ═════════════════════════════════════════════════════════════
# 3. BRAND GUIDELINES
# ═════════════════════════════════════════════════════════════

def build_brand():
    b = []
    b += [
        cover_title("Splitbo"),
        cover_subtitle("Brand & Design System Guidelines"),
        empty(),
        meta_header([
            ("Status",    "DRAFT v1.0"),
            ("Date",      "September 18, 2026"),
            ("Author",    "Vikas Chauhan"),
            ("Reference", "CrowdStrike Brand Guidelines 2026 (structural inspiration)"),
            ("Color Seed", "Splitbo brand identity — logo extract: #9CD246 Green on Black (splitbo.in)"),
        ]),
        empty(),
        color_block(
            "These guidelines are the single source of truth for Splitbo's visual identity. "
            "Every surface — iOS app, Android app, Web, documentation, marketing — MUST follow them. "
            "Consistency is non-negotiable.",
            BRAND["green"]),
        page_break(),
    ]

    # TOC
    b += [heading("Table of Contents")]
    for t in ["1. Brand Positioning", "2. Color System", "3. Typography",
              "4. Logo & Wordmark", "5. Iconography", "6. Spacing & Layout",
              "7. Component Design Language", "8. Motion & Animation",
              "9. Do / Don't", "10. Code Implementation (theme.ts)"]:
        b.append(para(t))
    b.append(page_break())

    # 1. Brand Positioning
    b += [heading("1. Brand Positioning"),
          heading("1.1 Brand Essence", 2),
          para("Splitbo makes shared money frictionless. "
               "When a group splits fairly and settles cleanly, friendships survive the trip."),
          empty(),
          heading("1.2 Brand Personality", 2),
          table(
              ["Attribute", "What It Means", "What It Does NOT Mean"],
              ["Trustworthy", "Clear numbers, no hidden complexity.", "Cold, corporate, or intimidating."],
              ["Friendly", "Approachable UI, warm micro-copy.", "Childish or informal."],
              ["Precise", "Math that is always correct to the paisa.", "Sterile or over-engineered UI."],
              ["Modern", "Clean, fast, works everywhere.", "Trendy for the sake of it."],
          ), empty(),
          heading("1.3 Voice Principles (inspired by CrowdStrike's framework)", 2),
          bullet("Lead with clarity — state the balance, not the formula behind it."),
          bullet("Be human — write 'You owe Nikki ₹350' not 'Outstanding liability: ₹350'."),
          bullet("Never be alarming — an orange badge for 'you owe' is enough; no red sirens."),
          bullet("Be brief — UI copy is 5 words max. Error messages are one sentence."),
          empty()]

    # 2. Color System
    b += [heading("2. Color System"),
          para("The Splitbo palette is anchored on brand green #9CD246 — extracted directly from the Splitbo logo. "
               "Pure black (#000000) and pure white (#FFFFFF) provide contrast. "
               "All semantic colors are derived from this foundation for visual consistency."),
          empty(),
          heading("2.1 Primary Palette", 2),
          color_swatch_table(
              ("Splitbo Green", BRAND["green"], "Primary — CTAs, links, headings"),
              ("Splitbo Deep", BRAND["green_dark"],    "Hover / pressed states"),
              ("Splitbo Light", BRAND["green_light"],  "Tinted backgrounds, badges"),
          ),
          empty(),
          color_swatch_table(
              ("Splitbo Green Accent",       BRAND["green"],  "Accent — highlights, icons, onboarding"),
              ("Splitbo Green Accent Muted", BRAND["green_light"],   "Subtle tints, selected states"),
          ),
          empty(),
          table(
              ["Token", "Hex", "RGB", "Usage"],
              ["green.primary",  f'#{BRAND["green"]}',  "156, 210, 70", "Buttons, links, primary actions"],
              ["green.dark",     f'#{BRAND["green_dark"]}',     "123, 168, 50",   "Hover, pressed states"],
              ["green.light",    f'#{BRAND["green_light"]}',    "238, 247, 217", "Badge fills, tinted backgrounds"],
              ["green.accent",   f'#{BRAND["green"]}',   "156, 210, 70",  "Secondary highlights, icons"],
              ["green.muted",    f'#{BRAND["green_light"]}',    "238, 247, 217", "Subtle tints, chips"],
          ), empty(),

          heading("2.2 Semantic Palette", 2),
          color_swatch_table(
              ("Positive",  BRAND["positive"], "You are owed"),
              ("Negative",  BRAND["negative"], "You owe"),
              ("Warning",   BRAND["warning"],  "Pending / partial"),
              ("Error",     BRAND["error"],    "Destructive actions"),
          ),
          empty(),
          table(
              ["Token", "Hex", "Usage", "Context"],
              ["semantic.positive", f'#{BRAND["positive"]}', "You are owed — amount chip", "Green: money coming your way"],
              ["semantic.negative", f'#{BRAND["negative"]}', "You owe — amount chip", "Orange: warm, not alarming (not red)"],
              ["semantic.warning",  f'#{BRAND["warning"]}',  "Pending settlement", "Amber: action needed"],
              ["semantic.error",    f'#{BRAND["error"]}',    "Delete / destructive", "Red: only for destructive actions"],
          ), empty(),

          heading("2.3 Neutral Palette — Light Mode", 2),
          color_swatch_table(
              ("BG",      BRAND["bg_light"],           "App background"),
              ("Surface", BRAND["surface_light"],      "Cards, sheets"),
              ("Border",  BRAND["border_light"],       "Dividers, input borders"),
              ("Text",    BRAND["text_primary_light"], "Primary text"),
              ("Muted",   BRAND["text_muted_light"],   "Captions, subtitles"),
          ), empty(),

          heading("2.4 Neutral Palette — Dark Mode", 2),
          color_swatch_table(
              ("BG",       BRAND["bg_dark"],            "App background"),
              ("Surface",  BRAND["surface_dark"],       "Cards"),
              ("Surface2", BRAND["surface2_dark"],      "Elevated cards"),
              ("Text",     BRAND["text_primary_dark"],  "Primary text"),
              ("Muted",    BRAND["text_muted_dark"],    "Captions"),
          ), empty(),

          heading("2.5 Color Usage Ratios", 2),
          para("Inspired by CrowdStrike's ratio guidance: primary brand color dominates, "
               "accent is used sparingly (≤ 20% of any design surface)."),
          table(
              ["Ratio", "Colors", "Use Case"],
              ["70% / 30%", "Neutrals / Splitbo Green", "Standard screen (list, settings)"],
              ["60% / 25% / 15%", "Neutrals / Green / Light Green", "Dashboard with visual hierarchy"],
              ["50% / 50%", "Dark surface / Green", "Dark-mode hero / header blocks"],
              ["100%", "Neutral", "Data-dense screens (expense lists) — let numbers breathe"],
          ), empty()]

    # 3. Typography
    b += [heading("3. Typography"),
          para("Splitbo uses Inter — the closest publicly available equivalent to CrowdStrike Sharp Sans. "
               "Inter is geometric, clean, highly legible at small sizes, and free via Google Fonts. "
               "It is used across iOS, Android, and Web via Expo's font loading system."),
          empty(),
          heading("3.1 Font Family", 2),
          table(
              ["Role", "Font", "Weight", "Source"],
              ["Primary — UI, body, labels", "Inter", "400 / 500 / 600 / 700", "Google Fonts (free)"],
              ["Display — hero text only", "Sora ExtraBold", "800", "Google Fonts (free)"],
              ["Amounts / IDs — tabular figures", "Inter Tabular", "600 / 700", "Built into Inter"],
          ), empty(),
          heading("3.2 Type Scale", 2),
          table(
              ["Name", "Size (px)", "Weight", "Line Height", "Usage"],
              ["Display XL", "48",  "800 Sora", "1.1", "Marketing / onboarding hero"],
              ["Display L",  "36",  "700 Inter",            "1.2", "Screen titles"],
              ["H1",         "28",  "700 Inter",            "1.3", "Section headers"],
              ["H2",         "22",  "600 Inter",            "1.35", "Card titles, modal headers"],
              ["H3",         "18",  "600 Inter",            "1.4", "List section headers"],
              ["Body L",     "16",  "400 Inter",            "1.5", "Primary body text"],
              ["Body M",     "14",  "400 Inter",            "1.5", "Secondary body, descriptions"],
              ["Label",      "13",  "500 Inter",            "1.4", "Buttons, tabs, badges"],
              ["Caption",    "11",  "400 Inter",            "1.4", "Timestamps, footnotes"],
              ["Amount",     "16",  "700 Inter",   "1.4", "Currency amounts"],
          ), empty(),
          heading("3.3 Typography Rules", 2),
          bullet("Never use more than 3 font sizes on a single screen."),
          bullet("Amount values (₹, $) use Inter 700 with fontVariant: ['tabular-nums'] — ensures monospaced digits."),
          bullet("Positive amounts: semantic.positive. Negative amounts: semantic.negative."),
          bullet("Settled amounts: text.muted (de-emphasised, not red or green)."),
          bullet("Never center-align body text — only headings and numeric amounts on balance screens."),
          empty()]

    # 4. Logo
    b += [heading("4. Logo & Wordmark"),
          heading("4.1 Wordmark Rules", 2),
          bullet("Wordmark: 'splitbo' — all lowercase, Inter Bold 700."),
          bullet("The 'b' in splitbo is optionally rendered in Splitbo Green Accent (#9CD246) for color contexts."),
          bullet("Clear space: minimum 20% of wordmark width on all sides (same rule as CrowdStrike)."),
          bullet("Minimum size: 80px wide on screen, 25mm in print."),
          empty(),
          heading("4.2 Color Variants", 2),
          table(
              ["Variant", "Background", "Logo Colors"],
              ["Primary", "White (#FFFFFF)", "Black wordmark + Green S% icon"],
              ["Reversed", "Black (#000000)", "White wordmark + Green S% icon"],
              ["Solid Green", "Green (#9CD246)", "White full wordmark"],
              ["Monochrome", "Any", "All-black or all-white — for single-color contexts"],
          ), empty(),
          heading("4.3 Do / Don't (Logo)", 2),
          table(
              ["DO", "DON'T"],
              ["Use approved color variants only", "Use unapproved color combinations"],
              ["Maintain clear space around logo", "Place logo on busy photo backgrounds"],
              ["Use Reversed on dark surfaces", "Use Primary on dark surfaces"],
              ["Keep proportions intact", "Stretch, skew, or rotate the wordmark"],
          ), empty()]

    # 5. Iconography
    b += [heading("5. Iconography"),
          para("Splitbo uses the Phosphor Icons library — clean, consistent, available for React Native "
               "and web. Icon style: Regular weight for UI, Bold weight for tab bar and primary actions."),
          empty(),
          table(
              ["Icon Set", "Style", "Size", "Usage"],
              ["Phosphor Icons", "Regular", "20px / 24px", "Lists, form fields, inline UI"],
              ["Phosphor Icons", "Bold",    "24px / 28px", "Tab bar, FAB, primary actions"],
              ["Phosphor Icons", "Fill",    "24px",        "Selected / active states only"],
          ), empty(),
          heading("5.1 Icon Color Rules", 2),
          bullet("Active/selected icon: Splitbo Green (#9CD246)"),
          bullet("Inactive icon: text.muted"),
          bullet("Semantic icons (positive/negative balance): semantic.positive / semantic.negative"),
          bullet("Destructive action icon: semantic.error — only when confirming a delete"),
          empty()]

    # 6. Spacing & Layout
    b += [heading("6. Spacing & Layout"),
          heading("6.1 Spacing Scale (4px base grid)", 2),
          table(
              ["Token", "Value", "Usage"],
              ["space.1", "4px",  "Icon internal padding, tight gaps"],
              ["space.2", "8px",  "Between icon and label"],
              ["space.3", "12px", "Compact card internal padding"],
              ["space.4", "16px", "Standard card padding, list item horizontal"],
              ["space.5", "20px", "Section gap"],
              ["space.6", "24px", "Card margin from screen edge"],
              ["space.8", "32px", "Section header to content"],
              ["space.10","40px", "Large section breaks"],
              ["space.12","48px", "Hero / onboarding vertical rhythm"],
          ), empty(),
          heading("6.2 Border Radius Scale", 2),
          table(
              ["Token", "Value", "Usage"],
              ["radius.sm",  "6px",   "Badges, tags, small chips"],
              ["radius.md",  "10px",  "Input fields, small cards"],
              ["radius.lg",  "16px",  "Cards, sheets, modals"],
              ["radius.xl",  "24px",  "Bottom sheets, FAB"],
              ["radius.full","9999px","Pills, avatars, toggles"],
          ), empty(),
          heading("6.3 Elevation (Shadow)", 2),
          table(
              ["Level", "Usage", "Shadow"],
              ["0 — Flat", "List items, inline elements", "No shadow"],
              ["1 — Card", "Standard cards, expense rows", "0 1px 3px rgba(0,0,0,0.08)"],
              ["2 — Float", "Modals, bottom sheets", "0 4px 16px rgba(0,0,0,0.12)"],
              ["3 — Overlay", "Toasts, popovers", "0 8px 32px rgba(0,0,0,0.20)"],
          ), empty()]

    # 7. Component Language
    b += [heading("7. Component Design Language"),
          heading("7.1 Buttons", 2),
          table(
              ["Variant", "Background", "Text", "Border", "Usage"],
              ["Primary",   BRAND["green"], "White", "None", "Main CTA: 'Add Expense', 'Settle Up'"],
              ["Secondary", "Transparent", BRAND["green"], f'1px {BRAND["green"]}', "Secondary actions: 'Share Link'"],
              ["Ghost",     "Transparent", BRAND["text_muted_light"], "None", "Tertiary: 'Cancel', 'Skip'"],
              ["Danger",    BRAND["error"], "White", "None", "Destructive: 'Delete Expense'"],
          ), empty(),
          heading("7.2 Balance Chip / Badge", 2),
          bullet("You are owed: background semantic.positive + 15% opacity, text semantic.positive, bold"),
          bullet("You owe: background semantic.negative + 15% opacity, text semantic.negative, bold"),
          bullet("Settled: background text.muted + 10% opacity, text text.muted"),
          empty(),
          heading("7.3 Cards", 2),
          bullet("Background: surface.card (light/dark mode aware)"),
          bullet("Border: 1px border.light / border.dark (mode aware)"),
          bullet("Radius: radius.lg (16px)"),
          bullet("Padding: space.4 (16px)"),
          bullet("Shadow: elevation level 1"),
          empty(),
          heading("7.4 Tab Bar", 2),
          bullet("Background: surface.card with blur effect"),
          bullet("Active/selected icon + label: Splitbo Green (#9CD246)"),
          bullet("Inactive icon + label: text.muted"),
          bullet("Four tabs: Friends · Groups · Activity · Account"),
          empty()]

    # 8. Motion
    b += [heading("8. Motion & Animation"),
          table(
              ["Type", "Duration", "Easing", "Usage"],
              ["Micro", "100–150ms", "ease-out", "Button press, icon change, badge update"],
              ["Standard", "200–250ms", "ease-in-out", "Screen transitions, card expand/collapse"],
              ["Entry", "300–350ms", "spring (stiffness 200, damping 20)", "Modal appears, bottom sheet slides up"],
              ["Exit", "180–200ms", "ease-in", "Modal dismisses, toast disappears"],
          ), empty(),
          para("Rule: Never animate amounts changing value — numbers update instantly. "
               "Motion is for spatial navigation, not for data rendering.", italic=True),
          empty()]

    # 9. Do / Don't
    b += [heading("9. Global Do / Don't"),
          table(
              ["DO", "DON'T"],
              ["Use Splitbo Green as the primary action color on all screens", "Mix brand colors arbitrarily — always use the token system"],
              ["Use semantic.positive (green) for 'owed to you'", "Use red for 'you owe' — use orange (semantic.negative) instead"],
              ["Use Inter across all text", "Mix fonts — one font family for the entire app"],
              ["Use Sora for display headings, Inter for all UI text", "Mix in Barlow or JetBrains — two fonts max"],
              ["Apply 4px grid for all spacing decisions", "Use arbitrary spacing values outside the scale"],
              ["Test both light and dark mode for every screen", "Design only for light mode and hope dark mode 'just works'"],
              ["Use border radius tokens consistently", "Mix rounded and square-corner elements on the same screen"],
              ["Keep screens data-dense but calm — let whitespace breathe", "Cram all information above the fold"],
          ), empty()]

    # 10. Code Implementation
    b += [heading("10. Code Implementation — src/shared/constants/theme.ts"),
          para("This is the single source of truth for all brand tokens in the app. "
               "NativeWind (Tailwind) reads from tailwind.config.ts which imports this file. "
               "The same tokens drive both mobile and web styling."),
          empty(),
          color_block("Every color, spacing, radius, and typography value in the app "
                      "MUST come from this file. No hardcoded hex values in components.",
                      BRAND["green_dark"]),
          empty(),
          para("File: src/shared/constants/theme.ts"),
          para("export const Colors = {", bold=True, color=BRAND["green"]),
          para("  brand: {"),
          para(f'    primary:   \'{BRAND["green"]}\',   // Brand Green #9CD246'),
          para(f'    deep:      \'{BRAND["green_dark"]}\',   // Dark Green'),
          para(f'    light:     \'{BRAND["green_light"]}\',   // Light Green'),
          para(f'    accent:      \'{BRAND["green"]}\',       // Green Accent'),
          para(f'    accentLight: \'{BRAND["green_light"]}\',  // Light Green tint'),
          para("  },"),
          para("  semantic: {"),
          para(f'    positive: \'{BRAND["positive"]}\',  // You are owed'),
          para(f'    negative: \'{BRAND["negative"]}\',  // You owe'),
          para(f'    warning:  \'{BRAND["warning"]}\',   // Pending'),
          para(f'    error:    \'{BRAND["error"]}\',     // Destructive'),
          para("  },"),
          para("  light: {"),
          para(f'    bg:         \'{BRAND["bg_light"]}\','),
          para(f'    surface:    \'{BRAND["surface_light"]}\','),
          para(f'    border:     \'{BRAND["border_light"]}\','),
          para(f'    textPrimary:\'{BRAND["text_primary_light"]}\','),
          para(f'    textMuted:  \'{BRAND["text_muted_light"]}\','),
          para("  },"),
          para("  dark: {"),
          para(f'    bg:         \'{BRAND["bg_dark"]}\','),
          para(f'    surface:    \'{BRAND["surface_dark"]}\','),
          para(f'    surface2:   \'{BRAND["surface2_dark"]}\','),
          para(f'    border:     \'{BRAND["border_dark"]}\','),
          para(f'    textPrimary:\'{BRAND["text_primary_dark"]}\','),
          para(f'    textMuted:  \'{BRAND["text_muted_dark"]}\','),
          para("  },"),
          para("} as const;"),
          empty(),
          para("export const Typography = {", bold=True, color=BRAND["green"]),
          para("  fonts: { primary: 'Inter', display: 'Sora', body: 'Inter' },"),
          para("  scale: { xs:11, sm:13, base:16, lg:18, xl:22, '2xl':28, '3xl':36, '4xl':48 },"),
          para("  weights: { regular:400, medium:500, semibold:600, bold:700, extrabold:800 },"),
          para("} as const;"),
          empty(),
          para("export const Spacing = {", bold=True, color=BRAND["green"]),
          para("  1:4, 2:8, 3:12, 4:16, 5:20, 6:24, 8:32, 10:40, 12:48"),
          para("} as const;"),
          empty(),
          para("export const Radius = {", bold=True, color=BRAND["green"]),
          para("  sm:6, md:10, lg:16, xl:24, full:9999"),
          para("} as const;"),
    ]

    return b


# ═════════════════════════════════════════════════════════════
# KPI / MVP TRACKING DOCUMENT
# Perspectives: PM/CEO · Sr Engineer · Sr UX Designer
# ═════════════════════════════════════════════════════════════

def build_kpi():
    b = []

    # Cover
    b += [
        cover_title("Splitbo KPI & MVP Tracker"),
        meta_header([
            ("Version",   "1.0"),
            ("Date",      "September 18, 2026"),
            ("Author",    "Vikas Chauhan"),
            ("Audience",  "Founders · Engineering · Design"),
            ("Framework", "PM/CEO + Sr Engineer + Sr UX Designer perspectives"),
        ]),
        empty(),
        color_block(
            "This document tracks the metrics that matter at every layer: "
            "business outcomes (PM/CEO), technical excellence (Sr Engineer), "
            "and user experience quality (Sr UX Designer). "
            "Review weekly pre-launch, monthly post-launch.",
            BRAND["green"]),
        page_break(),
    ]

    # ── PART 1: PM / CEO ─────────────────────────────────────
    b += [
        heading("Part 1 — PM / CEO Lens: Business & Product KPIs"),
        callout("Think in outcomes, not features. Every metric below ties to user retention, word-of-mouth, or monetisation runway."),
        empty(),
        heading("1.1 North Star Metric", 2),
        para("Monthly Active Expense-Splitting Users (MAESU) — "
             "users who add ≥1 expense or settlement in a rolling 30-day window. "
             "This combines acquisition, engagement, and retention in one number."),
        empty(),
        heading("1.2 OKRs — MVP Launch (Month 0–3)", 2),
        table(
            ["Objective", "Key Result", "Target", "Status"],
            ["Launch on App Store + Play Store + Web",
             "All 3 platforms live, zero P0 crash bugs",
             "Month 1", "—"],
            ["Achieve product–market fit signal",
             "Week-4 retention ≥ 30%",
             "30%", "—"],
            ["Drive organic growth",
             "≥40% of new users from referral / invite link",
             "40%", "—"],
            ["Validate core loop",
             "Avg. expenses per active group ≥ 5 in first 30 days",
             "5", "—"],
            ["Build trust",
             "App Store rating ≥ 4.4 stars at 100 reviews",
             "4.4 ★", "—"],
        ), empty(),

        heading("1.3 Growth Funnel KPIs", 2),
        table(
            ["Stage", "Metric", "MVP Target", "6-Month Target"],
            ["Acquisition",  "New signups / week",             "50",   "500"],
            ["Activation",   "% users who add first expense",  "60%",  "70%"],
            ["Retention",    "D7 retention",                   "25%",  "35%"],
            ["Retention",    "D30 retention",                  "15%",  "28%"],
            ["Revenue (future)", "Paid tier conversion",       "N/A",  "2%"],
            ["Referral",     "K-factor (invites sent per user)","0.4", "0.8"],
        ), empty(),

        heading("1.4 Feature Priority (MoSCoW)", 2),
        table(
            ["Priority", "Feature", "Rationale"],
            ["Must",  "Add expense (equal / exact / percentage split)", "Core loop — no value without this"],
            ["Must",  "Group creation and member invite via link",       "Groups are the retention hook"],
            ["Must",  "Real-time balance summary (you owe / owed)",      "Trust driver — must be instant + accurate"],
            ["Must",  "Settle up (record settlement)",                   "Closure — removes friction from social debt"],
            ["Must",  "Push notifications on expense added",             "Re-engagement — India users expect this"],
            ["Should","Expense receipt photo",                           "Reduces disputes"],
            ["Should","Simplify debts algorithm",                        "Reduces number of transfers in a group"],
            ["Should","INR / UPI deep link for settlement",              "India-first differentiator"],
            ["Could", "Recurring expenses",                              "Power users; post-MVP"],
            ["Won't", "In-app payments / escrow",                        "Regulatory + licensing complexity — out of scope v1"],
        ), empty(),

        heading("1.5 Launch Milestones", 2),
        table(
            ["Milestone", "Target Date", "Owner", "Done?"],
            ["Firestore security rules reviewed",          "Week 2",  "Eng", "—"],
            ["EAS build passes iOS + Android",             "Week 3",  "Eng", "—"],
            ["App Store + Play Store submission",          "Week 4",  "Eng", "—"],
            ["10 beta users onboarded (friends / family)", "Week 4",  "PM",  "—"],
            ["App Store approved + live",                  "Week 6",  "PM",  "—"],
            ["First 50 real groups created",               "Month 2", "PM",  "—"],
            ["Week-4 retention ≥ 25% confirmed",           "Month 2", "PM",  "—"],
            ["Public launch announcement",                 "Month 3", "PM",  "—"],
        ), empty(),
        page_break(),
    ]

    # ── PART 2: SR ENGINEER ───────────────────────────────────
    b += [
        heading("Part 2 — Sr Engineer Lens: Technical KPIs & Milestones"),
        callout("Ship fast, but never compromise data integrity. Balance accuracy is non-negotiable — one wrong number destroys trust permanently."),
        empty(),
        heading("2.1 Performance Benchmarks (Production Targets)", 2),
        table(
            ["Metric", "Target", "Measurement Method", "Priority"],
            ["App cold start (iOS/Android)",   "< 2.5 s",   "Expo perf monitor / Xcode Instruments", "P0"],
            ["App cold start (Web PWA)",        "< 3.0 s",   "Lighthouse / Web Vitals",               "P0"],
            ["Expense add → balance updated",   "< 1.5 s",   "Cloud Function execution logs",         "P0"],
            ["Firestore snapshot latency (P99)","< 500 ms",  "Firebase Performance SDK",              "P0"],
            ["Screen-to-screen navigation",     "< 300 ms",  "React Native FPS monitor",              "P1"],
            ["Push notification delivery",      "< 5 s",     "FCM delivery reports",                  "P1"],
            ["Offline → online resync",         "< 3 s",     "Manual + automated test",               "P1"],
            ["JS bundle size (web)",            "< 500 KB gzipped","webpack-bundle-analyzer",         "P2"],
        ), empty(),

        heading("2.2 Reliability & Correctness KPIs", 2),
        table(
            ["Metric", "Target", "Notes"],
            ["Balance calculation accuracy",  "100%",  "Cloud Function is sole writer — zero client drift"],
            ["Crash-free sessions (mobile)",  "> 99.5%","Firebase Crashlytics"],
            ["Cloud Function error rate",     "< 0.1%", "Firebase Functions logs"],
            ["Firestore read cost / MAU",     "< ₹50/month at 1k MAU", "Monitor via GCP billing alerts"],
            ["Security rule test coverage",   "100% of collection paths", "firebase emulator:exec"],
            ["Unit test coverage (functions)","≥ 80%",  "Jest + functions emulator"],
        ), empty(),

        heading("2.3 Technical Milestones (Sr Engineer Definition of Done)", 2),
        table(
            ["Milestone", "Acceptance Criteria", "Sprint"],
            ["Firestore data model finalized",
             "Schema matches Architecture doc; security rules written + tested",
             "Sprint 1"],
            ["Cloud Functions: onExpenseWrite",
             "Balance cache updated atomically; idempotent on retry",
             "Sprint 1"],
            ["Cloud Functions: onSettlementWrite",
             "Balances correctly zeroed; notification dispatched",
             "Sprint 2"],
            ["Auth flow complete (Email + Google + Phone OTP)",
             "All 3 paths tested on iOS + Android + Web",
             "Sprint 2"],
            ["Offline-first validated",
             "Add expense offline → syncs on reconnect; no data loss",
             "Sprint 3"],
            ["EAS build pipeline green",
             "iOS .ipa + Android .aab built from CI; env vars in EAS Secrets",
             "Sprint 3"],
            ["PWA offline shell",
             "App loads from service worker when offline on Chrome / Safari",
             "Sprint 4"],
            ["Performance targets met",
             "All P0 benchmarks hit on mid-range Android (Redmi Note 12 class)",
             "Sprint 4"],
        ), empty(),

        heading("2.4 Code Quality Gates (must pass before merge)", 2),
        bullet("TypeScript strict mode: zero `any` types in src/"),
        bullet("ESLint: zero errors, zero warnings in CI"),
        bullet("Firestore security rules: emulator suite passes 100% before deploy"),
        bullet("Cloud Function unit tests: Jest ≥ 80% branch coverage"),
        bullet("No hardcoded API keys or secrets — all via EAS Secrets / env vars"),
        bullet("Bundle size regression check on every PR (fail if +10% increase)"),
        empty(),
        page_break(),
    ]

    # ── PART 3: SR UX DESIGNER ────────────────────────────────
    b += [
        heading("Part 3 — Sr UX Designer Lens: Design Quality & Usability KPIs"),
        callout("Design quality is invisible when done right — users just feel the app is fast and trustworthy. Measure the absence of friction, not the presence of features."),
        empty(),
        heading("3.1 Usability KPIs (Target at Launch)", 2),
        table(
            ["Metric", "Target", "Method"],
            ["Time to add first expense (new user)",  "< 90 seconds",  "Usability test (5 participants)"],
            ["Task success rate — add expense",        "> 95%",         "Usability test"],
            ["Task success rate — settle up",          "> 90%",         "Usability test"],
            ["SUS score (System Usability Scale)",     "> 75 / 100",    "Post-session survey"],
            ["NPS (Net Promoter Score) — beta users",  "> 40",          "In-app survey at D14"],
            ["CSAT — expense addition flow",           "> 4.2 / 5",     "Post-task micro-survey"],
            ["User error rate in split-type selection","< 5%",          "Error logging + session recording"],
        ), empty(),

        heading("3.2 Design System Coverage KPIs", 2),
        table(
            ["Metric", "Target", "Notes"],
            ["Screens built from token system only",    "100%",   "Zero hardcoded hex values in components"],
            ["Component library coverage",              "> 80%",  "Storybook or Expo component catalogue"],
            ["Dark mode parity",                        "100%",   "Every screen reviewed in both modes before release"],
            ["Typography adherence",                    "100%",   "All text uses theme.ts size + weight tokens"],
            ["Accessibility: min contrast ratio",       "4.5:1",  "WCAG AA — checked via Figma / axe"],
            ["Touch target minimum size",               "44×44pt","Per iOS HIG + Android MD guidelines"],
        ), empty(),

        heading("3.3 UX Milestones (Design Definition of Done)", 2),
        table(
            ["Milestone", "Acceptance Criteria", "Sprint"],
            ["Core screens designed",
             "Home, Group, Add Expense, Settle Up, Profile screens in Figma",
             "Sprint 0"],
            ["Design tokens mapped to theme.ts",
             "All Figma tokens match src/shared/constants/theme.ts exactly",
             "Sprint 0"],
            ["Onboarding flow validated",
             "5-participant usability test; task success > 90%",
             "Sprint 1"],
            ["Empty states designed",
             "Zero-expense, no-groups, settled-up states all designed",
             "Sprint 2"],
            ["Error + loading states",
             "All async operations have loading skeleton + error message",
             "Sprint 2"],
            ["Dark mode review",
             "Full screen audit in dark mode; contrast ratios verified",
             "Sprint 3"],
            ["Accessibility audit",
             "VoiceOver (iOS) + TalkBack (Android) walkthrough of core flows",
             "Sprint 4"],
            ["Motion review",
             "All transitions reviewed against motion guidelines (no animated amounts)",
             "Sprint 4"],
        ), empty(),

        heading("3.4 Key Design Principles (non-negotiable)", 2),
        bullet("Balance numbers are always visible above the fold — never hidden behind a tap."),
        bullet("'You owe' is orange, never red. Orange is warm; red triggers anxiety."),
        bullet("Amounts use Inter 700 with tabular figures — consistency is trust."),
        bullet("Maximum 3 font sizes per screen — cognitive load control."),
        bullet("Every destructive action (delete, clear) requires a two-step confirmation."),
        bullet("Settled state is visually de-emphasised (muted grey) — let resolved items recede."),
        empty(),
        page_break(),
    ]

    # ── PART 4: DASHBOARD ─────────────────────────────────────
    b += [
        heading("Part 4 — Weekly Review Dashboard"),
        para("Use this table in weekly standups. "
             "Copy it to a Notion/Google Sheet and update every Monday.", italic=True),
        empty(),
        table(
            ["Metric", "Target", "W1", "W2", "W3", "W4", "Trend"],
            ["New signups",              "50/wk",  "—", "—", "—", "—", "—"],
            ["MAESU",                    "growing","—", "—", "—", "—", "—"],
            ["D7 retention",             "> 25%",  "—", "—", "—", "—", "—"],
            ["Crash-free sessions",      "> 99.5%","—", "—", "—", "—", "—"],
            ["Balance calc accuracy",    "100%",   "—", "—", "—", "—", "—"],
            ["App Store rating",         "≥ 4.4",  "—", "—", "—", "—", "—"],
            ["NPS",                      "> 40",   "—", "—", "—", "—", "—"],
            ["Open P0 bugs",             "0",      "—", "—", "—", "—", "—"],
            ["Cloud Function error rate","< 0.1%", "—", "—", "—", "—", "—"],
        ), empty(),
        color_block(
            "Splitbo's unfair advantage is trust. "
            "When users see their balance is always accurate and the app never crashes, "
            "they recommend it to everyone they travel or dine with. "
            "Every KPI in this document is a proxy for that trust.",
            BRAND["green"]),
    ]

    return b


# ═════════════════════════════════════════════════════════════
# MAIN
# ═════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("\nGenerating Splitbo documents...")
    write_docx("docs/01-PRD/Splitbo_PRD_v1.0.docx",          build_prd(),   "Splitbo PRD v1.0")
    write_docx("docs/02-Architecture/Splitbo_Architecture_v1.0.docx", build_arch(), "Splitbo Architecture v1.0")
    write_docx("docs/03-Brand/Splitbo_Brand_Guidelines_v1.0.docx",    build_brand(),"Splitbo Brand Guidelines v1.0")
    write_docx("docs/04-KPI/Splitbo_KPI_MVP_Tracker_v1.0.docx",       build_kpi(), "Splitbo KPI & MVP Tracker v1.0")
    print("\nAll documents generated.\n")
    print("Folder structure:")
    for root, dirs, files in os.walk(BASE):
        dirs[:] = [d for d in sorted(dirs) if not d.startswith('.') and d not in ['node_modules', '__pycache__']]
        level = root.replace(BASE, '').count(os.sep)
        indent = '  ' * level
        print(f"{indent}{os.path.basename(root)}/")
        for f in sorted(files):
            if not f.startswith('.'):
                print(f"{indent}  {f}")
