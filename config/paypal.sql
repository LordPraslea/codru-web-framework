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
	
	creation_at timestamp,
	payment_at timestamp,
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
ALTER TABLE paypal OWNER to lostone;

