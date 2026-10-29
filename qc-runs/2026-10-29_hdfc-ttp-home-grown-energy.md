# QC run: HDFC TTP video, "Widening India's Energy Base"

| | |
|---|---|
| File | `WhatsApp Video 2026-10-28 at 22.23.17.mp4` (15.9 MB) |
| Asset | TTP 27 Oct 2026, "India's Push for Home-Grown Energy Gathers Pace" (no asset code yet) |
| Source | `India's Push for Home-Grown Energy Gathers Pace.pdf` (TTP article, 27 Oct 2026, 2 pages) |
| Format | 480×864, H.264, 30 fps constant, AAC 48 kHz stereo, 75.37 s |
| Rulebook | `brand/hdfc.yaml` v0.2, engagement `TTP` |
| Run | 2026-10-29. ffprobe, ebur128, blackdetect, freezedetect, silencedetect. Vision on 1 fps frames and 2–2.5× crops. No VO transcript |
| **Result** | **FIX BEFORE SENDING: 0 blockers, 1 major, 4 minors, 5 checks need a human** (SEBI major withdrawn 29/10) |

## Client feedback (29 Oct), after this run

HDFC sent two comments. The sources comment is a QC miss. The 55% comment is a client change: the video matched the article.

| Time | Check | Client comment | QC miss? | Fix |
|---|---|---|---|---|
| 17–19 s | TXT-NUM | "This will be 55%" on the subline "50% of installed power capacity from non-fossil sources" | No. The 2030 target is 50%, and the article says so ("crossed half … five years ahead of the 2030 target"). HDFC wants the current figure (55%, Sept 2026) | Change the figure, but do not put 55% under the "2030 target" heading as is: it then reads as if the target is 55%. See the note below |
| 68–75 s | CMP-COPYSRC, CMP-DISCFMT | "The sources are wrong" | QC passed a shortened list because it covered the numbers in the video. The rulebook says copy word for word | Replace the sources line with the article's line, word for word (below) |

Sources line from the article:

> Sources: MoSPI, CEA, CMIE, PPAC, Ministry of Power, Ministry of New and Renewable Energy, Ministry of Petroleum and Natural Gas, BloombergNEF and other publicly available information.

The video had: "Sources: CEA, MNRE, Ministry of Power, publicly available information."

Note on the 55% change: the heading says "Crossing the 2030 target", and the timeline says "Crossed 50%" at 2025. If only the subline changes to 55%, the screen says the target is 55%, which is wrong. Suggested subline: "55% of installed power capacity from non-fossil sources, Sept 2026" (date chip as on the other screens). Keep "Crossed 50%" on the timeline. Ask Padma to confirm this wording with HDFC.

Rulebook: `compliance.data_claims` now has `sources_line` and `current_value_over_milestone` (29/10).

## Majors

| Time | Check | Finding | Fix |
|---|---|---|---|
| ~~8 s – end~~ | ~~CMP-SEBIREG~~ | **Withdrawn (29/10).** The rule is: SEBI line for the first 5 s, not on the title frame, not for the full video, not on the end disclaimer. The video shows it from 2 s to 7.6 s (5.6 s), after the title card. **Pass** | None |
| whole | TEC-LUFS | Integrated loudness −14.6 LUFS (pass, target −14 ±2). True peak −0.5 dBTP, above the −1 dBTP maximum | Put a limiter at −1 dBTP on the master. Measure again on the master file: the WhatsApp encode can change the peak |

## Minors

| Time | Check | Finding |
|---|---|---|
| 0–2.1 s | TEC-SILENCE | 2.1 s of silence (below −45 dB) at the start, on the title card. No VO and no music. On Reels, this costs the first 2 seconds |
| whole | TEC-DUR | 75.37 s. The TTP range is 45–75 s (`TODO(confirm)`), so the video is 0.4 s over. Probably OK, but the range is not confirmed |
| 29.8–31.8 s | TEC-FREEZE | The 88% chart holds still for 2.0 s. It looks intentional (the VO continues). No fix needed if the hold is planned |
| 68–75 s | TXT-LEGIBLE | The end card has about 120 words for 7.2 s. At 3 words/s, a viewer needs about 40 s to read it. This is usual for MF disclaimers, but tell the editor |

## Needs a human

