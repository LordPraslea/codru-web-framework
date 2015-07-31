
/*
	Users
*/
-- CITEXT for case insensitive TEXT
--Usertype to differentiate different "types" ..(not level or access!)
-- like 1 = student, 2 = professor, 4 = blabla..
CREATE EXTENSION IF NOT EXISTS citext ;
CREATE TABLE users (
	id serial PRIMARY KEY UNIQUE NOT NULL,
	username CITEXT UNIQUE NOT NULL ,
	password TEXT NOT NULL,
	telephone TEXT NOT NULL DEFAULT 0,
	email CITEXT UNIQUE NOT NULL,
	last_login_at timestamptz,
	creation_at timestamptz,
	creation_ip inet,

	password_reset_at timestamptz,
	password_code TEXT,
	login_attempts SMALLINT DEFAULT 0,
	temp_login_block_until timestamptz,

	timezone text,
	language text,

	activation_code TEXT,
	status smallint	DEFAULT 1,
	user_type smallint DEFAULT 1,
	credits int DEFAULT 0
);
create table login_stats (
	user_id int references users(id),
	login_at timestamptz,
	login_ip inet
);
-- CREATE UNIQUE INDEX users_username_key ON users (lower(username));
-- CREATE UNIQUE INDEX users_email_key ON users (lower(email));
--ALTER TABLE users OWNER TO lostone;
--ALTER TABLE login_stats OWNER TO lostone;

-- This is so we don't have a enormous users table
-- Everything else that's a field of user provided
-- data can come in the profile ,
-- required: 0=no, 1=yes, 2=optional register,3=required register..

CREATE TABLE profile_type (
	id serial PRIMARY KEY UNIQUE NOT NULL,
	name CITEXT UNIQUE NOT NULL,
	type TEXT,
--	empty smallint default 0,
	required INT default 0
);
CREATE TABLE user_profile (
	user_id int not null references users(id) ,
	profile_id  int not null references profile_type(id) ,
	profile_value CITEXT NOT NULL,
	CONSTRAINT user_profile_pkey PRIMARY KEY (user_id, profile_id)
);

/* RBAC 
	Role based Access Control List
*/


--auth_item
--id	name	type		description	bizrule	data
--type  (0: operation,		1: task, 	2: role)
--bizrule: piece of code to be executed when checkAccess is called..
--name: 	module.controller.view  	you can also use  wildcard * to indicate for ALL views

CREATE TABLE role_item (
	id serial PRIMARY KEY UNIQUE NOT NULL,
	name CITEXT UNIQUE NOT NULL,
	type int NOT NULL,
	description TEXT,
	bizrule TEXT,
	data TEXT
);
INSERT INTO role_item (name,type,description) VALUES ('superadmin',2,'Super Admin Perk'), ('authenticated',2,'Authenticated users'), ('guest',2,'Guest users');

--auth_item_child
-- referencing one another.. having multiple children.. etc:)
CREATE TABLE role_item_child (
	--either as id's or as NAME's..
	parent_id int references role_item(id),
	child_id int references role_item(id),
	constraint role_item_child_pkey primary key(parent_id,child_id)
);

--auth_assignment
CREATE TABLE role_assignment (
	item_id int  NOT NULL references role_item(id),
--	name CITEXT UNIQUE NOT NULL,
	user_id int not null references users(id) ,
	bizrule TEXT,
	data TEXT
);

/*
-- parent/child are id/name's from auth_item. 
These are TYPES that contain multiple subtypes
These can be assigned in auth_assignment

*/

/* LostMVC trash functionality
	When we delete something in any place, it actually comes here serialized
	We keep it here for aproximately 3-7 days, afterwards it gets deleted.
	You can recover it by going into "trash"	
*/
CREATE TABLE lostmvc_recyclebin (
	id serial primary key unique not null,
	user_id integer references users(id),
	deleted_at timestamptz,
	table_name text,
	data text
);

--ALTER TABLE lostmvc_recyclebin OWNER to lostone;

/*
	Tags that will be used all over the application
*/
create table tags (
	id serial PRIMARY KEY,
	tag CITEXT NOT NULL
);
-- Contact
create table contact_us (
	id serial primary key unique not null,
	user_id int references users(id) ,
	name text,
	email text,
	ip text,
	sent_at timestamptz,
	message text

);


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

	creation_at timestamptz,
	author_id int not null references users(id) ,
	update_at timestamptz,
	update_user_id int not null references users(id) ,
	public_at timestamptz,
	reading_time int,
	originaltranslation_id int references blog_post(id),
	language text,
	status smallint DEFAULT 0,
	cms smallint NOT NULL DEFAULT 0
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
	creation_at timestamptz,
	user_id int not null references users(id) ,
	status smallint DEFAULT 0
);

