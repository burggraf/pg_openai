CREATE EXTENSION IF NOT EXISTS http;
CREATE SCHEMA IF NOT EXISTS ai;
CREATE TABLE IF NOT EXISTS ai.settings (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    openai_api_key text not null,
    default_settings jsonb not null
);
/*
INSERT INTO ai.settings (name, openai_api_key, default_settings) 
VALUES (
  'default', 
  '[openai api key]', 
  '{
    "temperature":0.5,
    "max_tokens":512,
    "top_p":1,
    "frequency_penalty":0.0,
    "presence_penalty":0.0,
    "best_of":1
   }'
);
*/
REVOKE ALL ON TABLE ai.settings FROM PUBLIC;

DROP FUNCTION IF EXISTS public.create_completion;
CREATE OR REPLACE FUNCTION public.create_completion (
    prompt text, 
    settings_name text DEFAULT 'default'::text, 
    override_settings jsonb DEFAULT '{}'::jsonb)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER -- required in order to read keys in the ai schema
  -- Set a secure search_path: trusted schema(s), then 'pg_temp'.
  -- SET search_path = admin, pg_temp;
  AS $$
DECLARE
  settings jsonb;
  retval jsonb;
  OPENAI_API_KEY text;
  tempoutput text;
BEGIN
  
  SELECT ai.settings.openai_api_key::text 
  INTO OPENAI_API_KEY 
  FROM ai.settings 
  WHERE name = settings_name 
  LIMIT 1;
  IF NOT found THEN 
    RAISE EXCEPTION 'missing entry in ai.settings %', settings_name;
  END IF;
  
  -- create settings:
  -- 1. global defaults
  -- 2. default settings from entry in ai.settings
  -- 3. optional override_settings passed to function
  SELECT 
    '{  "temperature":0.5,
        "max_tokens":512,
        "top_p":1,
        "frequency_penalty":0.0,
        "presence_penalty":0.0,
        "best_of":1,
        "timeout":"60000",
        "engine":"text-davinci-003"
    }'::jsonb ||
    default_settings::jsonb ||
    override_settings::jsonb
  INTO settings
  FROM ai.settings 
  WHERE name = settings_name 
  LIMIT 1;
  IF NOT found THEN 
    RAISE EXCEPTION 'missing entry in ai.settings %', settings_name;
  END IF;

  -- set 60 second timeout
  SELECT * into tempoutput from http_set_curlopt('CURLOPT_TIMEOUT_MS', coalesce(settings->>'timeout', '60000'));

  SELECT to_jsonb(rows) INTO retval FROM (
  SELECT  status, 
          content::jsonb->'id' as id,
          content::jsonb->'model' as model,
          content::jsonb->'object' as object,
          content::jsonb->'created' as created,
          content::jsonb->'usage'->'prompt_tokens' as prompt_tokens,
          content::jsonb->'usage'->'completion_tokens' as completion_tokens,
          content::jsonb->'usage'->'total_tokens' as total_tokens,
          REGEXP_REPLACE(content::jsonb->'choices'->0->>'text', 
          '^\n\n(.*)', '\1', 'n') as result
  FROM
    http (('POST', 
      'https://api.openai.com/v1/engines/' || coalesce(settings->>'engine', 'text-davinci-003') || '/completions', 
      ARRAY[http_header ('Authorization', 
      'Bearer ' || OPENAI_API_KEY)], 
      'application/json', 
      jsonb_build_object('prompt', prompt,
          'temperature', settings->'temperature', -- 0.5,
          'max_tokens', settings->'max_tokens', -- 512,
          'top_p', settings->'top_p', -- 1,
          'frequency_penalty', settings->'frequency_penalty', -- 0.0, --0.52,
          'presence_penalty', settings->'presence_penalty', -- 0.0, --0.5,
          'best_of', settings->'best_of' --1
          )::text
      ))    
  ) rows;
  RETURN retval;
END;
$$;
-- Do not allow this function to be called by public users (or called at all from the client)
REVOKE EXECUTE on function public.create_completion FROM PUBLIC;
