# pg_openai
A PostgreSQL extension for calling the OpenAI artificial intelligence api.

## Quickstart
1.  Copy your `OpenAI API Key` into the `INSERT` statement at the top of `install.sql` and un-comment the `INSERT` line(s).
2.  Run `install.sql` script on your database.
3.  Make your first OpenAI API call:  `select create_completion('Say "Hello, world."');`

