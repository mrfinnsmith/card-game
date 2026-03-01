-- INS-1165: Design and create multiplayer database schema
-- Changes:
-- 1. Create cards_lobbies table with join code, host/guest, and status
-- 2. Create cards_games table with full serialised state as JSONB
-- 3. Add indexes on join_code, host_id, and lobby_id
-- 4. Enable RLS so players can only read/write their own lobbies and games
-- 5. Add updated_at trigger on cards_games

create table if not exists cards_lobbies (
  id uuid primary key default gen_random_uuid(),
  join_code text not null,
  host_id uuid not null references auth.users(id) on delete cascade,
  guest_id uuid references auth.users(id) on delete set null,
  status text not null default 'waiting',
  created_at timestamptz not null default now(),
  constraint cards_lobbies_join_code_key unique (join_code),
  constraint cards_lobbies_join_code_length check (char_length(join_code) = 6),
  constraint cards_lobbies_status_values check (
    status in ('waiting', 'ready', 'selecting', 'in_progress', 'completed', 'expired')
  )
);

create index cards_lobbies_join_code_idx on cards_lobbies (join_code);
create index cards_lobbies_host_id_idx on cards_lobbies (host_id);

alter table cards_lobbies enable row level security;

create policy "Players can read their own lobbies"
  on cards_lobbies for select
  using (auth.uid() = host_id or auth.uid() = guest_id);

create policy "Players can create lobbies as host"
  on cards_lobbies for insert
  with check (auth.uid() = host_id);

create policy "Players can update their own lobbies"
  on cards_lobbies for update
  using (auth.uid() = host_id or auth.uid() = guest_id);

-- Games table stores the full authoritative game state.
-- The state column contains the serialised GameState object.
-- The result column stores { winnerId, type } on match completion.
create table if not exists cards_games (
  id uuid primary key default gen_random_uuid(),
  lobby_id uuid not null references cards_lobbies(id) on delete cascade,
  state jsonb not null,
  current_player_id uuid references auth.users(id) on delete set null,
  status text not null default 'active',
  result jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint cards_games_status_values check (
    status in ('active', 'completed', 'abandoned', 'forfeited')
  )
);

create index cards_games_lobby_id_idx on cards_games (lobby_id);

alter table cards_games enable row level security;

-- Players may only read a game if they are host or guest in the linked lobby.
create policy "Players can read their own games"
  on cards_games for select
  using (
    auth.uid() in (select host_id from cards_lobbies where id = lobby_id)
    or
    auth.uid() in (select guest_id from cards_lobbies where id = lobby_id)
  );

-- Only the host may create a game row (triggered when the match starts).
create policy "Host can insert game"
  on cards_games for insert
  with check (
    auth.uid() in (select host_id from cards_lobbies where id = lobby_id)
  );

-- Both players may update game state (API routes use service role, but
-- this policy covers any direct client writes).
create policy "Players can update their own games"
  on cards_games for update
  using (
    auth.uid() in (select host_id from cards_lobbies where id = lobby_id)
    or
    auth.uid() in (select guest_id from cards_lobbies where id = lobby_id)
  );

-- Keep updated_at current on every write.
create or replace function cards_update_games_updated_at()
  returns trigger
  language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger cards_games_updated_at
  before update on cards_games
  for each row execute procedure cards_update_games_updated_at();
