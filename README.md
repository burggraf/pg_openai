# pg_openai
A PostgreSQL extension for calling the OpenAI artificial intelligence api.

## Quickstart
1.  Copy your `OpenAI API Key` into the `INSERT` statement at the top of `install.sql` and un-comment the `INSERT` line(s).
2.  Run `install.sql` script on your database.
3.  Make your first OpenAI API call:  `select create_completion('Say "Hello, world."');`

## What is this?
`pg_openai` is a set of PostgreSQL functions that use the [pgsql-http](https://github.com/pramsey/pgsql-http) to make calls directly to the OpenAI GPT-3 API to send prompts to online Artificial Intelligence models and return text results.  These results can be used in your application and can be optionally stored in and used by your database.  

Since it's implemented as PostgreSQL functions, it can be used by of other database functions, database triggers, and can be called using the Supabase client or server-based APIs through `.rpc()` calls.

Logging is available which can keep track of OpenAI `tokens` used by your application.  (`tokens` are the billing mechanism OpenAI uses.  For example, at the time of writing, tokens used by the `text-davinci-003` are billed at USD$0.02 per 1000 tokens.)  You can use this logging data to limit your overall spending with OpenAI, to limit individual users' usage, or even to set up a billing system for your application users based on their usage of the OpenAI system.

## Requirements
You'll need:

- An account with OpenAI and a private API key which you can obtain by going to [https://openai.com/api/](https://openai.com/api).
- A Supabase project, or any PostgreSQL database with the [pgsql-http](https://github.com/pramsey/pgsql-http) installed.  Certain special features may not work outside of the Supabase environment, such as logging the currently logged-in user, which uses the `auth.uid()` function to return the id of current user.

## Function: `create_completion`
Sends a [create completion](https://beta.openai.com/docs/api-reference/completions) request to OpenAI.

### Parameters
The `create_completion` function takes up to 3 parameters, 2 of which are optional.

#### prompt (text, required)
This is the [prompt](https://beta.openai.com/docs/api-reference/completions/create#completions/create-prompt) used to generate a response.  The longer and more descriptive the prompt, the more likely you are to get a desired response.

#### configuration set name (text, optional)
This is the name of the **configuration set** to be used by the call to the OpenAI API.  **Configuration sets** contain your unique **API Key** along with any default settings to use when making the API call.  If no **configuration set name** is supplied, the function will look for a set named `default` and use that.  **Configuration sets** are stored in the `ai.settings` table.

#### override settings (json, optional)
A block of `json` settings can be sent in this third parameter.  These settings override anything set in the selected **configuration set**. 

## Settings
Every call to the OpenAI API is managed by a group of settings, conveniently stored as a JSONB object.  To keep things simple, default settings are provided inside the function(s).  You can override these settings with **configuration sets**.  Each **configuration set** is stored as a single row in the `ai.settings` table.  Furthermore you can override any of these **configuration sets** by passing specific values to your function call.

The precendence of settings works like this:
1. `override settings` sent as the 3rd parameter of the `create_completion` function call are used first.
2. Settings in the selected (or default) **configuration set** are used if a setting is not provided above.
3. Hard-coded function default settings are used if a setting is not found in either of the above places.

### Examples:
Below are examples ranging from simply sending a prompt, to including a named **configuration set**, to overriding specific settings for each individual API call.

#### Prompt Only
`select create_completion('Say "Hello, world."');`

Here no special settings were specified, so a configuration set with the name of `default` will be used.  A configuration set is required because that's where the `OpenAI API Key` is stored.  The minimum requirements for a **configuration set** are just a `name` and an `open_api_key`.  

For example, `INSERT INTO ai.settings (name, openai_api_key, default_settings) VALUES ('default', '[my openai api key]', '{}')`.  

You can also store any individual settings in the `default_settings` column as JSONB, and those settings will be used any time you use this **configuration set**.

#### Prompt, Configuration Set
`select create_completion('Say "Hello, world."', 'Full Logging');`

Here we're passing the name of a **configuration set** we created that fully logs every request.  

We can create that set using something like:  `INSERT INTO ai.settings (name, openai_api_key, default_settings) VALUES ('Full Logging', '[my openai api key]', '{"log":"full"}')`.  

You can include as many other settings as well in the `default_settings` block.

#### Prompt, Configuration Set, Override Settings
`select create_completion('Say "Hello, world."', 'Full Logging', '{"timeout":300000,"max_tokens":1000}');`

In this case we're using the `Full Logging` set, which turns on full logging, and we're then also overriding the default `timeout` value (to 5 minutes in this case) and increasing the `max_tokens` setting to `1000`.

#### Prompt and Override Settings (using the default configuration set)
`select create_completion('Say "Hello, world."', null, '{"timeout":300000,"max_tokens":1000}');`

We may want to just send override settings and not specify a specific **configuration set**.  In this case we just pass `null` as the second parameter, and in that case the **configuration set** named `default` will be used.  

### Individual Settings Options
Here are all the possible options that can be stored in a **configuration set** or can be overridden using the 3rd parameter of the `create_completion` function:

#### `timeout`
- **type**: numeric
- **description**: how much time to allow for a response, in milliseconds
- **default**: 60000 (one minute)

#### `engine`
- **type**: text
- **description**: the name of OpenAI model to use
- **valid values**: 'text-davinci-003', 'text-curie-001', 'text-babbage-001', 'text-ada-001'
- **default**: 'text-davinci-003'
- **see**: [OpenAI GPT-3 Models](https://beta.openai.com/docs/models/gpt-3)


#### `log`
- **type**: text
- **description**: this setting controls whether or not the results of the function call are logged to the `ai.log` table, and if so, how much detail is logged
- **valid values**: 'none', 'full', 'short'
- **default**: 'none'
- **notes**: `full` logging logs every field in the `ai.log` table, `short` logging omits the `prompt` and `result` fields (useful for just accounting purposes to keep track of token usage), `none` does not log anything


#### `temperature`
- **type**: numeric
- **description**: What sampling temperature to use. Higher values means the model will take more risks. Try 0.9 for more creative applications, and 0 (argmax sampling) for ones with a well-defined answer.
- **default**: 1.0
- **see**: [OpenAI: temperature](https://beta.openai.com/docs/api-reference/completions/create#completions/create-temperature)


#### `max_tokens`
- **type**: numeric
- **description**: the maximum number of tokens to generate in the completion
- **default**: 16
- **see**: [OpenAI: max_tokens](https://beta.openai.com/docs/api-reference/completions/create#completions/create-max_tokens)


#### `top_p`
- **type**: numeric
- **description**: An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
- **default**: 1
- **see**: [OpenAI: top_p](https://beta.openai.com/docs/api-reference/completions/create#completions/create-top_p)


#### `frequency_penalty`
- **type**: numeric
- **description**: Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
- **default**: 0
- **see**: [OpenAI: frequency_penalty](https://beta.openai.com/docs/api-reference/completions/create#completions/create-frequency_penalty)


#### `presence_penalty`
- **type**: numeric
- **description**: Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
- **default**: 0
- **see**: [OpenAI: presence_penalty](https://beta.openai.com/docs/api-reference/completions/create#completions/create-presence_penalty)


#### `best_of`
- **type**: numeric
- **description**: Generates best_of completions server-side and returns the "best" (the one with the highest log probability per token). Results cannot be streamed.
- **default**: 1
- **see**: [OpenAI: best_of](https://beta.openai.com/docs/api-reference/completions/create#completions/create-best_of)
