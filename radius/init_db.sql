DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'radius') THEN
      CREATE DATABASE radius;
   END IF;
END
$$;

DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'radius') THEN
      CREATE USER radius WITH PASSWORD 'radiuspass';
   END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE radius TO radius;

\c radius;

CREATE TABLE IF NOT EXISTS radcheck (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64),
    attribute VARCHAR(64),
    op CHAR(2),
    value VARCHAR(253)
);

INSERT INTO radcheck (username, attribute, op, value)
VALUES ('sqluser', 'Cleartext-Password', ':=', 'sqlpassword')
ON CONFLICT DO NOTHING;
