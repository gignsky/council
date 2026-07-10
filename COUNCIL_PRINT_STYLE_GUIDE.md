# Council of Un — Print Edition Style Guide
### "The Landis Edition" house style · for future Claude · v1 · 2026-07-09

This document defines the visual system for the **Council of Un** printed papers
(the Keeper's Binder, the player packs, in-fiction letters and proposals). Follow
it so every new document looks like it came out of the same binder. If a request
conflicts with this guide, ask before diverging.

> **One-line brief:** white paper, all-serif, one deep-marine accent that must also
> read cleanly in black-and-white, an elegant calligraphic display face for
> headings, typewriter mono for labels, and a huge inlaid initial to open each
> document. Plain and simple, with a method to the madness.

---

## 1. Build & format

- **Every deliverable is a Design Component** (`Name.dc.html`) authored with the
  `dc_write` / `dc_html_str_replace` tools. Never a plain `.html` page.
- **Paged documents use the `doc-page` web component** (`copy_starter_component`
  → `doc_page.js`), mounted via
  `<x-import component-from-global-scope="doc-page" from="./doc-page.js" size="letter" orientation="portrait" margin="0.75in">`.
  It owns all print geometry — never write your own `@page`, desk background,
  page-card divs, or `break-after:page` fake sheets.
- **Paper:** US Letter, portrait, `0.75in` margin.
- **PDF export:** the browser print dialog (Cmd/Ctrl+P → Save as PDF). There is no
  server-side PDF step. For distribution, bundle each file with `super_inline_html`
  into `dist/` (needs a `<template id="__bundler_thumbnail">` — see §9) and zip via
  `present_fs_item_for_download`.
- **Styling is inline only** (Design Component rule). The only `<helmet><style>`
  content allowed: font `<link>`s, body reset, the `doc-page:not(:defined)` guard,
  link colors, and the one `doc-page{...!important}` font override (see §2).

---

## 2. Typography

Three families, loaded from Google Fonts. Load exactly these in every document's
`<helmet>`:

```
Cormorant+Garamond:ital,wght@0,500;0,600;1,500
Crimson+Pro:ital,wght@0,400;0,500;0,600;1,400;1,500
IM+Fell+English:ital@0;1
Courier+Prime:ital,wght@0,400;0,700;1,400
```

| Role | Family | Notes |
|---|---|---|
| **Headings / display** | `'Cormorant Garamond',Georgia,serif` | Elegant, high-contrast, calligraphic. Titles, chapter names, section heads. Weight 600. This is the "elegant, not corporate" face — do not substitute a grotesque or Inter/Roboto. |
| **Body copy** | `'Crimson Pro',Georgia,serif` | All running text. 14–15px, line-height 1.65. Weight 400; 600 for `<b>` leads. |
| **Inlaid initials, in-fiction quotes, epigraphs, giant numerals** | `'IM Fell English',serif` | The "old ledger" voice. Italic for quoted letters/seals. |
| **Labels, eyebrows, codes, tables headers, play-aid mock-ups** | `'Courier Prime',monospace` | Uppercase, letter-spacing 1.5–3px, small (8–10px). The "typewriter record" texture. |

**Critical `doc-page` font gotcha:** `doc-page` sets its own sans default on the
sheet, which overrides `body{font-family}` for slotted content. Fix BOTH ways:

```css
body{margin:0;font-family:'Crimson Pro',Georgia,serif;color:#1c1c1a}
doc-page{font-family:'Crimson Pro',Georgia,serif !important;color:#1c1c1a}
```

AND wrap all slotted body content (everything except the `slot="header"`/`slot="footer"`
elements) in a single `<div style="font-family:'Crimson Pro',Georgia,serif;color:#1c1c1a">…</div>`.
Elements with their own inline `font-family` (headings, mono labels) keep theirs.

**Type scale (px):**
- Cover title: 76, Cormorant 600, marine.
- Contents heading: 40, Cormorant 600, marine.
- Document title: ~39, Cormorant 600, marine, `letter-spacing:.2px`, `line-height:1.05`.
- Section head: 24, Cormorant 600, `#20506e`.
- Sub-section head: 23, Cormorant 600, `#20506e`.
- Body: 14–15, Crimson Pro, `line-height:1.65`.
- Small print / captions / keeper notes: 13–13.5, often italic `#5d5952`.
- Mono labels: 8–10, letter-spacing 1.5–3px.
- **Slides/decks are not used here.** Never go below 12px in a print doc.

---

## 3. Color

One accent. Everything must survive greyscale (test: does it still read as a clean
mid-grey with no color?).

| Token | Hex | Use |
|---|---|---|
| Ink (text) | `#1c1c1a` | Body, hard rules, drop-cap border, keeper boxes. |
| Paper | `#ffffff` | Background (the `doc-page` sheet). |
| **Marine (accent)** | `#2f5d7c` | Titles, drop-cap inner outline, eyebrows, links, seal left-borders, diamond marks. |
| Marine (section heads) | `#20506e` | Slightly deeper marine for section/sub-section headings. |
| Pale marine | `#a7c0d1` | The huge IM Fell numerals on document headers only. |
| Muted ink | `#5d5952` | Captions, italic asides, secondary text. |
| Faint label grey | `#8a857a` | Running header/footer mono, page furniture. |
| Hairline | `#d8d4ca` | Section rules, box borders, table row lines (lighter `#e4e1d8`). |

Do **not** introduce a second accent hue, gradients, drop shadows, or rounded-corner
+ left-accent "callout" cards. Boxes are 1px solid hairlines or 1px solid ink; the
"seal / quote" box adds a 2px marine **left** border only.

---

## 4. Signature components (copy these patterns verbatim)

**Inlaid initial (drop cap)** — opens the first paragraph of each document/major
section. A large IM Fell letter with an ink border and an inset marine outline:

```html
<span style="float:left;font-family:'IM Fell English',serif;font-size:56px;line-height:.75;
  padding:11px 12px 9px;margin:4px 14px 2px 0;border:1px solid #1c1c1a;
  outline:1px solid #2f5d7c;outline-offset:-4px;color:#1c1c1a">T</span>
```

**Document header** — eyebrow (mono, marine) + title (Cormorant, marine) on the
left, a giant pale-marine IM Fell numeral on the right, over a 2px ink bottom rule:

```html
<div style="display:flex;justify-content:space-between;align-items:flex-end;border-bottom:2px solid #1c1c1a;padding-bottom:12px">
  <div>
    <div style="font-family:'Courier Prime',monospace;font-size:9.5px;letter-spacing:3px;color:#2f5d7c;margin-bottom:8px">DOCUMENT V · …</div>
    <div style="font-family:'Cormorant Garamond',Georgia,serif;font-size:39px;font-weight:600;line-height:1.05;color:#2f5d7c;letter-spacing:.2px">The Ledger of Peoples</div>
  </div>
  <div style="font-family:'IM Fell English',serif;font-size:66px;line-height:.8;color:#a7c0d1">V</div>
</div>
```

Follow with an italic IM Fell dek (`#5d5952`) describing the document.

**Section rule** — mono tag + Cormorant heading + a growing hairline:

```html
<div style="display:flex;align-items:center;gap:10px;margin:26px 0 12px;break-after:avoid">
  <span style="font-family:'Courier Prime',monospace;font-size:9.5px;letter-spacing:2.5px;color:#2f5d7c;white-space:nowrap">PART II</span>
  <span style="font-family:'Cormorant Garamond',Georgia,serif;font-size:24px;font-weight:600;color:#20506e">Heading</span>
  <span style="flex:1;height:1px;background:#d8d4ca"></span>
</div>
```

**Seal / in-fiction quote box** — 1px hairline + 2px marine left border; mono
label, then the quote in italic IM Fell, then a plain-text gloss in muted ink:

```html
<div style="break-inside:avoid;border:1px solid #d8d4ca;border-left:2px solid #2f5d7c;padding:14px 18px;margin:0 0 12px">
  <div style="font-family:'Courier Prime',monospace;font-size:9.5px;letter-spacing:2px;font-weight:700">SEAL I — THE ORE</div>
  <div style="font-family:'IM Fell English',serif;font-style:italic;font-size:14px;line-height:1.65">…the quoted letter/seal…</div>
  <div style="font-size:13px;line-height:1.6;color:#5d5952"><b style="color:#1c1c1a">What it holds:</b> …</div>
</div>
```

**Keeper note / flag box** — 1px hairline (or 1px ink for "sealed, not for the
table"); opens with a mono label and the ⚑ glyph (`&#9873;`). Keeper-only content
belongs only in keeper documents (see §7).

**Redaction bars** — for redacted in-fiction letters, strike-through kept text with
`<s style="color:#8a857a">…</s>` and bury the rest under a solid ink bar:
`<span style="display:inline-block;height:11px;width:168px;background:#1c1c1a;vertical-align:middle"></span>`.
Vary the widths. Never put real spoilers in the HTML around the bars.

**Tables** — no vertical borders. Header row: mono 8.5px, `letter-spacing:1.5px`,
`#5d5952`, 1px ink bottom border. Body rows: 12.5–13.5px, `1px solid #e4e1d8`
bottom border, `vertical-align:top`, `break-inside:avoid` on each `<tr>`.

**Work cards** — bordered box (`1px solid #d8d4ca`), a header strip with a mono
card code (left) and mono watch-count (right) separated by a hairline, then title
(Cormorant/serif) and body. Grid them 2-up with `gap:12px`.

**Diamond mark** — the recurring ornament: a small rotated square outline,
`width:7px;height:7px;border:1px solid #2f5d7c;transform:rotate(45deg)`, flanked by
`1px` hairlines. Used on the cover and end-marks.

---

## 5. Page furniture (running header/footer)

Every paged document carries a repeating header and footer via `slot="header"` /
`slot="footer"`:

- **Header:** two mono lines over a hairline. Line 1: document family (left) +
  status/date (right). Line 2: a **navigation strip** — every major section as a
  mono `<a href="#id">` link separated by `·`, so headings double as electronic
  navigation on every page.
- **Footer:** hairline over one mono line — an in-fiction tag (left) + a
  `CONTENTS`/`#top` link (right).
- Give the title leaf `id="top"`; every section gets a stable `id`
  (`ch01`, `gov`, `inv`, …) referenced by the strip and the contents page.
- Put `data-screen-label="…"` on each section/screen wrapper for comment context.

A front **Contents** page lists everything: mono section-group labels over ink
rules, then each entry as a `<a>` row (Cormorant/serif title + mono descriptor),
`1px solid #e4e1d8` between rows.

---

## 6. Voice & content

- **In-world register.** Documents are artifacts: letters, ledgers, standing orders,
  sealed prices, proposals. Attribution lines are in-fiction ("Kept by the
  Ledgerman; append-only", "— L.F., aboard the Silver Surfer").
- **Landis Fishman (L.F.)** is the guiding voice: elegant, oblique, "method to the
  madness," prophetic, self-interrupting. In-fiction letters may be redacted (§4).
- **The record is append-only** — never phrase corrections as edits; they are new
  lines beneath old ones.
- No filler, no invented stats, no emoji. Every element earns its place.
- Set `a`/`a:hover` colors (marine `#2f5d7c` / `#1f425c`) in `<helmet>` even before
  links exist.

---

## 7. Player-facing vs keeper-only (redaction discipline)

Two-copy format is canon. **Never collate keeper material into a player document.**

- **Keeper-only** (bind only in the Keeper's Binder or a keeper file): the Genii /
  Hoffan / Brotherhood packages, Annex B, the Confederation, Divine Work
  timetables, sealed squalls, ⚑ keeper margins, embargoed names, the Response List,
  the Minutes pipeline internals, design notes.
- **Player-facing / clean:** SO-4 (Ledger of Peoples player leaves), SO-5 (Wraith),
  SO-1.2 roster (drop the Dionysus keeper note), the Atlantis Inventory, Governance
  bylaws, the redacted letter (bars kept, keeper footnote removed), Letters from
  Pegasus (the signed letter + the on-table choice).
- When producing a player pack, strip ⚑ margins, italic "Keeper's … note" asides,
  and any "held open by the Keeper" spoiler lines.

---

## 8. Reference files (this project)

- `Keeper's Binder — Landis Edition.dc.html` — the master 14-document collation;
  the canonical example of every pattern above.
- `Proposal for Cinco — Landis Fishman.dc.html` — a focused in-fiction package
  (covering letter + two enclosures); the model for single-recipient documents.
- `doc-page.js` — the paged-document shell (do not edit).

When starting a new Council document, open one of these, copy the `<helmet>`, the
`doc-page` mount, the header/footer slots, and the nearest matching section
pattern, then replace the content.

---

## 9. Bundle thumbnail

Bundling with `super_inline_html` requires a splash template in the DC (place it
just before `<helmet>`):

```html
<template id="__bundler_thumbnail" data-bg-color="#2f5d7c">
  <svg viewBox="0 0 1200 800" xmlns="http://www.w3.org/2000/svg">
    <rect width="1200" height="800" fill="#2f5d7c"/>
    <rect x="360" y="200" width="480" height="400" fill="#f7f4ec"/>
    <text x="600" y="430" font-family="Georgia,serif" font-size="230" fill="#2f5d7c" text-anchor="middle">C</text>
    <rect x="565" y="150" width="70" height="70" fill="#2f5d7c" transform="rotate(45 600 185)"/>
  </svg>
</template>
```

---

*Kept for the Keeper. Append-only — correct beneath, never erase. — filed 2026-07-09*
