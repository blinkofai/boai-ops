# QC run: HDFC Innovation Fund reel (sample)

| | |
|---|---|
| File | `WhatsApp Video 2026-10-15 at 10.27.52 (1).mp4` (105.5 MB) |
| Asset | not in the system yet (no asset code), engagement unknown |
| Format | 60.6 s · 1080×1920 · 30 fps CFR · H.264 / AAC 48 kHz · Hindi |
| Rulebook | `brand/hdfc.yaml` v0.1 (draft, gaps open) |
| Run | 2026-10-16, technical checks by script, visual checks on 1 fps frames + crops |
| **Result** | **FAIL: 5 blockers, 8 majors, 5 minors, 4 checks need a human** |

## Blockers

| Time | Check | Finding | Fix |
|---|---|---|---|
| 51–60 s | CMP-WARN | No standard MF warning ("Mutual Fund investments are subject to market risks…") anywhere in the video, in any language | Add HDFC's approved Hindi warning to the end card (wording/duration: rulebook gap) |
| 51–60 s | CMP-RISK | No riskometer on a scheme-specific ad | Add the current month's riskometer for HDFC Innovation Fund |
| 39–46 s | CMP-SOURCE | "यूनिकॉर्न की संख्या में" #3 ranking has no source line (the innovation ranking at 1–5 s does have one) | Add a source, e.g. the report it comes from, plus year |
| 1–5 s | TXT-NUM | "#66 भारत 2015 में": as far as I know India ranked 81st in GII 2015 and 66th in GII 2016. **Verify against the source** | Correct the year or the rank; ▲28 changes if the rank does |
| 24–26 s, 31–32 s | VIS-SENSITIVE | Checkout mockup shows "Organic Steak" with red meat in the cart | Replace the item (e.g. vegetables, groceries) |

## Majors

| Time | Check | Finding |
|---|---|---|
| whole | TEC-LUFS | Integrated loudness −21.2 LUFS vs −14 target (±2); true peak −4.0 dBTP is fine. Raise by ~7 dB |
| 51–60 s | BRD-LOGO | No HDFC MF logo anywhere; end card is title + disclaimer only |
| 24–26 s | TXT-SPELL | "Order successfull!" (checkout mockup) |
| 24–26 s | TXT-CURRENCY | Prices in **$** ($24.00, $18.00…) |
| 25 s | TXT-CURRENCY (locale) | Address "4517 washington ave. manchester, kentucky": a US UI-kit placeholder in an Indian ad |
| 24 s | BRD-3P | "Google Pay" shown as the payment method (third-party brand not on the allowed list) |
| 14–19 s, 31–32 s | VIS-AIART | Phone UI text garbled ("Flash" broken, bottom bar mangled); QR codes are noise; small "EV charging only" signs are unreadable |
| 6–15 s | LANG-MIXED | English captions in a Hindi video: "Software Update", "UPDATING…", "SOFTWARE UPDATED", "YOUR CAR IS NOW SMARTER". Confirm with the AM whether that's intended |

## Minors

| Time | Check | Finding |
|---|---|---|
| 40 s, 43 s | VIS-AIART | Medal spins and the "3" reads mirrored ("Ɛ") on held frames |
| 22–23 s, 26–28 s | VIS-CONTINUITY | The car in the side shots has a different body/roof from the hero car |
| 52–60 s | TXT-LEGIBLE | Scheme disclaimer glyphs are ~20 px tall on a 1080-wide frame, readable but small on a phone |
| 51–53 s | TXT-LEGIBLE | Subtitle and disclaimer type on over ~1 s; fine, end card holds 7 s |
| — | TEC-FILE | File name isn't `{asset code}_v{N}.mp4`. Expected: it hasn't gone through the app |

## Needs a human

| Check | Why |
|---|---|
| VIS-MAP (33–46 s) | 3D India map: check the northern boundary (J&K, Ladakh) against the official map. Frames are too stylised to call |
| CMP-SCRIPT | No approved script supplied, so on-screen text and VO weren't compared |
| CMP-WARN voice-over | No speech-to-text installed here; couldn't tell whether the audio has a VO |
| TEC-DUR | Engagement unknown (TTP? ad hoc?), so no duration rule applied |

## Passed

TEC-RES, TEC-FPS, TEC-CODEC, TEC-BLACK, TEC-SILENCE, TEC-FREEZE (6.8 s freeze is the end card) · CMP-SCHEME (scheme disclaimer present, wording matches rulebook) · CMP-SOURCE for the GII ranking · BRD-SCHEME ("HDFC Innovation Fund" spelled correctly) · CMP-FORBID (no forbidden terms seen) · TXT-SAFE (all text clear of the Reels top/bottom zones) · TXT-HINDI (Devanagari renders cleanly) · VIS-PII (number plates blank) · glass car badge is a generic lightning bolt, not a real brand.

## Rulebook gaps that limited this run

`standard_warning.text.hi`, `standard_warning.video.min_seconds`, `standard_warning.video.voice_over`, `brand.logo.files`, `riskometer.image_source`, engagement durations.
