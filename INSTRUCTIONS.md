# INSTRUCTIONS — Bring the Site & Knowledge Current

*Repo: github:gignsky/council · Site: frosted-mug.com (also served at fuckinphilosophers.com)*
*Chapter: Handbook handwritten-review → v3. Prepared for the update after this session.*

This document is the hand-off. It records everything decided or learned since the last data
dump (the project-knowledge upload) and tells you exactly what to change on the site, in the
repo, and in the canonical context files. Nothing here needs my presence to apply.

---

## 0. TL;DR — what happened this chapter

You handwrote margin notes on the printed Handbook; I read them, produced a **Review Edition**
(rich diff + 14 design proposals), you returned a **41-comment PR-style review**, and I cut
**Handbook v3** — clean, black-and-white, print-ready — now with the designer. This package
also contains the review tools, the archived review, the deferred **Keeper's Papers**, campaign
notes, a minutes template, and the two web files with the new tagline applied.

---

## 1. Canon decisions (fold into COUNCIL_MASTER_CONTEXT / CAMPAIGN_KNOWLEDGE)

**Identity & framing**
- **Tagline (official):** *"The pen is mightier than the die."* Replaces "played with words, not dice" everywhere.
- **Authorship (canon):** Sir **Landis Fishman** is the sole author of the Handbook and of all
  content on the site. Add the byline "by Sir Landis Fishman."
