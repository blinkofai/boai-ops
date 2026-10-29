-- Jev (TypeSafe System One) routes each message to a project and sets who has
-- the ball; Claude handles what Jev isn't sure about and writes summaries.

alter table messages
  add column route_attempted_at timestamptz,     -- Jev looked at it (classified_at stays null if it handed off to Claude)
  add column routed_by          text,            -- 'jev' | 'claude'
  add column route_confidence   numeric(4,3);    -- Jev's confidence in the project choice

-- Set when Jev changes a project's state or adds messages; Claude rewrites the
-- summary and next action, then clears it.
alter table workstreams
  add column summary_stale boolean not null default false;

create index workstreams_stale_idx on workstreams (summary_stale) where summary_stale;
