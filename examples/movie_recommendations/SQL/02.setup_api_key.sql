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
    "best_of":1,
    "timeout": 60000,
    "engine": "text-davinci-003",
    "log": "short"
   }'
);
