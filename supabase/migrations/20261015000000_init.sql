-- Blink of AI ops: initial schema
-- Unit of work is the asset. See docs/SPEC.md for the domain model.

-- ───────────────────────── Enums ─────────────────────────

create type app_role as enum ('founder', 'account_manager', 'editor');

create type asset_type as enum ('video', 'static', 'carousel');

create type asset_status as enum (
  'brief_logged',
  'info_missing',        -- waiting on client
  'scripting',
  'script_with_client',  -- waiting on client
  'ready_to_assign',
  'in_production',
  'quality_check',       -- AM proofread / check
  'with_client',         -- waiting on client reviewer
  'revising',
  'approved',
  'delivered',
  'invoiced',            -- waiting on payment
  'paid',
  'on_hold',
  'cancelled'
);

create type engagement_kind as enum ('retainer', 'series', 'adhoc');
create type billing_type    as enum ('weekly_retainer', 'per_asset', 'series_fee', 'included');
create type child_kind      as enum ('adapt', 'translation');
create type script_source   as enum ('client', 'in_house');
create type audio_source    as enum ('ai', 'client', 'none');
create type delivery_platform as enum ('portal', 'onedrive', 'google_drive', 'wetransfer', 'email');
create type retainer_week_status as enum ('awaiting_brief', 'in_progress', 'delivered', 'skipped');
create type message_channel as enum ('whatsapp', 'email');
create type message_kind    as enum ('brief', 'feedback', 'approval', 'chat', 'unclassified');

-- ───────────────────────── People & clients ─────────────────────────

create table people (
  id         uuid primary key references auth.users (id) on delete cascade,
  full_name  text not null,
  email      text not null unique,
  phone      text,
  role       app_role not null,
  active     boolean not null default true,
  created_at timestamptz not null default now()
);

create table clients (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  code       text not null unique,          -- short prefix for asset codes, e.g. HDFC
  is_amc     boolean not null default false,
  default_delivery delivery_platform not null default 'portal',
  notes      text,
  active     boolean not null default true,
  created_at timestamptz not null default now()
);

create table contacts (
  id          uuid primary key default gen_random_uuid(),
  client_id   uuid not null references clients (id) on delete cascade,
  full_name   text not null,
  email       text,
  phone       text,
  is_reviewer boolean not null default false,
  created_at  timestamptz not null default now()
);

-- ───────────────────────── Engagements ─────────────────────────

create table engagements (
  id                 uuid primary key default gen_random_uuid(),
  client_id          uuid not null references clients (id),
  name               text not null,             -- "Tuesday Talking Point"
  code               text not null,             -- "TTP"
  kind               engagement_kind not null,
  billing            billing_type not null,
  weekly_fee         numeric(12,2),             -- retainers: 45000 TTP, 64000 Weekend Bytes
  series_fee         numeric(12,2),
  series_asset_count int,
  due_weekday        smallint check (due_weekday between 0 and 6),  -- 0 = Sunday
  account_manager_id uuid references people (id),
  starts_on          date,
  ends_on            date,
  active             boolean not null default true,
  created_at         timestamptz not null default now(),
  unique (client_id, code),
  check (kind <> 'retainer' or weekly_fee is not null)
);

-- One row per retainer delivery week. Billing counts delivered weeks per month.
create table retainer_weeks (
  id            uuid primary key default gen_random_uuid(),
  engagement_id uuid not null references engagements (id) on delete cascade,
  week_start    date not null,                  -- Monday of the week
  due_at        timestamptz,
  status        retainer_week_status not null default 'awaiting_brief',
  delivered_at  timestamptz,
  invoice_id    uuid,                           -- fk added below
  unique (engagement_id, week_start)
);

-- ───────────────────────── Messages (WhatsApp / email) ─────────────────────────

create table whatsapp_groups (
  id         uuid primary key default gen_random_uuid(),
  wa_jid     text not null unique,              -- WhatsApp group id from the bridge
  name       text not null,
  client_id  uuid references clients (id),      -- null until mapped in the app
  mapped_at  timestamptz,
  created_at timestamptz not null default now()
);

create table messages (
  id            uuid primary key default gen_random_uuid(),
  channel       message_channel not null,
  external_id   text not null,                  -- WhatsApp msg id or email Message-ID
  group_id      uuid references whatsapp_groups (id),
  client_id     uuid references clients (id),
  sender_name   text,
  sender_handle text,                           -- phone or email address
  subject       text,
  body          text,
  media_key     text,                           -- storage key of attached media
  sent_at       timestamptz not null,
  kind          message_kind not null default 'unclassified',
  asset_id      uuid,                           -- fk added below
  classified_at timestamptz,
  created_at    timestamptz not null default now(),
  unique (channel, external_id)
);

