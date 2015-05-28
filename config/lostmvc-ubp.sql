/*
	Every Second Matters
	time and project management 
	todo parent id? or a tag is a parent id..?:d
	0 = deleted/hidden
	1 = running
	2 = paused
	3 = finished

*/
create table esm (
	id serial primary key unique not null,
	user_id int not null references users(id) ,
	name text,
	description text,

	start_at timestamptz,
	stop_at timestamptz,
	continue_at timestamptz,
	duration int DEFAULT 0,
	pauses int,
	running smallint default 0
);

CREATE TABLE esm_tags (
	tag_id INT NOT NULL references tags(id),
	esm_id INT NOT NULL references esm(id),
	constraint esm_tags_pkey primary key(tag_id,esm_id)
);
/* Time dates you worked on this..
1 = start_time
2 = stop_time
TODO new TEXT explaining..?
*/
CREATE TABLE esm_time (
	esm_id INT NOT NULL references esm(id),
	type INT default 1,
	date timestamptz
);
/*
Idea pool 
*/

/*
TODO items and an idea pool combined
*/
CREATE TABLE esm_todo (
	id serial PRIMARY KEY UNIQUE NOT NULL,
	user_id INT NOT NULL references users(id) ,
	description TEXT,
	created_at timestamptz,
	deadline timestamptz,
	colour TEXT
);

/*
	Personal Goldbag
*/

create table currency (
	id serial PRIMARY KEY UNIQUE NOT NULL,
	name TEXT
);

create table goldbag (
	id serial primary key unique not null,
	user_id int not null references users(id) ,
	 value numeric(20,2) NOT NULL,
	description text,
	spent_at timestamptz,
	expense smallint default 1,
	currency_id INT references currency(id)
);
CREATE TABLE goldbag_tags (
	tag_id INT NOT NULL references tags(id),
	goldbag_id INT NOT NULL references goldbag(id),

	constraint goldbag_tags_pkey primary key(tag_id,goldbag_id)
);

/*
	Brain Organizer
*/
--If you remember it, then you can schedule it to the next level (longer time)
-- If you forgot it, you need to reschedule it in the same amount of time.. (or start over..?)




CREATE TYPE repetition AS ENUM ('10 minutes','3 hours','1 day','1 week','1 month','3 months','1 year','5 years');
CREATE TYPE priority AS ENUM('Low','Medium','High');
create table brain_organizer (
	id serial primary key unique not null,
	author_id int not null references users(id) ,
	title citext,
	note text,
	added_at timestamptz,
	modify_at timestamptz,
	priority priority,

	reminder_at timestamptz,
	reminder_type repetition,
	rescheduled int
);
create table brain_organizer_questions (
	id serial primary key unique not null,
	brain_organizer_id INT NOT NULL references brain_organizer(id),
	question citext,
	answer citext,
	type int

);

CREATE TABLE brain_organizer_tags (
	tag_id INT NOT NULL references tags(id),
	brain_organizer_id INT NOT NULL references brain_organizer(id),
	constraint brain_organizer_tags_pkey primary key(tag_id,brain_organizer_id)
);


-- TODO TESTS!
-- multiple choice -- "fill in" -- definition words -- sentence --gap filling -- pronunciation
--Only form flashcards or simple question/answer.. per tag
create table brain_organizer_tests (
	id bigserial primary key unique not null,
	tag_id INT NOT NULL references tags(id)
);
CREATE TABLE brain_organizer_test_results (
	--id bigserial primary key unique not null,
	brain_organizer_test_id INT NOT NULL references brain_organizer_tests(id),
	question_id INT NOT NULL references brain_organizer_questions(id),
	qorder int, --order 1, 2, 3, 4.. 
	test_at timestamptz,
	correct int, -- 0=no,  1 yes		

	constraint brain_organizer_test_results_pkey primary key(question_id,brain_organizer_test_id)
);
CREATE TABLE brain_organizer_reminders (
	id bigserial primary key unique not null,
	reminder_at timestamptz,
	reminder_type repetition,
	done int, -- 0 = todo, 1=pass, 2=reschedule , 3=done
	rescheduled int, -- times rescheduled
	brain_organizer_id INT NOT NULL references brain_organizer(id)
);

CREATE TABLE brain_organizer_content (
	id serial primary key unique not null,
	tag_id INT NOT NULL references tags(id),
	price int

);

