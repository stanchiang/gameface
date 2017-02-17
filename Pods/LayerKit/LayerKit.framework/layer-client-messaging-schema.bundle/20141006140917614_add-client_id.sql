-- Adds client_id to streams and events

ALTER TABLE streams ADD client_id STRING;

ALTER TABLE events ADD client_id STRING;

CREATE INDEX events_client_id_idx ON events(client_id);

CREATE INDEX streams_client_id_idx ON streams(client_id);
