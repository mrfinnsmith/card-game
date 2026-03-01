-- INS-1174: Build quick match queue
-- Changes:
-- 1. Make join_code nullable on cards_lobbies (quick match lobbies have no human-readable code)
-- 2. Create cards_quick_match_queue table with unique-per-user constraint and RLS
-- 3. Add security definer function: cards_queue_count()
-- 4. Add security definer function: cards_join_queue(p_display_name)
-- 5. Enable realtime on cards_quick_match_queue

-- Quick match lobbies are created server-side and do not need a join code.
-- char_length(NULL) returns NULL, which satisfies the existing CHECK (evaluates to NULL = no violation).
-- The unique constraint treats NULLs as distinct, so multiple quick match lobbies are fine.
alter table cards_lobbies alter column join_code drop not null;

-- Queue table: one row per user while waiting.
create table if not exists cards_quick_match_queue (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null,
  status text not null default 'waiting',
  lobby_id uuid references cards_lobbies(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint cards_quick_match_queue_user_id_key unique (user_id),
  constraint cards_quick_match_queue_status_values check (status in ('waiting', 'matched'))
);

-- Partial index: only index rows that are actively waiting (the hot path for matching).
create index cards_quick_match_queue_waiting_idx
  on cards_quick_match_queue (created_at)
  where status = 'waiting';

alter table cards_quick_match_queue enable row level security;

-- Authenticated users can insert their own row.
create policy "Authenticated users can insert own queue entry"
  on cards_quick_match_queue for insert
  with check (auth.uid() = user_id);

-- Users can read their own row (needed for postgres_changes to deliver the payload).
create policy "Users can read own queue entry"
  on cards_quick_match_queue for select
  using (auth.uid() = user_id);

-- Users can delete their own row (cancel queue).
create policy "Users can delete own queue entry"
  on cards_quick_match_queue for delete
  using (auth.uid() = user_id);

-- Count of non-stale waiting entries. Security definer so it can bypass RLS and count
-- rows the caller cannot individually see.
create or replace function cards_queue_count()
  returns bigint
  language sql
  security definer set search_path = public
as $$
  select count(*)
  from cards_quick_match_queue
  where status = 'waiting'
    and created_at > now() - interval '5 minutes';
$$;

-- Join the queue or match immediately with the oldest waiting opponent.
-- Returns {"waiting": true} when queued, or {"lobby_id": "<uuid>"} when matched.
-- FOR UPDATE SKIP LOCKED prevents two simultaneous calls from matching the same opponent.
create or replace function cards_join_queue(p_display_name text)
  returns jsonb
  language plpgsql
  security definer set search_path = public
as $$
declare
  v_user_id      uuid := auth.uid();
  v_other_id     uuid;
  v_other_row_id uuid;
  v_lobby_id     uuid;
begin
  -- Find the oldest non-stale waiting entry from a different user.
  select id, user_id
  into v_other_row_id, v_other_id
  from cards_quick_match_queue
  where status = 'waiting'
    and user_id != v_user_id
    and created_at > now() - interval '5 minutes'
  order by created_at asc
  limit 1
  for update skip locked;

  if v_other_row_id is null then
    -- No opponent available. Upsert: refreshes created_at so the entry is not stale.
    insert into cards_quick_match_queue (user_id, display_name, status, created_at)
    values (v_user_id, p_display_name, 'waiting', now())
    on conflict (user_id) do update
      set display_name = excluded.display_name,
          status       = 'waiting',
          lobby_id     = null,
          created_at   = now();

    return jsonb_build_object('waiting', true);
  end if;

  -- Create a quick match lobby. Host = older (waiting) entry, guest = current user.
  -- join_code is null for quick match lobbies (not needed for automated pairing).
  insert into cards_lobbies (host_id, guest_id, status)
  values (v_other_id, v_user_id, 'selecting')
  returning id into v_lobby_id;

  -- Notify the waiting player by updating their queue row.
  -- Their postgres_changes subscription will fire and redirect them.
  update cards_quick_match_queue
  set status   = 'matched',
      lobby_id = v_lobby_id
  where id = v_other_row_id;

  return jsonb_build_object('lobby_id', v_lobby_id);
end;
$$;

-- Enable realtime so the waiting client receives postgres_changes when their row is matched.
alter publication supabase_realtime add table cards_quick_match_queue;