-- ───────────────────────── Briefs & assets ─────────────────────────

create table briefs (
  id                uuid primary key default gen_random_uuid(),
  client_id         uuid not null references clients (id),
  engagement_id     uuid references engagements (id),
  retainer_week_id  uuid references retainer_weeks (id),
  title             text not null,
  raw_text          text,                       -- brief as received
  source_message_id uuid references messages (id),
  received_at       timestamptz not null default now(),
  logged_by         uuid references people (id),
  created_at        timestamptz not null default now()
);

create table assets (
  id                 uuid primary key default gen_random_uuid(),
  code               text not null unique,      -- HDFC-TTP-26W42-01, child: HDFC-TTP-26W42-01-HI
  brief_id           uuid references briefs (id),
  client_id          uuid not null references clients (id),
  engagement_id      uuid references engagements (id),
  parent_asset_id    uuid references assets (id),
  child_kind         child_kind,
  language           text,                      -- translations

  -- spec
  asset_type         asset_type not null,
  topic              text not null,
  ip_name            text,                      -- set when part of an IP
  style              text,
  format             text,                      -- 9:16, 1:1, 16:9
  dimensions         text,                      -- 1080x1920
  duration_sec       int,
  slide_count        int,
  co_branding        boolean not null default false,

  -- content
  script_source      script_source,
  script_text        text,
  script_approved_at timestamptz,
  creative_brief     text,
  references_list    jsonb not null default '[]',  -- [{label, url}]
  audio              audio_source,
  disclaimers        text,
  remarks            text,

  -- workflow
  deadline           timestamptz,
  account_manager_id uuid references people (id),
  editor_id          uuid references people (id),
  client_reviewer_id uuid references contacts (id),
  status             asset_status not null default 'brief_logged',
  status_changed_at  timestamptz not null default now(),
  current_version    int not null default 0,

  -- delivery & billing
  delivery_platform  delivery_platform,
  delivery_link      text,
  delivered_at       timestamptz,
  billing            billing_type not null default 'per_asset',
  billable           boolean not null default true,
  price              numeric(12,2),             -- defaults from rate_card in the app
  invoice_id         uuid,                      -- fk added below

  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),

  check ((parent_asset_id is null) = (child_kind is null)),
  check (child_kind <> 'translation' or language is not null)
);

create index assets_status_idx   on assets (status);
create index assets_deadline_idx on assets (deadline);
create index assets_editor_idx   on assets (editor_id);
create index assets_am_idx       on assets (account_manager_id);
create index assets_client_idx   on assets (client_id);

create table asset_versions (
  id          uuid primary key default gen_random_uuid(),
  asset_id    uuid not null references assets (id) on delete cascade,
  version_no  int not null,
  is_final    boolean not null default false,
  storage_key text not null,                    -- R2 object key
  file_name   text not null,                    -- HDFC-TTP-26W42-01_v2.mp4
  size_bytes  bigint,
  mime_type   text,
  uploaded_by uuid references people (id),
  uploaded_at timestamptz not null default now(),
  shared_at   timestamptz,                      -- when sent to the client
  unique (asset_id, version_no)
);

-- Client review comments, pinned to a video timecode or carousel slide
create table review_comments (
  id             uuid primary key default gen_random_uuid(),
  version_id     uuid not null references asset_versions (id) on delete cascade,
  author_contact uuid references contacts (id),
  author_person  uuid references people (id),
  body           text not null,
  timecode_sec   numeric(8,2),
  slide_no       int,
  resolved       boolean not null default false,
  created_at     timestamptz not null default now(),
  check ((author_contact is null) <> (author_person is null))
);

-- Append-only activity log; feeds the daily brief
create table asset_events (
  id          bigint generated always as identity primary key,
  asset_id    uuid not null references assets (id) on delete cascade,
  actor_id    uuid references people (id),
  event       text not null,                    -- status_changed, version_uploaded, comment, ...
  from_status asset_status,
  to_status   asset_status,
  payload     jsonb not null default '{}',
  at          timestamptz not null default now()
);

create index asset_events_at_idx on asset_events (at);

-- ───────────────────────── Billing ─────────────────────────

create table rate_card (
  asset_type asset_type primary key,
  price      numeric(12,2) not null
);

insert into rate_card (asset_type, price) values
  ('video', 20000), ('carousel', 8000), ('static', 3000);

create table invoices (
  id              uuid primary key default gen_random_uuid(),
  zoho_invoice_id text unique,
  client_id       uuid not null references clients (id),
  number          text,
  issued_on       date,
  due_on          date,
  total           numeric(12,2),
  status          text,                         -- mirrors Zoho: draft, sent, overdue, paid
  paid_on         date,
  synced_at       timestamptz
);