- **The Keeper is Landis (canon).** Proposed as the Book I epigraph (John 1:1 pastiche, Landis's words):
  > *In the beginning was the Keeper, and the Keeper was with Landis, and the Keeper was Landis.
  > The same was in the beginning with Landis, in the homely heart of he who was with the same.*
  ◻ Awaiting final yes to set it as the epigraph.
- **The Creed** (Landis's, verbatim) is now **canon-optional** — spoken at Session Zero only if
  truly held; none is bound to a creed they do not hold. Full text lives in the Handbook (§5.1) and below.
- **Handbook doctrine:** this book is the **generic system**. Each table raises *its own* handbook
  from it — exactly as the Standing Orders do for the Council of Un. A short **per-campaign preface**
  is planned (◻ to draft).

**Rules ratified in v3** (see CHANGELOG_v3.md for exact wording)
- Watch **decoupled from the session**: a watch is *a unit of the tide, not of table time*; a
  session may pass one watch or several (sleep passes one; long travel may pass more).
- **Favor owed** = keeper names the price now, seals it, hands it to the crew to hold *unread*
  until called, and only then is it opened.
- **Footholds** — the graspable Works a Divine Work throws off; marked on the card with a small
  cursive **ℓ**. (Renamed from "dependent visible works.")
- **Weatherglass** — earned advance-notice of a coming turn; the squall's twin.
- **Trigger Points** — Divine Works run on armed clocks (Trigger / Clock / Break); non-step-able
  until armed. Full engine in the Keeper's Papers.
- **Reversion** — a Work left unheld slips back one watch per watch; a deputy's hold stays the
  slip; a Directive keeps the hand at the task.
- **The Fasces** — whether the final seat is fixed or rotates is the table's choice at Session Zero;
  the veto is *not* general (it would filibuster) — reserve it for honorary/keeper/guest seats only.
- **Absence Beyond Reach** rewritten: the need is met *rough* by whoever's present; mark such Works,
  they may be worth re-doing when the head returns.
- **Between-session Work Orders** turn no extra watch; they come due as of the next watch the tide brings.
- **Grace is bounded by nature:** the maker's free hand cannot make a people other than what they are.
- Minor: §3.4 lesser Works may carry squalls at keeper discretion; §3.5 truth is one sentence;
  "always → still" delivers its squall; §3.7 "or a season" + hidden countdown; letterhead = "testimony is king."

---

## 2. Website — exact changes

**Already applied in this package** (`web/`), ready to commit:
- `24_Council_Landing_Page_dc.html` — `<title>` and hero tagline → *"The pen is mightier than the die."*
- `21_The_Handbook_Web_Hub_dc.html` — strap tagline → *"The pen is mightier than the die."*

**Still to do on the site** (recommended, not yet applied to avoid touching layout blind):
1. **Byline.** Add under the title on the landing + hub: a small line `by Sir Landis Fishman`.
   Suggested markup to drop under each title block:
   ```html
   <div style="text-align:center;font-style:italic;font-size:13px;letter-spacing:1px;margin-top:4px">by Sir Landis Fishman</div>
   ```
2. **Link the new edition.** Point the "handbook" link/button at the v3 print edition once the
   designer's pass is done (this package ships the interim `handbook/Council_Handbook_v3_PRINT_bw.pdf`).
3. **Author/colophon.** Anywhere the site names a maker, credit Sir Landis Fishman.
4. **(Optional) Reviews archive.** If you want the review loop public, publish `reviews/` — the
   Markdown renders natively on GitHub and reads as an editorial trail.

*Fonts:* Cartograph/artifacts swap is still deferred to the design tool; taglines above are text-only and font-safe.

---

## 3. Repo layout — where these files go

Suggested drop into `gignsky/council`:

```
/handbook/        Council_Handbook_v3_PRINT_bw.pdf   (interim, pre-designer)
                  Council_Handbook_Review.pdf         (the annotated review edition)
                  Council_Handbook_RichDiff.html
/keeper/          Keepers_Papers_Divine_Works.md
/campaign/        CAMPAIGN_NOTES_CoU.md
                  Council_Minutes.md                  (running log; append after each session)
/reviews/         2026-07-07-handbook-diff-landis-fishman.md  (+ .json)
                  README.md
/review-tools/    Council_Handbook_Diff_Review.html   (CURRENT review app — PR-style margin comments)
                  Council_Handbook_Review_Workspace.html (superseded card-based app; kept for archive)
CHANGELOG_v3.md
INSTRUCTIONS.md   (this file)
```

---

## 4. The review workflow (now a documented loop)

For future handbook passes:
1. Print/annotate on the reMarkable (colored pen, circle-and-line, export **PDF**).
2. Upload the marked-up PDF and say "read my notes" — colored ink is lifted off the black print.
3. I produce a **Review Edition** (rich diff + proposals).
4. Open `review-tools/Council_Handbook_Diff_Review.html`, comment in the margin, **Export Markdown**.
5. Commit the export to `reviews/` and hand it back; the next clean cut follows.

---

## 5. Open threads (carry to next session)

- ◻ **P2 — Ledger quantification & research tiers.** Hard numbers for Hands/Power (generic, no
  campaign items); **Standing = hidden dial, prose/poetry to the players**, with guidance on
  setting/adjusting. Research tiers to be designed *inside* this.
- ◻ **Trigger-Point default** — confirm hidden-by-default clock (Keeper's Papers §5).
- ◻ **Per-campaign preface** — draft the front-matter that says "each table raises its own handbook."
- ◻ **Book I epigraph** — confirm "The Keeper is Landis."
- ◻ **Proposal renumbering** — reorder proposals into document order in the next Review Edition
  (Landis noted P3 appeared before P1).
- ◻ **The two Landis handouts** — needed to complete the printed Crew's Packet (§5.6).
- ◻ **Taxe's Federation** — draft as a Saga-tier Divine Work (see campaign notes).
- ◻ Give the designer the v3 file (in progress) for the bold→italics/Cartograph pass.

---

## 6. Landis's Creed (canon-optional) — reference copy

> I believe in the power of words.
> No thing is created without them,
> Nor no thing that is not created can be described with them.
> I believe there is Grace in words,
> For the cutting syllable is duller than the sword.
> **Hold Fast!** Hipp Hipp Hurrah!
> And don't forget to: **Tally Hoe!**
> Hurumph! Hurumph! Hurumph!
> — *L.F.*
