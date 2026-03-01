-- INS-1167: Implement pre-game faction and leader selection
-- Changes:
-- 1. Add host_faction, host_leader, guest_faction, guest_leader, host_confirmed, guest_confirmed to cards_lobbies
-- 2. Add unique constraint on cards_games(lobby_id) to prevent duplicate game records
-- 3. Add cards_confirm_selection() function: atomically saves a player's selection and transitions lobby when both confirm
-- 4. Add cards_create_game() function: inserts the initial game record (idempotent via ON CONFLICT DO NOTHING)

alter table cards_lobbies
  add column if not exists host_faction  text,
  add column if not exists host_leader   text,
  add column if not exists guest_faction text,
  add column if not exists guest_leader  text,
  add column if not exists host_confirmed  boolean not null default false,
  add column if not exists guest_confirmed boolean not null default false;

alter table cards_games
  add constraint cards_games_lobby_id_unique unique (lobby_id);

-- Atomically saves a player's faction/leader selection and marks them confirmed.
-- If both players are now confirmed, transitions lobby status to 'in_progress' and
-- returns the full selection data so the caller can initialise the game state.
create or replace function cards_confirm_selection(
  p_lobby_id uuid,
  p_faction  text,
  p_leader   text
)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  v_lobby   cards_lobbies;
  v_user_id uuid := auth.uid();
begin
  select * into v_lobby
  from cards_lobbies
  where id = p_lobby_id
  for update;

  if not found then
    return jsonb_build_object('error', 'not_found');
  end if;

  if v_lobby.host_id != v_user_id and
     (v_lobby.guest_id is null or v_lobby.guest_id != v_user_id) then
    return jsonb_build_object('error', 'unauthorized');
  end if;

  if v_lobby.status != 'selecting' then
    return jsonb_build_object('error', 'invalid_status');
  end if;

  if v_lobby.host_id = v_user_id then
    update cards_lobbies
    set host_faction   = p_faction,
        host_leader    = p_leader,
        host_confirmed = true
    where id = p_lobby_id
    returning * into v_lobby;
  else
    update cards_lobbies
    set guest_faction   = p_faction,
        guest_leader    = p_leader,
        guest_confirmed = true
    where id = p_lobby_id
    returning * into v_lobby;
  end if;

  if v_lobby.host_confirmed and v_lobby.guest_confirmed then
    update cards_lobbies set status = 'in_progress' where id = p_lobby_id;
    return jsonb_build_object(
      'both_confirmed', true,
      'host_id',        v_lobby.host_id,
      'guest_id',       v_lobby.guest_id,
      'host_faction',   v_lobby.host_faction,
      'host_leader',    v_lobby.host_leader,
      'guest_faction',  v_lobby.guest_faction,
      'guest_leader',   v_lobby.guest_leader
    );
  end if;

  return jsonb_build_object('both_confirmed', false);
end;
$$;

-- Inserts the initial game record for a lobby that is now 'in_progress'.
-- ON CONFLICT DO NOTHING makes this safe to call from either player: only the first
-- call creates the row, the second returns the existing game_id.
create or replace function cards_create_game(
  p_lobby_id          uuid,
  p_state             jsonb,
  p_current_player_id uuid
)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  v_lobby   cards_lobbies;
  v_game_id uuid;
begin
  select * into v_lobby from cards_lobbies where id = p_lobby_id;

  if not found then
    return jsonb_build_object('error', 'not_found');
  end if;

  if auth.uid() != v_lobby.host_id and auth.uid() != v_lobby.guest_id then
    return jsonb_build_object('error', 'unauthorized');
  end if;

  insert into cards_games (lobby_id, state, current_player_id, status)
  values (p_lobby_id, p_state, p_current_player_id, 'active')
  on conflict on constraint cards_games_lobby_id_unique do nothing
  returning id into v_game_id;

  if v_game_id is null then
    select id into v_game_id from cards_games where lobby_id = p_lobby_id;
  end if;

  return jsonb_build_object('game_id', v_game_id);
end;
$$;
