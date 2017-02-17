-- During sync, streams, stream_members, etc. get updated.  If a stream is deleted, for example,
-- it should not delete the associaged conversation.  Inbound Recon needs to do that. When IR
-- deletes the conversation, it must have the fully hydrated conversation to alert the UI about.
-- Thus, we need to remove ON DELETE CASCADES.  We also need to remove foreign keys between server
-- models and their corresponding API models, since an conversation row may refer to a deleted
-- stream row.  So Sync inserts a synced_changes for a deleted stream, and IR picks up the deleted
-- stream's row ID to delete from the conversations table.


-- Create synced_changes table for tracking stream, stream_member, etc. changes during sync for processing during InboundRecon

CREATE TABLE synced_changes (
  change_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  table_name TEXT NOT NULL,
  row_identifier INTEGER NOT NULL,
  change_type INTEGER NOT NULL
);


-- Remove the streams->conversations foreign key (decouple event deletes from message deletes)

CREATE TABLE temp_conversations (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  stream_database_identifier INTEGER UNIQUE,
  stream_id BLOB UNIQUE,
  created_at DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME,
  object_identifier TEXT UNIQUE NOT NULL
);

INSERT INTO temp_conversations (database_identifier, stream_database_identifier, created_at, deleted_at, object_identifier) SELECT database_identifier, stream_database_identifier, created_at, deleted_at, object_identifier FROM conversations;

UPDATE temp_conversations SET stream_id = (SELECT streams.stream_id FROM streams WHERE streams.database_identifier = stream_database_identifier);

DROP TABLE conversations;

ALTER TABLE temp_conversations RENAME TO conversations;

-- Recreate dropped triggers

CREATE TRIGGER track_deletes_of_conversations AFTER UPDATE OF deleted_at ON conversations
WHEN (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversations', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_inserts_of_conversations AFTER INSERT ON conversations
WHEN NEW.stream_database_identifier IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversations', NEW.database_identifier, 0);
END;


-- Remove the events->messages on foreign key (decouple event deletes from message deletes)

CREATE TABLE temp_messages (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  sent_at DATETIME,
  received_at DATETIME,
  deleted_at DATETIME,
  user_id STRING NOT NULL,
  seq INTEGER,
  conversation_database_identifier INTEGER NOT NULL,
  event_database_identifier INTEGER UNIQUE,
  version INT,
  object_identifier TEXT UNIQUE NOT NULL,
  message_index INT,
  UNIQUE(conversation_database_identifier, seq),
  FOREIGN KEY(conversation_database_identifier) REFERENCES conversations(database_identifier) ON DELETE CASCADE
);

INSERT INTO temp_messages (database_identifier, created_at, sent_at, received_at, deleted_at, user_id, seq, conversation_database_identifier, event_database_identifier, version, object_identifier, message_index) SELECT database_identifier, created_at, sent_at, received_at, deleted_at, user_id, seq, conversation_database_identifier, event_database_identifier, version, object_identifier, message_index FROM messages;

DROP TABLE messages;

ALTER TABLE temp_messages RENAME TO messages;

-- Recreate dropped triggers

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


-- Copy unprocessed events into synced_changes; drop unprocessed_events

DROP TRIGGER queue_events_for_processing;

INSERT INTO synced_changes (table_name, row_identifier, change_type) SELECT 'events', event_database_identifier, 0 FROM unprocessed_events;

DROP TABLE unprocessed_events;


-- Drop delete/tombstone triggers

DROP TRIGGER track_inserts_of_tombstone_events;

DROP TRIGGER track_updates_of_message_events_to_tombstone;


-- Triggers
--   0 INSERT
--   1 UPDATE
--   2 DELETE


----------------------------------------------------
-- Streams (INSERT/UPDATE/DELETE)
----------------------------------------------------

-- new inbound

CREATE TRIGGER track_inserts_of_streams AFTER INSERT ON streams
WHEN NEW.stream_id IS NOT NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', NEW.database_identifier, 0);
END;

-- unposted -> posted

CREATE TRIGGER track_updates_of_streams AFTER UPDATE OF stream_id ON streams
WHEN NEW.stream_id IS NOT NULL AND OLD.stream_id IS NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', NEW.database_identifier, 1);
END;

-- delete inbound

CREATE TRIGGER track_deletes_of_streams AFTER DELETE ON streams
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', OLD.database_identifier, 2);
END;


----------------------------------------------------
-- Stream Members (INSERT/DELETE)
----------------------------------------------------

-- new inbound

CREATE TRIGGER track_inserts_of_stream_members AFTER INSERT ON stream_members
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('stream_members', NEW._ROWID_, 0);
END;

-- delete inbound

CREATE TRIGGER track_deletes_of_stream_members AFTER DELETE ON stream_members
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('stream_members', OLD._ROWID_, 2);
END;


----------------------------------------------------
-- Events (INSERT [EVENT_DELETED and otherwise] / UPDATE)
----------------------------------------------------

-- new inbound

CREATE TRIGGER track_inserts_of_events_non_delete AFTER INSERT ON events
WHEN NEW.seq IS NOT NULL AND NEW.type != 9
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', NEW.database_identifier, 0);
END;

-- delete inbound: Inserts the EVENT_DELETED, then updates the target event to TOMBSTONE.  That update triggers its own deletion from event_content_parts and event_metadata.

CREATE TRIGGER track_inserts_of_events_delete AFTER INSERT ON events
WHEN NEW.seq IS NOT NULL AND NEW.type = 9
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', (SELECT database_identifier FROM events WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq), 2);
  UPDATE events SET type = 10, subtype = NULL, external_content_id = NULL, member_id = NULL, target_seq = NULL, version = NULL WHERE database_identifier = (SELECT database_identifier FROM events WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq);
END;

-- unposted -> posted

CREATE TRIGGER track_updates_of_event_seqs AFTER UPDATE OF seq ON events
WHEN NEW.seq IS NOT NULL AND OLD.seq IS NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', NEW.database_identifier, 1);
END;

-- Recreate tombstone trigger without message deletion

CREATE TRIGGER track_updates_of_event_type_message_to_tombstone AFTER UPDATE OF type ON events
WHEN NEW.type = 10 AND OLD.type = 4
BEGIN
  DELETE FROM event_content_parts WHERE event_database_identifier = NEW.database_identifier;
  DELETE FROM event_metadata WHERE event_database_identifier = NEW.database_identifier;
END;






