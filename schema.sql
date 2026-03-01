--
-- PostgreSQL database dump
--

\restrict mHHKBTyOiHiGvakRwSMo2CvkWJUeqezFaOGbcPlbjF92TGDyvsVNh3g2yAGuWLW

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA supabase_migrations;


ALTER SCHEMA supabase_migrations OWNER TO postgres;

--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


ALTER TYPE auth.oauth_authorization_status OWNER TO supabase_auth_admin;

--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


ALTER TYPE auth.oauth_client_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE auth.oauth_registration_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


ALTER TYPE auth.oauth_response_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


ALTER TYPE storage.buckettype OWNER TO supabase_storage_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: supabase_admin
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO supabase_admin;

--
-- Name: assign_daily_puzzle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.assign_daily_puzzle() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  target_date DATE := CURRENT_DATE;
  next_puzzle_num INTEGER;
  selected_fjord_id INTEGER;
  result_puzzle_num INTEGER;
BEGIN
  SELECT puzzle_number INTO result_puzzle_num 
  FROM daily_puzzles 
  WHERE presented_date = target_date;
  
  IF result_puzzle_num IS NOT NULL THEN
      RETURN result_puzzle_num;
  END IF;
  
  WITH puzzle_numbers AS (
      SELECT puzzle_number FROM daily_puzzles WHERE puzzle_number IS NOT NULL
  ),
  number_series AS (
      SELECT generate_series(1, COALESCE((SELECT MAX(puzzle_number) FROM puzzle_numbers), 0) + 1) AS num
  )
  SELECT COALESCE(MIN(num), 1) INTO next_puzzle_num
  FROM number_series 
  WHERE num NOT IN (SELECT puzzle_number FROM puzzle_numbers);
  
  SELECT fjord_id INTO selected_fjord_id 
  FROM puzzle_queue 
  WHERE scheduled_date = target_date;
  
  IF selected_fjord_id IS NOT NULL THEN
      DELETE FROM puzzle_queue WHERE scheduled_date = target_date;
  ELSE
      SELECT id INTO selected_fjord_id 
      FROM fjords 
      WHERE id NOT IN (SELECT fjord_id FROM daily_puzzles WHERE fjord_id IS NOT NULL)
        AND quarantined = FALSE
        AND wikipedia_url_no IS NOT NULL
      ORDER BY RANDOM() 
      LIMIT 1;
      
      IF selected_fjord_id IS NULL THEN
          SELECT id INTO selected_fjord_id 
          FROM fjords 
          WHERE id NOT IN (SELECT fjord_id FROM daily_puzzles WHERE fjord_id IS NOT NULL)
            AND quarantined = FALSE
          ORDER BY RANDOM() 
          LIMIT 1;
      END IF;
      
      IF selected_fjord_id IS NULL THEN
          SELECT dp.fjord_id INTO selected_fjord_id
          FROM daily_puzzles dp
          JOIN fjords f ON dp.fjord_id = f.id
          WHERE dp.fjord_id IS NOT NULL AND f.quarantined = FALSE
          ORDER BY dp.last_presented_date ASC, RANDOM()
          LIMIT 1;
      END IF;
  END IF;
  
  IF selected_fjord_id IS NULL THEN
      RAISE EXCEPTION 'No fjord could be selected for puzzle assignment';
  END IF;
  
  INSERT INTO daily_puzzles (fjord_id, puzzle_number, presented_date, last_presented_date)
  VALUES (selected_fjord_id, next_puzzle_num, target_date, target_date);
  
  SELECT puzzle_number INTO result_puzzle_num 
  FROM daily_puzzles 
  WHERE presented_date = target_date;
  
  IF result_puzzle_num IS NULL THEN
      RAISE EXCEPTION 'Puzzle insertion failed for unknown reason';
  END IF;
  
  RETURN result_puzzle_num;
  
EXCEPTION
  WHEN unique_violation THEN
      RAISE EXCEPTION 'Failed to create daily puzzle due to constraint violation';
  WHEN OTHERS THEN
      RAISE EXCEPTION 'Unexpected error in assign_daily_puzzle: %', SQLERRM;
END;
$$;


ALTER FUNCTION public.assign_daily_puzzle() OWNER TO postgres;

