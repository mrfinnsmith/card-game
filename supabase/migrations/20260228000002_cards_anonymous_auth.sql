-- INS-1173: Enable anonymous play and remove mandatory auth
-- Changes:
-- 1. Fix cards_handle_new_user trigger to skip profile insert for anonymous signins
-- 2. Restrict cards_profiles insert to registered (non-anonymous) users only
-- 3. Restrict cards_profiles update to registered users only
-- 4. Restrict cards_lobbies insert to registered users only (invite lobby is registered-only)

-- Anonymous users have is_anonymous = true in their JWT.
create or replace function cards_handle_new_user()
  returns trigger
  language plpgsql
  security definer set search_path = public
as $$
begin
  -- Skip profile creation for anonymous signins (no username in metadata).
  if new.raw_user_meta_data ->> 'username' is null then
    return new;
  end if;

  insert into public.cards_profiles (user_id, username)
  values (new.id, new.raw_user_meta_data ->> 'username');
  return new;
end;
$$;

-- Restrict profile insert to registered (non-anonymous) users.
drop policy if exists "Users can insert own profile" on cards_profiles;
create policy "Registered users can insert own profile"
  on cards_profiles for insert
  with check (
    auth.uid() = user_id
    and not coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false)
  );

-- Restrict profile update to registered users (anonymous users have no profile to update).
drop policy if exists "Users can update own profile" on cards_profiles;
create policy "Registered users can update own profile"
  on cards_profiles for update
  using (
    auth.uid() = user_id
    and not coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false)
  );

-- Restrict invite lobby creation to registered users.
-- Quick match lobby creation happens via security definer functions (bypasses RLS).
drop policy if exists "Players can create lobbies as host" on cards_lobbies;
create policy "Registered users can create lobbies as host"
  on cards_lobbies for insert
  with check (
    auth.uid() = host_id
    and not coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false)
  );
