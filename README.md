# pg_openai
A PostgreSQL extension for calling the OpenAI artificial intelligence api.

## Quickstart
1.  Copy your `OpenAI API Key` into the `INSERT` statement at the top of `install.sql` and un-comment the `INSERT` line(s).
2.  Run `install.sql` script on your database.
3.  Make your first OpenAI API call:  `select create_completion('Say "Hello, world."');`

## Settings
Every call to the OpenAI API is managed by a group of settings, conveniently stored as a JSONB object.  To keep things simple, default settings are provided inside the function(s).  You can override these settings with **configuration sets**.  Each **configuration set** is stored as a single row in the `ai.settings` table.  Furthermore you can override any of these **configuration sets** by passing specific values to your function call.

### Examples:

#### Prompt Only
`select create_completion('Say "Hello, world."');`
Here no special settings were specified, so a configuration set with the name of `default` will be used.  A configuration set is required because that's where the `OpenAI API Key` is stored.  The minimum requirements for a **configuration set** are just a `name` and an `open_api_key`.  For example, `INSERT INTO ai.settings (name, openai_api_key) VALUES ('default', '[my openai api key]')`.  You can also store any individual settings in the `default_settings` column as JSONB, and those settings will be used any time you use this **configuration set**.

#### Prompt, Configuration Set
`select create_completion('Say "Hello, world."', 'Full Logging');`
Here we're passing the name of a **configuration set** we created that fully logs every request.  We can create that set using something like:  `INSERT INTO ai.settings (name, openai_api_key, default_settings) VALUES ('Full Logging', '[my openai api key]', '{"log":"full"}')`.  You can include as many other settings as well in the `default_settings` block.

#### Prompt, Configuration Set, Override Settings
`select create_completion('Say "Hello, world."', 'Full Logging', '{"timeout":300000,"max_tokens":1000}');`
In this case we're using the `Full Logging` set, which turns on full logging, and we're then also overriding the default `timeout` value (to 5 minutes in this case) and increasing the `max_tokens` setting to `1000`.

#### Prompt and Override Settings (using the default configuration set)
`select create_completion('Say "Hello, world."', null, '{"timeout":300000,"max_tokens":1000}');`
We may want to just send override settings and not specify a specific **configuration set**.  In this case we just pass `null` as the second parameter, and in that case the **configuration set** named `default` will be used.  


### Individual Settings Options

`temperature`
`max_tokens`
`top_p`
`frequency_penalty`
`presence_penalty`
`best_of`
`timeout`
`engine`
`log`
