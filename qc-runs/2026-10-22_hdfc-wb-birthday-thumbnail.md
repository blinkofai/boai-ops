# QC run: HDFC Weekend Bytes thumbnail, "Every Birthday is a Portfolio Check-in!"

| | |
|---|---|
| File | `678 X 528.png` (308 KB), Rohith, Editors group, 22 Oct 11:35. Also sent as a JPEG (pixel-identical apart from compression) |
| Asset | WB "Birthday Flight" thumbnail (no asset code yet) |
| Format | 679×529 PNG, sRGB, 8-bit with alpha |
| Spec | 678×528 (Sagar, Editors 11:07) + new WB thumbnail template (Padma, Editors 11:56) |
| Rulebook | `brand/hdfc.yaml` v0.2 |
| Run | 2026-10-22, metadata via ImageMagick, visual checks on the full image + 2.5–6× crops |
| **Result** | **FIX BEFORE SENDING: 0 blockers, 2 majors, 3 minors, 3 checks need a human** |

## Majors

| Where | Check | Finding | Fix |
|---|---|---|---|
| whole file | TEC-SIZE | **679×529, not 678×528.** The extra row and column, plus the top row, are semi-transparent (1,885 px with alpha < 100%): the artboard was a fraction of a pixel off, so the edges came out soft | Set the artboard to exactly 678×528 and export without transparency (flatten), PNG or JPG |
| phone screen | CMP-IMPLIED (`copy_source.implied_return_visuals: never`) | The phone shows a **rising chart**. HDFC rejected growth graphs without data on 07/05 and 01/10, and this WB was already flagged for a "promising" line (19/10) | Replace the screen with a neutral UI (a portfolio list, a pie or donut only) or blur it |

## Minors

| Where | Check | Finding |
|---|---|---|
| bottom right | TXT-LEGIBLE | The SEBI line is ~11 px tall at 678 wide. If HDFC shows thumbnails at ~360 px wide (as on their WB listing page), that's ~6 px: present, but not readable |
| top 150 px | VIS-LAYOUT | Large empty dark area above "HDFC MF". Fine if it's deliberate crop room; otherwise move the title block up or the scene down |
| — | TEC-FILE | File name `678 X 528.png` doesn't follow `{asset code}_v{N}`. Expected until assets go through the app |

## Needs a human

| Check | Why |
|---|---|
| TXT-TITLE | "Every Birthday is a Portfolio Check-in!" must match the title in the **compliance-approved** WB PDF word for word. I don't have the PDF |
| Rulebook conflict | `hdfc.yaml` says thumbnails are exempt from the SEBI line and carry no disclaimers (22/04). Padma's new template asks for the AI disclaimer and SEBI number in a box. The template is newer, so I passed it, but confirm and I'll update the rulebook |
| Display crop | HDFC's WB listing page shows cards at ~1.66:1; 678×528 is 1.28:1. If the site crops to fit, the SEBI box at the bottom gets cut. Check where this size is used |

## Passed

Template (Padma 11:56): product name "HDFC MF" ✓, illustration ✓, WB title ✓, AI disclaimer ✓, SEBI Reg. No. in a box ✓, no logo ✓, no website ✓ ·
SEBI number `MF/044/00/6` matches the earlier WB thumbnails · Spelling and casing clean · No forbidden terms · No third-party brands · AI art: hands, fingers, glasses, candles and the phone hold up at 2.5× · Colour profile sRGB.

## Rulebook gaps that limited this run

`formats.thumbnail` (no size/type rules yet; add 678×528), the thumbnail exception for the AI disclaimer and SEBI box, the approved WB title source.
