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
  uid uuid;
  favorites_string text;
  fullprompt text;
  tokens_used int;
BEGIN
    select auth.uid() into uid;
    if uid is null then
        RAISE EXCEPTION 'missing user id or user not logged in';
    end if;

    select coalesce(sum(total_tokens),0) 
        from ai.log 
        where user_id = uid 
        and inserted > now() - interval '24 hours'
        into tokens_used;
    
    -- apply a limit of 500 tokens per day per user
    if tokens_used > 500 then
        RAISE EXCEPTION 'usage limit exceeded, try again tomorrow';
    end if;
 
    select array_to_string(ARRAY[favorites],','::text,'') 
        into favorites_string 
        from movies 
        where movies.userid = uid;

    if not found then
        RAISE EXCEPTION 'missing favorites for user';
    end if;

    select 'I enjoyed the following movies: ' || 
            favorites_string || 
            '. Can you suggest some other movies I might like? ' || 
            'Please format the results with one movie per line.' into fullprompt;
    select create_completion(fullprompt) into retval;
    update movies set recommendations = retval->>'result', updated = now() where userid = uid;

    RETURN retval;
END;
$$;
