# movie recommendations
This is a sample app that uses `pg_openai` to generate movie recommendations based on an input list of your favorite movies.

- It's written in Svelte / SvelteKit.
- It uses Supabase Auth to allow users to:
    - Sign up
    - Sign in
    - Change passwords
- Users can enter a list of favorite movies, click a button, and get a list of recommended movies they might like.
- Data is written to the `movies` table in the PostgreSQL database.
- Recommendations are fetched by the PostgreSQL function `public.movie_recommendations()`.
- Users are limited to using 500 `tokens` per 24 hour period, after which they'll get an error message asking them to "try again tomorrow".

## Getting Started

1. Create a Supabase project if you don't already have one. 
2. Set the `VITE_SUPABASE_URL` environment variable to your [Supabase Project URL](https://app.supabase.com/project/_/settings/api).
3. Set the `VITE_SUPABASE_KEY` environment variable to your [Supabase anon/public key](https://app.supabase.com/project/_/settings/api).
4. Enter your [OpenAI API Key](https://openai.com/api) in the file [02.setup_api_key.sql](./SQL/02.setup_api_key.sql).
5. Execute the contents of the following files in the [Supabase Dashboard SQL Editor](https://app.supabase.com/project/_/sql).
    - [01.install.pg_openai.sql](./SQL/01.install.pg_openai.sql)
    - [02.setup_api_key.sql](./SQL/02.setup_api_key.sql)
    - [03.movie_recommendations.sql](./SQL/03.movie_recommendations.sql)
6. Run the app
    - Development: `npm run dev`
    - Production: deploy to Vercel, Netlify, or anywhere you like (don't forget to set the environment variables `VITE_SUPABASE_URL` and `VITE_SUPABASE_KEY`).
