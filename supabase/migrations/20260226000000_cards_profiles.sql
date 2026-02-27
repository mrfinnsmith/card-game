-- INS-1109: Implement registration and login
-- Changes:
-- 1. Create cards_profiles table with unique username constraint
-- 2. Enable RLS with read-all, insert/update own profile policies
-- 3. Create cards_handle_new_user trigger to auto-create profile on signup

create table if not exists cards_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  username text not null,
  created_at timestamptz not null default now(),
  constraint cards_profiles_user_id_key unique (user_id),
  constraint cards_profiles_username_key unique (username),
  constraint cards_profiles_username_format check (
    username ~ '^[a-zA-Z0-9_]{3,20}$'
  )
);

alter table cards_profiles enable row level security;

create policy "Anyone can read profiles"
  on cards_profiles for select
  using (true);

create policy "Users can insert own profile"
  on cards_profiles for insert
  with check (auth.uid() = user_id);

create policy "Users can update own profile"
  on cards_profiles for update
  using (auth.uid() = user_id);

-- Create profile automatically when a new user signs up.
-- Username is passed as user metadata at registration time.
create or replace function cards_handle_new_user()
  returns trigger
  language plpgsql
  security definer set search_path = public
as $$
begin
  insert into public.cards_profiles (user_id, username)
  values (new.id, new.raw_user_meta_data ->> 'username');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure cards_handle_new_user();