alter table retainer_weeks add foreign key (invoice_id) references invoices (id);
alter table assets         add foreign key (invoice_id) references invoices (id);
alter table messages       add foreign key (asset_id)   references assets (id);

-- ───────────────────────── Triggers ─────────────────────────

create function touch_asset() returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  if new.status is distinct from old.status then
    new.status_changed_at := now();
    insert into asset_events (asset_id, actor_id, event, from_status, to_status)
    values (new.id, auth.uid(), 'status_changed', old.status, new.status);
  end if;
  return new;
end $$;

create trigger assets_touch before update on assets
for each row execute function touch_asset();

-- ───────────────────────── Views ─────────────────────────

-- Unbilled work for a month: delivered retainer weeks + delivered billable assets
create view unbilled_work as
select e.client_id,
       date_trunc('month', rw.delivered_at)::date as month,
       e.code                                     as item,
       count(*)                                   as qty,
       e.weekly_fee                               as unit_price,
       count(*) * e.weekly_fee                    as amount
from retainer_weeks rw
join engagements e on e.id = rw.engagement_id
where rw.status = 'delivered' and rw.invoice_id is null
group by e.client_id, month, e.code, e.weekly_fee
union all
select a.client_id,
       date_trunc('month', a.delivered_at)::date,
       a.asset_type::text,
       count(*),
       null::numeric,
       sum(a.price)
from assets a
where a.billing = 'per_asset' and a.billable
  and a.delivered_at is not null and a.invoice_id is null
group by a.client_id, date_trunc('month', a.delivered_at)::date, a.asset_type;

-- Assets waiting on the client longer than their limit
create view stale_waiting as
select a.*, now() - a.status_changed_at as waiting_for
from assets a
where (a.status in ('info_missing', 'script_with_client', 'with_client')
       and a.status_changed_at < now() - interval '24 hours');

-- ───────────────────────── Row-level security ─────────────────────────
-- v1: founders and AMs see everything; editors see only their assets and no money.
-- Client portal access goes through server-side routes with signed links, not RLS.

create function my_role() returns app_role
language sql stable security definer set search_path = public as $$
  select role from people where id = auth.uid() and active
$$;

do $$
declare t text;
begin
  foreach t in array array[
    'people','clients','contacts','engagements','retainer_weeks','whatsapp_groups',
    'messages','briefs','assets','asset_versions','review_comments','asset_events',
    'rate_card','invoices'
  ] loop
    execute format('alter table %I enable row level security', t);
    execute format(
      'create policy staff_all on %I for all to authenticated
         using (my_role() in (''founder'',''account_manager''))
         with check (my_role() in (''founder'',''account_manager''))', t);
  end loop;
end $$;

create policy editor_read_own on assets for select to authenticated
  using (my_role() = 'editor' and editor_id = auth.uid());

-- Editors don't update assets directly (that would expose price/billing columns).
-- They move their own assets between production stages through this function.
create function editor_set_status(p_asset uuid, p_status asset_status) returns void
language plpgsql security definer set search_path = public as $$
begin
  if my_role() <> 'editor' then
    raise exception 'only editors use this function';
  end if;
  if p_status not in ('in_production', 'quality_check') then
    raise exception 'editors can only move assets to in_production or quality_check';
  end if;
  update assets set status = p_status
  where id = p_asset and editor_id = auth.uid()
    and status in ('ready_to_assign', 'in_production', 'revising');
  if not found then
    raise exception 'asset not found, not yours, or not in a production stage';
  end if;
end $$;

create policy editor_versions on asset_versions for all to authenticated
  using (my_role() = 'editor'
         and exists (select 1 from assets a where a.id = asset_id and a.editor_id = auth.uid()))
  with check (my_role() = 'editor'
         and exists (select 1 from assets a where a.id = asset_id and a.editor_id = auth.uid()));

create policy editor_comments_read on review_comments for select to authenticated
  using (my_role() = 'editor'
         and exists (select 1 from asset_versions v join assets a on a.id = v.asset_id
                     where v.id = version_id and a.editor_id = auth.uid()));

create policy self_read on people for select to authenticated using (true);

-- Editors must not see price/invoice columns: the app reads assets for editors
-- through this view (security_invoker so RLS above still applies).
create view editor_assets with (security_invoker = true) as
select id, code, client_id, engagement_id, parent_asset_id, child_kind, language,
       asset_type, topic, ip_name, style, format, dimensions, duration_sec, slide_count,
       co_branding, script_source, script_text, creative_brief, references_list, audio,
       disclaimers, remarks, deadline, account_manager_id, editor_id, status,
       status_changed_at, current_version
from assets;