| Check | Why |
|---|---|
| TEC-RES, TEC-FILE | This file is a WhatsApp copy at 480×864. Check the master is 1080×1920 and has a correct file name. Run TEC-LUFS again on the master |
| CMP-SCRIPT, TXT-VOMATCH | No transcript was made (no Whisper on this machine). Listen to the VO and check each number against the supers: 55%, 50%, 5 years, 31%, 11%, 88%, 271 GW, ₹1.86 trillion, 135 GW, March 2033 |
| CMP-WARN (voice) | The standard warning is on screen (68–75 s). The rulebook does not say if TTP must voice it (`voice_over: null`). Check the VO and confirm with HDFC |
| CMP-DISCFMT | The end card disclaimer matches the article PDF word for word, with one change: the video adds "are as on 27th October, 2026 and". Confirm that this is HDFC's approved TTP video wording |
| CMP-SOURCE | The video shows numbers on 9 screens but gives sources only on the end card ("Sources: CEA, MNRE, Ministry of Power, publicly available information"). The rulebook wants a source on screen for every number. Confirm that an end-card source line is the TTP standard |

## Checked against the article

Each number on screen matches the PDF.

| Time | On screen | Article | Result |
|---|---|---|---|
| 9–16 s | 55% non-fossil sources, of India's installed power capacity, Sept 2026 | 55% by September 2026 | ✓ |
| 17–19 s | Crossed 50% in 2025, 2030 target, 5 years ahead of schedule | crossed half in 2025, five years ahead of the 2030 target | ✓ |
| 20–25 s | Solar 31%, wind 11% of installed power capacity, Sept 2026 | solar 31%, wind 11%, September 2026 | ✓ |
| 26–31 s | 88% of power capacity added in FY26, bar chart FY15–FY26 | 88% in FY26. Chart: 9, 23, 64, 69, 71, 65, 63, 89, 92, 71, 86, 88 | ✓ all 12 bars match |
| 36–40 s | Record high peak power demand 271 GW, May 2026 | record 271 GW in May 2026 | ✓ |
| 41–45 s | Energy needs: manufacturing, air conditioning, electric vehicles | manufacturing, air conditioners, EVs | ✓ |
| 47–52 s | Approved Sept 2026, ₹1.86 trillion for transmission networks, Green Energy Corridor Phase III | ₹1.86 trillion, September 2026, third phase of the Green Energy Corridor | ✓ |
| 53–59 s | 135 GW of renewable capacity connected, by March 2033 | to connect 135 GW by March 2033 | ✓ (see note) |
| 68–75 s | "as on 27th October, 2026" | article dated 27 Oct 2026 | ✓ CMP-ASON |

Note on 53–59 s: "135 GW of renewable capacity connected" can read as done. The "by March 2033" chip comes in 1 s later. Optional: change it to "to be connected".

Note on TXT-NUM: the article uses "₹1.86 trillion", so the super is correct under CMP-COPYSRC. The Indian form is "₹1.86 lakh crore". Keep the article's form unless HDFC asks.

## Passed

- **Compliance:** standard MF warning on the end card, word for word, 7 s. Disclaimer body matches the PDF apart from the "as on" line. No scheme named, so no riskometer and no scheme disclaimer needed. No forbidden terms. No return or growth claims. The bar chart has its data labels, so CMP-IMPLIED passes.
- **Brand:** HDFC MF logo and Talking Point badge on every frame, end card included.
- **Copy:** spelling and casing are clean on all supers. Supers checked: "Did you know India", "By September 2026", "Crossing the 2030 target", "At the same time power demand", "Driven by growing energy needs", "To support this shift", "As energy demand grows", "Expanding renewables / Strengthening the grid", "Building storage", "Key to India's energy security". All amounts use ₹, and no $, £ or € appears.
- **Visuals:** the EV has no visible badge, and the AC unit has no brand. The charger screen is soft, but not garbled. No India map, flag or sensitive imagery.
- **Technical:** 30 fps constant, H.264, AAC 48 kHz. No black frames. Silence at 67.2–68.8 s is at the end-card transition. The freeze from 68.2 s is the end card.

## Rulebook gaps that limited this run

- `standard_warning.video.min_seconds` and `voice_over` (FILL).
- `sebi_registration.text` (FILL): this run used `MF/044/00/6` from the article footer.
- The full-video vs end-card rule for the SEBI line on TTP.
- `engagements.TTP.duration_sec` is `TODO(confirm)`.
- Whether an end-card source line meets `data_claims.source_required` for TTP.
