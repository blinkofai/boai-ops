# QC checklist

What the QC plugin checks on every version before an AM moves it from `quality_check` to `with_client`. Values come from the client's rulebook (`brand/{client}.yaml`). Every check has an id, which the plugin writes on each finding.

**Method**: `auto` = ffprobe/ffmpeg/metadata, `vision` = Claude reads frames, slides and the transcript, `human` = the AM ticks it.
**Severity**: `blocker` stops the asset going to the client, `major` needs a fix or an AM override with a note, `minor` is a note for the editor.

Gaps for you to fill are marked **FILL**.

## 1. Technical (auto)

| ID | Check | Applies to | Severity |
|---|---|---|---|
| TEC-RES | Resolution and aspect ratio match `formats` | all | blocker |
| TEC-FPS | Frame rate is in the allowed list, constant | video | major |
| TEC-CODEC | Video/audio codec and sample rate | video | major |
| TEC-DUR | Duration inside the engagement's range | video | major |
| TEC-LUFS | Integrated loudness within ±tolerance of target; true peak under max | video | major |
| TEC-SILENCE | No unintended silence > 0.7 s (outside the end card) | video | minor |
| TEC-BLACK | No black or flash frames outside fades | video | major |
| TEC-BLANK | No stretch longer than `max_blank_sec` with no text or visual (incl. the opening) | video | major |
| TEC-GLITCH | No transition glitches or export artefacts (dropped frames, jumps) | video | major |
| TEC-FREEZE | No frozen frames > 1.5 s, except the end card | video | minor |
| TEC-FILE | File name matches `{asset code}_v{N}.{ext}`; size under the limit | all | blocker |
| TEC-SLIDES | Slide count, every slide the same size | carousel | major |

## 2. Compliance (vision + human)

| ID | Check | Severity |
|---|---|---|
| CMP-WARN | Standard MF warning present, in the asset's language, legible, on screen long enough (and voiced, if required) | blocker |
| CMP-SCHEME | Scheme-specific disclaimer present when a scheme is named | blocker |
| CMP-RISK | Riskometer present for scheme ads, and it's the current month's | blocker |
| CMP-SOURCE | Every number, ranking or statistic has a source on screen | blocker |
| CMP-FORBID | No forbidden terms (`brand.forbidden_terms`), no return promises | blocker |
| CMP-PERF | No past performance unless in the approved format | blocker |
| CMP-SCRIPT | On-screen text and voice-over match the client-approved script word for word | major |
| CMP-SEBIREG | SEBI registration line present (`compliance.sebi_registration`), not shown before its visual | blocker |
| CMP-DISCFMT | Statutory disclaimer on one line, at or above `min_font_pt`, word for word from the latest supplied text; disclaimer slate on carousels and PDFs; none on thumbnails | blocker |
| CMP-ASON | Every number, unit price, riskometer and table has an "as on" date, and it matches the date the client gave for this asset | blocker |
| CMP-LABEL | Riskometer, product label and scheme type are for the same scheme, latest month, only for schemes named; risk text matches the meter; colours untouched | blocker |
| CMP-HEDGE | Growth/return lines are hedged (`brand.unhedged_claims`); no track-record or promise lines | blocker |
| CMP-PERFTBL | Performance table in SEBI format: headers without %, same font weight, footnote symbols distinct, FY-end disclaimer | blocker |
| CMP-CTA | CTA is the approved wording with the full scheme name; search super where `compliance.cta` says | major |
| CMP-IMPLIED | No rising arrows, growth graphs or bar/line charts that aren't backed by data on screen | blocker |
| CMP-COPYSRC | Copy comes only from the approved source (`compliance.copy_source`), not reworded | major |
| CMP-SIGNOFF | **human** AM confirms compliance-sensitive frames | blocker |

## 3. Brand (vision)

| ID | Check | Severity |
|---|---|---|
| BRD-LOGO | Logo present where required, approved lockup, not stretched, clear space kept | major |
| BRD-SCHEME | Scheme name spelled and cased exactly as in `brand.scheme_names` | blocker |
| BRD-COLOUR | Key colours within ΔE tolerance | minor |
| BRD-FONT | Fonts match the rulebook per script | minor |
| BRD-3P | No third-party brand, app or competitor visible unless allowed | major |

## 4. Copy and language (vision)

