# Blink of AI Ops — Technical Spec (v1)

Internal operations system for Blink of AI: every brief and asset, from intake to payment, plus a client delivery portal.
Visual overview: `docs/ops-blueprint.html` (published at https://claude.ai/artifact/WrvuxVjk8nbpCyU6W7xeXP).

## 1. Users

| Role | Who | Can |
|---|---|---|
| founder | Sandeep, the user (tech + accounts) | Everything, including billing |
| account_manager | Padma, Tejita | Everything except changing billing settings |
| editor | 4 editors | See their own assets (no prices), upload versions, move work between `in_production` and `quality_check` |
| client (portal) | Client reviewers | View their own assets' versions, comment, approve, download finals |

## 2. Apps and domains

| Domain | App |
|---|---|
| `ops.blinkofai.io` | Internal app (team) |
| `deliver.blinkofai.io` | Client portal (same Next.js app, separate route group and auth) |

## 3. Stack

- **Next.js** (App Router, TypeScript, Tailwind, shadcn/ui), hosted on Vercel.
- **Supabase**: Postgres, Auth (Google and Microsoft sign-in for staff), Row-Level Security.
- **Cloudflare R2** for files (no egress fees). Uploads go straight from the browser using presigned URLs. Video previews use R2 public-bucket-off plus short-lived signed GET URLs.
- **WhatsApp bridge**: a separate Node service (`services/wa-bridge`, Baileys) on a small always-on VM, for example a GCP e2-small. It writes to Supabase with the service-role key.
- **Jobs**: Vercel Cron or Supabase scheduled functions for the Zoho sync, Outlook sync, message classification and the 8 am brief.
- **Claude**: Claude API for brief parsing, message classification and the daily brief. A custom MCP server (`services/mcp`) gives the team Claude access to the database.

## 4. Repo layout (target)

```
apps/web/                 Next.js app (ops + portal)
  app/(ops)/...           internal routes
  app/(portal)/...        client routes
  lib/db/                 Supabase clients + generated types
  lib/ai/                 Claude calls (parse brief, classify message, daily brief)
services/wa-bridge/       Baileys WhatsApp logger
services/mcp/             MCP server exposing ops tools to Claude
supabase/migrations/      SQL migrations (source of truth for schema)
docs/                     spec, blueprint
```

## 5. Domain rules

- **Asset code**: `{CLIENT}-{ENGAGEMENT}-{YY}W{WW}-{NN}` for retainers (`HDFC-TTP-26W42-01`), `{CLIENT}-{ENGAGEMENT}-{NNN}` otherwise. A child asset appends a suffix: `-HI` (language) or `-A1` (adapt). Codes are generated in the app, never typed by hand.
- **Child assets**: adapts and translations are rows with `parent_asset_id`. `billable` defaults to true, and the AM switches it off when the child is included in the master.
- **Status flow**: see the `asset_status` enum. Waiting-on-client stages are `info_missing`, `script_with_client` and `with_client`. Scripts always need client approval before `ready_to_assign`. AMs always do a `quality_check` before `with_client`.
- **Retainer billing**: one `retainer_weeks` row per week. A month is billed for the weeks **delivered** in it (`weekly_fee × delivered weeks`). TTP is ₹45,000/week and Weekend Bytes ₹64,000/week. The app creates next week's rows every Monday.
- **Per-asset billing**: the price defaults from `rate_card` (video ₹20,000 · carousel ₹8,000 · static ₹3,000) and can be edited per asset.
- **Month end**: the `unbilled_work` view drives draft invoices in Zoho. A founder reviews them before they're sent.
- **File naming**: `{asset code}_v{N}.{ext}`, final: `{asset code}_FINAL.{ext}`. The R2 key is `{client code}/{asset code}/{file name}`.
- **Every change** to an asset's status is logged in `asset_events` by a trigger. The daily brief reads from it.

## 6. Build phases

Each phase ends with something the team uses. Build them in order.

### Phase 1: Asset tracking (weeks 1–2)
1. Scaffold the Next.js app, Supabase project and auth with Google/Microsoft. Seed `people`, `clients`, `engagements`.
2. Apply `supabase/migrations`. Generate TS types.
3. Screens: **Board** (columns = status, filters by client/AM/editor/deadline), **Asset detail** (all fields, grouped as in the blueprint), **New brief** (one brief → many assets, including child assets).
4. **Paste-a-brief**: an AM pastes WhatsApp/email text, Claude returns structured asset drafts (tool use / JSON schema), and the AM confirms. Missing required fields are highlighted.
5. Editor view: "My queue", using the `editor_assets` view and the `editor_set_status` RPC.
6. Retainer weeks: auto-create, and show "brief not received" slots on the board.

### Phase 2: Files and the client portal (weeks 3–4)
1. R2 bucket, presigned upload, version list per asset, automatic naming.
2. Portal auth: magic link to client contacts, scoped to their client (server routes using the service role, checking the client id).
3. Portal: asset list per engagement, version player (video with timecoded comments, carousel with per-slide comments), Approve button, final downloads.
4. Approval moves the asset to `approved` and records who approved it and when.
5. Optional push of finals to the client's OneDrive (Microsoft Graph).

### Phase 3: WhatsApp and email capture (weeks 5–6)
1. `wa-bridge`: Baileys, multi-file auth state on a persistent disk, a dedicated Ops number. On each group message, upsert `whatsapp_groups` and insert into `messages`. Upload media to R2.
2. Group mapping screen: unmapped groups → pick a client.
3. Classifier job: new messages go to Claude, which sets `kind` and `asset_id`. A `brief` creates a draft brief for AM review.
4. Outlook: Microsoft Graph subscription on the shared inbox, written to `messages`.

### Phase 4: Money and intelligence (weeks 7–8)
1. Zoho Invoice sync: invoices and payments become `invoices`. Draft month-end invoices come from `unbilled_work`.
2. 8 am daily brief: a Claude summary of yesterday's `asset_events` and messages, overdue items, `stale_waiting`, unbilled/unpaid work, and editor load. Shown on the dashboard, and optionally posted to Teams.
3. MCP server: tools `find_assets`, `get_asset`, `create_brief`, `update_asset_status`, `search_messages`, `daily_brief`, `unbilled_summary`. Connected to the team's Claude.

## 7. Environment variables

```
NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY
R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET
ANTHROPIC_API_KEY
ZOHO_CLIENT_ID, ZOHO_CLIENT_SECRET, ZOHO_REFRESH_TOKEN, ZOHO_ORG_ID
MS_TENANT_ID, MS_CLIENT_ID, MS_CLIENT_SECRET
```

Never commit these. Use `.env.local` locally and Vercel / VM secrets in production.

## 8. Risks

- **WhatsApp bridge** uses an unofficial client, which breaks WhatsApp's terms and can get the number banned. Use a dedicated number, only read and log (never auto-send), and keep a manual "forward to Ops" fallback.
- **Personal chats** are invisible to the bridge. Team habit: forward briefs to the Ops number.
- **Client IT rules** (AMCs) may require OneDrive delivery. The portal must be able to push finals there.

## 9. Open items
- File volume per month and retention period (sizes the R2 bucket and the cleanup policy).
- Any AMC security or delivery requirements.
