-- INS-1166: Build lobby creation and join flow
-- Changes:
-- 1. Add host_ready and guest_ready columns to cards_lobbies
-- 2. Add cards_join_lobby RPC for race-condition-safe lobby joining with expiry
-- 3. Enable realtime on cards_lobbies for waiting room live updates

alter table cards_lobbies
  add column if not exists host_ready boolean not null default false,
  add column if not exists guest_ready boolean not null default false;

-- Atomically joins a lobby by code. Returns { lobby_id } on success or { error } on failure.
-- Runs with security definer to bypass RLS for the update while still reading
-- auth.uid() from the caller's JWT. The FOR UPDATE lock prevents two guests
-- joining the same lobby simultaneously.
create or replace function cards_join_lobby(p_join_code text)
  returns jsonb
  language plpgsql
  security definer
  set search_path = public
as $$
declare
  v_lobby cards_lobbies;
begin
  select * into v_lobby
  from cards_lobbies
  where join_code = upper(trim(p_join_code))
  for update;

  if not found then
    return jsonb_build_object('error', 'not_found');
  end if;

  -- Mark as expired if open lobby is older than 30 minutes with no guest
  if v_lobby.guest_id is null
    and v_lobby.status = 'waiting'
    and v_lobby.created_at < now() - interval '30 minutes'
  then
    update cards_lobbies set status = 'expired' where id = v_lobby.id;
    return jsonb_build_object('error', 'expired');
  end if;

  if v_lobby.status = 'expired' then
    return jsonb_build_object('error', 'expired');
  end if;

  if v_lobby.status != 'waiting' then
    return jsonb_build_object('error', 'unavailable');
  end if;

  if v_lobby.guest_id is not null then
    return jsonb_build_object('error', 'full');
  end if;

  if v_lobby.host_id = auth.uid() then
    return jsonb_build_object('error', 'own_lobby');
  end if;

  update cards_lobbies
  set guest_id = auth.uid()
  where id = v_lobby.id;

  return jsonb_build_object('lobby_id', v_lobby.id::text);
end;
$$;

-- Enable realtime so waiting rooms can subscribe to lobby row changes.
alter publication supabase_realtime add table cards_lobbies;
