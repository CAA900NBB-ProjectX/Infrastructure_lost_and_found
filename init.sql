-- Create itemdb and its tables
CREATE DATABASE itemdb;
\c itemdb;

CREATE TABLE lostitems (
    item_id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    category_id integer,
    contact_info varchar(255),
    created_at time without time zone,
    date_time_found timestamp without time zone,
    description varchar(255),
    image_ids bigint[],
    item_name varchar(255),
    location_found varchar(255),
    reported_by varchar(255),
    status varchar(255),
    updated_at time without time zone,
    PRIMARY KEY(item_id)
);

CREATE TABLE itemimages (
    id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    created_at time without time zone,
    date_time time without time zone,
    description varchar(255),
    image bytea,
    location_found varchar(255),
    status varchar(255),
    updated_at time without time zone,
    item_id integer,
    PRIMARY KEY(id),
    CONSTRAINT fked85ginr93196hj2sbefocc7y FOREIGN KEY(item_id) REFERENCES lostitems(item_id)
);

-- Create chatdb and its tables
CREATE DATABASE chatdb;
\c chatdb;

CREATE TABLE chat (
    id varchar(255) NOT NULL,
    created_date timestamp without time zone,
    last_modified_date timestamp without time zone,
    item_id integer NOT NULL,
    recipient integer,
    sender integer,
    PRIMARY KEY(id)
);

CREATE TABLE messages (
    id bigint NOT NULL,
    created_date timestamp without time zone,
    last_modified_date timestamp without time zone,
    content text,
    item_id integer NOT NULL,
    media_file_path varchar(255),
    receiver_id varchar(255) NOT NULL,
    sender_id varchar(255) NOT NULL,
    state varchar(255),
    "type" varchar(255),
    chat_id varchar(255),
    PRIMARY KEY(id),
    CONSTRAINT fkdumcu11xf8ldun8i4xpd04j43 FOREIGN KEY(chat_id) REFERENCES chat(id),
    CONSTRAINT messages_state_check CHECK ((state)::text = ANY ((ARRAY['SENT', 'SEEN'])::text[])),
    CONSTRAINT messages_type_check CHECK ((type)::text = ANY ((ARRAY['TEXT', 'IMAGE'])::text[]))
);
