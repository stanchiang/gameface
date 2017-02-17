-- Drops everything and recreates to:
--   * correct schema case (TYPE, TABLE_NAME, KEY, VALUE)
--   * make indents consistent (spaces instead of tabs)
--   * drop dates besides `deleted_at` from messages (which would drop many triggers anyway)
--   * add UNIQUE(object_type, object_id, key) to keyed_values

-- drop tables

DROP TABLE IF EXISTS conversation_participants;

DROP TABLE IF EXISTS conversations;

DROP TABLE IF EXISTS event_content_parts;

DROP TABLE IF EXISTS event_metadata;

DROP TABLE IF EXISTS events;

DROP TABLE IF EXISTS keyed_values;

DROP TABLE IF EXISTS message_index;

DROP TABLE IF EXISTS message_parts;

DROP TABLE IF EXISTS message_recipient_status;

DROP TABLE IF EXISTS messages;

DROP TABLE IF EXISTS schema_migrations;

DROP TABLE IF EXISTS stream_members;

DROP TABLE IF EXISTS streams;

DROP TABLE IF EXISTS syncable_changes;

DROP TABLE IF EXISTS unprocessed_events;


-- drop triggers

DROP TRIGGER IF EXISTS queue_events_for_processing;

DROP TRIGGER IF EXISTS tombstone_deleted_events_on_delete;

DROP TRIGGER IF EXISTS track_deletes_of_conversation_participants;

DROP TRIGGER IF EXISTS track_deletes_of_conversations;

DROP TRIGGER IF EXISTS track_deletes_of_keyed_values;

DROP TRIGGER IF EXISTS track_deletes_of_messages;

DROP TRIGGER IF EXISTS track_inserts_of_conversation_participants;

DROP TRIGGER IF EXISTS track_inserts_of_conversations;

DROP TRIGGER IF EXISTS track_inserts_of_keyed_values;

DROP TRIGGER IF EXISTS track_inserts_of_messages;

DROP TRIGGER IF EXISTS track_inserts_of_tombstone_events;

DROP TRIGGER IF EXISTS track_re_inserts_of_conversation_participants;

DROP TRIGGER IF EXISTS track_updates_of_keyed_values;

DROP TRIGGER IF EXISTS track_updates_of_message_events_to_tombstone;


-- create tables

CREATE TABLE conversation_participants (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  conversation_database_identifier INTEGER NOT NULL,
  stream_member_database_identifier INTEGER,
  member_id STRING NOT NULL,
  created_at DATETIME NOT NULL,
  deleted_at DATETIME,
  seq INTEGER,
  event_database_identifier INTEGER UNIQUE,
  UNIQUE(conversation_database_identifier, member_id),
  FOREIGN KEY(conversation_database_identifier) REFERENCES conversations(database_identifier) ON DELETE CASCADE,
  FOREIGN KEY(event_database_identifier) REFERENCES events(database_identifier) ON DELETE CASCADE
);

CREATE TABLE conversations (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  stream_database_identifier INTEGER UNIQUE, deleted_at DATETIME,
  FOREIGN KEY(stream_database_identifier) REFERENCES streams(database_identifier) ON DELETE CASCADE
);

CREATE TABLE event_content_parts (
  event_content_part_id INTEGER NOT NULL,
  event_database_identifier INTEGER NOT NULL,
  type TEXT NOT NULL,
  value BLOB,
  FOREIGN KEY(event_database_identifier) REFERENCES events(database_identifier) ON DELETE CASCADE,
  PRIMARY KEY(event_content_part_id, event_database_identifier)
);

CREATE TABLE event_metadata (
  event_database_identifier INTEGER NOT NULL,
  key TEXT NOT NULL,
  value BLOB NOT NULL,
  FOREIGN KEY(event_database_identifier) REFERENCES events(database_identifier) ON DELETE CASCADE,
  PRIMARY KEY(event_database_identifier, key)
);

CREATE TABLE events (
  database_identifier INTEGER PRIMARY KEY AUTOINCREMENT,
  type INTEGER NOT NULL,
  creator_id STRING,
  seq INTEGER,
  timestamp INTEGER,
  preceding_seq INTEGER,
  client_seq INTEGER NOT NULL,
  subtype INTEGER,
  external_content_id BLOB,
  member_id STRING,
  target_seq INTEGER,
  stream_database_identifier INTEGER NOT NULL,
  version INT,
  UNIQUE(stream_database_identifier, seq),
  FOREIGN KEY(stream_database_identifier) REFERENCES streams(database_identifier) ON DELETE CASCADE
);

CREATE TABLE keyed_values (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  object_type STRING NOT NULL,
  object_id INTEGER NOT NULL,
  key_type INTEGER NOT NULL,
  key STRING NOT NULL,
  value BLOB NOT NULL,
  deleted_at DATETIME,
  seq INTEGER,
  UNIQUE(object_type, object_id, key)
);

CREATE TABLE message_index (
  conversation_database_identifier INTEGER NOT NULL,
  message_database_identifier INTEGER UNIQUE NOT NULL,
  FOREIGN KEY(message_database_identifier) REFERENCES messages(database_identifier) ON DELETE CASCADE
);

CREATE TABLE message_parts (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  message_database_identifier INTEGER NOT NULL,
  mime_type STRING NOT NULL,
  content BLOB,
  url STRING,
  FOREIGN KEY(message_database_identifier) REFERENCES messages(database_identifier) ON DELETE CASCADE
);

