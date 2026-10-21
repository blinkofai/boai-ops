# HDFC pre-delivery checklist

Tick every box before an HDFC asset leaves BOAI. Every item is an error Khushi caught in review between March and October 2026, most of them more than once. The QC plugin checks the same things automatically (IDs in brackets, values in `brand/hdfc.yaml`); this list is for the AM who watches the final file in full.

One unticked box means the asset doesn't go out.

## Before you open the file

- [ ] I'm working from HDFC's **final approved** source (compliance-approved PDF/Word, the script, the factsheet month they named), not an earlier draft. *(DEL-SOURCE)*
- [ ] I have **one consolidated list** of every comment from every round, and each one is ticked. *(DEL-COMMENTS)*
- [ ] I know the **"as on" date** HDFC gave for this asset, in writing. *(CMP-ASON)*

## Compliance (blockers)

- [ ] **SEBI registration line** is on it (video, static, carousel, GIF, PDF; not thumbnails) and doesn't appear before its visual. *(CMP-SEBIREG)*
- [ ] **MF disclaimer** is word for word from the latest version HDFC sent, on **one line**, **8pt or larger** at delivered size. *(CMP-DISCFMT)*
- [ ] Carousels and PDFs end with a **disclaimer slate**. Statics carry the 14-word disclaimer with the riskometer. Thumbnails carry none.
- [ ] **Riskometer, product label and scheme type** are all for the **same scheme**, the latest month, with the release date. Only schemes named in the asset get a label. The risk level in the text matches the meter, and the meter's colours are untouched. *(CMP-LABEL)*
- [ ] Every number, unit price, riskometer and table has an **"as on" date**, and it's the date HDFC gave. *(CMP-ASON)*
- [ ] **Performance tables** are in SEBI format: "Returns / Benchmark returns / Additional returns" with no % in the header, the same font weight throughout, a different symbol for each footnote (* and ^), and the FY-end disclaimer. *(CMP-PERFTBL)*
- [ ] **No banned or unhedged wording:** no "proven", "greatly increased", "come invest with confidence", "strong", "guaranteed", and no years-of-track-record lines. Growth is "may grow" or "potential", and nothing reads as a promise. *(CMP-FORBID, CMP-HEDGE)*
- [ ] **No implied returns:** no rising arrows, and no growth graph or bar/line chart without real data on screen. *(CMP-IMPLIED)*
- [ ] SEBI-mandate posts use **only the emailer's wording**, not reordered or paraphrased. *(CMP-COPYSRC)*

## Names, numbers, words

- [ ] **Fund name** is exactly as in the factsheet, the same everywhere, in one weight (ETF vs index fund correct; "HDFC Nifty Small Cap 250 ETF" fully bold). *(BRD-SCHEME)*
- [ ] **₹** on every amount, on screen and in the VO. SIP performance is in lakhs. No coins that look like crypto. *(TXT-CURRENCY)*
- [ ] **Every number in the VO matches the super:** amount, unit price, date. *(TXT-VOMATCH)*
- [ ] **SIP spelled out** (Systematic Investment Plan) on first use. Same for NFO, ETF and FoF. *(TXT-FULLFORM)*
- [ ] Numbers in stock images or UI that aren't in the script are **blurred or xxxx**. *(TXT-STOCKNUM)*
- [ ] Spelling checked, including "Large Cap" and "Long term" as two words and "Performance" as one. *(TXT-SPELL, TXT-WORDFORM)*
- [ ] **CTA:** "Consider investing in {full scheme name}", with the search super and search icon on the second-last screen and the end slate. *(CMP-CTA)*

## Languages

- [ ] **Regional fund videos:** only the VO changes. Supers, riskometer, product label and end slates stay in English.
- [ ] **Hindi PDFs:** body text fully Hindi, disclaimer in English.
- [ ] **Weekend Bytes Hindi video:** MF disclaimer shown *and* voiced in Hindi, and the full illustration disclaimer copied from the PDF.
- [ ] Every translation has been **approved by a native reviewer** before sending.

## Watch it in full

- [ ] Watched or read **end to end** at delivery size, with sound. *(DEL-FINAL)*
- [ ] Nothing on screen is blank for more than 2 s, including the opening seconds. *(TEC-BLANK)*
- [ ] No transition glitches or export artefacts. Re-watch the exported file, not the timeline. *(TEC-GLITCH)*
- [ ] VO is clear and well paced (watch for "debt" being swallowed), and the music suits the brief.

## Send

- [ ] Every size and format asked for is there (1:1 and 4:5, JPEG + PDF, GIF under 10 MB for carousels or anything over 4 images for X), plus the HDFC Securities co-branded set if needed. *(DEL-PACK)*
- [ ] Files are **named correctly**, and the link folder holds only the final files.
- [ ] Sent on the **same email thread**, with a **SharePoint** link (HDFC can't open Google Drive), and Tejitha and Padma cc'd. *(DEL-CHANNEL)*