| ID | Check | Severity |
|---|---|---|
| TXT-SPELL | Spelling and grammar of all on-screen text, including text inside UI mockups and props | major |
| TXT-HINDI | Devanagari renders correctly (conjuncts, matras, nukta), natural phrasing | major |
| TXT-NUM | Numbers match the script and source; Indian formatting (₹, lakh/crore) | blocker |
| TXT-CURRENCY | Currency on screen is ₹ (no $, £, € anywhere, including mockups; no crypto-looking coins) | major |
| TXT-VOMATCH | Every number and amount said in the VO matches the super (₹, value, unit) | blocker |
| TXT-FULLFORM | Abbreviations spelled out on first use (SIP, NFO, ETF, FoF as the rulebook lists) | major |
| TXT-STOCKNUM | Numbers that appear in stock imagery or UI and aren't in the script are blurred or xxxx | major |
| TXT-WORDFORM | Word forms match `brand.word_forms` | minor |
| TXT-LANGRULE | The engagement's language rules hold (which parts stay in English, which are translated) | major |
| TXT-SAFE | Text stays out of the platform safe zones | major |
| TXT-LEGIBLE | Text is on screen long enough to read (≈ 3 words/sec) and large enough | minor |

## 5. Visual quality and sensitivity (vision)

| ID | Check | Severity |
|---|---|---|
| VIS-AIART | AI artefacts: gibberish text, broken hands/faces, melted objects, garbled UI | major |
| VIS-SENSITIVE | Nothing culturally or religiously sensitive for the Indian audience (food, symbols, gestures) | blocker |
| VIS-MAP | India map is the official boundary (J&K, Ladakh, Arunachal) | blocker |
| VIS-FLAG | National symbols used correctly | blocker |
| VIS-PII | No real number plates, phone numbers, faces of real people without rights | major |
| VIS-CONTINUITY | Characters, cars, props stay consistent between shots | minor |

## 6. Delivery (auto + human)

| ID | Check | Severity |
|---|---|---|
| DEL-CHILD | Each child asset (language/adapt) passes the same checks as the parent | blocker |
| DEL-VERSION | Version uploaded is the latest; the previous round's client comments are resolved | major |
| DEL-COMMENTS | **human** Every comment from every earlier round is ticked off one by one on a single consolidated list, not just the latest round | blocker |
| DEL-SOURCE | The source used is the client's final approved file (PDF, script, factsheet month), not an earlier draft | blocker |
| DEL-PACK | Every size, format and variant asked for is present (e.g. 1:1 + 4:5, JPEG/PDF/GIF, co-branded set), GIFs under `gif_max_mb` | major |
| DEL-CHANNEL | Sent the way `delivery` says (e.g. email on the same thread, SharePoint link) | minor |
| DEL-FINAL | **human** AM ticks "watched/read in full" | blocker |

For HDFC, the AM's 2-minute version of all this is `brand/hdfc-delivery-checklist.md`.

## Test cases from the sample video

Run on the HDFC Innovation Fund reel (`WhatsApp Video 2026-10-15 at 10.27.52 (1).mp4`, 60.6 s, 1080×1920, 30 fps). A working plugin should report these:

| Time | ID | Finding |
|---|---|---|
| whole | TEC-LUFS | Integrated loudness −21.2 LUFS, about 7 LU under the −14 target |
| ~24 s | TXT-SPELL | Checkout mockup says "Order successfull!" |
| ~24 s | TXT-CURRENCY | Checkout prices are in $ |
| ~24 s | VIS-SENSITIVE | "Organic Steak" with red meat in the cart |
| ~24 s | BRD-3P | "Google Pay" shown as the payment method |
| ~30–33 s | VIS-AIART | Phone UI garbled ("Flash" broken), QR codes are noise |
| ~40–48 s | CMP-SOURCE | Unicorn ranking (#3) has no source line; the innovation ranking at 0–6 s has one |
| ~44 s | VIS-AIART | Medal turns and the "3" reads mirrored |
| ~42 s | VIS-MAP | 3D India map, boundary needs checking |
| 53–60 s | CMP-WARN | No standard MF warning on the end card *(unless the file is cut)* |
| 53–60 s | CMP-RISK, BRD-LOGO | No riskometer and no HDFC MF logo on the end card |
| 53–60 s | TXT-LEGIBLE | Scheme disclaimer is very small on a 1080-wide frame |

These should pass: the innovation ranking has its source, the scheme disclaimer is present, number plates are blank, the end-card freeze is intentional.

## FILL

- Where the AM signs off when they override a `major`.
- Who (if anyone) can override a `blocker`.
- Any check HDFC's compliance team has asked for that isn't listed here.
