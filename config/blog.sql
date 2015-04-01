/*
Blog Module Stuff
Posts
post_tags
Comments
Authors
*/
-- POSTS
-- Status 0 = DRAFT, 1= PUBLISHED PUBLIC, 2= PUBLISHED LOGGED IN, 3 = featured(public on top), 4=archived(marked as archive)

create table blog_post (
	id serial primary key unique not null,
	title text,
	slug text,
	post text,

	creation_at timestamp,
	author_id int not null references users(id) ,
	update_at timestamp,
	update_user_id int not null references users(id) ,
	public_at timestamp,
	reading_time int,
	originaltranslation_id int references blog_post(id),
	language text,
	status smallint DEFAULT 0
);
/*
	Tags that will be used all over the application
*/
CREATE TABLE blog_tags (
	tag_id INT NOT NULL references tags(id),
	post_id INT NOT NULL references blog_post(id),
	constraint blog_tags_pkey primary key(tag_id,post_id)
);

-- Comments
-- Status 0 = Review required, 1 = approved, 2 = blocked
create table blog_comment (
	id serial primary key unique not null,
	reply_to INT references blog_comment(id),
	post_id INT NOT NULL references blog_post(id),
	comment text,
	creation_at timestamp,
	user_id int not null references users(id) ,
	status smallint DEFAULT 0
);

