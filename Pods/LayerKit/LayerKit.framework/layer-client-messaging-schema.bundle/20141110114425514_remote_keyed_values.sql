-- Corresponding remote table for client `local_keyed_values`
CREATE TABLE "remote_keyed_values" (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  object_type TEXT NOT NULL,
  object_id INTEGER NOT NULL,
  key_type INTEGER NOT NULL,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  deleted_at DATETIME,
  timestamp INTEGER,
  UNIQUE(object_type, object_id, key)
);

-- Triggers inbound remote_keyed_values inserts to synced_changes
-- Uses timestamp to differentiate between inbound/outbound
CREATE TRIGGER track_inserts_of_remote_keyed_values AFTER INSERT ON remote_keyed_values
WHEN NEW.timestamp NOT NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('remote_keyed_values', NEW.database_identifier, 0);
END;

-- Triggers inbound remote_keyed_values updates to synced_changes
-- Uses timestamp to differentiate between inbound/outbound
CREATE TRIGGER track_updates_of_remote_keyed_values AFTER UPDATE OF timestamp ON remote_keyed_values
WHEN NEW.timestamp NOT NULL AND OLD.deleted_at IS NULL AND (NEW.value != OLD.value)
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('remote_keyed_values', NEW.database_identifier, 1);
END;

-- Triggers inbound remote_keyed_values deletes to synced_changes
-- Uses deleted_at to differentiate deletes
CREATE TRIGGER track_deletes_of_remote_keyed_values AFTER UPDATE OF deleted_at ON remote_keyed_values
WHEN NEW.timestamp NOT NULL AND (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('remote_keyed_values', OLD.database_identifier, 2);
END;

-- Triggers inbound deleted->inserted inserts to synced_changes
CREATE TRIGGER track_re_inserts_of_remote_keyed_values AFTER UPDATE OF deleted_at ON remote_keyed_values
WHEN NEW.timestamp NOT NULL AND (NEW.deleted_at IS NULL AND OLD.deleted_at NOT NULL)
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('remote_keyed_values', NEW.database_identifier, 0);
END;



-- Switch from event_metadata to remote_keyed_values
-- key_type 0 is TRANSIENT
INSERT INTO remote_keyed_values (object_type, object_id, key_type, key, value) 
  SELECT 'event', event_database_identifier, 0, key, value FROM event_metadata;

DROP TABLE event_metadata;

DROP TRIGGER track_updates_of_event_type_message_to_tombstone;

CREATE TRIGGER track_updates_of_event_type_message_to_tombstone AFTER UPDATE OF type ON events
WHEN NEW.type = 10 AND OLD.type = 4
BEGIN
  DELETE FROM event_content_parts WHERE event_database_identifier = NEW.database_identifier;
  DELETE FROM remote_keyed_values WHERE object_type = 'event' AND object_id = NEW.database_identifier;
END;


-- Change keyed_values to local_keyed_values
-- with: value changed from BLOB to TEXT, seq changed to timestamp
CREATE TABLE local_keyed_values (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  object_type TEXT NOT NULL,
  object_id INTEGER NOT NULL,
  key_type INTEGER NOT NULL,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  deleted_at DATETIME,
  timestamp INTEGER,
  UNIQUE(object_type, object_id, key)
);

DROP TABLE keyed_values;

CREATE TRIGGER track_inserts_of_local_keyed_values AFTER INSERT ON local_keyed_values
WHEN NEW.timestamp IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('local_keyed_values', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_updates_of_local_keyed_values AFTER UPDATE OF value ON local_keyed_values
WHEN OLD.deleted_at IS NULL AND NEW.timestamp IS NULL AND (NEW.value != OLD.value)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('local_keyed_values', NEW.database_identifier, 1);
END;

CREATE TRIGGER track_deletes_of_local_keyed_values AFTER UPDATE OF deleted_at ON local_keyed_values
WHEN NEW.timestamp IS NULL AND (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('local_keyed_values', NEW.database_identifier, 2);
END;

-- Triggers outbound deleted->inserted inserts to syncable_changes
CREATE TRIGGER track_re_inserts_of_local_keyed_values AFTER UPDATE OF deleted_at ON local_keyed_values
WHEN NEW.timestamp IS NULL AND (NEW.deleted_at IS NULL AND OLD.deleted_at NOT NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('local_keyed_values', NEW.database_identifier, 0);
END;


-- Add timestamp to streams
ALTER TABLE streams ADD metadata_timestamp INTEGER;

