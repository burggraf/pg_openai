# trigger_example
This example shows how you can call pg_openai automatically via a PostgreSQL database trigger.

In this example, we'll:
1. Create a table called tv_show_ideas.
2. Insert a record into the table with a sample title and genre.
3. View the automatically-generated description of our soon-to-be hit TV series.

## Getting Started
- Follow the instructions to run [install.sql](../../install.sql).
    - Be sure to uncomment the `ai.settings` block.
    - Make sure your personal OpenAI key has been entered.
- Execute [tv_show_ideas.sql](./tv_show_ideas.sql) in the [Supabase Dashboard SQL Editor](https://app.supabase.com/project/_/sql).
- Try inserting records in the `tv_show_ideas` table.

## Samples

`insert into tv_show_ideas (title, genre) values ('Unsolved Ancient Puzzles', 'documentary');`

The `description` field gets populated automatically:

> Unsolved Ancient Puzzles is a new documentary series that takes viewers on an exciting journey through time, exploring the mysteries of the past. Each episode follows a team of experts as they investigate unexplained phenomena and try to uncover the truth behind some of the world's oldest mysteries. From the mysterious structures of Stonehenge to the unsolved riddles of the Great Pyramids, this series will take viewers on a thrilling adventure as they search for the answers to some of history's most perplexing puzzles. With a mix of historical facts and cutting-edge technology, Unsolved Ancient Puzzles will leave viewers wondering what secrets the past holds.

`insert into tv_show_ideas (title, genre) values ('Dr. Morrison: Invisible Physics Professor', 'comedy');`

The `description` field gets populated automatically:

> Dr. Morrison: Invisible Physics Professor follows the misadventures of Dr. Morrison, an invisible physics professor who is determined to teach the world about the wonders of physics. Despite his invisibility, Dr. Morrison is not one to be deterred and uses his unique abilities to get his students to understand the complexities of physics. With the help of his quirky assistant, he must battle the bureaucracy of the university and the antics of his students in order to make sure that everyone learns the wonders of physics. This lighthearted comedy explores the unique challenges of teaching an invisible professor and the unique bond that forms between Dr. Morrison and his students.
