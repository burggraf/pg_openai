DROP FUNCTION IF EXISTS public.movie_recommendations;
CREATE OR REPLACE FUNCTION public.movie_recommendations()
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER -- required in order to read keys in the ai schema
  -- Set a secure search_path: trusted schema(s), then 'pg_temp'.
  -- SET search_path = admin, pg_temp;
  AS $$
DECLARE
  retval jsonb;
  uid text;
  favorites_string text;
  fullprompt text;
BEGIN
  select auth.uid() into uid;
  if uid is null then
    RAISE EXCEPTION 'missing user id';
  end if;

  select array_to_string(ARRAY[favorites],','::text,'') 
    into favorites_string 
    from movies 
    where movies.userid = uid::uuid;
  if not found then
    RAISE EXCEPTION 'missing favorites for user %', uid;
  end if;

  select 'I enjoyed the following movies: ' || 
        favorites_string || 
        '. Can you suggest some other movies I might like? ' || 
        'Please format the results with one movie per line.' into fullprompt;
  select create_completion(fullprompt) into retval;
  update movies set recommendations = retval->>'result', updated = now() where userid = uid::uuid;

  RETURN retval;
END;
$$;
