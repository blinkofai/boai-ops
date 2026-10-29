-- Phase 3 pulled forward: WhatsApp + Outlook capture, who-is-who, workstreams
-- and auto-QC of files posted in tracked chats. Feeds the live dashboard.

create type chat_feed    as enum ('pipeline', 'brief_only');
create type party_side   as enum ('team', 'client', 'vendor', 'partner', 'other');
create type stream_state as enum ('waiting_on_us', 'waiting_on_client', 'in_progress', 'done', 'on_hold');
create type qc_verdict   as enum ('pass', 'fix', 'fail', 'error');
create type draft_status as enum ('pending', 'sent', 'dismissed');

-- ───────────────────────── Chats ─────────────────────────

-- whatsapp_groups now holds every tracked chat, groups and 1:1s alike.
-- Rows come from config/whatsapp-tracking.yaml (scripts/sync-config.ts).
alter table whatsapp_groups
  add column is_group      boolean not null default true,
  add column tracked       boolean not null default false,
  add column feed          chat_feed,
  add column engagement_id uuid references engagements (id),
  add column active        boolean not null default true;

-- ───────────────────────── Who is who ─────────────────────────

-- One row per handle: a phone number, a WhatsApp @lid alias or an email
-- address. A person with an old number or a lid alias has several rows with
-- the same display_name. Rows come from config/people.yaml.
create table identities (
  id           uuid primary key default gen_random_uuid(),
  handle       text not null unique,            -- digits only for WhatsApp, lowercase for email
  display_name text not null,
  side         party_side not null,
  client_id    uuid references clients (id),
  person_id    uuid references people (id),     -- set once the team member has a login
  contact_id   uuid references contacts (id),
  role         text,
  note         text
);

-- ───────────────────────── Workstreams ─────────────────────────

-- A piece of client work as it shows up in conversations ("WB Birthday
-- Flight", "Intangles InCert film"). Claude groups messages into these; an AM
-- later links each one to the brief and assets logged in the app.
create table workstreams (
  id               uuid primary key default gen_random_uuid(),
  client_id        uuid references clients (id),
  engagement_id    uuid references engagements (id),
  title            text not null,
  summary          text,
  state            stream_state not null default 'in_progress',
  next_action      text,
  waiting_since    timestamptz,                 -- when the ball last changed sides
  last_activity_at timestamptz not null default now(),
  brief_id         uuid references briefs (id),
  asset_id         uuid references assets (id),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index workstreams_activity_idx on workstreams (last_activity_at desc);

-- ───────────────────────── Messages ─────────────────────────

alter table messages
  add column chat_id       text,                -- WhatsApp chat JID or Outlook conversationId
  add column identity_id   uuid references identities (id),
  add column from_team     boolean,
  add column media_type    text,                -- image, video, document, audio
  add column media_name    text,
  add column workstream_id uuid references workstreams (id);

create index messages_sent_idx       on messages (sent_at desc);
create index messages_chat_idx       on messages (chat_id, sent_at);
create index messages_unclassified   on messages (sent_at) where classified_at is null;

-- ───────────────────────── QC ─────────────────────────

-- One automatic QC run per file posted in a tracked chat.
create table qc_runs (
  id              uuid primary key default gen_random_uuid(),
  message_id      uuid not null references messages (id) on delete cascade,
  workstream_id   uuid references workstreams (id),
  asset_id        uuid references assets (id),
  client_id       uuid references clients (id),
  file_name       text not null,
  rulebook        text,                         -- e.g. "hdfc v0.2"; null when the client has none
  verdict         qc_verdict not null,
  blockers        int not null default 0,
  majors          int not null default 0,
  minors          int not null default 0,
  human_checks    int not null default 0,
  findings        jsonb not null default '[]',  -- [{severity, check, where, finding, fix}]
  tech            jsonb not null default '{}',  -- ffprobe / image metadata
  report_md       text,
  draft_message   text,                         -- for the editor, sent only after an AM approves
  draft_status    draft_status,
  created_at      timestamptz not null default now(),
  unique (message_id)
);

create index qc_runs_created_idx on qc_runs (created_at desc);

-- ───────────────────────── Sync cursors ─────────────────────────

-- Where each importer left off (bridge rowid, Graph delta link).
create table sync_state (
  source     text primary key,                  -- 'whatsapp', 'outlook'
  cursor     text,
  updated_at timestamptz not null default now()
);

-- ───────────────────────── Security & realtime ─────────────────────────

do $$
declare t text;
begin
  foreach t in array array['identities', 'workstreams', 'qc_runs', 'sync_state'] loop
    execute format('alter table %I enable row level security', t);
    execute format(
      'create policy staff_all on %I for all to authenticated
         using (my_role() in (''founder'',''account_manager''))
         with check (my_role() in (''founder'',''account_manager''))', t);
  end loop;
end $$;

-- The dashboard subscribes to these.
alter publication supabase_realtime add table messages, workstreams, qc_runs;