CREATE TABLE message_recipient_status (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  message_database_identifier INTEGER NOT NULL,
  user_id STRING NOT NULL,
  status INTEGER NOT NULL,
  seq INTEGER,
  FOREIGN KEY(message_database_identifier) REFERENCES messages(database_identifier) ON DELETE CASCADE
);

CREATE TABLE messages (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  deleted_at DATETIME,
  user_id STRING NOT NULL,
  seq INTEGER,
  conversation_database_identifier INTEGER NOT NULL,
  event_database_identifier INTEGER UNIQUE, version INT,
  UNIQUE(conversation_database_identifier, seq),
  FOREIGN KEY(conversation_database_identifier) REFERENCES conversations(database_identifier) ON DELETE CASCADE,
  FOREIGN KEY(event_database_identifier) REFERENCES events(database_identifier) ON DELETE CASCADE
);

CREATE TABLE schema_migrations (
  version INTEGER UNIQUE NOT NULL
);

CREATE TABLE stream_members (
  stream_database_identifier INTEGER NOT NULL,
  member_id STRING NOT NULL,
  PRIMARY KEY(stream_database_identifier, member_id),
  FOREIGN KEY(stream_database_identifier) REFERENCES streams(database_identifier) ON DELETE CASCADE
);

CREATE TABLE streams (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  stream_id BLOB UNIQUE,
  seq INTEGER NOT NULL DEFAULT 0,
  client_seq INTEGER NOT NULL DEFAULT 0,
  version INT
);

CREATE TABLE syncable_changes (
  change_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  table_name TEXT NOT NULL,
  row_identifier INTEGER NOT NULL,
  change_type INTEGER NOT NULL
);

CREATE TABLE unprocessed_events (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  event_database_identifier INTEGER NOT NULL UNIQUE,
  created_at DATETIME NOT NULL,
  FOREIGN KEY(event_database_identifier) REFERENCES events(database_identifier) ON DELETE CASCADE
);


-- create triggers

CREATE TRIGGER queue_events_for_processing AFTER INSERT ON events
WHEN NEW.seq IS NOT NULL
BEGIN
  INSERT INTO unprocessed_events(event_database_identifier, created_at) VALUES(NEW.database_identifier, datetime('now'));
END;

CREATE TRIGGER tombstone_deleted_events_on_delete AFTER INSERT ON events
WHEN NEW.type = 9
BEGIN
  UPDATE events SET type = 10, subtype = NULL, external_content_id = NULL, member_id = NULL, target_seq = NULL, version = NULL, creator_id = NULL
  WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq;
END;

CREATE TRIGGER track_deletes_of_conversation_participants AFTER UPDATE OF deleted_at ON conversation_participants
WHEN NEW.seq IS OLD.seq AND (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversation_participants', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_deletes_of_conversations AFTER UPDATE OF deleted_at ON conversations
WHEN (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversations', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_deletes_of_keyed_values AFTER UPDATE OF deleted_at ON keyed_values
WHEN (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('keyed_values', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_deletes_of_messages AFTER UPDATE OF deleted_at ON messages
WHEN (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('messages', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_inserts_of_conversation_participants AFTER INSERT ON conversation_participants
WHEN NEW.stream_member_database_identifier IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversation_participants', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_inserts_of_conversations AFTER INSERT ON conversations
WHEN NEW.stream_database_identifier IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversations', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_inserts_of_keyed_values AFTER INSERT ON keyed_values
WHEN NEW.seq IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('keyed_values', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_inserts_of_messages AFTER INSERT ON messages
WHEN NEW.seq IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('messages', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_inserts_of_tombstone_events AFTER INSERT ON events
WHEN NEW.type = 10
BEGIN
  DELETE FROM messages WHERE seq = NEW.target_seq AND conversation_database_identifier = (
    SELECT conversations.database_identifier FROM conversations
    WHERE conversations.stream_database_identifier = NEW.stream_database_identifier
  );
  DELETE FROM event_content_parts WHERE event_database_identifier = NEW.database_identifier;
  DELETE FROM event_metadata WHERE event_database_identifier = NEW.database_identifier;
END;

CREATE TRIGGER track_re_inserts_of_conversation_participants AFTER UPDATE OF deleted_at ON conversation_participants
WHEN NEW.seq IS NOT NULL AND NEW.seq = OLD.seq AND (NEW.deleted_at IS NULL AND OLD.deleted_at NOT NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversation_participants', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_updates_of_keyed_values AFTER UPDATE OF value ON keyed_values
WHEN ((NEW.value NOT NULL AND OLD.value IS NULL) OR (NEW.value IS NULL AND OLD.value NOT NULL) OR (NEW.value != OLD.value))
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('keyed_values', NEW.database_identifier, 1);
END;

CREATE TRIGGER track_updates_of_message_events_to_tombstone AFTER UPDATE OF type ON events
WHEN NEW.type = 10 AND OLD.type = 4
BEGIN
  DELETE FROM messages WHERE event_database_identifier = NEW.database_identifier;
  DELETE FROM event_content_parts WHERE event_database_identifier = NEW.database_identifier;
  DELETE FROM event_metadata WHERE event_database_identifier = NEW.database_identifier;
END;

