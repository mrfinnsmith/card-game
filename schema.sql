--
-- PostgreSQL database dump
--

\restrict uQRx6bkX1MKTgSRFhL8LTF9cNgeYZbh2SXjamcdxL2mg1gfPFdTjzEK6j7KM4Vy

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: assign_daily_puzzle(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: cards_handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cards_handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  insert into public.cards_profiles (user_id, username)
  values (new.id, new.raw_user_meta_data ->> 'username');
  return new;
end;
$$;


--
-- Name: check_missing_puzzles(integer); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: check_puzzle_integrity(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: daily_health_check(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fjordle_assign_daily_puzzle(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fjordle_check_missing_puzzles(integer); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fjordle_check_puzzle_integrity(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fjordle_daily_health_check(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fjordle_get_daily_fjord_puzzle(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fjordle_get_fjord_by_slug(text); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fjordle_get_fjord_puzzle_by_number(integer); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fjordle_get_past_puzzles(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: fjordle_update_puzzle_difficulty_tiers(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: frisc_assign_daily_puzzle(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: frisc_auto_assign_queue_position(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: frisc_get_daily_puzzle(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: frisc_get_next_puzzle(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: frisc_get_past_puzzles(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: frisc_get_puzzle_by_number(integer); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: frisc_normalize_and_validate_category(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: frisc_update_puzzle_difficulty_tiers(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: frisc_validate_puzzle_composition(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: get_daily_fjord_puzzle(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: get_fjord_puzzle_by_number(integer); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: get_past_puzzles(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: update_difficulty_tiers(); Type: FUNCTION; Schema: public; Owner: -
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: guesses; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: anonymous_guesses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.anonymous_guesses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anonymous_guesses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.anonymous_guesses_id_seq OWNED BY public.guesses.id;


--
-- Name: cards_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cards_profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    username text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cards_profiles_username_format CHECK ((username ~ '^[a-zA-Z0-9_]{3,20}$'::text))
);


--
-- Name: daily_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_puzzles (
    id integer NOT NULL,
    presented_date date NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    fjord_id integer,
    puzzle_number integer,
    last_presented_date date
);


--
-- Name: fjordle_counties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fjordle_counties (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: fjordle_counties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: fjordle_daily_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fjordle_daily_puzzles (
    id integer NOT NULL,
    presented_date date NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    fjord_id integer,
    puzzle_number integer,
    last_presented_date date
);


--
-- Name: fjordle_daily_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: fjordle_fjord_counties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fjordle_fjord_counties (
    fjord_id integer NOT NULL,
    county_id integer NOT NULL
);


--
-- Name: fjordle_fjord_municipalities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fjordle_fjord_municipalities (
    fjord_id integer NOT NULL,
    municipality_id integer NOT NULL
);


--
-- Name: fjordle_fjords; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: fjordle_fjords_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: fjordle_game_sessions; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: fjordle_guesses; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: fjordle_guesses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: fjordle_municipalities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fjordle_municipalities (
    id integer NOT NULL,
    name text NOT NULL,
    county_id integer
);


--
-- Name: fjordle_municipalities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: fjordle_puzzle_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fjordle_puzzle_queue (
    id integer NOT NULL,
    fjord_id integer NOT NULL,
    scheduled_date date NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    created_by text DEFAULT 'manual'::text
);


--
-- Name: fjordle_puzzle_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: fjords; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: fjords_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fjords_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fjords_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fjords_id_seq OWNED BY public.fjords.id;


--
-- Name: frisc_anonymous_guesses; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: frisc_anonymous_guesses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: frisc_anonymous_sessions; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: frisc_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.frisc_categories (
    id integer NOT NULL,
    puzzle_id integer,
    name text NOT NULL,
    difficulty integer NOT NULL,
    items text[] NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: frisc_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: frisc_category_staging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.frisc_category_staging (
    name text,
    difficulty integer,
    item1 text,
    item2 text,
    item3 text,
    item4 text
);


--
-- Name: frisc_puzzle_presentations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.frisc_puzzle_presentations (
    id integer NOT NULL,
    puzzle_id integer,
    presented_date date NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: frisc_puzzle_presentations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: frisc_puzzle_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.frisc_puzzle_queue (
    queue_position integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    scheduled_date date,
    published boolean DEFAULT false,
    puzzle_id integer NOT NULL,
    archived boolean DEFAULT false
);


--
-- Name: frisc_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.frisc_puzzles (
    id integer NOT NULL,
    puzzle_number integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    difficulty_tier integer DEFAULT 1
);


--
-- Name: frisc_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: game_sessions; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: puzzle_presentations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.puzzle_presentations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: puzzle_presentations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.puzzle_presentations_id_seq OWNED BY public.daily_puzzles.id;


--
-- Name: puzzle_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.puzzle_queue (
    id integer NOT NULL,
    fjord_id integer NOT NULL,
    scheduled_date date NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    created_by text DEFAULT 'manual'::text,
    CONSTRAINT puzzle_queue_scheduled_date_check CHECK ((scheduled_date >= CURRENT_DATE))
);


--
-- Name: puzzle_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.puzzle_queue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: puzzle_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.puzzle_queue_id_seq OWNED BY public.puzzle_queue.id;


--
-- Name: violets_completions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.violets_completions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid,
    completed_at timestamp with time zone DEFAULT now(),
    ending_node_id text NOT NULL,
    completion_number integer NOT NULL
);


--
-- Name: violets_game_sessions; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: violets_node_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.violets_node_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    node_id text NOT NULL,
    version_number integer NOT NULL,
    content_json jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: violets_player_choices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.violets_player_choices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid,
    node_id text NOT NULL,
    choice_index integer NOT NULL,
    next_node_id text NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now()
);


--
-- Name: violets_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.violets_sessions (
    session_id uuid DEFAULT gen_random_uuid() NOT NULL,
    started_at timestamp with time zone DEFAULT now(),
    device_type text
);


--
-- Name: daily_puzzles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_puzzles ALTER COLUMN id SET DEFAULT nextval('public.puzzle_presentations_id_seq'::regclass);


--
-- Name: fjords id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjords ALTER COLUMN id SET DEFAULT nextval('public.fjords_id_seq'::regclass);


--
-- Name: guesses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guesses ALTER COLUMN id SET DEFAULT nextval('public.anonymous_guesses_id_seq'::regclass);


--
-- Name: puzzle_queue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.puzzle_queue ALTER COLUMN id SET DEFAULT nextval('public.puzzle_queue_id_seq'::regclass);


--
-- Name: guesses anonymous_guesses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guesses
    ADD CONSTRAINT anonymous_guesses_pkey PRIMARY KEY (id);


--
-- Name: game_sessions anonymous_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_sessions
    ADD CONSTRAINT anonymous_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: cards_profiles cards_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards_profiles
    ADD CONSTRAINT cards_profiles_pkey PRIMARY KEY (id);


--
-- Name: cards_profiles cards_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards_profiles
    ADD CONSTRAINT cards_profiles_user_id_key UNIQUE (user_id);


--
-- Name: cards_profiles cards_profiles_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards_profiles
    ADD CONSTRAINT cards_profiles_username_key UNIQUE (username);


--
-- Name: daily_puzzles daily_puzzles_presented_date_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_puzzles
    ADD CONSTRAINT daily_puzzles_presented_date_unique UNIQUE (presented_date);


--
-- Name: daily_puzzles daily_puzzles_puzzle_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_puzzles
    ADD CONSTRAINT daily_puzzles_puzzle_number_key UNIQUE (puzzle_number);


--
-- Name: fjordle_counties fjordle_counties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_counties
    ADD CONSTRAINT fjordle_counties_pkey PRIMARY KEY (id);


--
-- Name: fjordle_daily_puzzles fjordle_daily_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_daily_puzzles
    ADD CONSTRAINT fjordle_daily_puzzles_pkey PRIMARY KEY (id);


--
-- Name: fjordle_fjord_counties fjordle_fjord_counties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_fjord_counties
    ADD CONSTRAINT fjordle_fjord_counties_pkey PRIMARY KEY (fjord_id, county_id);


--
-- Name: fjordle_fjord_municipalities fjordle_fjord_municipalities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_fjord_municipalities
    ADD CONSTRAINT fjordle_fjord_municipalities_pkey PRIMARY KEY (fjord_id, municipality_id);


--
-- Name: fjordle_fjords fjordle_fjords_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_fjords
    ADD CONSTRAINT fjordle_fjords_pkey PRIMARY KEY (id);


--
-- Name: fjordle_fjords fjordle_fjords_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_fjords
    ADD CONSTRAINT fjordle_fjords_slug_key UNIQUE (slug);


--
-- Name: fjordle_game_sessions fjordle_game_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_game_sessions
    ADD CONSTRAINT fjordle_game_sessions_pkey PRIMARY KEY (session_id, puzzle_id);


--
-- Name: fjordle_guesses fjordle_guesses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_guesses
    ADD CONSTRAINT fjordle_guesses_pkey PRIMARY KEY (id);


--
-- Name: fjordle_municipalities fjordle_municipalities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_municipalities
    ADD CONSTRAINT fjordle_municipalities_pkey PRIMARY KEY (id);


--
-- Name: fjordle_puzzle_queue fjordle_puzzle_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_puzzle_queue
    ADD CONSTRAINT fjordle_puzzle_queue_pkey PRIMARY KEY (id);


--
-- Name: fjords fjords_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjords
    ADD CONSTRAINT fjords_pkey PRIMARY KEY (id);


--
-- Name: frisc_anonymous_guesses frisc_anonymous_guesses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_anonymous_guesses
    ADD CONSTRAINT frisc_anonymous_guesses_pkey PRIMARY KEY (id);


--
-- Name: frisc_anonymous_sessions frisc_anonymous_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_anonymous_sessions
    ADD CONSTRAINT frisc_anonymous_sessions_pkey PRIMARY KEY (session_id, puzzle_id);


--
-- Name: frisc_categories frisc_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_categories
    ADD CONSTRAINT frisc_categories_pkey PRIMARY KEY (id);


--
-- Name: frisc_puzzle_presentations frisc_puzzle_presentations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_puzzle_presentations
    ADD CONSTRAINT frisc_puzzle_presentations_pkey PRIMARY KEY (id);


--
-- Name: frisc_puzzle_presentations frisc_puzzle_presentations_puzzle_presented_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_puzzle_presentations
    ADD CONSTRAINT frisc_puzzle_presentations_puzzle_presented_unique UNIQUE (puzzle_id, presented_date);


--
-- Name: frisc_puzzle_queue frisc_puzzle_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_puzzle_queue
    ADD CONSTRAINT frisc_puzzle_queue_pkey PRIMARY KEY (puzzle_id);


--
-- Name: frisc_puzzles frisc_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_puzzles
    ADD CONSTRAINT frisc_puzzles_pkey PRIMARY KEY (id);


--
-- Name: frisc_puzzles frisc_puzzles_puzzle_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_puzzles
    ADD CONSTRAINT frisc_puzzles_puzzle_number_key UNIQUE (puzzle_number);


--
-- Name: daily_puzzles puzzle_presentations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_puzzles
    ADD CONSTRAINT puzzle_presentations_pkey PRIMARY KEY (id);


--
-- Name: puzzle_queue puzzle_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.puzzle_queue
    ADD CONSTRAINT puzzle_queue_pkey PRIMARY KEY (id);


--
-- Name: puzzle_queue puzzle_queue_scheduled_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.puzzle_queue
    ADD CONSTRAINT puzzle_queue_scheduled_date_key UNIQUE (scheduled_date);


--
-- Name: violets_completions violets_completions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.violets_completions
    ADD CONSTRAINT violets_completions_pkey PRIMARY KEY (id);


--
-- Name: violets_game_sessions violets_game_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.violets_game_sessions
    ADD CONSTRAINT violets_game_sessions_pkey PRIMARY KEY (id);


--
-- Name: violets_node_versions violets_node_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.violets_node_versions
    ADD CONSTRAINT violets_node_versions_pkey PRIMARY KEY (id);


--
-- Name: violets_player_choices violets_player_choices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.violets_player_choices
    ADD CONSTRAINT violets_player_choices_pkey PRIMARY KEY (id);


--
-- Name: violets_sessions violets_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.violets_sessions
    ADD CONSTRAINT violets_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: idx_daily_puzzles_last_presented; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_daily_puzzles_last_presented ON public.daily_puzzles USING btree (last_presented_date);


--
-- Name: idx_puzzle_queue_scheduled_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_puzzle_queue_scheduled_date ON public.puzzle_queue USING btree (scheduled_date);


--
-- Name: idx_violets_completions_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_violets_completions_session_id ON public.violets_completions USING btree (session_id);


--
-- Name: idx_violets_game_sessions_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_violets_game_sessions_session_id ON public.violets_game_sessions USING btree (session_id);


--
-- Name: idx_violets_node_versions_node_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_violets_node_versions_node_id ON public.violets_node_versions USING btree (node_id);


--
-- Name: idx_violets_player_choices_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_violets_player_choices_session_id ON public.violets_player_choices USING btree (session_id);


--
-- Name: frisc_puzzle_queue auto_queue_position; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER auto_queue_position BEFORE INSERT ON public.frisc_puzzle_queue FOR EACH ROW EXECUTE FUNCTION public.frisc_auto_assign_queue_position();


--
-- Name: frisc_categories validate_category_data; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER validate_category_data BEFORE INSERT OR UPDATE ON public.frisc_categories FOR EACH ROW EXECUTE FUNCTION public.frisc_normalize_and_validate_category();


--
-- Name: frisc_categories validate_puzzle_data; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER validate_puzzle_data BEFORE INSERT OR UPDATE ON public.frisc_categories FOR EACH ROW EXECUTE FUNCTION public.frisc_validate_puzzle_composition();


--
-- Name: guesses anonymous_guesses_guessed_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guesses
    ADD CONSTRAINT anonymous_guesses_guessed_fjord_id_fkey FOREIGN KEY (guessed_fjord_id) REFERENCES public.fjords(id);


--
-- Name: guesses anonymous_guesses_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guesses
    ADD CONSTRAINT anonymous_guesses_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.game_sessions(session_id);


--
-- Name: cards_profiles cards_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards_profiles
    ADD CONSTRAINT cards_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: daily_puzzles daily_puzzles_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_puzzles
    ADD CONSTRAINT daily_puzzles_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjords(id);


--
-- Name: fjordle_daily_puzzles fjordle_daily_puzzles_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_daily_puzzles
    ADD CONSTRAINT fjordle_daily_puzzles_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjordle_fjords(id);


--
-- Name: fjordle_fjord_counties fjordle_fjord_counties_county_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_fjord_counties
    ADD CONSTRAINT fjordle_fjord_counties_county_id_fkey FOREIGN KEY (county_id) REFERENCES public.fjordle_counties(id);


--
-- Name: fjordle_fjord_counties fjordle_fjord_counties_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_fjord_counties
    ADD CONSTRAINT fjordle_fjord_counties_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjordle_fjords(id);


--
-- Name: fjordle_fjord_municipalities fjordle_fjord_municipalities_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_fjord_municipalities
    ADD CONSTRAINT fjordle_fjord_municipalities_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjordle_fjords(id);


--
-- Name: fjordle_fjord_municipalities fjordle_fjord_municipalities_municipality_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_fjord_municipalities
    ADD CONSTRAINT fjordle_fjord_municipalities_municipality_id_fkey FOREIGN KEY (municipality_id) REFERENCES public.fjordle_municipalities(id);


--
-- Name: fjordle_guesses fjordle_guesses_guessed_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_guesses
    ADD CONSTRAINT fjordle_guesses_guessed_fjord_id_fkey FOREIGN KEY (guessed_fjord_id) REFERENCES public.fjordle_fjords(id);


--
-- Name: fjordle_municipalities fjordle_municipalities_county_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_municipalities
    ADD CONSTRAINT fjordle_municipalities_county_id_fkey FOREIGN KEY (county_id) REFERENCES public.fjordle_counties(id);


--
-- Name: fjordle_puzzle_queue fjordle_puzzle_queue_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fjordle_puzzle_queue
    ADD CONSTRAINT fjordle_puzzle_queue_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjordle_fjords(id);


--
-- Name: frisc_anonymous_guesses frisc_anonymous_guesses_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_anonymous_guesses
    ADD CONSTRAINT frisc_anonymous_guesses_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.frisc_categories(id);


--
-- Name: frisc_anonymous_guesses frisc_anonymous_guesses_puzzle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_anonymous_guesses
    ADD CONSTRAINT frisc_anonymous_guesses_puzzle_id_fkey FOREIGN KEY (puzzle_id) REFERENCES public.frisc_puzzles(id);


--
-- Name: frisc_anonymous_sessions frisc_anonymous_sessions_puzzle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_anonymous_sessions
    ADD CONSTRAINT frisc_anonymous_sessions_puzzle_id_fkey FOREIGN KEY (puzzle_id) REFERENCES public.frisc_puzzles(id);


--
-- Name: frisc_categories frisc_categories_puzzle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_categories
    ADD CONSTRAINT frisc_categories_puzzle_id_fkey FOREIGN KEY (puzzle_id) REFERENCES public.frisc_puzzles(id);


--
-- Name: frisc_puzzle_presentations frisc_puzzle_presentations_puzzle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_puzzle_presentations
    ADD CONSTRAINT frisc_puzzle_presentations_puzzle_id_fkey FOREIGN KEY (puzzle_id) REFERENCES public.frisc_puzzles(id);


--
-- Name: frisc_puzzle_queue frisc_puzzle_queue_puzzle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frisc_puzzle_queue
    ADD CONSTRAINT frisc_puzzle_queue_puzzle_id_fkey FOREIGN KEY (puzzle_id) REFERENCES public.frisc_puzzles(id);


--
-- Name: puzzle_queue puzzle_queue_fjord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.puzzle_queue
    ADD CONSTRAINT puzzle_queue_fjord_id_fkey FOREIGN KEY (fjord_id) REFERENCES public.fjords(id);


--
-- Name: violets_completions violets_completions_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.violets_completions
    ADD CONSTRAINT violets_completions_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.violets_sessions(session_id);


--
-- Name: violets_player_choices violets_player_choices_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.violets_player_choices
    ADD CONSTRAINT violets_player_choices_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.violets_sessions(session_id);


--
-- Name: violets_completions Allow anonymous access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow anonymous access" ON public.violets_completions USING (true);


--
-- Name: violets_game_sessions Allow anonymous access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow anonymous access" ON public.violets_game_sessions USING (true);


--
-- Name: violets_node_versions Allow anonymous access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow anonymous access" ON public.violets_node_versions USING (true);


--
-- Name: violets_player_choices Allow anonymous access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow anonymous access" ON public.violets_player_choices USING (true);


--
-- Name: violets_sessions Allow anonymous access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow anonymous access" ON public.violets_sessions USING (true);


--
-- Name: frisc_anonymous_guesses Allow anonymous guess tracking; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow anonymous guess tracking" ON public.frisc_anonymous_guesses FOR INSERT WITH CHECK (true);


--
-- Name: frisc_categories Allow anonymous read categories; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow anonymous read categories" ON public.frisc_categories FOR SELECT USING (((puzzle_id IN ( SELECT frisc_puzzle_queue.puzzle_id
   FROM public.frisc_puzzle_queue
  WHERE (frisc_puzzle_queue.published = true))) OR (puzzle_id IS NULL)));


--
-- Name: frisc_puzzles Allow anonymous read published puzzles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow anonymous read published puzzles" ON public.frisc_puzzles FOR SELECT USING ((id IN ( SELECT frisc_puzzle_queue.puzzle_id
   FROM public.frisc_puzzle_queue
  WHERE (frisc_puzzle_queue.published = true))));


--
-- Name: frisc_anonymous_sessions Allow anonymous session management; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow anonymous session management" ON public.frisc_anonymous_sessions USING (true);


--
-- Name: frisc_category_staging Allow public read access to category staging; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow public read access to category staging" ON public.frisc_category_staging FOR SELECT USING (true);


--
-- Name: fjordle_counties Allow public read access to counties; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow public read access to counties" ON public.fjordle_counties FOR SELECT USING (true);


--
-- Name: fjordle_fjord_counties Allow public read access to fjord-county relationships; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow public read access to fjord-county relationships" ON public.fjordle_fjord_counties FOR SELECT USING (true);


--
-- Name: fjordle_fjord_municipalities Allow public read access to fjord-municipality relationships; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow public read access to fjord-municipality relationships" ON public.fjordle_fjord_municipalities FOR SELECT USING (true);


--
-- Name: fjordle_municipalities Allow public read access to municipalities; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow public read access to municipalities" ON public.fjordle_municipalities FOR SELECT USING (true);


--
-- Name: frisc_puzzle_presentations Allow public read access to puzzle presentations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow public read access to puzzle presentations" ON public.frisc_puzzle_presentations FOR SELECT USING (true);


--
-- Name: fjordle_puzzle_queue Allow public read access to puzzle queue; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow public read access to puzzle queue" ON public.fjordle_puzzle_queue FOR SELECT USING (true);


--
-- Name: frisc_puzzle_queue Allow public read access to puzzle queue; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow public read access to puzzle queue" ON public.frisc_puzzle_queue FOR SELECT USING (true);


--
-- Name: cards_profiles Anyone can read profiles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can read profiles" ON public.cards_profiles FOR SELECT USING (true);


--
-- Name: fjordle_game_sessions Public insert access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public insert access" ON public.fjordle_game_sessions FOR INSERT WITH CHECK (true);


--
-- Name: fjordle_guesses Public insert access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public insert access" ON public.fjordle_guesses FOR INSERT WITH CHECK (true);


--
-- Name: game_sessions Public insert access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public insert access" ON public.game_sessions FOR INSERT WITH CHECK (true);


--
-- Name: guesses Public insert access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public insert access" ON public.guesses FOR INSERT WITH CHECK (true);


--
-- Name: daily_puzzles Public read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public read access" ON public.daily_puzzles FOR SELECT USING (true);


--
-- Name: fjordle_daily_puzzles Public read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public read access" ON public.fjordle_daily_puzzles FOR SELECT USING (true);


--
-- Name: fjordle_fjords Public read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public read access" ON public.fjordle_fjords FOR SELECT USING (true);


--
-- Name: fjordle_game_sessions Public read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public read access" ON public.fjordle_game_sessions FOR SELECT USING (true);


--
-- Name: fjordle_guesses Public read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public read access" ON public.fjordle_guesses FOR SELECT USING (true);


--
-- Name: fjords Public read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public read access" ON public.fjords FOR SELECT USING (true);


--
-- Name: game_sessions Public read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public read access" ON public.game_sessions FOR SELECT USING (true);


--
-- Name: guesses Public read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public read access" ON public.guesses FOR SELECT USING (true);


--
-- Name: fjordle_game_sessions Public update access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public update access" ON public.fjordle_game_sessions FOR UPDATE USING (true);


--
-- Name: game_sessions Public update access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public update access" ON public.game_sessions FOR UPDATE USING (true);


--
-- Name: cards_profiles Users can insert own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert own profile" ON public.cards_profiles FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: cards_profiles Users can update own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update own profile" ON public.cards_profiles FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: cards_profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cards_profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: daily_puzzles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.daily_puzzles ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_counties; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fjordle_counties ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_daily_puzzles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fjordle_daily_puzzles ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_fjord_counties; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fjordle_fjord_counties ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_fjord_municipalities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fjordle_fjord_municipalities ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_fjords; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fjordle_fjords ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_game_sessions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fjordle_game_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_guesses; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fjordle_guesses ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_municipalities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fjordle_municipalities ENABLE ROW LEVEL SECURITY;

--
-- Name: fjordle_puzzle_queue; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fjordle_puzzle_queue ENABLE ROW LEVEL SECURITY;

--
-- Name: fjords; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fjords ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_anonymous_guesses; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.frisc_anonymous_guesses ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_anonymous_sessions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.frisc_anonymous_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_categories; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.frisc_categories ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_category_staging; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.frisc_category_staging ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_puzzle_presentations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.frisc_puzzle_presentations ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_puzzle_queue; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.frisc_puzzle_queue ENABLE ROW LEVEL SECURITY;

--
-- Name: frisc_puzzles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.frisc_puzzles ENABLE ROW LEVEL SECURITY;

--
-- Name: game_sessions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.game_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: guesses; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.guesses ENABLE ROW LEVEL SECURITY;

--
-- Name: violets_completions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.violets_completions ENABLE ROW LEVEL SECURITY;

--
-- Name: violets_game_sessions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.violets_game_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: violets_node_versions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.violets_node_versions ENABLE ROW LEVEL SECURITY;

--
-- Name: violets_player_choices; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.violets_player_choices ENABLE ROW LEVEL SECURITY;

--
-- Name: violets_sessions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.violets_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: FUNCTION assign_daily_puzzle(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.assign_daily_puzzle() TO anon;
GRANT ALL ON FUNCTION public.assign_daily_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.assign_daily_puzzle() TO service_role;


--
-- Name: FUNCTION cards_handle_new_user(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.cards_handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.cards_handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.cards_handle_new_user() TO service_role;


--
-- Name: FUNCTION check_missing_puzzles(days_back integer); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.check_missing_puzzles(days_back integer) TO anon;
GRANT ALL ON FUNCTION public.check_missing_puzzles(days_back integer) TO authenticated;
GRANT ALL ON FUNCTION public.check_missing_puzzles(days_back integer) TO service_role;


--
-- Name: FUNCTION check_puzzle_integrity(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.check_puzzle_integrity() TO anon;
GRANT ALL ON FUNCTION public.check_puzzle_integrity() TO authenticated;
GRANT ALL ON FUNCTION public.check_puzzle_integrity() TO service_role;


--
-- Name: FUNCTION daily_health_check(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.daily_health_check() TO anon;
GRANT ALL ON FUNCTION public.daily_health_check() TO authenticated;
GRANT ALL ON FUNCTION public.daily_health_check() TO service_role;


--
-- Name: FUNCTION fjordle_assign_daily_puzzle(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.fjordle_assign_daily_puzzle() TO anon;
GRANT ALL ON FUNCTION public.fjordle_assign_daily_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_assign_daily_puzzle() TO service_role;


--
-- Name: FUNCTION fjordle_check_missing_puzzles(days_back integer); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.fjordle_check_missing_puzzles(days_back integer) TO anon;
GRANT ALL ON FUNCTION public.fjordle_check_missing_puzzles(days_back integer) TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_check_missing_puzzles(days_back integer) TO service_role;


--
-- Name: FUNCTION fjordle_check_puzzle_integrity(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.fjordle_check_puzzle_integrity() TO anon;
GRANT ALL ON FUNCTION public.fjordle_check_puzzle_integrity() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_check_puzzle_integrity() TO service_role;


--
-- Name: FUNCTION fjordle_daily_health_check(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.fjordle_daily_health_check() TO anon;
GRANT ALL ON FUNCTION public.fjordle_daily_health_check() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_daily_health_check() TO service_role;


--
-- Name: FUNCTION fjordle_get_daily_fjord_puzzle(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.fjordle_get_daily_fjord_puzzle() TO anon;
GRANT ALL ON FUNCTION public.fjordle_get_daily_fjord_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_get_daily_fjord_puzzle() TO service_role;


--
-- Name: FUNCTION fjordle_get_fjord_by_slug(p_slug text); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.fjordle_get_fjord_by_slug(p_slug text) TO anon;
GRANT ALL ON FUNCTION public.fjordle_get_fjord_by_slug(p_slug text) TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_get_fjord_by_slug(p_slug text) TO service_role;


--
-- Name: FUNCTION fjordle_get_fjord_puzzle_by_number(puzzle_num integer); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.fjordle_get_fjord_puzzle_by_number(puzzle_num integer) TO anon;
GRANT ALL ON FUNCTION public.fjordle_get_fjord_puzzle_by_number(puzzle_num integer) TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_get_fjord_puzzle_by_number(puzzle_num integer) TO service_role;


--
-- Name: FUNCTION fjordle_get_past_puzzles(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.fjordle_get_past_puzzles() TO anon;
GRANT ALL ON FUNCTION public.fjordle_get_past_puzzles() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_get_past_puzzles() TO service_role;


--
-- Name: FUNCTION fjordle_update_puzzle_difficulty_tiers(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.fjordle_update_puzzle_difficulty_tiers() TO anon;
GRANT ALL ON FUNCTION public.fjordle_update_puzzle_difficulty_tiers() TO authenticated;
GRANT ALL ON FUNCTION public.fjordle_update_puzzle_difficulty_tiers() TO service_role;


--
-- Name: FUNCTION frisc_assign_daily_puzzle(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.frisc_assign_daily_puzzle() TO anon;
GRANT ALL ON FUNCTION public.frisc_assign_daily_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_assign_daily_puzzle() TO service_role;


--
-- Name: FUNCTION frisc_auto_assign_queue_position(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.frisc_auto_assign_queue_position() TO anon;
GRANT ALL ON FUNCTION public.frisc_auto_assign_queue_position() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_auto_assign_queue_position() TO service_role;


--
-- Name: FUNCTION frisc_get_daily_puzzle(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.frisc_get_daily_puzzle() TO anon;
GRANT ALL ON FUNCTION public.frisc_get_daily_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_get_daily_puzzle() TO service_role;


--
-- Name: FUNCTION frisc_get_next_puzzle(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.frisc_get_next_puzzle() TO anon;
GRANT ALL ON FUNCTION public.frisc_get_next_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_get_next_puzzle() TO service_role;


--
-- Name: FUNCTION frisc_get_past_puzzles(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.frisc_get_past_puzzles() TO anon;
GRANT ALL ON FUNCTION public.frisc_get_past_puzzles() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_get_past_puzzles() TO service_role;


--
-- Name: FUNCTION frisc_get_puzzle_by_number(puzzle_num integer); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.frisc_get_puzzle_by_number(puzzle_num integer) TO anon;
GRANT ALL ON FUNCTION public.frisc_get_puzzle_by_number(puzzle_num integer) TO authenticated;
GRANT ALL ON FUNCTION public.frisc_get_puzzle_by_number(puzzle_num integer) TO service_role;


--
-- Name: FUNCTION frisc_normalize_and_validate_category(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.frisc_normalize_and_validate_category() TO anon;
GRANT ALL ON FUNCTION public.frisc_normalize_and_validate_category() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_normalize_and_validate_category() TO service_role;


--
-- Name: FUNCTION frisc_update_puzzle_difficulty_tiers(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.frisc_update_puzzle_difficulty_tiers() TO anon;
GRANT ALL ON FUNCTION public.frisc_update_puzzle_difficulty_tiers() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_update_puzzle_difficulty_tiers() TO service_role;


--
-- Name: FUNCTION frisc_validate_puzzle_composition(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.frisc_validate_puzzle_composition() TO anon;
GRANT ALL ON FUNCTION public.frisc_validate_puzzle_composition() TO authenticated;
GRANT ALL ON FUNCTION public.frisc_validate_puzzle_composition() TO service_role;


--
-- Name: FUNCTION get_daily_fjord_puzzle(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.get_daily_fjord_puzzle() TO anon;
GRANT ALL ON FUNCTION public.get_daily_fjord_puzzle() TO authenticated;
GRANT ALL ON FUNCTION public.get_daily_fjord_puzzle() TO service_role;


--
-- Name: FUNCTION get_fjord_puzzle_by_number(puzzle_num integer); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.get_fjord_puzzle_by_number(puzzle_num integer) TO anon;
GRANT ALL ON FUNCTION public.get_fjord_puzzle_by_number(puzzle_num integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_fjord_puzzle_by_number(puzzle_num integer) TO service_role;


--
-- Name: FUNCTION get_past_puzzles(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.get_past_puzzles() TO anon;
GRANT ALL ON FUNCTION public.get_past_puzzles() TO authenticated;
GRANT ALL ON FUNCTION public.get_past_puzzles() TO service_role;


--
-- Name: FUNCTION update_difficulty_tiers(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.update_difficulty_tiers() TO anon;
GRANT ALL ON FUNCTION public.update_difficulty_tiers() TO authenticated;
GRANT ALL ON FUNCTION public.update_difficulty_tiers() TO service_role;


--
-- Name: TABLE guesses; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.guesses TO anon;
GRANT ALL ON TABLE public.guesses TO authenticated;
GRANT ALL ON TABLE public.guesses TO service_role;


--
-- Name: SEQUENCE anonymous_guesses_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.anonymous_guesses_id_seq TO anon;
GRANT ALL ON SEQUENCE public.anonymous_guesses_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.anonymous_guesses_id_seq TO service_role;


--
-- Name: TABLE cards_profiles; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.cards_profiles TO anon;
GRANT ALL ON TABLE public.cards_profiles TO authenticated;
GRANT ALL ON TABLE public.cards_profiles TO service_role;


--
-- Name: TABLE daily_puzzles; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.daily_puzzles TO anon;
GRANT ALL ON TABLE public.daily_puzzles TO authenticated;
GRANT ALL ON TABLE public.daily_puzzles TO service_role;


--
-- Name: TABLE fjordle_counties; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.fjordle_counties TO anon;
GRANT ALL ON TABLE public.fjordle_counties TO authenticated;
GRANT ALL ON TABLE public.fjordle_counties TO service_role;


--
-- Name: SEQUENCE fjordle_counties_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.fjordle_counties_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_counties_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_counties_id_seq TO service_role;


--
-- Name: TABLE fjordle_daily_puzzles; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.fjordle_daily_puzzles TO anon;
GRANT ALL ON TABLE public.fjordle_daily_puzzles TO authenticated;
GRANT ALL ON TABLE public.fjordle_daily_puzzles TO service_role;


--
-- Name: SEQUENCE fjordle_daily_puzzles_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.fjordle_daily_puzzles_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_daily_puzzles_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_daily_puzzles_id_seq TO service_role;


--
-- Name: TABLE fjordle_fjord_counties; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.fjordle_fjord_counties TO anon;
GRANT ALL ON TABLE public.fjordle_fjord_counties TO authenticated;
GRANT ALL ON TABLE public.fjordle_fjord_counties TO service_role;


--
-- Name: TABLE fjordle_fjord_municipalities; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.fjordle_fjord_municipalities TO anon;
GRANT ALL ON TABLE public.fjordle_fjord_municipalities TO authenticated;
GRANT ALL ON TABLE public.fjordle_fjord_municipalities TO service_role;


--
-- Name: TABLE fjordle_fjords; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.fjordle_fjords TO anon;
GRANT ALL ON TABLE public.fjordle_fjords TO authenticated;
GRANT ALL ON TABLE public.fjordle_fjords TO service_role;


--
-- Name: SEQUENCE fjordle_fjords_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.fjordle_fjords_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_fjords_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_fjords_id_seq TO service_role;


--
-- Name: TABLE fjordle_game_sessions; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.fjordle_game_sessions TO anon;
GRANT ALL ON TABLE public.fjordle_game_sessions TO authenticated;
GRANT ALL ON TABLE public.fjordle_game_sessions TO service_role;


--
-- Name: TABLE fjordle_guesses; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.fjordle_guesses TO anon;
GRANT ALL ON TABLE public.fjordle_guesses TO authenticated;
GRANT ALL ON TABLE public.fjordle_guesses TO service_role;


--
-- Name: SEQUENCE fjordle_guesses_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.fjordle_guesses_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_guesses_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_guesses_id_seq TO service_role;


--
-- Name: TABLE fjordle_municipalities; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.fjordle_municipalities TO anon;
GRANT ALL ON TABLE public.fjordle_municipalities TO authenticated;
GRANT ALL ON TABLE public.fjordle_municipalities TO service_role;


--
-- Name: SEQUENCE fjordle_municipalities_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.fjordle_municipalities_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_municipalities_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_municipalities_id_seq TO service_role;


--
-- Name: TABLE fjordle_puzzle_queue; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.fjordle_puzzle_queue TO anon;
GRANT ALL ON TABLE public.fjordle_puzzle_queue TO authenticated;
GRANT ALL ON TABLE public.fjordle_puzzle_queue TO service_role;


--
-- Name: SEQUENCE fjordle_puzzle_queue_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.fjordle_puzzle_queue_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjordle_puzzle_queue_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjordle_puzzle_queue_id_seq TO service_role;


--
-- Name: TABLE fjords; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.fjords TO anon;
GRANT ALL ON TABLE public.fjords TO authenticated;
GRANT ALL ON TABLE public.fjords TO service_role;


--
-- Name: SEQUENCE fjords_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.fjords_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fjords_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fjords_id_seq TO service_role;


--
-- Name: TABLE frisc_anonymous_guesses; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.frisc_anonymous_guesses TO anon;
GRANT ALL ON TABLE public.frisc_anonymous_guesses TO authenticated;
GRANT ALL ON TABLE public.frisc_anonymous_guesses TO service_role;


--
-- Name: SEQUENCE frisc_anonymous_guesses_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.frisc_anonymous_guesses_id_seq TO anon;
GRANT ALL ON SEQUENCE public.frisc_anonymous_guesses_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.frisc_anonymous_guesses_id_seq TO service_role;


--
-- Name: TABLE frisc_anonymous_sessions; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.frisc_anonymous_sessions TO anon;
GRANT ALL ON TABLE public.frisc_anonymous_sessions TO authenticated;
GRANT ALL ON TABLE public.frisc_anonymous_sessions TO service_role;


--
-- Name: TABLE frisc_categories; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.frisc_categories TO anon;
GRANT ALL ON TABLE public.frisc_categories TO authenticated;
GRANT ALL ON TABLE public.frisc_categories TO service_role;


--
-- Name: SEQUENCE frisc_categories_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.frisc_categories_id_seq TO anon;
GRANT ALL ON SEQUENCE public.frisc_categories_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.frisc_categories_id_seq TO service_role;


--
-- Name: TABLE frisc_category_staging; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.frisc_category_staging TO anon;
GRANT ALL ON TABLE public.frisc_category_staging TO authenticated;
GRANT ALL ON TABLE public.frisc_category_staging TO service_role;


--
-- Name: TABLE frisc_puzzle_presentations; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.frisc_puzzle_presentations TO anon;
GRANT ALL ON TABLE public.frisc_puzzle_presentations TO authenticated;
GRANT ALL ON TABLE public.frisc_puzzle_presentations TO service_role;


--
-- Name: SEQUENCE frisc_puzzle_presentations_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.frisc_puzzle_presentations_id_seq TO anon;
GRANT ALL ON SEQUENCE public.frisc_puzzle_presentations_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.frisc_puzzle_presentations_id_seq TO service_role;


--
-- Name: TABLE frisc_puzzle_queue; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.frisc_puzzle_queue TO anon;
GRANT ALL ON TABLE public.frisc_puzzle_queue TO authenticated;
GRANT ALL ON TABLE public.frisc_puzzle_queue TO service_role;


--
-- Name: TABLE frisc_puzzles; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.frisc_puzzles TO anon;
GRANT ALL ON TABLE public.frisc_puzzles TO authenticated;
GRANT ALL ON TABLE public.frisc_puzzles TO service_role;


--
-- Name: SEQUENCE frisc_puzzles_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.frisc_puzzles_id_seq TO anon;
GRANT ALL ON SEQUENCE public.frisc_puzzles_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.frisc_puzzles_id_seq TO service_role;


--
-- Name: TABLE game_sessions; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.game_sessions TO anon;
GRANT ALL ON TABLE public.game_sessions TO authenticated;
GRANT ALL ON TABLE public.game_sessions TO service_role;


--
-- Name: SEQUENCE puzzle_presentations_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.puzzle_presentations_id_seq TO anon;
GRANT ALL ON SEQUENCE public.puzzle_presentations_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.puzzle_presentations_id_seq TO service_role;


--
-- Name: TABLE puzzle_queue; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.puzzle_queue TO anon;
GRANT ALL ON TABLE public.puzzle_queue TO authenticated;
GRANT ALL ON TABLE public.puzzle_queue TO service_role;


--
-- Name: SEQUENCE puzzle_queue_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.puzzle_queue_id_seq TO anon;
GRANT ALL ON SEQUENCE public.puzzle_queue_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.puzzle_queue_id_seq TO service_role;


--
-- Name: TABLE violets_completions; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.violets_completions TO anon;
GRANT ALL ON TABLE public.violets_completions TO authenticated;
GRANT ALL ON TABLE public.violets_completions TO service_role;


--
-- Name: TABLE violets_game_sessions; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.violets_game_sessions TO anon;
GRANT ALL ON TABLE public.violets_game_sessions TO authenticated;
GRANT ALL ON TABLE public.violets_game_sessions TO service_role;


--
-- Name: TABLE violets_node_versions; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.violets_node_versions TO anon;
GRANT ALL ON TABLE public.violets_node_versions TO authenticated;
GRANT ALL ON TABLE public.violets_node_versions TO service_role;


--
-- Name: TABLE violets_player_choices; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.violets_player_choices TO anon;
GRANT ALL ON TABLE public.violets_player_choices TO authenticated;
GRANT ALL ON TABLE public.violets_player_choices TO service_role;


--
-- Name: TABLE violets_sessions; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.violets_sessions TO anon;
GRANT ALL ON TABLE public.violets_sessions TO authenticated;
GRANT ALL ON TABLE public.violets_sessions TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- PostgreSQL database dump complete
--

\unrestrict uQRx6bkX1MKTgSRFhL8LTF9cNgeYZbh2SXjamcdxL2mg1gfPFdTjzEK6j7KM4Vy

