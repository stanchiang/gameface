-- Adding a `NOT NULL` constraint to version column in `messages` table
-- and adding the same column also to the `conversations` table.

-- Drop related triggers, to avoid errors when dropping old tables.
DROP TRIGGER track_deletes_of_conversations;

DROP TRIGGER track_inserts_of_conversations;

DROP TRIGGER track_deletes_of_messages;

DROP TRIGGER track_message_send_on_insert;

-------------------------------------
-- Modifying `conversations` table --
-------------------------------------

-- Make a copy of the conversation table, now featured with the
-- `version` column having the `NOT NULL` constraint!
CREATE TABLE new_conversations_with_version (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  stream_database_identifier INTEGER UNIQUE,
  stream_id BLOB UNIQUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME,
  object_identifier TEXT UNIQUE NOT NULL,
  version INT NOT NULL
);

-- Copy records from `conversations` to `new_conversations_with_version`,
-- also set the `version` column to `0` for every record.
INSERT INTO new_conversations_with_version
     SELECT database_identifier,
            stream_database_identifier,
            stream_id,
            created_at,
            deleted_at,
            object_identifier,
            0 -- for `version`
       FROM conversations;

-- Drop the original table.
DROP TABLE conversations;

-- Let's make the new table to be to original
ALTER TABLE new_conversations_with_version RENAME to conversations;

--------------------------------
-- Modifying `messages` table --
--------------------------------

-- Make a copy of the messages table, where its `version` table has the
-- `NOT NULL` constraint!
CREATE TABLE new_messages_with_version_constraint (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  sent_at DATETIME,
  received_at DATETIME,
  deleted_at DATETIME,
  user_id STRING NOT NULL,
  seq INTEGER,
  conversation_database_identifier INTEGER NOT NULL,
  event_database_identifier INTEGER UNIQUE,
  version INT NOT NULL,
  object_identifier TEXT UNIQUE NOT NULL,
  message_index INT,
  UNIQUE(conversation_database_identifier, seq),
  FOREIGN KEY(conversation_database_identifier) REFERENCES conversations(database_identifier) ON DELETE CASCADE,
  FOREIGN KEY(event_database_identifier) REFERENCES events(database_identifier) ON DELETE CASCADE
);

-- Copy records from `messages` to `new_messages_with_version_constraint`,
-- also set the `version` column to `0` for every record.
INSERT INTO new_messages_with_version_constraint
     SELECT database_identifier,
            created_at,
            sent_at,
            received_at,
            deleted_at,
            user_id,
            seq,
            conversation_database_identifier,
            event_database_identifier,
            0, -- for `version`
            object_identifier,
            message_index
       FROM messages;

-- Drop the original table.
DROP TABLE messages;

-- Let's make the new table to be to original
ALTER TABLE new_messages_with_version_constraint RENAME to messages;

-- Bring back triggers we dropped earlier for `conversations`
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

-- Also create triggers for the `messages` table
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
