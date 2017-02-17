-- Update SQL Schema for Messaging 6 Support
-- 1. Messages Table
--    Remove the not null constraint from user_id in messages table.
--      SQLite doesn't support modifying column constraints. So, create a new temp table without constraint, copy the data over, delete the old table and rename the new one
--    Add user_name to messages table.
-- 2. Events Table
--      Add creator_name to events table 
--      Change client_id to BLOB from TEXT
--      Remove 'version' column as it is deprecated  in thrift
-- 3. Streams Table
--      Change client_id to BLOB from TEXT
--      Remove 'version' column as it is deprecated in thrift

CREATE TABLE "messages_new" (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  sent_at DATETIME,
  received_at DATETIME,
  deleted_at DATETIME,
  user_id TEXT,
  seq INTEGER,
  conversation_database_identifier INTEGER NOT NULL,
  event_database_identifier INTEGER UNIQUE,
  version INTEGER NOT NULL,
  object_identifier TEXT UNIQUE NOT NULL,
  message_index INTEGER, is_unread INTEGER NOT NULL DEFAULT 0,
  UNIQUE(conversation_database_identifier, seq),
  FOREIGN KEY(conversation_database_identifier) REFERENCES conversations(database_identifier) ON DELETE CASCADE,
  FOREIGN KEY(event_database_identifier) REFERENCES events(database_identifier) ON DELETE CASCADE
);

INSERT INTO messages_new
    SELECT * FROM messages;

DROP TABLE messages;

ALTER TABLE messages_new RENAME to messages;

ALTER TABLE messages ADD user_name TEXT;

CREATE INDEX messages_conversation_database_identifier_idx ON messages(conversation_database_identifier);

CREATE INDEX messages_deleted_at_idx ON messages(deleted_at);

CREATE INDEX messages_event_database_identifier_idx ON messages(event_database_identifier);

CREATE INDEX messages_is_unread_idx ON messages(is_unread);

CREATE INDEX messages_message_index_idx ON messages(message_index);

