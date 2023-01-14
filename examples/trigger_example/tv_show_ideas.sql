-- create the table
create table if not exists tv_show_ideas
(
  id uuid primary key default gen_random_uuid(),
  title text,
  genre text,
  description text,
  tagline text,
  actors text
);
-- create a trigger function on the tv_show_ideas table
-- that will generate a description for a new tv show idea
-- when a new record is inserted
create or replace function generate_tv_show_data()
  returns trigger
  language plpgsql
  security definer
  as $$
declare
    retval jsonb;
begin
    select create_completion(
        'Write a description for a new TV show named "' ||
         new.title || '".  The genre for this show is ' || new.genre || '.'
    ) into retval;
    if coalesce((retval->'status')::smallint,0) = 200 then
        new.description = (retval->>'result')::text;
    else
        new.description = 'No description available.';
    end if;
    return new;
end;
$$;
-- create the trigger
create trigger generate_tv_show_data
  before insert
  on tv_show_ideas
  for each row
  execute procedure generate_tv_show_data();
