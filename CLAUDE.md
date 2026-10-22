# Blink of AI Ops

This repo holds the ops system and client delivery portal for Blink of AI. Blink of AI is a creative studio. It makes videos, statics and carousels, mostly for AMCs such as HDFC.

The full spec is in `docs/SPEC.md`. Read it before you start a phase.

## Writing style

Write all output in ASD-STE100 (Simplified Technical English), at about 80% strictness. This applies to chat replies, docs, QC runs, commit messages and code comments.

Follow these rules:
- Keep sentences short. Use a maximum of 20 words in an instruction and 25 words in a description.
- Put one instruction in one sentence. Put one topic in one paragraph.
- Use the active voice. Say who or what does the action.
- Write instructions in the imperative: "Run the migration", not "The migration should be run".
- Use one word for one meaning. If you call it an "asset", do not call it a "deliverable" later.
- Use simple, common verbs: "use", "make", "start", "stop", "show", "check". Do not use "utilize", "leverage", "facilitate".
- Do not use a verb in its "-ing" form as a noun or after "when": write "when you upload", not "when uploading".
- Do not use filler, hedges or praise ("basically", "just", "great question").
- Use lists and tables for steps, checks and comparisons.

The 20% that is relaxed:
- Use technical names, project terms and code identifiers as they are (`retainer_weeks`, "adapt", "riskometer"). You do not need the STE dictionary for these.
- Use a longer sentence if a split makes the meaning less clear.
- Use the passive voice if the actor is not known or not important.
- Use a natural tone in chat. Do not make it sound like a maintenance manual.

## Repo contents

| Path | Contents |
|---|---|
| `docs/SPEC.md` | Technical spec (v1): users, stack, domain rules, build phases |
| `docs/ops-blueprint.html` | Visual overview of the system |
| `supabase/migrations/` | SQL migrations. These are the source of truth for the schema |
| `brand/qc-checklist.md` | The checks the QC plugin does on each version |
| `brand/{client}.yaml` | QC rulebook for each client (for example `brand/hdfc.yaml`) |
| `brand/hdfc-delivery-checklist.md` | The AM's pre-delivery checklist for HDFC |
| `qc-runs/` | QC run reports. File name: `{YYYY-MM-DD}_{client}-{short-name}.md` |
| `config/people.yaml` | WhatsApp numbers and ids for team, clients and vendors |
| `config/whatsapp-tracking.yaml` | The WhatsApp chats that the bridge logs |

The app code (`apps/web/`, `services/`) does not exist yet. SPEC §4 gives the target layout.

## Key facts

- The unit of work is the **asset**. Adapts and translations are child assets (`parent_asset_id`). Each child asset has its own `billable` flag.
- Retainers are billed per week **delivered**, through `retainer_weeks`. HDFC TTP is ₹45k/week. Weekend Bytes (WB) is ₹64k/week.
- Roles: `founder`, `account_manager`, `editor`. The founders are Sagar and Sandeep. The account managers (AMs) are Padma and Tejitha. `config/people.yaml` has the full team.
- Domains: `ops.blinkofai.io` (team) and `deliver.blinkofai.io` (clients).

## Conventions

- Change the schema only in `supabase/migrations/`. Do not change tables in the Supabase dashboard. Add a new migration.
- Editors read assets through the `editor_assets` view. They change status only through `editor_set_status()`. Do not show `price`, `billing` or `invoice_id` to editors.
- Portal routes check the client id on the server. Do not trust a client id from the browser.
- Code makes asset codes and file names (SPEC §5). Users do not type them.
- Put Claude API calls in `apps/web/lib/ai/`. Validate their structured output with zod.
- Keep secrets in `.env.local` or platform secrets. Do not put secrets in the repo.
- In config and rulebooks, mark a gap with `FILL` and a value that needs a check with `TODO(confirm)`.