CREATE TRIGGER track_deletes_of_messages AFTER UPDATE OF deleted_at ON messages
WHEN (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('messages', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_message_send_on_insert AFTER INSERT ON messages
WHEN NEW.seq IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('messages', NEW.database_identifier, 0);
END;

-- Update events table
CREATE TABLE "events_new" (
  database_identifier INTEGER PRIMARY KEY AUTOINCREMENT,
  type INTEGER NOT NULL,
  creator_id TEXT,
  seq INTEGER,
  timestamp INTEGER,
  preceding_seq INTEGER,
  client_seq INTEGER NOT NULL,
  subtype INTEGER,
  external_content_id BLOB,
  member_id TEXT,
  target_seq INTEGER,
  stream_database_identifier INTEGER NOT NULL,
  client_id BLOB,
  UNIQUE(stream_database_identifier, seq),
  FOREIGN KEY(stream_database_identifier) REFERENCES streams(database_identifier) ON DELETE CASCADE
);


INSERT INTO events_new
    SELECT database_identifier, 
    type, 
    creator_id, 
    seq, 
    timestamp, 
    preceding_seq, 
    client_seq, 
    subtype, 
    external_content_id, 
    member_id, 
    target_seq, 
    stream_database_identifier,  
    SUBSTR(client_id, 1, 8) || SUBSTR(client_id, 10, 4) || SUBSTR(client_id, 15, 4) || SUBSTR(client_id, 20, 4) || SUBSTR(client_id, 25, 12)
    FROM events;

DROP TABLE events;

ALTER TABLE events_new ADD creator_name TEXT;

ALTER TABLE events_new RENAME to events;

CREATE INDEX events_client_id_idx ON events(client_id);

CREATE INDEX events_seq_idx ON events(seq);

CREATE INDEX events_stream_database_identifier_idx ON events(stream_database_identifier);

CREATE TRIGGER tombstone_duplicate_events_by_client_id
AFTER INSERT ON events
FOR EACH ROW WHEN NEW.client_id IS NOT NULL
BEGIN
       UPDATE events SET type = 10
       WHERE database_identifier = NEW.database_identifier
       AND (SELECT count(*) FROM events WHERE client_id = NEW.client_id) > 1;
END;

CREATE TRIGGER track_inserts_of_events_delete
AFTER INSERT ON events FOR EACH ROW
WHEN NEW.seq IS NOT NULL AND NEW.type = 9 AND NOT EXISTS (SELECT 1 FROM events WHERE client_id = NEW.client_id AND database_identifier != NEW.database_identifier)
BEGIN
  INSERT OR IGNORE INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', (SELECT database_identifier FROM events WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq), 2);
  UPDATE events SET type = 10, subtype = NULL, external_content_id = NULL, member_id = NULL, target_seq = NULL WHERE database_identifier = (SELECT database_identifier FROM events WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq);
END;

CREATE TRIGGER track_inserts_of_events_non_delete
AFTER INSERT ON events FOR EACH ROW
WHEN NEW.seq IS NOT NULL AND NEW.type != 9 AND NOT EXISTS (SELECT 1 FROM events WHERE client_id = NEW.client_id AND database_identifier != NEW.database_identifier)
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_updates_of_event_seqs AFTER UPDATE OF seq ON events
WHEN NEW.seq IS NOT NULL AND OLD.seq IS NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', NEW.database_identifier, 1);
END;

CREATE TRIGGER track_updates_of_event_type_message_to_tombstone AFTER UPDATE OF type ON events
WHEN NEW.type = 10 AND OLD.type = 4
BEGIN
  DELETE FROM event_content_parts WHERE event_database_identifier = NEW.database_identifier;
  DELETE FROM remote_keyed_values WHERE object_type = 'event' AND object_id = NEW.database_identifier;
END;

CREATE TRIGGER track_updates_of_stream_id_for_events AFTER UPDATE OF stream_database_identifier ON events
WHEN NEW.stream_database_identifier IS NOT NULL AND OLD.stream_database_identifier IS NOT NULL AND NEW.stream_database_identifier != OLD.stream_database_identifier
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', NEW.database_identifier, 1);
END;

-- Update stream table to use BLOB instead of TEXT for client_id
CREATE TABLE "streams_new" (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  stream_id BLOB UNIQUE,
  seq INTEGER NOT NULL DEFAULT 0,
  client_seq INTEGER NOT NULL DEFAULT 0,
  client_id BLOB, 
  deleted_at DATETIME, 
  min_synced_seq INTEGER, 
  max_synced_seq INTEGER, metadata_timestamp INTEGER, is_distinct INTEGER NOT NULL DEFAULT 0
);

INSERT INTO streams_new
    SELECT database_identifier, 
    stream_id, 
    seq, 
    client_seq,
    SUBSTR(client_id, 1, 8) || SUBSTR(client_id, 10, 4) || SUBSTR(client_id, 15, 4) || SUBSTR(client_id, 20, 4) || SUBSTR(client_id, 25, 12), 
    deleted_at,
    min_synced_seq,
    max_synced_seq,
    metadata_timestamp,
    is_distinct FROM streams;

DROP TABLE streams;

ALTER TABLE streams_new RENAME to streams;

CREATE INDEX streams_client_id_idx ON streams(client_id);

CREATE INDEX streams_deleted_at_idx ON streams(deleted_at);

CREATE TRIGGER track_deletes_of_streams AFTER UPDATE OF deleted_at ON streams
WHEN NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', OLD.database_identifier, 2);
END;

CREATE TRIGGER track_inserts_of_streams AFTER INSERT ON streams
WHEN NEW.stream_id IS NOT NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_updates_of_streams AFTER UPDATE OF stream_id ON streams
WHEN NEW.stream_id IS NOT NULL AND OLD.stream_id IS NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', NEW.database_identifier, 1);
END;
