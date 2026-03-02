-- INS-1172: Record match results and wire multiplayer UI
-- Adds win/loss/draw counters to cards_profiles for registered users.
-- A trigger auto-increments the correct counters whenever a game reaches
-- a terminal status ('completed' or 'forfeited') with a result recorded.

alter table cards_profiles
  add column if not exists wins   int not null default 0,
  add column if not exists losses int not null default 0,
  add column if not exists draws  int not null default 0;

-- Reads the result JSONB from the game row and updates both players' stats.
-- Anonymous users have no profile row, so the UPDATE is silently a no-op for them.
create or replace function cards_update_stats()
  returns trigger
  language plpgsql
  security definer
as $$
declare
  v_host_id  uuid;
  v_guest_id uuid;
  v_winner_id uuid;
begin
  -- Only act on the first transition to a terminal state with a result.
  if new.status not in ('completed', 'forfeited') then
    return new;
  end if;
  if old.status in ('completed', 'forfeited', 'abandoned') then
    return new;
  end if;
  if new.result is null then
    return new;
  end if;

  select host_id, guest_id
    into v_host_id, v_guest_id
    from cards_lobbies
   where id = new.lobby_id;

  v_winner_id := (new.result->>'winner_id')::uuid;

  if v_winner_id is null then
    update cards_profiles set draws = draws + 1 where user_id = v_host_id;
    update cards_profiles set draws = draws + 1 where user_id = v_guest_id;
  else
    update cards_profiles set wins   = wins   + 1 where user_id = v_winner_id;
    if v_winner_id = v_host_id then
      update cards_profiles set losses = losses + 1 where user_id = v_guest_id;
    else
      update cards_profiles set losses = losses + 1 where user_id = v_host_id;
    end if;
  end if;

  return new;
end;
$$;

create trigger cards_games_update_stats
  after update on cards_games
  for each row execute procedure cards_update_stats();