create table blog_gallery (
	post_id INT NOT NULL references blog_post(id),
	image_name TEXT,
	uploade_at timestamptz
);
/*
TODO bank transfer implementation
*/
create table banktransfer_payments (

);
/*
PayPal REST api paypemt for LostMVC

*/
create table paypal_payments (
	id serial primary key unique not null,
	pay_id text,
	access_token text UNIQUE,

	description text,
	amount numeric,
	currency text,
	--	Subscription or item_id or order_id ..?
	subscription text,

	payment_method text,
	
	creation_at timestamptz,
	payment_at timestamptz,
	user_id int not null references users(id) ,
	email text,
	first_name text,
	last_name text,
	
	token text,
	payer_id text,
	execute_url text,
	related_resources text,

	state text
);
-- ALTER TABLE paypal_payments OWNER to lostone;

/*
United Brain Power 
	Subscriptions
	Orders
	Items(downloads)
*/
CREATE TABLE credit_purchase (
	id serial primary key not null,
	user_id INT NOT NULL references users(id),
	issued_by INT references users(id), -- SYSTEM or user_id
	credits int,
	price numeric,
	buy_at timestamptz
);
-- ALTER TABLE credit_purchase OWNER to lostone;

CREATE TABLE credit_history (
	user_id INT NOT NULL references users(id),
	credits int,
	use_for text,
	use_at timestamptz
);
-- ALTER TABLE credit_history OWNER to lostone;

-- Subscription table from within administration panel...
-- can be overwritten by each controller..
create table subscription (
	id serial primary key unique not null,
	description text,
	controller text,
	time int, -- days either 30 or 365
	credits int
);
-- ALTER TABLE subscription OWNER to lostone;

create table user_subscription (
	subscription_id INT NOT NULL references subscription(id),
	user_id INT NOT NULL references users(id),
	begin_at timestamptz,
	end_at timestamptz,
	--  suspended 0 , Ok 1 
	status smallint default 1
);

-- ALTER TABLE user_subscription OWNER to lostone;

/*	United Brain Power
	---	Online Shop System
*/

create table shop_address (
	id serial primary key unique not null,
	user_id INT NOT NULL references users(id),

	name citext,
	telephone text,
	country text,
	state text,
	city text,
	address text,
	
	vat text,
	company text
);

create table shop_order (
	id serial primary key unique not null,
	user_id INT NOT NULL references users(id),
	creation_date timestamptz,
	payment_date timestamptz,
	payment_instrument text,
	invoice_number text,
	final_price numeric,

	shop_address_id  INT NOT NULL references shop_address(id),
	
	creation_ip inet,
	payment_ip inet,
	--  Open 0 , In Process 1, Error 2, Complete 3 = Paid, 4 Not Accepted/Refused , 5 = refunded 
	status smallint default 0
);



-- ALTER TABLE shop_order OWNER to lostone;


Create table shop_item (
	id serial primary key unique not null,
	name text,
	url text,
	description text,
	price numeric,
	-- RON USD EUR etc
	currency text,
	-- if lang is set, then we show it in searches only for that specific language!
	lang text,
	credits int,
	stock int,
	sold int DEFAULT 0,
	-- Images .. 
	images_gallery text
);

create table shop_item_belongs (
	parent_id INT  references shop_item(id), 
	child_id INT  references shop_item(id), 
	constraint shop_item_belongs_pk primary key(parent_id,child_id)
);

-- ALTER TABLE shop_item OWNER to lostone;
Create table shop_item_rating (
	item_id INT  references shop_item(id),
	user_id INT NOT NULL references users(id),
	rating int,
	rating_ip inet
);

-- ALTER TABLE shop_item_rating OWNER to lostone;
Create table shop_item_comment (
	id serial primary key unique not null,
	reply_to INT references shop_item_comment(id),
	item_id INT NOT NULL references shop_item(id),
	comment text,
	creation_at timestamptz,
	user_id int not null references users(id) ,
	status smallint DEFAULT 0
);

-- ALTER TABLE shop_item_comment OWNER to lostone;
-- Used for recommended/related products!
CREATE TABLE shop_item_tags (
	tag_id INT NOT NULL references tags(id),
	item_id INT NOT NULL references shop_item(id),
	constraint shop_item_tags_pkey primary key(tag_id,item_id)
);

-- ALTER TABLE shop_item_tags OWNER to lostone;

Create table shop_order_item (
	shop_order_id INT NOT NULL references shop_order(id),
	item_id INT  references shop_item(id),
	final_price numeric,
	quantity INT DEFAULT 1,
	constraint shop_order_item_pkey primary key(shop_order_id,item_id)
);
-- ALTER TABLE shop_order_item OWNER to lostone;