--
-- Name: cards_confirm_selection(uuid, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cards_confirm_selection(p_lobby_id uuid, p_faction text, p_leader text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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


ALTER FUNCTION public.cards_confirm_selection(p_lobby_id uuid, p_faction text, p_leader text) OWNER TO postgres;

--
-- Name: cards_create_game(uuid, jsonb, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cards_create_game(p_lobby_id uuid, p_state jsonb, p_current_player_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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


ALTER FUNCTION public.cards_create_game(p_lobby_id uuid, p_state jsonb, p_current_player_id uuid) OWNER TO postgres;

--
-- Name: cards_handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cards_handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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


ALTER FUNCTION public.cards_handle_new_user() OWNER TO postgres;

--
-- Name: cards_join_lobby(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cards_join_lobby(p_join_code text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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


ALTER FUNCTION public.cards_join_lobby(p_join_code text) OWNER TO postgres;

--
-- Name: cards_join_queue(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cards_join_queue(p_display_name text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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


ALTER FUNCTION public.cards_join_queue(p_display_name text) OWNER TO postgres;

--
-- Name: cards_queue_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cards_queue_count() RETURNS bigint
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  select count(*)
  from cards_quick_match_queue
  where status = 'waiting'
    and created_at > now() - interval '5 minutes';
$$;


ALTER FUNCTION public.cards_queue_count() OWNER TO postgres;

--
-- Name: cards_update_games_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cards_update_games_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION public.cards_update_games_updated_at() OWNER TO postgres;

--
-- Name: check_missing_puzzles(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_missing_puzzles(days_back integer DEFAULT 7) RETURNS TABLE(date_checked date, status text, puzzle_number integer, fjord_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        date_series.date as date_checked,
        CASE 
            WHEN dp.presented_date IS NULL THEN 'MISSING' 
            ELSE 'EXISTS' 
        END as status,
        dp.puzzle_number,
        f.name as fjord_name
    FROM (
        SELECT generate_series(
            CURRENT_DATE - (days_back || ' days')::INTERVAL,
            CURRENT_DATE,
            INTERVAL '1 day'
        )::date as date
    ) date_series
    LEFT JOIN daily_puzzles dp ON dp.presented_date = date_series.date
    LEFT JOIN fjords f ON dp.fjord_id = f.id
    ORDER BY date_series.date DESC;
END;
$$;


ALTER FUNCTION public.check_missing_puzzles(days_back integer) OWNER TO postgres;

--
-- Name: check_puzzle_integrity(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_puzzle_integrity() RETURNS TABLE(puzzle_number integer, count_occurrences bigint, status text, dates_used text[])
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH puzzle_stats AS (
        SELECT 
            dp.puzzle_number,
            COUNT(*) as count_occurrences,
            ARRAY_AGG(dp.presented_date::TEXT ORDER BY dp.presented_date) as dates_used
        FROM daily_puzzles dp
        WHERE dp.puzzle_number IS NOT NULL
        GROUP BY dp.puzzle_number
    ),
    expected_numbers AS (
        SELECT generate_series(1, COALESCE((SELECT MAX(puzzle_number) FROM daily_puzzles), 1)) as expected_num
    )
    SELECT 
        COALESCE(ps.puzzle_number, en.expected_num) as puzzle_number,
        COALESCE(ps.count_occurrences, 0) as count_occurrences,
        CASE 
            WHEN ps.count_occurrences IS NULL THEN 'MISSING'
            WHEN ps.count_occurrences > 1 THEN 'DUPLICATE'
            ELSE 'OK'
        END as status,
        COALESCE(ps.dates_used, ARRAY[]::TEXT[]) as dates_used
    FROM expected_numbers en
    FULL OUTER JOIN puzzle_stats ps ON en.expected_num = ps.puzzle_number
    WHERE COALESCE(ps.count_occurrences, 0) != 1
    ORDER BY COALESCE(ps.puzzle_number, en.expected_num);
END;
$$;


ALTER FUNCTION public.check_puzzle_integrity() OWNER TO postgres;

--
-- Name: daily_health_check(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.daily_health_check() RETURNS TABLE(check_name text, status text, details text, checked_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
   today_puzzle INTEGER;
   missing_count INTEGER;
   duplicate_count INTEGER;
   queue_count INTEGER;
   total_fjords INTEGER;
   used_fjords INTEGER;
BEGIN
   SELECT puzzle_number INTO today_puzzle
   FROM daily_puzzles 
   WHERE presented_date = CURRENT_DATE;
   
   SELECT COUNT(*) INTO missing_count
   FROM generate_series(CURRENT_DATE - INTERVAL '6 days', CURRENT_DATE, INTERVAL '1 day') date_series(date)
   LEFT JOIN daily_puzzles dp ON dp.presented_date = date_series.date::date
   WHERE dp.presented_date IS NULL;
   
   SELECT COUNT(*) INTO duplicate_count
   FROM (
       SELECT puzzle_number 
       FROM daily_puzzles 
       WHERE puzzle_number IS NOT NULL
       GROUP BY puzzle_number 
       HAVING COUNT(*) > 1
   ) duplicates;
   
   SELECT COUNT(*) INTO queue_count
   FROM puzzle_queue
   WHERE scheduled_date >= CURRENT_DATE;
   
   SELECT COUNT(*) INTO total_fjords FROM fjords WHERE quarantined = FALSE;
   SELECT COUNT(DISTINCT fjord_id) INTO used_fjords 
   FROM daily_puzzles 
   WHERE fjord_id IS NOT NULL;
   
   RETURN QUERY VALUES
       ('Today Puzzle', 
        CASE WHEN today_puzzle IS NOT NULL THEN 'OK' ELSE 'MISSING' END,
        CASE WHEN today_puzzle IS NOT NULL THEN 'Puzzle #' || today_puzzle::TEXT ELSE 'No puzzle assigned for today' END,
        NOW()),
       ('Recent Missing', 
        CASE WHEN missing_count = 0 THEN 'OK' ELSE 'WARNING' END,
        missing_count::TEXT || ' missing puzzles in last 7 days',
        NOW()),
       ('Puzzle Duplicates',
        CASE WHEN duplicate_count = 0 THEN 'OK' ELSE 'ERROR' END,
        duplicate_count::TEXT || ' duplicate puzzle numbers found',
        NOW()),
       ('Queue Status',
        CASE WHEN queue_count >= 0 THEN 'OK' ELSE 'INFO' END,
        queue_count::TEXT || ' puzzles queued for future dates',
        NOW()),
       ('Fjord Usage',
        CASE WHEN used_fjords < total_fjords THEN 'OK' ELSE 'INFO' END,
        used_fjords::TEXT || '/' || total_fjords::TEXT || ' fjords used (' || 
        ROUND((used_fjords::NUMERIC / total_fjords::NUMERIC) * 100, 1)::TEXT || '%)',
        NOW());
END;
$$;


ALTER FUNCTION public.daily_health_check() OWNER TO postgres;

--
-- Name: fjordle_assign_daily_puzzle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fjordle_assign_daily_puzzle() RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE
  target_date DATE := CURRENT_DATE;
  next_puzzle_num INTEGER;
  selected_fjord_id INTEGER;
  result_puzzle_num INTEGER;
BEGIN
  SELECT puzzle_number INTO result_puzzle_num 
  FROM fjordle_daily_puzzles 
  WHERE presented_date = target_date;
  
  IF result_puzzle_num IS NOT NULL THEN
      RETURN result_puzzle_num;
  END IF;
  
  WITH puzzle_numbers AS (
      SELECT puzzle_number FROM fjordle_daily_puzzles WHERE puzzle_number IS NOT NULL
  ),
  number_series AS (
      SELECT generate_series(1, COALESCE((SELECT MAX(puzzle_number) FROM puzzle_numbers), 0) + 1) AS num
  )
  SELECT COALESCE(MIN(num), 1) INTO next_puzzle_num
  FROM number_series 
  WHERE num NOT IN (SELECT puzzle_number FROM puzzle_numbers);
  
  SELECT fjord_id INTO selected_fjord_id 
  FROM fjordle_puzzle_queue 
  WHERE scheduled_date = target_date;
  
  IF selected_fjord_id IS NOT NULL THEN
      DELETE FROM fjordle_puzzle_queue WHERE scheduled_date = target_date;
  ELSE
      SELECT id INTO selected_fjord_id 
      FROM fjordle_fjords 
      WHERE id NOT IN (SELECT fjord_id FROM fjordle_daily_puzzles WHERE fjord_id IS NOT NULL)
        AND quarantined = FALSE
        AND wikipedia_url_no IS NOT NULL
      ORDER BY RANDOM() 
      LIMIT 1;
      
      IF selected_fjord_id IS NULL THEN
          SELECT id INTO selected_fjord_id 
          FROM fjordle_fjords 
          WHERE id NOT IN (SELECT fjord_id FROM fjordle_daily_puzzles WHERE fjord_id IS NOT NULL)
            AND quarantined = FALSE
          ORDER BY RANDOM() 
          LIMIT 1;
      END IF;
      
      IF selected_fjord_id IS NULL THEN
          SELECT dp.fjord_id INTO selected_fjord_id
          FROM fjordle_daily_puzzles dp
          JOIN fjordle_fjords f ON dp.fjord_id = f.id
          WHERE dp.fjord_id IS NOT NULL AND f.quarantined = FALSE
          ORDER BY dp.last_presented_date ASC, RANDOM()
          LIMIT 1;
      END IF;
  END IF;
  
  IF selected_fjord_id IS NULL THEN
      RAISE EXCEPTION 'No fjord could be selected for puzzle assignment';
  END IF;
  
  INSERT INTO fjordle_daily_puzzles (fjord_id, puzzle_number, presented_date, last_presented_date)
  VALUES (selected_fjord_id, next_puzzle_num, target_date, target_date);
  
  SELECT puzzle_number INTO result_puzzle_num 
  FROM fjordle_daily_puzzles 
  WHERE presented_date = target_date;
  
  IF result_puzzle_num IS NULL THEN
      RAISE EXCEPTION 'Puzzle insertion failed for unknown reason';
  END IF;
  
  RETURN result_puzzle_num;
  
EXCEPTION
  WHEN unique_violation THEN
      RAISE EXCEPTION 'Failed to create daily puzzle due to constraint violation';
  WHEN OTHERS THEN
      RAISE EXCEPTION 'Unexpected error in assign_daily_puzzle: %', SQLERRM;
END;
$$;


ALTER FUNCTION public.fjordle_assign_daily_puzzle() OWNER TO postgres;

--
-- Name: fjordle_check_missing_puzzles(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fjordle_check_missing_puzzles(days_back integer) RETURNS TABLE(date_checked date, status text, puzzle_number integer, fjord_name text)
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        date_series.date as date_checked,
        CASE 
            WHEN dp.presented_date IS NULL THEN 'MISSING' 
            ELSE 'EXISTS' 
        END as status,
        dp.puzzle_number,
        f.name as fjord_name
    FROM (
        SELECT generate_series(
            CURRENT_DATE - (days_back || ' days')::INTERVAL,
            CURRENT_DATE,
            INTERVAL '1 day'
        )::date as date
    ) date_series
    LEFT JOIN fjordle_daily_puzzles dp ON dp.presented_date = date_series.date
    LEFT JOIN fjordle_fjords f ON dp.fjord_id = f.id
    ORDER BY date_series.date DESC;
END;
$$;


ALTER FUNCTION public.fjordle_check_missing_puzzles(days_back integer) OWNER TO postgres;

--
-- Name: fjordle_check_puzzle_integrity(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fjordle_check_puzzle_integrity() RETURNS TABLE(puzzle_number integer, count_occurrences integer, status text, dates_used text[])
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    WITH puzzle_stats AS (
        SELECT 
            dp.puzzle_number,
            COUNT(*) as count_occurrences,
            ARRAY_AGG(dp.presented_date::TEXT ORDER BY dp.presented_date) as dates_used
        FROM fjordle_daily_puzzles dp
        WHERE dp.puzzle_number IS NOT NULL
        GROUP BY dp.puzzle_number
    ),
    expected_numbers AS (
        SELECT generate_series(1, COALESCE((SELECT MAX(puzzle_number) FROM fjordle_daily_puzzles), 1)) as expected_num
    )
    SELECT 
        COALESCE(ps.puzzle_number, en.expected_num) as puzzle_number,
        COALESCE(ps.count_occurrences, 0) as count_occurrences,
        CASE 
            WHEN ps.count_occurrences IS NULL THEN 'MISSING'
            WHEN ps.count_occurrences > 1 THEN 'DUPLICATE'
            ELSE 'OK'
        END as status,
        COALESCE(ps.dates_used, ARRAY[]::TEXT[]) as dates_used
    FROM expected_numbers en
    FULL OUTER JOIN puzzle_stats ps ON en.expected_num = ps.puzzle_number
    WHERE COALESCE(ps.count_occurrences, 0) != 1
    ORDER BY COALESCE(ps.puzzle_number, en.expected_num);
END;
$$;


ALTER FUNCTION public.fjordle_check_puzzle_integrity() OWNER TO postgres;

--
-- Name: fjordle_daily_health_check(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fjordle_daily_health_check() RETURNS TABLE(check_name text, status text, message text, checked_at timestamp with time zone)
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE
   today_puzzle INTEGER;
   missing_count INTEGER;
   duplicate_count INTEGER;
   queue_count INTEGER;
   total_fjords INTEGER;
   used_fjords INTEGER;
BEGIN
   SELECT puzzle_number INTO today_puzzle
   FROM fjordle_daily_puzzles 
   WHERE presented_date = CURRENT_DATE;
   
   SELECT COUNT(*) INTO missing_count
   FROM generate_series(CURRENT_DATE - INTERVAL '6 days', CURRENT_DATE, INTERVAL '1 day') date_series(date)
   LEFT JOIN fjordle_daily_puzzles dp ON dp.presented_date = date_series.date::date
   WHERE dp.presented_date IS NULL;
   
   SELECT COUNT(*) INTO duplicate_count
   FROM (
       SELECT puzzle_number 
       FROM fjordle_daily_puzzles 
       WHERE puzzle_number IS NOT NULL
       GROUP BY puzzle_number 
       HAVING COUNT(*) > 1
   ) duplicates;
   
   SELECT COUNT(*) INTO queue_count
   FROM fjordle_puzzle_queue
   WHERE scheduled_date >= CURRENT_DATE;
   
   SELECT COUNT(*) INTO total_fjords FROM fjordle_fjords WHERE quarantined = FALSE;
   SELECT COUNT(DISTINCT fjord_id) INTO used_fjords 
   FROM fjordle_daily_puzzles 
   WHERE fjord_id IS NOT NULL;
   
   RETURN QUERY VALUES
       ('Today Puzzle', 
        CASE WHEN today_puzzle IS NOT NULL THEN 'OK' ELSE 'MISSING' END,
        CASE WHEN today_puzzle IS NOT NULL THEN 'Puzzle #' || today_puzzle::TEXT ELSE 'No puzzle assigned for today' END,
        NOW()),
       ('Recent Missing', 
        CASE WHEN missing_count = 0 THEN 'OK' ELSE 'WARNING' END,
        missing_count::TEXT || ' missing puzzles in last 7 days',
        NOW()),
       ('Puzzle Duplicates',
        CASE WHEN duplicate_count = 0 THEN 'OK' ELSE 'ERROR' END,
        duplicate_count::TEXT || ' duplicate puzzle numbers found',
        NOW()),
       ('Queue Status',
        CASE WHEN queue_count >= 0 THEN 'OK' ELSE 'INFO' END,
        queue_count::TEXT || ' puzzles queued for future dates',
        NOW()),
       ('Fjord Usage',
        CASE WHEN used_fjords < total_fjords THEN 'OK' ELSE 'INFO' END,
        used_fjords::TEXT || '/' || total_fjords::TEXT || ' fjords used (' || 
        ROUND((used_fjords::NUMERIC / total_fjords::NUMERIC) * 100, 1)::TEXT || '%)',
        NOW());
END;
$$;


ALTER FUNCTION public.fjordle_daily_health_check() OWNER TO postgres;

--
-- Name: fjordle_get_daily_fjord_puzzle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fjordle_get_daily_fjord_puzzle() RETURNS TABLE(puzzle_id integer, puzzle_number integer, fjord_id integer, fjord_name text, svg_filename text, satellite_filename text, center_lat numeric, center_lng numeric, wikipedia_url_no text, wikipedia_url_en text, wikipedia_url_nn text, wikipedia_url_da text, wikipedia_url_ceb text, date date)
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN   
  RETURN QUERY   
  SELECT      
    dp.id as puzzle_id,     
    dp.puzzle_number,     
    f.id as fjord_id,     
    f.name as fjord_name,     
    f.svg_filename,
    f.satellite_filename,     
    f.center_lat,     
    f.center_lng,     
    f.wikipedia_url_no,     
    f.wikipedia_url_en,
    f.wikipedia_url_nn,
    f.wikipedia_url_da,
    f.wikipedia_url_ceb,     
    dp.presented_date as date   
  FROM fjordle_daily_puzzles dp   
  JOIN fjordle_fjords f ON dp.fjord_id = f.id   
  WHERE dp.presented_date = CURRENT_DATE    
  LIMIT 1; 
END;
$$;


ALTER FUNCTION public.fjordle_get_daily_fjord_puzzle() OWNER TO postgres;

--
-- Name: fjordle_get_fjord_by_slug(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fjordle_get_fjord_by_slug(p_slug text) RETURNS TABLE(fjord_id integer, fjord_name text, slug text, svg_filename text, satellite_filename text, center_lat numeric, center_lng numeric, wikipedia_url_no text, wikipedia_url_en text, wikipedia_url_nn text, wikipedia_url_da text, wikipedia_url_ceb text, length_km numeric, width_km numeric, depth_m numeric, measurement_source_url text, municipalities text[], counties text[])
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    f.id               AS fjord_id,
    f.name             AS fjord_name,
    f.slug,
    f.svg_filename,
    f.satellite_filename,
    f.center_lat,
    f.center_lng,
    f.wikipedia_url_no,
    f.wikipedia_url_en,
    f.wikipedia_url_nn,
    f.wikipedia_url_da,
    f.wikipedia_url_ceb,
    f.length_km,
    f.width_km,
    f.depth_m,
    f.measurement_source_url,
    ARRAY(
      SELECT m.name
      FROM fjordle_fjord_municipalities fm
      JOIN fjordle_municipalities m ON m.id = fm.municipality_id
      WHERE fm.fjord_id = f.id
      ORDER BY m.name
    ) AS municipalities,
    ARRAY(
      SELECT DISTINCT c.name
      FROM (
        SELECT fc.county_id
        FROM fjordle_fjord_counties fc
        WHERE fc.fjord_id = f.id
        UNION
        SELECT m2.county_id
        FROM fjordle_fjord_municipalities fm2
        JOIN fjordle_municipalities m2 ON m2.id = fm2.municipality_id
        WHERE fm2.fjord_id = f.id
          AND m2.county_id IS NOT NULL
      ) combined
      JOIN fjordle_counties c ON c.id = combined.county_id
      ORDER BY c.name
    ) AS counties
  FROM fjordle_fjords f
  WHERE f.slug = p_slug;
END;
$$;


ALTER FUNCTION public.fjordle_get_fjord_by_slug(p_slug text) OWNER TO postgres;

--
-- Name: fjordle_get_fjord_puzzle_by_number(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fjordle_get_fjord_puzzle_by_number(puzzle_num integer) RETURNS TABLE(puzzle_id integer, puzzle_number integer, fjord_id integer, fjord_name text, svg_filename text, satellite_filename text, center_lat numeric, center_lng numeric, wikipedia_url_no text, wikipedia_url_en text, wikipedia_url_nn text, wikipedia_url_da text, wikipedia_url_ceb text, date date)
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN   
  RETURN QUERY   
  SELECT      
    dp.id as puzzle_id,     
    dp.puzzle_number,     
    f.id as fjord_id,     
    f.name as fjord_name,     
    f.svg_filename,
    f.satellite_filename,     
    f.center_lat,     
    f.center_lng,     
    f.wikipedia_url_no,     
    f.wikipedia_url_en,
    f.wikipedia_url_nn,
    f.wikipedia_url_da,
    f.wikipedia_url_ceb,     
    dp.presented_date as date   
  FROM fjordle_daily_puzzles dp   
  JOIN fjordle_fjords f ON dp.fjord_id = f.id   
  WHERE dp.puzzle_number = puzzle_num    
  LIMIT 1; 
END;
$$;


ALTER FUNCTION public.fjordle_get_fjord_puzzle_by_number(puzzle_num integer) OWNER TO postgres;

--
-- Name: fjordle_get_past_puzzles(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fjordle_get_past_puzzles() RETURNS TABLE(puzzle_id integer, puzzle_number integer, fjord_name text, date date, difficulty_tier integer)
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
 RETURN QUERY
 SELECT 
   dp.id as puzzle_id,
   dp.puzzle_number,
   f.name as fjord_name,
   dp.presented_date as date,
   COALESCE(f.difficulty_tier, 0) as difficulty_tier
 FROM fjordle_daily_puzzles dp
 JOIN fjordle_fjords f ON dp.fjord_id = f.id
 WHERE dp.presented_date < CURRENT_DATE
 ORDER BY dp.puzzle_number DESC;
END;
$$;


ALTER FUNCTION public.fjordle_get_past_puzzles() OWNER TO postgres;

--
-- Name: fjordle_update_puzzle_difficulty_tiers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fjordle_update_puzzle_difficulty_tiers() RETURNS TABLE(execution_time_ms integer, updated_count integer, easy_count integer, medium_count integer, hard_count integer, changes_count integer)
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE
start_time TIMESTAMP;
end_time TIMESTAMP;
min_sessions INTEGER;
easy_threshold NUMERIC;
medium_threshold NUMERIC;
updated_count INTEGER;
easy_cnt INTEGER;
medium_cnt INTEGER;
hard_cnt INTEGER;
changes_cnt INTEGER;
qualified_fjords_count INTEGER;
BEGIN
start_time := clock_timestamp();

SELECT LEAST(100, GREATEST(10, PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY session_count)))::INTEGER
INTO min_sessions
FROM (
  SELECT COUNT(DISTINCT g.session_id) as session_count
  FROM fjordle_daily_puzzles dp
  JOIN fjordle_guesses g ON dp.id = g.puzzle_id
  GROUP BY dp.fjord_id
) session_counts;

SELECT COUNT(*)
INTO qualified_fjords_count
FROM (
  SELECT dp.fjord_id
  FROM fjordle_daily_puzzles dp
  JOIN fjordle_guesses g ON dp.id = g.puzzle_id
  GROUP BY dp.fjord_id
  HAVING COUNT(DISTINCT g.session_id) >= min_sessions
) qualified_fjords;

IF qualified_fjords_count < 5 THEN
  easy_threshold := 45;
  medium_threshold := 30;
ELSE
  SELECT 
    PERCENTILE_CONT(0.67) WITHIN GROUP (ORDER BY win_rate),
    PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY win_rate)
  INTO easy_threshold, medium_threshold
  FROM (
    SELECT 
      ROUND(
        COUNT(DISTINCT CASE WHEN g.is_correct THEN g.session_id END) * 100.0 / 
        COUNT(DISTINCT g.session_id), 1
      ) as win_rate
    FROM fjordle_daily_puzzles dp
    JOIN fjordle_guesses g ON dp.id = g.puzzle_id
    GROUP BY dp.fjord_id
    HAVING COUNT(DISTINCT g.session_id) >= min_sessions
  ) qualified_rates;
END IF;

CREATE TEMP TABLE tier_changes_temp AS
SELECT id, difficulty_tier as old_tier
FROM fjordle_fjords
WHERE difficulty_tier IS NOT NULL;

UPDATE fjordle_fjords 
SET difficulty_tier = 
  CASE 
    WHEN win_stats.win_rate >= easy_threshold THEN 1
    WHEN win_stats.win_rate >= medium_threshold THEN 2
    ELSE 3
  END
FROM (
  SELECT 
    dp.fjord_id,
    ROUND(
      COUNT(DISTINCT CASE WHEN g.is_correct THEN g.session_id END) * 100.0 / 
      COUNT(DISTINCT g.session_id), 1
    ) as win_rate
  FROM fjordle_daily_puzzles dp
  JOIN fjordle_guesses g ON dp.id = g.puzzle_id
  GROUP BY dp.fjord_id
  HAVING COUNT(DISTINCT g.session_id) >= min_sessions
) win_stats
WHERE fjordle_fjords.id = win_stats.fjord_id;

GET DIAGNOSTICS updated_count = ROW_COUNT;

SELECT 
  COUNT(CASE WHEN difficulty_tier = 1 THEN 1 END),
  COUNT(CASE WHEN difficulty_tier = 2 THEN 1 END),
  COUNT(CASE WHEN difficulty_tier = 3 THEN 1 END)
INTO easy_cnt, medium_cnt, hard_cnt
FROM fjordle_fjords
WHERE difficulty_tier IS NOT NULL;

SELECT COUNT(*)
INTO changes_cnt
FROM fjordle_fjords f
JOIN tier_changes_temp t ON f.id = t.id
WHERE f.difficulty_tier != t.old_tier;

end_time := clock_timestamp();

DROP TABLE tier_changes_temp;

RETURN QUERY SELECT 
  EXTRACT(MILLISECONDS FROM (end_time - start_time))::INTEGER,
  updated_count,
  easy_cnt,
  medium_cnt,
  hard_cnt,
  changes_cnt;
EXCEPTION
WHEN OTHERS THEN
  DROP TABLE IF EXISTS tier_changes_temp;
  RAISE;
END;
$$;


ALTER FUNCTION public.fjordle_update_puzzle_difficulty_tiers() OWNER TO postgres;

--
-- Name: frisc_assign_daily_puzzle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.frisc_assign_daily_puzzle() RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE
    current_puzzle_id INTEGER;
    next_puzzle_id INTEGER;
BEGIN
    -- Find current published puzzle
    SELECT puzzle_id INTO current_puzzle_id
    FROM frisc_puzzle_queue 
    WHERE published = TRUE;
    
    -- Unpublish and archive current puzzle if it exists
    IF current_puzzle_id IS NOT NULL THEN
        UPDATE frisc_puzzle_queue 
        SET published = FALSE, archived = TRUE 
        WHERE puzzle_id = current_puzzle_id;
    END IF;
    
    -- Get next puzzle using recycling algorithm
    SELECT frisc_get_next_puzzle() INTO next_puzzle_id;
    
    IF next_puzzle_id IS NOT NULL THEN
        -- If puzzle is in queue, publish it
        IF EXISTS (SELECT 1 FROM frisc_puzzle_queue WHERE puzzle_id = next_puzzle_id) THEN
            UPDATE frisc_puzzle_queue
            SET published = TRUE
            WHERE puzzle_id = next_puzzle_id;
        ELSE
            -- If puzzle is not in queue (recycled), add it and publish
            INSERT INTO frisc_puzzle_queue (puzzle_id, published, archived)
            VALUES (next_puzzle_id, TRUE, FALSE);
        END IF;
        
        -- Record presentation
        INSERT INTO frisc_puzzle_presentations (puzzle_id, presented_date)
        VALUES (next_puzzle_id, CURRENT_DATE)
        ON CONFLICT (puzzle_id, presented_date) DO NOTHING;
    END IF;
    
    RETURN next_puzzle_id;
END;
$$;


ALTER FUNCTION public.frisc_assign_daily_puzzle() OWNER TO postgres;

--
-- Name: frisc_auto_assign_queue_position(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.frisc_auto_assign_queue_position() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
    IF NEW.queue_position IS NULL THEN
        NEW.queue_position := (SELECT COALESCE(MAX(queue_position), 0) + 1 FROM frisc_puzzle_queue);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.frisc_auto_assign_queue_position() OWNER TO postgres;

--
-- Name: frisc_get_daily_puzzle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.frisc_get_daily_puzzle() RETURNS TABLE(puzzle_id integer, puzzle_number integer, category_id integer, category_name text, difficulty integer, items text[])
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE
    published_count INTEGER;
BEGIN
    -- Check how many puzzles are published
    SELECT COUNT(*) INTO published_count
    FROM frisc_puzzle_queue
    WHERE published = TRUE;
    
    -- Return nothing if not exactly 1 published puzzle
    IF published_count != 1 THEN
        RETURN;
    END IF;
    
    -- Return the single published puzzle
    RETURN QUERY
    SELECT 
        p.id as puzzle_id,
        p.puzzle_number,
        c.id as category_id,
        c.name as category_name,
        c.difficulty,
        c.items
    FROM frisc_puzzles p
    JOIN frisc_puzzle_queue pq ON p.id = pq.puzzle_id
    JOIN frisc_categories c ON p.id = c.puzzle_id
    WHERE pq.published = true
    ORDER BY c.difficulty;
END;
$$;


ALTER FUNCTION public.frisc_get_daily_puzzle() OWNER TO postgres;

--
-- Name: frisc_get_next_puzzle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.frisc_get_next_puzzle() RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE
    selected_puzzle_id INTEGER;
BEGIN
    -- Tier 1: Check puzzle_queue for next unplayed puzzle
    SELECT puzzle_id INTO selected_puzzle_id
    FROM frisc_puzzle_queue
    WHERE published = false AND archived = false
    ORDER BY queue_position
    LIMIT 1;
    
    IF selected_puzzle_id IS NOT NULL THEN
        RETURN selected_puzzle_id;
    END IF;
    
    -- Tier 2: Puzzles not presented in 6+ months
    SELECT p.id INTO selected_puzzle_id
    FROM frisc_puzzles p
    WHERE p.id NOT IN (
        SELECT puzzle_id FROM frisc_puzzle_presentations 
        WHERE presented_date > CURRENT_DATE - INTERVAL '6 months'
    )
    ORDER BY RANDOM()
    LIMIT 1;
    
    IF selected_puzzle_id IS NOT NULL THEN
        RETURN selected_puzzle_id;
    END IF;
    
    -- Tier 3: Puzzles not presented in 3+ months
    SELECT p.id INTO selected_puzzle_id
    FROM frisc_puzzles p
    WHERE p.id NOT IN (
        SELECT puzzle_id FROM frisc_puzzle_presentations 
        WHERE presented_date > CURRENT_DATE - INTERVAL '3 months'
    )
    ORDER BY RANDOM()
    LIMIT 1;
    
    IF selected_puzzle_id IS NOT NULL THEN
        RETURN selected_puzzle_id;
    END IF;
    
    -- Tier 4: Puzzles not presented in 1+ month
    SELECT p.id INTO selected_puzzle_id
    FROM frisc_puzzles p
    WHERE p.id NOT IN (
        SELECT puzzle_id FROM frisc_puzzle_presentations 
        WHERE presented_date > CURRENT_DATE - INTERVAL '1 month'
    )
    ORDER BY RANDOM()
    LIMIT 1;
    
    IF selected_puzzle_id IS NOT NULL THEN
        RETURN selected_puzzle_id;
    END IF;
    
    -- Tier 5: All puzzles except those presented in past 3 days
    SELECT p.id INTO selected_puzzle_id
    FROM frisc_puzzles p
    WHERE p.id NOT IN (
        SELECT puzzle_id FROM frisc_puzzle_presentations 
        WHERE presented_date > CURRENT_DATE - INTERVAL '3 days'
    )
    ORDER BY RANDOM()
    LIMIT 1;
    
    RETURN selected_puzzle_id;
END;
$$;


ALTER FUNCTION public.frisc_get_next_puzzle() OWNER TO postgres;

--
-- Name: frisc_get_past_puzzles(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.frisc_get_past_puzzles() RETURNS TABLE(puzzle_number integer, last_presented date, difficulty_tier integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  BEGIN
      RETURN QUERY
      SELECT
          p.puzzle_number,
          MAX(pp.presented_date)::date as last_presented,
          p.difficulty_tier
      FROM frisc_puzzles p
      LEFT JOIN frisc_puzzle_presentations pp ON p.id = pp.puzzle_id
      GROUP BY p.puzzle_number, p.difficulty_tier
      HAVING MAX(pp.presented_date) IS NOT NULL
      ORDER BY p.puzzle_number DESC;
  END;
  $$;


ALTER FUNCTION public.frisc_get_past_puzzles() OWNER TO postgres;

--
-- Name: frisc_get_puzzle_by_number(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.frisc_get_puzzle_by_number(puzzle_num integer) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'id', p.id,
        'puzzle_number', p.puzzle_number,
        'categories', json_agg(
            json_build_object(
                'id', c.id,
                'name', c.name,
                'difficulty', c.difficulty,
                'items', c.items
            ) ORDER BY c.difficulty
        )
    )
    INTO result
    FROM frisc_puzzles p
    JOIN frisc_categories c ON p.id = c.puzzle_id
    WHERE p.puzzle_number = puzzle_num
    GROUP BY p.id, p.puzzle_number;
    
    RETURN result;
END;
$$;


ALTER FUNCTION public.frisc_get_puzzle_by_number(puzzle_num integer) OWNER TO postgres;

--
-- Name: frisc_normalize_and_validate_category(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.frisc_normalize_and_validate_category() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Normalize data
    NEW.name := UPPER(TRIM(NEW.name));
    
    -- Normalize items array
    FOR i IN 1..array_length(NEW.items, 1) LOOP
        NEW.items[i] := UPPER(TRIM(NEW.items[i]));
    END LOOP;
    
    -- Validate data
    IF NEW.name IS NULL OR NEW.name = '' THEN
        RAISE EXCEPTION 'Category name cannot be empty';
    END IF;
    
    IF array_length(NEW.items, 1) != 4 THEN
        RAISE EXCEPTION 'Category must have exactly 4 items';
    END IF;
    
    -- Check for duplicate items within category
    IF (SELECT COUNT(*) FROM unnest(NEW.items) AS item) != 
       (SELECT COUNT(DISTINCT item) FROM unnest(NEW.items) AS item) THEN
        RAISE EXCEPTION 'Category cannot have duplicate items';
    END IF;
    
    -- Check for empty items
    IF EXISTS (SELECT 1 FROM unnest(NEW.items) AS item WHERE item IS NULL OR item = '') THEN
        RAISE EXCEPTION 'Category items cannot be empty';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.frisc_normalize_and_validate_category() OWNER TO postgres;

--
-- Name: frisc_update_puzzle_difficulty_tiers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.frisc_update_puzzle_difficulty_tiers() RETURNS TABLE(execution_time_ms integer, total_updated integer, easy_count integer, medium_count integer, hard_count integer)
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE
    start_time timestamp;
    easy_threshold numeric := 45.0;
    medium_threshold numeric := 30.0;
BEGIN
    start_time = clock_timestamp();
    
    WITH win_stats AS (
        SELECT 
            p.id,
            ROUND(
                COUNT(DISTINCT CASE WHEN s.completed THEN s.session_id END) * 100.0 / 
                COUNT(DISTINCT s.session_id), 1
            ) as win_rate
        FROM frisc_puzzles p
        LEFT JOIN frisc_anonymous_sessions s ON p.id = s.puzzle_id
        GROUP BY p.id
        HAVING COUNT(DISTINCT s.session_id) >= 10
    )
    UPDATE frisc_puzzles
    SET difficulty_tier = CASE
        WHEN win_stats.win_rate >= easy_threshold THEN 1
        WHEN win_stats.win_rate >= medium_threshold THEN 2
        ELSE 3
    END
    FROM win_stats
    WHERE frisc_puzzles.id = win_stats.id;
    
    RETURN QUERY
    SELECT 
        EXTRACT(milliseconds FROM clock_timestamp() - start_time)::integer,
        (SELECT COUNT(*) FROM frisc_puzzles WHERE difficulty_tier IS NOT NULL),
        (SELECT COUNT(*) FROM frisc_puzzles WHERE difficulty_tier = 1),
        (SELECT COUNT(*) FROM frisc_puzzles WHERE difficulty_tier = 2),
        (SELECT COUNT(*) FROM frisc_puzzles WHERE difficulty_tier = 3);
END;
$$;


ALTER FUNCTION public.frisc_update_puzzle_difficulty_tiers() OWNER TO postgres;

--
-- Name: frisc_validate_puzzle_composition(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.frisc_validate_puzzle_composition() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE
    puzzle_category_count INTEGER;
    difficulty_counts INTEGER[];
    all_items TEXT[];
BEGIN
    -- Only validate if puzzle_id is set
    IF NEW.puzzle_id IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Count categories for this puzzle
    SELECT COUNT(*) INTO puzzle_category_count
    FROM frisc_categories 
    WHERE puzzle_id = NEW.puzzle_id;
    
    -- Get difficulty distribution
    SELECT ARRAY[
        COUNT(*) FILTER (WHERE difficulty = 1),
        COUNT(*) FILTER (WHERE difficulty = 2), 
        COUNT(*) FILTER (WHERE difficulty = 3),
        COUNT(*) FILTER (WHERE difficulty = 4)
    ] INTO difficulty_counts
    FROM frisc_categories 
    WHERE puzzle_id = NEW.puzzle_id;
    
    -- Collect all items for duplicate check
    SELECT ARRAY_AGG(category_item) INTO all_items
    FROM frisc_categories c, UNNEST(c.items) AS category_item
    WHERE c.puzzle_id = NEW.puzzle_id;
    
    -- Validate rules
    IF puzzle_category_count > 4 THEN
        RAISE EXCEPTION 'Puzzle cannot have more than 4 categories';
    END IF;
    
    IF puzzle_category_count = 4 THEN
        IF difficulty_counts != ARRAY[1,1,1,1] THEN
            RAISE EXCEPTION 'Complete puzzle must have exactly one category of each difficulty (1,2,3,4)';
        END IF;
        
        IF ARRAY_LENGTH(all_items, 1) != 16 THEN
            RAISE EXCEPTION 'Complete puzzle must have exactly 16 items';
        END IF;
        
        -- Check for duplicates
        IF (SELECT COUNT(*) FROM UNNEST(all_items) AS check_item) != 
           (SELECT COUNT(DISTINCT check_item) FROM UNNEST(all_items) AS check_item) THEN
            RAISE EXCEPTION 'Puzzle cannot have duplicate items across categories';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.frisc_validate_puzzle_composition() OWNER TO postgres;

--
-- Name: get_daily_fjord_puzzle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_daily_fjord_puzzle() RETURNS TABLE(puzzle_id integer, puzzle_number integer, fjord_id integer, fjord_name text, svg_filename text, satellite_filename text, center_lat numeric, center_lng numeric, wikipedia_url_no text, wikipedia_url_en text, date date)
    LANGUAGE plpgsql
    AS $$BEGIN   
  RETURN QUERY   
  SELECT      
    dp.id as puzzle_id,     
    dp.puzzle_number,     
    f.id as fjord_id,     
    f.name as fjord_name,     
    f.svg_filename,
    f.satellite_filename,     
    f.center_lat,     
    f.center_lng,     
    f.wikipedia_url_no,     
    f.wikipedia_url_en,     
    dp.presented_date as date   
  FROM daily_puzzles dp   
  JOIN fjords f ON dp.fjord_id = f.id   
  WHERE dp.presented_date = CURRENT_DATE    
  LIMIT 1; 
END;$$;


ALTER FUNCTION public.get_daily_fjord_puzzle() OWNER TO postgres;

--
-- Name: get_fjord_puzzle_by_number(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_fjord_puzzle_by_number(puzzle_num integer) RETURNS TABLE(puzzle_id integer, puzzle_number integer, fjord_id integer, fjord_name text, svg_filename text, satellite_filename text, center_lat numeric, center_lng numeric, wikipedia_url_no text, wikipedia_url_en text, date date)
    LANGUAGE plpgsql
    AS $$BEGIN
  RETURN QUERY
  SELECT 
    dp.id as puzzle_id,
    dp.puzzle_number,
    f.id as fjord_id,
    f.name as fjord_name,
    f.svg_filename,
    f.satellite_filename,
    f.center_lat,
    f.center_lng,
    f.wikipedia_url_no,
    f.wikipedia_url_en,
    dp.presented_date as date
  FROM daily_puzzles dp
  JOIN fjords f ON dp.fjord_id = f.id
  WHERE dp.puzzle_number = puzzle_num;
END;$$;


ALTER FUNCTION public.get_fjord_puzzle_by_number(puzzle_num integer) OWNER TO postgres;

--
-- Name: get_past_puzzles(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_past_puzzles() RETURNS TABLE(puzzle_id integer, puzzle_number integer, fjord_name text, date date)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    dp.id as puzzle_id,
    dp.puzzle_number,
    f.name as fjord_name,
    dp.presented_date as date
  FROM daily_puzzles dp
  JOIN fjords f ON dp.fjord_id = f.id
  WHERE dp.presented_date < CURRENT_DATE
  ORDER BY dp.puzzle_number DESC;
END;
$$;


ALTER FUNCTION public.get_past_puzzles() OWNER TO postgres;

--
-- Name: update_difficulty_tiers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_difficulty_tiers() RETURNS TABLE(execution_time_ms integer, total_updated integer, easy_count integer, medium_count integer, hard_count integer, tier_changes integer)
    LANGUAGE plpgsql
    AS $$
DECLARE start_time TIMESTAMP;
end_time TIMESTAMP;
min_sessions INTEGER;
easy_threshold NUMERIC;
medium_threshold NUMERIC;
updated_count INTEGER;
easy_cnt INTEGER;
medium_cnt INTEGER;
hard_cnt INTEGER;
changes_cnt INTEGER;
qualified_fjords_count INTEGER;
BEGIN start_time := clock_timestamp();
SELECT LEAST(
        100,
        GREATEST(
            10,
            PERCENTILE_CONT(0.75) WITHIN GROUP (
                ORDER BY session_count
            )
        )
    )::INTEGER INTO min_sessions
FROM (
        SELECT COUNT(DISTINCT g.session_id) as session_count
        FROM daily_puzzles dp
            JOIN guesses g ON dp.id = g.puzzle_id
        GROUP BY dp.fjord_id
    ) session_counts;
SELECT COUNT(*) INTO qualified_fjords_count
FROM (
        SELECT dp.fjord_id
        FROM daily_puzzles dp
            JOIN guesses g ON dp.id = g.puzzle_id
        GROUP BY dp.fjord_id
        HAVING COUNT(DISTINCT g.session_id) >= min_sessions
    ) qualified_fjords;
IF qualified_fjords_count < 5 THEN easy_threshold := 45;
medium_threshold := 30;
ELSE
SELECT PERCENTILE_CONT(0.67) WITHIN GROUP (
        ORDER BY win_rate
    ),
    PERCENTILE_CONT(0.33) WITHIN GROUP (
        ORDER BY win_rate
    ) INTO easy_threshold,
    medium_threshold
FROM (
        SELECT ROUND(
                COUNT(
                    DISTINCT CASE
                        WHEN g.is_correct THEN g.session_id
                    END
                ) * 100.0 / COUNT(DISTINCT g.session_id),
                1
            ) as win_rate
        FROM daily_puzzles dp
            JOIN guesses g ON dp.id = g.puzzle_id
        GROUP BY dp.fjord_id
        HAVING COUNT(DISTINCT g.session_id) >= min_sessions
    ) qualified_rates;
END IF;
CREATE TEMP TABLE tier_changes_temp AS
SELECT id,
    difficulty_tier as old_tier
FROM fjords
WHERE difficulty_tier IS NOT NULL;
UPDATE fjords
SET difficulty_tier = CASE
        WHEN win_stats.win_rate >= easy_threshold THEN 1
        WHEN win_stats.win_rate >= medium_threshold THEN 2
        ELSE 3
    END
FROM (
        SELECT dp.fjord_id,
            ROUND(
                COUNT(
                    DISTINCT CASE
                        WHEN g.is_correct THEN g.session_id
                    END
                ) * 100.0 / COUNT(DISTINCT g.session_id),
                1
            ) as win_rate
        FROM daily_puzzles dp
            JOIN guesses g ON dp.id = g.puzzle_id
        GROUP BY dp.fjord_id
        HAVING COUNT(DISTINCT g.session_id) >= min_sessions
    ) win_stats
WHERE fjords.id = win_stats.fjord_id;
GET DIAGNOSTICS updated_count = ROW_COUNT;
SELECT COUNT(
        CASE
            WHEN difficulty_tier = 1 THEN 1
        END
    ),
    COUNT(
        CASE
            WHEN difficulty_tier = 2 THEN 1
        END
    ),
    COUNT(
        CASE
            WHEN difficulty_tier = 3 THEN 1
        END
    ) INTO easy_cnt,
    medium_cnt,
    hard_cnt
FROM fjords
WHERE difficulty_tier IS NOT NULL;
SELECT COUNT(*) INTO changes_cnt
FROM fjords f
    JOIN tier_changes_temp t ON f.id = t.id
WHERE f.difficulty_tier != t.old_tier;
end_time := clock_timestamp();
DROP TABLE tier_changes_temp;
RETURN QUERY
SELECT EXTRACT(
        MILLISECONDS
        FROM (end_time - start_time)
    )::INTEGER,
    updated_count,
    easy_cnt,
    medium_cnt,
    hard_cnt,
    changes_cnt;
EXCEPTION
WHEN OTHERS THEN DROP TABLE IF EXISTS tier_changes_temp;
RAISE;
END;
$$;


ALTER FUNCTION public.update_difficulty_tiers() OWNER TO postgres;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_
        -- Filter by action early - only get subscriptions interested in this action
        -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
        and (subs.action_filter = '*' or subs.action_filter = action::text);

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- Name: add_prefixes(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.add_prefixes(_bucket_id text, _name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION storage.add_prefixes(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: delete_leaf_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


ALTER FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix(_bucket_id text, _name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


ALTER FUNCTION storage.delete_prefix(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix_hierarchy_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION storage.delete_prefix_hierarchy_trigger() OWNER TO supabase_storage_admin;

--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION storage.enforce_bucket_name_length() OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION storage.get_level(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


ALTER FUNCTION storage.get_prefix(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


ALTER FUNCTION storage.get_prefixes(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: lock_top_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


ALTER FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: objects_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_insert_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_insert_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEW−OLD (added paths) and OLD−NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEW−OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLD−NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_update_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_level_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_level_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Set the new level
        NEW."level" := "storage"."get_level"(NEW."name");
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_level_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.prefixes_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.prefixes_insert_trigger() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v1_optimised(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


ALTER FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text, sort_order text, sort_column text, sort_column_after text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


ALTER TABLE auth.custom_oauth_providers OWNER TO supabase_auth_admin;

--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


ALTER TABLE auth.oauth_authorizations OWNER TO supabase_auth_admin;

--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE auth.oauth_client_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


ALTER TABLE auth.oauth_clients OWNER TO supabase_auth_admin;

--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


ALTER TABLE auth.oauth_consents OWNER TO supabase_auth_admin;

--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: guesses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.guesses (
    id integer NOT NULL,
    session_id text NOT NULL,
    puzzle_id integer NOT NULL,
    guessed_fjord_id integer NOT NULL,
    is_correct boolean NOT NULL,
    distance_km integer NOT NULL,
    proximity_percent integer NOT NULL,
    attempt_number integer NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.guesses OWNER TO postgres;

--
-- Name: anonymous_guesses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.anonymous_guesses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.anonymous_guesses_id_seq OWNER TO postgres;

--
-- Name: anonymous_guesses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.anonymous_guesses_id_seq OWNED BY public.guesses.id;


--
-- Name: cards_games; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cards_games (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    lobby_id uuid NOT NULL,
    state jsonb NOT NULL,
    current_player_id uuid,
    status text DEFAULT 'active'::text NOT NULL,
    result jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cards_games_status_values CHECK ((status = ANY (ARRAY['active'::text, 'completed'::text, 'abandoned'::text, 'forfeited'::text])))
);


ALTER TABLE public.cards_games OWNER TO postgres;

--
-- Name: cards_lobbies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cards_lobbies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    join_code text,
    host_id uuid NOT NULL,
    guest_id uuid,
    status text DEFAULT 'waiting'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    host_ready boolean DEFAULT false NOT NULL,
    guest_ready boolean DEFAULT false NOT NULL,
    host_faction text,
    host_leader text,
    guest_faction text,
    guest_leader text,
    host_confirmed boolean DEFAULT false NOT NULL,
    guest_confirmed boolean DEFAULT false NOT NULL,
    CONSTRAINT cards_lobbies_join_code_length CHECK ((char_length(join_code) = 6)),
    CONSTRAINT cards_lobbies_status_values CHECK ((status = ANY (ARRAY['waiting'::text, 'ready'::text, 'selecting'::text, 'in_progress'::text, 'completed'::text, 'expired'::text])))
);


ALTER TABLE public.cards_lobbies OWNER TO postgres;

--
-- Name: cards_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cards_profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    username text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cards_profiles_username_format CHECK ((username ~ '^[a-zA-Z0-9_]{3,20}$'::text))
);


ALTER TABLE public.cards_profiles OWNER TO postgres;

--
-- Name: cards_quick_match_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cards_quick_match_queue (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    display_name text NOT NULL,
    status text DEFAULT 'waiting'::text NOT NULL,
    lobby_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cards_quick_match_queue_status_values CHECK ((status = ANY (ARRAY['waiting'::text, 'matched'::text])))
);


ALTER TABLE public.cards_quick_match_queue OWNER TO postgres;

--
-- Name: daily_puzzles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.daily_puzzles (
    id integer NOT NULL,
    presented_date date NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    fjord_id integer,
    puzzle_number integer,
    last_presented_date date
);


ALTER TABLE public.daily_puzzles OWNER TO postgres;

--
-- Name: fjordle_counties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fjordle_counties (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.fjordle_counties OWNER TO postgres;

--
-- Name: fjordle_counties_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_counties ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fjordle_counties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fjordle_daily_puzzles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fjordle_daily_puzzles (
    id integer NOT NULL,
    presented_date date NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    fjord_id integer,
    puzzle_number integer,
    last_presented_date date
);


ALTER TABLE public.fjordle_daily_puzzles OWNER TO postgres;

--
-- Name: fjordle_daily_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_daily_puzzles ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fjordle_daily_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fjordle_fjord_counties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fjordle_fjord_counties (
    fjord_id integer NOT NULL,
    county_id integer NOT NULL
);


ALTER TABLE public.fjordle_fjord_counties OWNER TO postgres;

--
-- Name: fjordle_fjord_municipalities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fjordle_fjord_municipalities (
    fjord_id integer NOT NULL,
    municipality_id integer NOT NULL
);


ALTER TABLE public.fjordle_fjord_municipalities OWNER TO postgres;

--
-- Name: fjordle_fjords; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fjordle_fjords (
    id integer NOT NULL,
    name text NOT NULL,
    svg_filename text NOT NULL,
    center_lat numeric NOT NULL,
    center_lng numeric NOT NULL,
    difficulty_tier integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now(),
    fjordid text,
    wikipedia_url_no text,
    wikipedia_url_en text,
    quarantined boolean DEFAULT false,
    quarantine_reason text,
    quarantined_at timestamp without time zone,
    satellite_filename text,
    notes text,
    wikipedia_url_nn text,
    wikipedia_url_da text,
    wikipedia_url_ceb text,
    length_km numeric,
    width_km numeric,
    depth_m numeric,
    measurement_source_url text,
    slug text NOT NULL
);


ALTER TABLE public.fjordle_fjords OWNER TO postgres;

--
-- Name: fjordle_fjords_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_fjords ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fjordle_fjords_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fjordle_game_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fjordle_game_sessions (
    session_id text NOT NULL,
    puzzle_id integer NOT NULL,
    completed boolean DEFAULT false,
    attempts_used integer DEFAULT 0,
    won boolean DEFAULT false,
    start_time timestamp with time zone DEFAULT now(),
    end_time timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    hints jsonb DEFAULT '{"firstLetter": false}'::jsonb
);


ALTER TABLE public.fjordle_game_sessions OWNER TO postgres;

--
-- Name: fjordle_guesses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fjordle_guesses (
    id integer NOT NULL,
    session_id text NOT NULL,
    puzzle_id integer NOT NULL,
    guessed_fjord_id integer NOT NULL,
    is_correct boolean NOT NULL,
    distance_km integer NOT NULL,
    proximity_percent integer NOT NULL,
    attempt_number integer NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.fjordle_guesses OWNER TO postgres;

--
-- Name: fjordle_guesses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_guesses ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fjordle_guesses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fjordle_municipalities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fjordle_municipalities (
    id integer NOT NULL,
    name text NOT NULL,
    county_id integer
);


ALTER TABLE public.fjordle_municipalities OWNER TO postgres;

--
-- Name: fjordle_municipalities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_municipalities ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fjordle_municipalities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fjordle_puzzle_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fjordle_puzzle_queue (
    id integer NOT NULL,
    fjord_id integer NOT NULL,
    scheduled_date date NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    created_by text DEFAULT 'manual'::text
);


ALTER TABLE public.fjordle_puzzle_queue OWNER TO postgres;

--
-- Name: fjordle_puzzle_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_puzzle_queue ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fjordle_puzzle_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fjords; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fjords (
    id integer NOT NULL,
    name text NOT NULL,
    svg_filename text NOT NULL,
    center_lat numeric(10,8) NOT NULL,
    center_lng numeric(11,8) NOT NULL,
    difficulty_tier integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now(),
    fjordid text,
    wikipedia_url_no text,
    wikipedia_url_en text,
    quarantined boolean DEFAULT false,
    quarantine_reason text,
    quarantined_at timestamp without time zone,
    satellite_filename text,
    notes text,
    CONSTRAINT fjords_difficulty_tier_check CHECK ((difficulty_tier = ANY (ARRAY[1, 2, 3])))
);


ALTER TABLE public.fjords OWNER TO postgres;

--
-- Name: fjords_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fjords_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fjords_id_seq OWNER TO postgres;

--
-- Name: fjords_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fjords_id_seq OWNED BY public.fjords.id;


--
-- Name: frisc_anonymous_guesses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.frisc_anonymous_guesses (
    id integer NOT NULL,
    session_id text,
    puzzle_id integer,
    guessed_items text[] NOT NULL,
    item_difficulties integer[] NOT NULL,
    is_correct boolean NOT NULL,
    category_id integer,
    attempt_number integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now()
);


ALTER TABLE public.frisc_anonymous_guesses OWNER TO postgres;

--
-- Name: frisc_anonymous_guesses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.frisc_anonymous_guesses ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.frisc_anonymous_guesses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: frisc_anonymous_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.frisc_anonymous_sessions (
    session_id text NOT NULL,
    puzzle_id integer NOT NULL,
    completed boolean DEFAULT false,
    attempts_used integer DEFAULT 0,
    solved_categories integer[] DEFAULT '{}'::integer[],
    start_time timestamp without time zone DEFAULT now(),
    end_time timestamp without time zone
);


ALTER TABLE public.frisc_anonymous_sessions OWNER TO postgres;

--
-- Name: frisc_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.frisc_categories (
    id integer NOT NULL,
    puzzle_id integer,
    name text NOT NULL,
    difficulty integer NOT NULL,
    items text[] NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.frisc_categories OWNER TO postgres;

--
-- Name: frisc_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.frisc_categories ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.frisc_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: frisc_category_staging; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.frisc_category_staging (
    name text,
    difficulty integer,
    item1 text,
    item2 text,
    item3 text,
    item4 text
);


ALTER TABLE public.frisc_category_staging OWNER TO postgres;

--
-- Name: frisc_puzzle_presentations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.frisc_puzzle_presentations (
    id integer NOT NULL,
    puzzle_id integer,
    presented_date date NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.frisc_puzzle_presentations OWNER TO postgres;

--
-- Name: frisc_puzzle_presentations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.frisc_puzzle_presentations ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.frisc_puzzle_presentations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: frisc_puzzle_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.frisc_puzzle_queue (
    queue_position integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    scheduled_date date,
    published boolean DEFAULT false,
    puzzle_id integer NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE public.frisc_puzzle_queue OWNER TO postgres;

--
-- Name: frisc_puzzles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.frisc_puzzles (
    id integer NOT NULL,
    puzzle_number integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    difficulty_tier integer DEFAULT 1
);


ALTER TABLE public.frisc_puzzles OWNER TO postgres;

--
-- Name: frisc_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.frisc_puzzles ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.frisc_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: game_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.game_sessions (
    session_id text NOT NULL,
    puzzle_id integer NOT NULL,
    completed boolean DEFAULT false,
    attempts_used integer DEFAULT 0,
    won boolean DEFAULT false,
    start_time timestamp with time zone DEFAULT now(),
    end_time timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    hints jsonb DEFAULT '{"firstLetter": false}'::jsonb
);


ALTER TABLE public.game_sessions OWNER TO postgres;

--
-- Name: puzzle_presentations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.puzzle_presentations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.puzzle_presentations_id_seq OWNER TO postgres;

--
-- Name: puzzle_presentations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.puzzle_presentations_id_seq OWNED BY public.daily_puzzles.id;


--
-- Name: puzzle_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.puzzle_queue (
    id integer NOT NULL,
    fjord_id integer NOT NULL,
    scheduled_date date NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    created_by text DEFAULT 'manual'::text,
    CONSTRAINT puzzle_queue_scheduled_date_check CHECK ((scheduled_date >= CURRENT_DATE))
);


ALTER TABLE public.puzzle_queue OWNER TO postgres;

--
-- Name: puzzle_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.puzzle_queue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.puzzle_queue_id_seq OWNER TO postgres;

--
-- Name: puzzle_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.puzzle_queue_id_seq OWNED BY public.puzzle_queue.id;


--
-- Name: violets_completions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.violets_completions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid,
    completed_at timestamp with time zone DEFAULT now(),
    ending_node_id text NOT NULL,
    completion_number integer NOT NULL
);


ALTER TABLE public.violets_completions OWNER TO postgres;

--
-- Name: violets_game_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.violets_game_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id text NOT NULL,
    current_node_id text NOT NULL,
    visited_nodes text[] DEFAULT '{}'::text[],
    choices jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.violets_game_sessions OWNER TO postgres;

--
-- Name: violets_node_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.violets_node_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    node_id text NOT NULL,
    version_number integer NOT NULL,
    content_json jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.violets_node_versions OWNER TO postgres;

--
-- Name: violets_player_choices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.violets_player_choices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid,
    node_id text NOT NULL,
    choice_index integer NOT NULL,
    next_node_id text NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now()
);


ALTER TABLE public.violets_player_choices OWNER TO postgres;

--
-- Name: violets_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.violets_sessions (
    session_id uuid DEFAULT gen_random_uuid() NOT NULL,
    started_at timestamp with time zone DEFAULT now(),
    device_type text
);


ALTER TABLE public.violets_sessions OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: messages_2026_02_28; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_02_28 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_02_28 OWNER TO supabase_admin;

--
-- Name: messages_2026_03_01; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_03_01 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_03_01 OWNER TO supabase_admin;

--
-- Name: messages_2026_03_02; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_03_02 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_03_02 OWNER TO supabase_admin;

--
-- Name: messages_2026_03_03; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_03_03 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_03_03 OWNER TO supabase_admin;

--
-- Name: messages_2026_03_04; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_03_04 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_03_04 OWNER TO supabase_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE storage.buckets_analytics OWNER TO supabase_storage_admin;

--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.buckets_vectors OWNER TO supabase_storage_admin;

--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    level integer
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.prefixes (
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    level integer GENERATED ALWAYS AS (storage.get_level(name)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE storage.prefixes OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.vector_indexes OWNER TO supabase_storage_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: postgres
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text
);


ALTER TABLE supabase_migrations.schema_migrations OWNER TO postgres;

--
-- Name: messages_2026_02_28; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_02_28 FOR VALUES FROM ('2026-02-28 00:00:00') TO ('2026-03-01 00:00:00');


--
-- Name: messages_2026_03_01; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_01 FOR VALUES FROM ('2026-03-01 00:00:00') TO ('2026-03-02 00:00:00');


--
-- Name: messages_2026_03_02; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_02 FOR VALUES FROM ('2026-03-02 00:00:00') TO ('2026-03-03 00:00:00');


--
-- Name: messages_2026_03_03; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_03 FOR VALUES FROM ('2026-03-03 00:00:00') TO ('2026-03-04 00:00:00');


--
-- Name: messages_2026_03_04; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_04 FOR VALUES FROM ('2026-03-04 00:00:00') TO ('2026-03-05 00:00:00');


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: daily_puzzles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_puzzles ALTER COLUMN id SET DEFAULT nextval('public.puzzle_presentations_id_seq'::regclass);


--
-- Name: fjords id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjords ALTER COLUMN id SET DEFAULT nextval('public.fjords_id_seq'::regclass);


--
-- Name: guesses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guesses ALTER COLUMN id SET DEFAULT nextval('public.anonymous_guesses_id_seq'::regclass);


--
-- Name: puzzle_queue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puzzle_queue ALTER COLUMN id SET DEFAULT nextval('public.puzzle_queue_id_seq'::regclass);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: guesses anonymous_guesses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guesses
    ADD CONSTRAINT anonymous_guesses_pkey PRIMARY KEY (id);


--
-- Name: game_sessions anonymous_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_sessions
    ADD CONSTRAINT anonymous_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: cards_games cards_games_lobby_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_games
    ADD CONSTRAINT cards_games_lobby_id_unique UNIQUE (lobby_id);


--
-- Name: cards_games cards_games_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_games
    ADD CONSTRAINT cards_games_pkey PRIMARY KEY (id);


--
-- Name: cards_lobbies cards_lobbies_join_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_lobbies
    ADD CONSTRAINT cards_lobbies_join_code_key UNIQUE (join_code);


--
-- Name: cards_lobbies cards_lobbies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_lobbies
    ADD CONSTRAINT cards_lobbies_pkey PRIMARY KEY (id);


--
-- Name: cards_profiles cards_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_profiles
    ADD CONSTRAINT cards_profiles_pkey PRIMARY KEY (id);


--
-- Name: cards_profiles cards_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_profiles
    ADD CONSTRAINT cards_profiles_user_id_key UNIQUE (user_id);


--
-- Name: cards_profiles cards_profiles_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_profiles
    ADD CONSTRAINT cards_profiles_username_key UNIQUE (username);


--
-- Name: cards_quick_match_queue cards_quick_match_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_quick_match_queue
    ADD CONSTRAINT cards_quick_match_queue_pkey PRIMARY KEY (id);


--
-- Name: cards_quick_match_queue cards_quick_match_queue_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_quick_match_queue
    ADD CONSTRAINT cards_quick_match_queue_user_id_key UNIQUE (user_id);


--
-- Name: daily_puzzles daily_puzzles_presented_date_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_puzzles
    ADD CONSTRAINT daily_puzzles_presented_date_unique UNIQUE (presented_date);


--
-- Name: daily_puzzles daily_puzzles_puzzle_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_puzzles
    ADD CONSTRAINT daily_puzzles_puzzle_number_key UNIQUE (puzzle_number);


--
-- Name: fjordle_counties fjordle_counties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_counties
    ADD CONSTRAINT fjordle_counties_pkey PRIMARY KEY (id);


--
-- Name: fjordle_daily_puzzles fjordle_daily_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_daily_puzzles
    ADD CONSTRAINT fjordle_daily_puzzles_pkey PRIMARY KEY (id);


--
-- Name: fjordle_fjord_counties fjordle_fjord_counties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_fjord_counties
    ADD CONSTRAINT fjordle_fjord_counties_pkey PRIMARY KEY (fjord_id, county_id);


--
-- Name: fjordle_fjord_municipalities fjordle_fjord_municipalities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_fjord_municipalities
    ADD CONSTRAINT fjordle_fjord_municipalities_pkey PRIMARY KEY (fjord_id, municipality_id);


--
-- Name: fjordle_fjords fjordle_fjords_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_fjords
    ADD CONSTRAINT fjordle_fjords_pkey PRIMARY KEY (id);


--
-- Name: fjordle_fjords fjordle_fjords_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_fjords
    ADD CONSTRAINT fjordle_fjords_slug_key UNIQUE (slug);


--
-- Name: fjordle_game_sessions fjordle_game_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_game_sessions
    ADD CONSTRAINT fjordle_game_sessions_pkey PRIMARY KEY (session_id, puzzle_id);


--
-- Name: fjordle_guesses fjordle_guesses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_guesses
    ADD CONSTRAINT fjordle_guesses_pkey PRIMARY KEY (id);


--
-- Name: fjordle_municipalities fjordle_municipalities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_municipalities
    ADD CONSTRAINT fjordle_municipalities_pkey PRIMARY KEY (id);


--
-- Name: fjordle_puzzle_queue fjordle_puzzle_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_puzzle_queue
    ADD CONSTRAINT fjordle_puzzle_queue_pkey PRIMARY KEY (id);


--
-- Name: fjords fjords_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjords
    ADD CONSTRAINT fjords_pkey PRIMARY KEY (id);


--
-- Name: frisc_anonymous_guesses frisc_anonymous_guesses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_anonymous_guesses
    ADD CONSTRAINT frisc_anonymous_guesses_pkey PRIMARY KEY (id);


--
-- Name: frisc_anonymous_sessions frisc_anonymous_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_anonymous_sessions
    ADD CONSTRAINT frisc_anonymous_sessions_pkey PRIMARY KEY (session_id, puzzle_id);


--
-- Name: frisc_categories frisc_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_categories
    ADD CONSTRAINT frisc_categories_pkey PRIMARY KEY (id);


--
-- Name: frisc_puzzle_presentations frisc_puzzle_presentations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_puzzle_presentations
    ADD CONSTRAINT frisc_puzzle_presentations_pkey PRIMARY KEY (id);


--
-- Name: frisc_puzzle_presentations frisc_puzzle_presentations_puzzle_presented_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_puzzle_presentations
    ADD CONSTRAINT frisc_puzzle_presentations_puzzle_presented_unique UNIQUE (puzzle_id, presented_date);


--
-- Name: frisc_puzzle_queue frisc_puzzle_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_puzzle_queue
    ADD CONSTRAINT frisc_puzzle_queue_pkey PRIMARY KEY (puzzle_id);


--
-- Name: frisc_puzzles frisc_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_puzzles
    ADD CONSTRAINT frisc_puzzles_pkey PRIMARY KEY (id);


--
-- Name: frisc_puzzles frisc_puzzles_puzzle_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_puzzles
    ADD CONSTRAINT frisc_puzzles_puzzle_number_key UNIQUE (puzzle_number);


--
-- Name: daily_puzzles puzzle_presentations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_puzzles
    ADD CONSTRAINT puzzle_presentations_pkey PRIMARY KEY (id);


--
-- Name: puzzle_queue puzzle_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puzzle_queue
    ADD CONSTRAINT puzzle_queue_pkey PRIMARY KEY (id);


--
-- Name: puzzle_queue puzzle_queue_scheduled_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puzzle_queue
    ADD CONSTRAINT puzzle_queue_scheduled_date_key UNIQUE (scheduled_date);


--
-- Name: violets_completions violets_completions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.violets_completions
    ADD CONSTRAINT violets_completions_pkey PRIMARY KEY (id);


--
-- Name: violets_game_sessions violets_game_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.violets_game_sessions
    ADD CONSTRAINT violets_game_sessions_pkey PRIMARY KEY (id);


--
-- Name: violets_node_versions violets_node_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.violets_node_versions
    ADD CONSTRAINT violets_node_versions_pkey PRIMARY KEY (id);


--
-- Name: violets_player_choices violets_player_choices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.violets_player_choices
    ADD CONSTRAINT violets_player_choices_pkey PRIMARY KEY (id);


--
-- Name: violets_sessions violets_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.violets_sessions
    ADD CONSTRAINT violets_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_02_28 messages_2026_02_28_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_02_28
    ADD CONSTRAINT messages_2026_02_28_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_01 messages_2026_03_01_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_03_01
    ADD CONSTRAINT messages_2026_03_01_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_02 messages_2026_03_02_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_03_02
    ADD CONSTRAINT messages_2026_03_02_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_03 messages_2026_03_03_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_03_03
    ADD CONSTRAINT messages_2026_03_03_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_04 messages_2026_03_04_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_03_04
    ADD CONSTRAINT messages_2026_03_04_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: cards_games_lobby_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cards_games_lobby_id_idx ON public.cards_games USING btree (lobby_id);


--
-- Name: cards_lobbies_host_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cards_lobbies_host_id_idx ON public.cards_lobbies USING btree (host_id);


--
-- Name: cards_lobbies_join_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cards_lobbies_join_code_idx ON public.cards_lobbies USING btree (join_code);


--
-- Name: cards_quick_match_queue_waiting_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cards_quick_match_queue_waiting_idx ON public.cards_quick_match_queue USING btree (created_at) WHERE (status = 'waiting'::text);


--
-- Name: idx_daily_puzzles_last_presented; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daily_puzzles_last_presented ON public.daily_puzzles USING btree (last_presented_date);


--
-- Name: idx_puzzle_queue_scheduled_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_puzzle_queue_scheduled_date ON public.puzzle_queue USING btree (scheduled_date);


--
-- Name: idx_violets_completions_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_violets_completions_session_id ON public.violets_completions USING btree (session_id);


--
-- Name: idx_violets_game_sessions_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_violets_game_sessions_session_id ON public.violets_game_sessions USING btree (session_id);


--
-- Name: idx_violets_node_versions_node_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_violets_node_versions_node_id ON public.violets_node_versions USING btree (node_id);


--
-- Name: idx_violets_player_choices_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_violets_player_choices_session_id ON public.violets_player_choices USING btree (session_id);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_02_28_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_02_28_inserted_at_topic_idx ON realtime.messages_2026_02_28 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_01_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_03_01_inserted_at_topic_idx ON realtime.messages_2026_03_01 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_02_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_03_02_inserted_at_topic_idx ON realtime.messages_2026_03_02 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_03_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_03_03_inserted_at_topic_idx ON realtime.messages_2026_03_03 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_04_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_03_04_inserted_at_topic_idx ON realtime.messages_2026_03_04 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_action_filter_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_key ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: messages_2026_02_28_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_02_28_inserted_at_topic_idx;


--
-- Name: messages_2026_02_28_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_02_28_pkey;


--
-- Name: messages_2026_03_01_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_01_inserted_at_topic_idx;


--
-- Name: messages_2026_03_01_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_01_pkey;


--
-- Name: messages_2026_03_02_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_02_inserted_at_topic_idx;


--
-- Name: messages_2026_03_02_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_02_pkey;


--
-- Name: messages_2026_03_03_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_03_inserted_at_topic_idx;


--
-- Name: messages_2026_03_03_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_03_pkey;


--
-- Name: messages_2026_03_04_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_04_inserted_at_topic_idx;


--
-- Name: messages_2026_03_04_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_04_pkey;


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.cards_handle_new_user();


--
-- Name: frisc_puzzle_queue auto_queue_position; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER auto_queue_position BEFORE INSERT ON public.frisc_puzzle_queue FOR EACH ROW EXECUTE FUNCTION public.frisc_auto_assign_queue_position();


--
-- Name: cards_games cards_games_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER cards_games_updated_at BEFORE UPDATE ON public.cards_games FOR EACH ROW EXECUTE FUNCTION public.cards_update_games_updated_at();


--
-- Name: frisc_categories validate_category_data; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validate_category_data BEFORE INSERT OR UPDATE ON public.frisc_categories FOR EACH ROW EXECUTE FUNCTION public.frisc_normalize_and_validate_category();


--
-- Name: frisc_categories validate_puzzle_data; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validate_puzzle_data BEFORE INSERT OR UPDATE ON public.frisc_categories FOR EACH ROW EXECUTE FUNCTION public.frisc_validate_puzzle_composition();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: guesses anonymous_guesses_guessed_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guesses
    ADD CONSTRAINT anonymous_guesses_guessed_fjord_id_fkey FOREIGN KEY (guessed_fjord_id) REFERENCES public.fjords(id);


--
-- Name: guesses anonymous_guesses_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guesses
    ADD CONSTRAINT anonymous_guesses_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.game_sessions(session_id);


--
-- Name: cards_games cards_games_current_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_games
    ADD CONSTRAINT cards_games_current_player_id_fkey FOREIGN KEY (current_player_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: cards_games cards_games_lobby_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_games
    ADD CONSTRAINT cards_games_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.cards_lobbies(id) ON DELETE CASCADE;


--
-- Name: cards_lobbies cards_lobbies_guest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_lobbies
    ADD CONSTRAINT cards_lobbies_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: cards_lobbies cards_lobbies_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_lobbies
    ADD CONSTRAINT cards_lobbies_host_id_fkey FOREIGN KEY (host_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: cards_profiles cards_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_profiles
    ADD CONSTRAINT cards_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: cards_quick_match_queue cards_quick_match_queue_lobby_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_quick_match_queue
    ADD CONSTRAINT cards_quick_match_queue_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.cards_lobbies(id) ON DELETE SET NULL;


--
-- Name: cards_quick_match_queue cards_quick_match_queue_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards_quick_match_queue
    ADD CONSTRAINT cards_quick_match_queue_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: daily_puzzles daily_puzzles_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daily_puzzles
    ADD CONSTRAINT daily_puzzles_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjords(id);


--
-- Name: fjordle_daily_puzzles fjordle_daily_puzzles_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_daily_puzzles
    ADD CONSTRAINT fjordle_daily_puzzles_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjordle_fjords(id);


--
-- Name: fjordle_fjord_counties fjordle_fjord_counties_county_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_fjord_counties
    ADD CONSTRAINT fjordle_fjord_counties_county_id_fkey FOREIGN KEY (county_id) REFERENCES public.fjordle_counties(id);


--
-- Name: fjordle_fjord_counties fjordle_fjord_counties_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_fjord_counties
    ADD CONSTRAINT fjordle_fjord_counties_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjordle_fjords(id);


--
-- Name: fjordle_fjord_municipalities fjordle_fjord_municipalities_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_fjord_municipalities
    ADD CONSTRAINT fjordle_fjord_municipalities_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjordle_fjords(id);


--
-- Name: fjordle_fjord_municipalities fjordle_fjord_municipalities_municipality_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_fjord_municipalities
    ADD CONSTRAINT fjordle_fjord_municipalities_municipality_id_fkey FOREIGN KEY (municipality_id) REFERENCES public.fjordle_municipalities(id);


--
-- Name: fjordle_guesses fjordle_guesses_guessed_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_guesses
    ADD CONSTRAINT fjordle_guesses_guessed_fjord_id_fkey FOREIGN KEY (guessed_fjord_id) REFERENCES public.fjordle_fjords(id);


--
-- Name: fjordle_municipalities fjordle_municipalities_county_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_municipalities
    ADD CONSTRAINT fjordle_municipalities_county_id_fkey FOREIGN KEY (county_id) REFERENCES public.fjordle_counties(id);


--
-- Name: fjordle_puzzle_queue fjordle_puzzle_queue_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fjordle_puzzle_queue
    ADD CONSTRAINT fjordle_puzzle_queue_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjordle_fjords(id);


--
-- Name: frisc_anonymous_guesses frisc_anonymous_guesses_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_anonymous_guesses
    ADD CONSTRAINT frisc_anonymous_guesses_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.frisc_categories(id);


--
-- Name: frisc_anonymous_guesses frisc_anonymous_guesses_puzzle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_anonymous_guesses
    ADD CONSTRAINT frisc_anonymous_guesses_puzzle_id_fkey FOREIGN KEY (puzzle_id) REFERENCES public.frisc_puzzles(id);


--
-- Name: frisc_anonymous_sessions frisc_anonymous_sessions_puzzle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_anonymous_sessions
    ADD CONSTRAINT frisc_anonymous_sessions_puzzle_id_fkey FOREIGN KEY (puzzle_id) REFERENCES public.frisc_puzzles(id);


--
-- Name: frisc_categories frisc_categories_puzzle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_categories
    ADD CONSTRAINT frisc_categories_puzzle_id_fkey FOREIGN KEY (puzzle_id) REFERENCES public.frisc_puzzles(id);


--
-- Name: frisc_puzzle_presentations frisc_puzzle_presentations_puzzle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_puzzle_presentations
    ADD CONSTRAINT frisc_puzzle_presentations_puzzle_id_fkey FOREIGN KEY (puzzle_id) REFERENCES public.frisc_puzzles(id);


--
-- Name: frisc_puzzle_queue frisc_puzzle_queue_puzzle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.frisc_puzzle_queue
    ADD CONSTRAINT frisc_puzzle_queue_puzzle_id_fkey FOREIGN KEY (puzzle_id) REFERENCES public.frisc_puzzles(id);


--
-- Name: puzzle_queue puzzle_queue_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.puzzle_queue
    ADD CONSTRAINT puzzle_queue_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjords(id);


--
-- Name: violets_completions violets_completions_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.violets_completions
    ADD CONSTRAINT violets_completions_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.violets_sessions(session_id);


--
-- Name: violets_player_choices violets_player_choices_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.violets_player_choices
    ADD CONSTRAINT violets_player_choices_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.violets_sessions(session_id);


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: violets_completions Allow anonymous access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow anonymous access" ON public.violets_completions USING (true);


--
-- Name: violets_game_sessions Allow anonymous access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow anonymous access" ON public.violets_game_sessions USING (true);


--
-- Name: violets_node_versions Allow anonymous access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow anonymous access" ON public.violets_node_versions USING (true);


--
-- Name: violets_player_choices Allow anonymous access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow anonymous access" ON public.violets_player_choices USING (true);


--
-- Name: violets_sessions Allow anonymous access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow anonymous access" ON public.violets_sessions USING (true);


--
-- Name: frisc_anonymous_guesses Allow anonymous guess tracking; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow anonymous guess tracking" ON public.frisc_anonymous_guesses FOR INSERT WITH CHECK (true);


--
-- Name: frisc_categories Allow anonymous read categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow anonymous read categories" ON public.frisc_categories FOR SELECT USING (((puzzle_id IN ( SELECT frisc_puzzle_queue.puzzle_id
   FROM public.frisc_puzzle_queue
  WHERE (frisc_puzzle_queue.published = true))) OR (puzzle_id IS NULL)));


--
-- Name: frisc_puzzles Allow anonymous read published puzzles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow anonymous read published puzzles" ON public.frisc_puzzles FOR SELECT USING ((id IN ( SELECT frisc_puzzle_queue.puzzle_id
   FROM public.frisc_puzzle_queue
  WHERE (frisc_puzzle_queue.published = true))));


--
-- Name: frisc_anonymous_sessions Allow anonymous session management; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow anonymous session management" ON public.frisc_anonymous_sessions USING (true);


--
-- Name: frisc_category_staging Allow public read access to category staging; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to category staging" ON public.frisc_category_staging FOR SELECT USING (true);


--
-- Name: fjordle_counties Allow public read access to counties; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to counties" ON public.fjordle_counties FOR SELECT USING (true);


--
-- Name: fjordle_fjord_counties Allow public read access to fjord-county relationships; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to fjord-county relationships" ON public.fjordle_fjord_counties FOR SELECT USING (true);


--
-- Name: fjordle_fjord_municipalities Allow public read access to fjord-municipality relationships; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to fjord-municipality relationships" ON public.fjordle_fjord_municipalities FOR SELECT USING (true);


--
-- Name: fjordle_municipalities Allow public read access to municipalities; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to municipalities" ON public.fjordle_municipalities FOR SELECT USING (true);


--
-- Name: frisc_puzzle_presentations Allow public read access to puzzle presentations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to puzzle presentations" ON public.frisc_puzzle_presentations FOR SELECT USING (true);


--
-- Name: fjordle_puzzle_queue Allow public read access to puzzle queue; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to puzzle queue" ON public.fjordle_puzzle_queue FOR SELECT USING (true);


--
-- Name: frisc_puzzle_queue Allow public read access to puzzle queue; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to puzzle queue" ON public.frisc_puzzle_queue FOR SELECT USING (true);


--
-- Name: cards_profiles Anyone can read profiles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can read profiles" ON public.cards_profiles FOR SELECT USING (true);


--
-- Name: cards_quick_match_queue Authenticated users can insert own queue entry; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can insert own queue entry" ON public.cards_quick_match_queue FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: cards_games Host can insert game; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Host can insert game" ON public.cards_games FOR INSERT WITH CHECK ((auth.uid() IN ( SELECT cards_lobbies.host_id
   FROM public.cards_lobbies
  WHERE (cards_lobbies.id = cards_games.lobby_id))));


--
-- Name: cards_games Players can read their own games; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Players can read their own games" ON public.cards_games FOR SELECT USING (((auth.uid() IN ( SELECT cards_lobbies.host_id
   FROM public.cards_lobbies
  WHERE (cards_lobbies.id = cards_games.lobby_id))) OR (auth.uid() IN ( SELECT cards_lobbies.guest_id
   FROM public.cards_lobbies
  WHERE (cards_lobbies.id = cards_games.lobby_id)))));


--
-- Name: cards_lobbies Players can read their own lobbies; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Players can read their own lobbies" ON public.cards_lobbies FOR SELECT USING (((auth.uid() = host_id) OR (auth.uid() = guest_id)));


--
-- Name: cards_games Players can update their own games; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Players can update their own games" ON public.cards_games FOR UPDATE USING (((auth.uid() IN ( SELECT cards_lobbies.host_id
   FROM public.cards_lobbies
  WHERE (cards_lobbies.id = cards_games.lobby_id))) OR (auth.uid() IN ( SELECT cards_lobbies.guest_id
   FROM public.cards_lobbies
  WHERE (cards_lobbies.id = cards_games.lobby_id)))));


--
-- Name: cards_lobbies Players can update their own lobbies; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Players can update their own lobbies" ON public.cards_lobbies FOR UPDATE USING (((auth.uid() = host_id) OR (auth.uid() = guest_id)));


--
-- Name: fjordle_game_sessions Public insert access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public insert access" ON public.fjordle_game_sessions FOR INSERT WITH CHECK (true);


--
-- Name: fjordle_guesses Public insert access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public insert access" ON public.fjordle_guesses FOR INSERT WITH CHECK (true);


--
-- Name: game_sessions Public insert access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public insert access" ON public.game_sessions FOR INSERT WITH CHECK (true);


--
-- Name: guesses Public insert access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public insert access" ON public.guesses FOR INSERT WITH CHECK (true);


--
-- Name: daily_puzzles Public read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read access" ON public.daily_puzzles FOR SELECT USING (true);


--
-- Name: fjordle_daily_puzzles Public read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read access" ON public.fjordle_daily_puzzles FOR SELECT USING (true);


--
-- Name: fjordle_fjords Public read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read access" ON public.fjordle_fjords FOR SELECT USING (true);


--
-- Name: fjordle_game_sessions Public read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read access" ON public.fjordle_game_sessions FOR SELECT USING (true);


--
-- Name: fjordle_guesses Public read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read access" ON public.fjordle_guesses FOR SELECT USING (true);


--
-- Name: fjords Public read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read access" ON public.fjords FOR SELECT USING (true);


--
-- Name: game_sessions Public read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read access" ON public.game_sessions FOR SELECT USING (true);


--
-- Name: guesses Public read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read access" ON public.guesses FOR SELECT USING (true);


--
-- Name: fjordle_game_sessions Public update access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public update access" ON public.fjordle_game_sessions FOR UPDATE USING (true);


--
-- Name: game_sessions Public update access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public update access" ON public.game_sessions FOR UPDATE USING (true);


--
-- Name: cards_lobbies Registered users can create lobbies as host; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Registered users can create lobbies as host" ON public.cards_lobbies FOR INSERT WITH CHECK (((auth.uid() = host_id) AND (NOT COALESCE(((auth.jwt() ->> 'is_anonymous'::text))::boolean, false))));


--
-- Name: cards_profiles Registered users can insert own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Registered users can insert own profile" ON public.cards_profiles FOR INSERT WITH CHECK (((auth.uid() = user_id) AND (NOT COALESCE(((auth.jwt() ->> 'is_anonymous'::text))::boolean, false))));


--
-- Name: cards_profiles Registered users can update own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Registered users can update own profile" ON public.cards_profiles FOR UPDATE USING (((auth.uid() = user_id) AND (NOT COALESCE(((auth.jwt() ->> 'is_anonymous'::text))::boolean, false))));


--
-- Name: cards_quick_match_queue Users can delete own queue entry; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete own queue entry" ON public.cards_quick_match_queue FOR DELETE USING ((auth.uid() = user_id));


--
-- Name: cards_quick_match_queue Users can read own queue entry; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can read own queue entry" ON public.cards_quick_match_queue FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: cards_games; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cards_games ENABLE ROW LEVEL SECURITY;

--
-- Name: cards_lobbies; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cards_lobbies ENABLE ROW LEVEL SECURITY;

--
-- Name: cards_profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cards_profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: cards_quick_match_queue; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cards_quick_match_queue ENABLE ROW LEVEL SECURITY;

--
-- Name: daily_puzzles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.daily_puzzles ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_counties; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_counties ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_daily_puzzles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_daily_puzzles ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_fjord_counties; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_fjord_counties ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_fjord_municipalities; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_fjord_municipalities ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_fjords; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_fjords ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_game_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_game_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_guesses; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_guesses ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_municipalities; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_municipalities ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_puzzle_queue; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.fjordle_puzzle_queue ENABLE ROW LEVEL SECURITY;

--
-- Name: fjords; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.fjords ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_anonymous_guesses; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.frisc_anonymous_guesses ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_anonymous_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.frisc_anonymous_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_categories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.frisc_categories ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_category_staging; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.frisc_category_staging ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_puzzle_presentations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.frisc_puzzle_presentations ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_puzzle_queue; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.frisc_puzzle_queue ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_puzzles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.frisc_puzzles ENABLE ROW LEVEL SECURITY;

--
-- Name: game_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.game_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: guesses; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.guesses ENABLE ROW LEVEL SECURITY;

--
-- Name: violets_completions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.violets_completions ENABLE ROW LEVEL SECURITY;

--
-- Name: violets_game_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.violets_game_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: violets_node_versions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.violets_node_versions ENABLE ROW LEVEL SECURITY;

--
-- Name: violets_player_choices; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.violets_player_choices ENABLE ROW LEVEL SECURITY;

--
-- Name: violets_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.violets_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: supabase_realtime_messages_publication; Type: PUBLICATION; Schema: -; Owner: supabase_admin
--

CREATE PUBLICATION supabase_realtime_messages_publication WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime_messages_publication OWNER TO supabase_admin;

--
-- Name: supabase_realtime cards_lobbies; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.cards_lobbies;


--
-- Name: supabase_realtime cards_quick_match_queue; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.cards_quick_match_queue;


--
-- Name: supabase_realtime_messages_publication messages; Type: PUBLICATION TABLE; Schema: realtime; Owner: supabase_admin
--

ALTER PUBLICATION supabase_realtime_messages_publication ADD TABLE ONLY realtime.messages;


--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA storage TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: SCHEMA vault; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea, text[], text[]) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.crypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.dearmor(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_bytes(integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_uuid() FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text, integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO dashboard_user;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_key_id(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1mc() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v4() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_nil() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_dns() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_oid() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_url() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_x500() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- Name: FUNCTION assign_daily_puzzle(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.assign_daily_puzzle() TO anon;
GRANT ALL ON FUNCTION public.assign_daily_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.assign_daily_puzzle() TO service_role;


--
-- Name: FUNCTION cards_confirm_selection(p_lobby_id uuid, p_faction text, p_leader text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.cards_confirm_selection(p_lobby_id uuid, p_faction text, p_leader text) TO anon;
GRANT ALL ON FUNCTION public.cards_confirm_selection(p_lobby_id uuid, p_faction text, p_leader text) TO authenticated;
GRANT ALL ON FUNCTION public.cards_confirm_selection(p_lobby_id uuid, p_faction text, p_leader text) TO service_role;


--
-- Name: FUNCTION cards_create_game(p_lobby_id uuid, p_state jsonb, p_current_player_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.cards_create_game(p_lobby_id uuid, p_state jsonb, p_current_player_id uuid) TO anon;
GRANT ALL ON FUNCTION public.cards_create_game(p_lobby_id uuid, p_state jsonb, p_current_player_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.cards_create_game(p_lobby_id uuid, p_state jsonb, p_current_player_id uuid) TO service_role;


--
-- Name: FUNCTION cards_handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.cards_handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.cards_handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.cards_handle_new_user() TO service_role;


--
-- Name: FUNCTION cards_join_lobby(p_join_code text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.cards_join_lobby(p_join_code text) TO anon;
GRANT ALL ON FUNCTION public.cards_join_lobby(p_join_code text) TO authenticated;
GRANT ALL ON FUNCTION public.cards_join_lobby(p_join_code text) TO service_role;


--
-- Name: FUNCTION cards_join_queue(p_display_name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.cards_join_queue(p_display_name text) TO anon;
GRANT ALL ON FUNCTION public.cards_join_queue(p_display_name text) TO authenticated;
GRANT ALL ON FUNCTION public.cards_join_queue(p_display_name text) TO service_role;


--
-- Name: FUNCTION cards_queue_count(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.cards_queue_count() TO anon;
GRANT ALL ON FUNCTION public.cards_queue_count() TO authenticated;
GRANT ALL ON FUNCTION public.cards_queue_count() TO service_role;


--
-- Name: FUNCTION cards_update_games_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.cards_update_games_updated_at() TO anon;
GRANT ALL ON FUNCTION public.cards_update_games_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.cards_update_games_updated_at() TO service_role;


--
-- Name: FUNCTION check_missing_puzzles(days_back integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.check_missing_puzzles(days_back integer) TO anon;
GRANT ALL ON FUNCTION public.check_missing_puzzles(days_back integer) TO authenticated;
GRANT ALL ON FUNCTION public.check_missing_puzzles(days_back integer) TO service_role;


--
-- Name: FUNCTION check_puzzle_integrity(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.check_puzzle_integrity() TO anon;
GRANT ALL ON FUNCTION public.check_puzzle_integrity() TO authenticated;
GRANT ALL ON FUNCTION public.check_puzzle_integrity() TO service_role;


--
-- Name: FUNCTION daily_health_check(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.daily_health_check() TO anon;
GRANT ALL ON FUNCTION public.daily_health_check() TO authenticated;
GRANT ALL ON FUNCTION public.daily_health_check() TO service_role;


--
-- Name: FUNCTION fjordle_assign_daily_puzzle(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fjordle_assign_daily_puzzle() TO anon;
GRANT ALL ON FUNCTION public.fjordle_assign_daily_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_assign_daily_puzzle() TO service_role;


--
-- Name: FUNCTION fjordle_check_missing_puzzles(days_back integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fjordle_check_missing_puzzles(days_back integer) TO anon;
GRANT ALL ON FUNCTION public.fjordle_check_missing_puzzles(days_back integer) TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_check_missing_puzzles(days_back integer) TO service_role;


--
-- Name: FUNCTION fjordle_check_puzzle_integrity(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fjordle_check_puzzle_integrity() TO anon;
GRANT ALL ON FUNCTION public.fjordle_check_puzzle_integrity() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_check_puzzle_integrity() TO service_role;


--
-- Name: FUNCTION fjordle_daily_health_check(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fjordle_daily_health_check() TO anon;
GRANT ALL ON FUNCTION public.fjordle_daily_health_check() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_daily_health_check() TO service_role;


--
-- Name: FUNCTION fjordle_get_daily_fjord_puzzle(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fjordle_get_daily_fjord_puzzle() TO anon;
GRANT ALL ON FUNCTION public.fjordle_get_daily_fjord_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_get_daily_fjord_puzzle() TO service_role;


--
-- Name: FUNCTION fjordle_get_fjord_by_slug(p_slug text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fjordle_get_fjord_by_slug(p_slug text) TO anon;
GRANT ALL ON FUNCTION public.fjordle_get_fjord_by_slug(p_slug text) TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_get_fjord_by_slug(p_slug text) TO service_role;


--
-- Name: FUNCTION fjordle_get_fjord_puzzle_by_number(puzzle_num integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fjordle_get_fjord_puzzle_by_number(puzzle_num integer) TO anon;
GRANT ALL ON FUNCTION public.fjordle_get_fjord_puzzle_by_number(puzzle_num integer) TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_get_fjord_puzzle_by_number(puzzle_num integer) TO service_role;


--
-- Name: FUNCTION fjordle_get_past_puzzles(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fjordle_get_past_puzzles() TO anon;
GRANT ALL ON FUNCTION public.fjordle_get_past_puzzles() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_get_past_puzzles() TO service_role;


--
-- Name: FUNCTION fjordle_update_puzzle_difficulty_tiers(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fjordle_update_puzzle_difficulty_tiers() TO anon;
GRANT ALL ON FUNCTION public.fjordle_update_puzzle_difficulty_tiers() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_update_puzzle_difficulty_tiers() TO service_role;


--
-- Name: FUNCTION frisc_assign_daily_puzzle(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.frisc_assign_daily_puzzle() TO anon;
GRANT ALL ON FUNCTION public.frisc_assign_daily_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_assign_daily_puzzle() TO service_role;


--
-- Name: FUNCTION frisc_auto_assign_queue_position(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.frisc_auto_assign_queue_position() TO anon;
GRANT ALL ON FUNCTION public.frisc_auto_assign_queue_position() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_auto_assign_queue_position() TO service_role;


--
-- Name: FUNCTION frisc_get_daily_puzzle(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.frisc_get_daily_puzzle() TO anon;
GRANT ALL ON FUNCTION public.frisc_get_daily_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_get_daily_puzzle() TO service_role;


--
-- Name: FUNCTION frisc_get_next_puzzle(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.frisc_get_next_puzzle() TO anon;
GRANT ALL ON FUNCTION public.frisc_get_next_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_get_next_puzzle() TO service_role;


--
-- Name: FUNCTION frisc_get_past_puzzles(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.frisc_get_past_puzzles() TO anon;
GRANT ALL ON FUNCTION public.frisc_get_past_puzzles() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_get_past_puzzles() TO service_role;


--
-- Name: FUNCTION frisc_get_puzzle_by_number(puzzle_num integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.frisc_get_puzzle_by_number(puzzle_num integer) TO anon;
GRANT ALL ON FUNCTION public.frisc_get_puzzle_by_number(puzzle_num integer) TO authenticated;
GRANT ALL ON FUNCTION public.frisc_get_puzzle_by_number(puzzle_num integer) TO service_role;


--
-- Name: FUNCTION frisc_normalize_and_validate_category(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.frisc_normalize_and_validate_category() TO anon;
GRANT ALL ON FUNCTION public.frisc_normalize_and_validate_category() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_normalize_and_validate_category() TO service_role;


--
-- Name: FUNCTION frisc_update_puzzle_difficulty_tiers(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.frisc_update_puzzle_difficulty_tiers() TO anon;
GRANT ALL ON FUNCTION public.frisc_update_puzzle_difficulty_tiers() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_update_puzzle_difficulty_tiers() TO service_role;


--
-- Name: FUNCTION frisc_validate_puzzle_composition(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.frisc_validate_puzzle_composition() TO anon;
GRANT ALL ON FUNCTION public.frisc_validate_puzzle_composition() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_validate_puzzle_composition() TO service_role;


--
-- Name: FUNCTION get_daily_fjord_puzzle(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_daily_fjord_puzzle() TO anon;
GRANT ALL ON FUNCTION public.get_daily_fjord_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.get_daily_fjord_puzzle() TO service_role;


--
-- Name: FUNCTION get_fjord_puzzle_by_number(puzzle_num integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_fjord_puzzle_by_number(puzzle_num integer) TO anon;
GRANT ALL ON FUNCTION public.get_fjord_puzzle_by_number(puzzle_num integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_fjord_puzzle_by_number(puzzle_num integer) TO service_role;


--
-- Name: FUNCTION get_past_puzzles(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_past_puzzles() TO anon;
GRANT ALL ON FUNCTION public.get_past_puzzles() TO authenticated;
GRANT ALL ON FUNCTION public.get_past_puzzles() TO service_role;


--
-- Name: FUNCTION update_difficulty_tiers(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_difficulty_tiers() TO anon;
GRANT ALL ON FUNCTION public.update_difficulty_tiers() TO authenticated;
GRANT ALL ON FUNCTION public.update_difficulty_tiers() TO service_role;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO service_role;


--
-- Name: FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE custom_oauth_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.custom_oauth_providers TO postgres;
GRANT ALL ON TABLE auth.custom_oauth_providers TO dashboard_user;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE oauth_authorizations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_authorizations TO postgres;
GRANT ALL ON TABLE auth.oauth_authorizations TO dashboard_user;


--
-- Name: TABLE oauth_client_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_client_states TO postgres;
GRANT ALL ON TABLE auth.oauth_client_states TO dashboard_user;


--
-- Name: TABLE oauth_clients; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_clients TO postgres;
GRANT ALL ON TABLE auth.oauth_clients TO dashboard_user;


--
-- Name: TABLE oauth_consents; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_consents TO postgres;
GRANT ALL ON TABLE auth.oauth_consents TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements_info FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


--
-- Name: TABLE guesses; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.guesses TO anon;
GRANT ALL ON TABLE public.guesses TO authenticated;
GRANT ALL ON TABLE public.guesses TO service_role;


--
-- Name: SEQUENCE anonymous_guesses_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.anonymous_guesses_id_seq TO anon;
GRANT ALL ON SEQUENCE public.anonymous_guesses_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.anonymous_guesses_id_seq TO service_role;


--
-- Name: TABLE cards_games; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.cards_games TO anon;
GRANT ALL ON TABLE public.cards_games TO authenticated;
GRANT ALL ON TABLE public.cards_games TO service_role;


--
-- Name: TABLE cards_lobbies; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.cards_lobbies TO anon;
GRANT ALL ON TABLE public.cards_lobbies TO authenticated;
GRANT ALL ON TABLE public.cards_lobbies TO service_role;


--
-- Name: TABLE cards_profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.cards_profiles TO anon;
GRANT ALL ON TABLE public.cards_profiles TO authenticated;
GRANT ALL ON TABLE public.cards_profiles TO service_role;


--
-- Name: TABLE cards_quick_match_queue; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.cards_quick_match_queue TO anon;
GRANT ALL ON TABLE public.cards_quick_match_queue TO authenticated;
GRANT ALL ON TABLE public.cards_quick_match_queue TO service_role;


--
-- Name: TABLE daily_puzzles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.daily_puzzles TO anon;
GRANT ALL ON TABLE public.daily_puzzles TO authenticated;
GRANT ALL ON TABLE public.daily_puzzles TO service_role;


--
-- Name: TABLE fjordle_counties; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fjordle_counties TO anon;
GRANT ALL ON TABLE public.fjordle_counties TO authenticated;
GRANT ALL ON TABLE public.fjordle_counties TO service_role;


--
-- Name: SEQUENCE fjordle_counties_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fjordle_counties_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_counties_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_counties_id_seq TO service_role;


--
-- Name: TABLE fjordle_daily_puzzles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fjordle_daily_puzzles TO anon;
GRANT ALL ON TABLE public.fjordle_daily_puzzles TO authenticated;
GRANT ALL ON TABLE public.fjordle_daily_puzzles TO service_role;


--
-- Name: SEQUENCE fjordle_daily_puzzles_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fjordle_daily_puzzles_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_daily_puzzles_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_daily_puzzles_id_seq TO service_role;


--
-- Name: TABLE fjordle_fjord_counties; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fjordle_fjord_counties TO anon;
GRANT ALL ON TABLE public.fjordle_fjord_counties TO authenticated;
GRANT ALL ON TABLE public.fjordle_fjord_counties TO service_role;


--
-- Name: TABLE fjordle_fjord_municipalities; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fjordle_fjord_municipalities TO anon;
GRANT ALL ON TABLE public.fjordle_fjord_municipalities TO authenticated;
GRANT ALL ON TABLE public.fjordle_fjord_municipalities TO service_role;


--
-- Name: TABLE fjordle_fjords; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fjordle_fjords TO anon;
GRANT ALL ON TABLE public.fjordle_fjords TO authenticated;
GRANT ALL ON TABLE public.fjordle_fjords TO service_role;


--
-- Name: SEQUENCE fjordle_fjords_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fjordle_fjords_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_fjords_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_fjords_id_seq TO service_role;


--
-- Name: TABLE fjordle_game_sessions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fjordle_game_sessions TO anon;
GRANT ALL ON TABLE public.fjordle_game_sessions TO authenticated;
GRANT ALL ON TABLE public.fjordle_game_sessions TO service_role;


--
-- Name: TABLE fjordle_guesses; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fjordle_guesses TO anon;
GRANT ALL ON TABLE public.fjordle_guesses TO authenticated;
GRANT ALL ON TABLE public.fjordle_guesses TO service_role;


--
-- Name: SEQUENCE fjordle_guesses_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fjordle_guesses_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_guesses_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_guesses_id_seq TO service_role;


--
-- Name: TABLE fjordle_municipalities; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fjordle_municipalities TO anon;
GRANT ALL ON TABLE public.fjordle_municipalities TO authenticated;
GRANT ALL ON TABLE public.fjordle_municipalities TO service_role;


--
-- Name: SEQUENCE fjordle_municipalities_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fjordle_municipalities_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_municipalities_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_municipalities_id_seq TO service_role;


--
-- Name: TABLE fjordle_puzzle_queue; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fjordle_puzzle_queue TO anon;
GRANT ALL ON TABLE public.fjordle_puzzle_queue TO authenticated;
GRANT ALL ON TABLE public.fjordle_puzzle_queue TO service_role;


--
-- Name: SEQUENCE fjordle_puzzle_queue_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fjordle_puzzle_queue_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_puzzle_queue_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_puzzle_queue_id_seq TO service_role;


--
-- Name: TABLE fjords; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fjords TO anon;
GRANT ALL ON TABLE public.fjords TO authenticated;
GRANT ALL ON TABLE public.fjords TO service_role;


--
-- Name: SEQUENCE fjords_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fjords_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjords_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjords_id_seq TO service_role;


--
-- Name: TABLE frisc_anonymous_guesses; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.frisc_anonymous_guesses TO anon;
GRANT ALL ON TABLE public.frisc_anonymous_guesses TO authenticated;
GRANT ALL ON TABLE public.frisc_anonymous_guesses TO service_role;


--
-- Name: SEQUENCE frisc_anonymous_guesses_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.frisc_anonymous_guesses_id_seq TO anon;
GRANT ALL ON SEQUENCE public.frisc_anonymous_guesses_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.frisc_anonymous_guesses_id_seq TO service_role;


--
-- Name: TABLE frisc_anonymous_sessions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.frisc_anonymous_sessions TO anon;
GRANT ALL ON TABLE public.frisc_anonymous_sessions TO authenticated;
GRANT ALL ON TABLE public.frisc_anonymous_sessions TO service_role;


--
-- Name: TABLE frisc_categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.frisc_categories TO anon;
GRANT ALL ON TABLE public.frisc_categories TO authenticated;
GRANT ALL ON TABLE public.frisc_categories TO service_role;


--
-- Name: SEQUENCE frisc_categories_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.frisc_categories_id_seq TO anon;
GRANT ALL ON SEQUENCE public.frisc_categories_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.frisc_categories_id_seq TO service_role;


--
-- Name: TABLE frisc_category_staging; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.frisc_category_staging TO anon;
GRANT ALL ON TABLE public.frisc_category_staging TO authenticated;
GRANT ALL ON TABLE public.frisc_category_staging TO service_role;


--
-- Name: TABLE frisc_puzzle_presentations; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.frisc_puzzle_presentations TO anon;
GRANT ALL ON TABLE public.frisc_puzzle_presentations TO authenticated;
GRANT ALL ON TABLE public.frisc_puzzle_presentations TO service_role;


--
-- Name: SEQUENCE frisc_puzzle_presentations_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.frisc_puzzle_presentations_id_seq TO anon;
GRANT ALL ON SEQUENCE public.frisc_puzzle_presentations_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.frisc_puzzle_presentations_id_seq TO service_role;


--
-- Name: TABLE frisc_puzzle_queue; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.frisc_puzzle_queue TO anon;
GRANT ALL ON TABLE public.frisc_puzzle_queue TO authenticated;
GRANT ALL ON TABLE public.frisc_puzzle_queue TO service_role;


--
-- Name: TABLE frisc_puzzles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.frisc_puzzles TO anon;
GRANT ALL ON TABLE public.frisc_puzzles TO authenticated;
GRANT ALL ON TABLE public.frisc_puzzles TO service_role;


--
-- Name: SEQUENCE frisc_puzzles_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.frisc_puzzles_id_seq TO anon;
GRANT ALL ON SEQUENCE public.frisc_puzzles_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.frisc_puzzles_id_seq TO service_role;


--
-- Name: TABLE game_sessions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.game_sessions TO anon;
GRANT ALL ON TABLE public.game_sessions TO authenticated;
GRANT ALL ON TABLE public.game_sessions TO service_role;


--
-- Name: SEQUENCE puzzle_presentations_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.puzzle_presentations_id_seq TO anon;
GRANT ALL ON SEQUENCE public.puzzle_presentations_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.puzzle_presentations_id_seq TO service_role;


--
-- Name: TABLE puzzle_queue; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.puzzle_queue TO anon;
GRANT ALL ON TABLE public.puzzle_queue TO authenticated;
GRANT ALL ON TABLE public.puzzle_queue TO service_role;


--
-- Name: SEQUENCE puzzle_queue_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.puzzle_queue_id_seq TO anon;
GRANT ALL ON SEQUENCE public.puzzle_queue_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.puzzle_queue_id_seq TO service_role;


--
-- Name: TABLE violets_completions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.violets_completions TO anon;
GRANT ALL ON TABLE public.violets_completions TO authenticated;
GRANT ALL ON TABLE public.violets_completions TO service_role;


--
-- Name: TABLE violets_game_sessions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.violets_game_sessions TO anon;
GRANT ALL ON TABLE public.violets_game_sessions TO authenticated;
GRANT ALL ON TABLE public.violets_game_sessions TO service_role;


--
-- Name: TABLE violets_node_versions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.violets_node_versions TO anon;
GRANT ALL ON TABLE public.violets_node_versions TO authenticated;
GRANT ALL ON TABLE public.violets_node_versions TO service_role;


--
-- Name: TABLE violets_player_choices; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.violets_player_choices TO anon;
GRANT ALL ON TABLE public.violets_player_choices TO authenticated;
GRANT ALL ON TABLE public.violets_player_choices TO service_role;


--
-- Name: TABLE violets_sessions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.violets_sessions TO anon;
GRANT ALL ON TABLE public.violets_sessions TO authenticated;
GRANT ALL ON TABLE public.violets_sessions TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: TABLE messages_2026_02_28; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_02_28 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_02_28 TO dashboard_user;


--
-- Name: TABLE messages_2026_03_01; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_03_01 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_03_01 TO dashboard_user;


--
-- Name: TABLE messages_2026_03_02; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_03_02 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_03_02 TO dashboard_user;


--
-- Name: TABLE messages_2026_03_03; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_03_03 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_03_03 TO dashboard_user;


--
-- Name: TABLE messages_2026_03_04; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_03_04 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_03_04 TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

REVOKE ALL ON TABLE storage.buckets FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.buckets TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO postgres WITH GRANT OPTION;


--
-- Name: TABLE buckets_analytics; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets_analytics TO service_role;
GRANT ALL ON TABLE storage.buckets_analytics TO authenticated;
GRANT ALL ON TABLE storage.buckets_analytics TO anon;


--
-- Name: TABLE buckets_vectors; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.buckets_vectors TO service_role;
GRANT SELECT ON TABLE storage.buckets_vectors TO authenticated;
GRANT SELECT ON TABLE storage.buckets_vectors TO anon;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

REVOKE ALL ON TABLE storage.objects FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.objects TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO postgres WITH GRANT OPTION;


--
-- Name: TABLE prefixes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.prefixes TO service_role;
GRANT ALL ON TABLE storage.prefixes TO authenticated;
GRANT ALL ON TABLE storage.prefixes TO anon;


--
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- Name: TABLE vector_indexes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.vector_indexes TO service_role;
GRANT SELECT ON TABLE storage.vector_indexes TO authenticated;
GRANT SELECT ON TABLE storage.vector_indexes TO anon;


--
-- Name: TABLE secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.secrets TO service_role;


--
-- Name: TABLE decrypted_secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO supabase_admin;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

\unrestrict mHHKBTyOiHiGvakRwSMo2CvkWJUeqezFaOGbcPlbjF92TGDyvsVNh3g2yAGuWLW

