-- Removing `is_draft` from messages table and `is_draft` related stuff

-- Update triggers to work without the `is_draft` column
DROP TRIGGER track_message_send_on_insert;

DROP TRIGGER track_message_send_on_update;

CREATE TRIGGER track_message_send_on_insert AFTER INSERT ON messages
WHEN NEW.seq IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('messages', NEW.database_identifier, 0);
END;

-- Backup `messages` table first, before dropping it
CREATE TABLE messages_backup (
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
  message_index INT
);

INSERT INTO messages_backup
    SELECT  database_identifier,
            created_at,
            sent_at,
            received_at,
            deleted_at,
            user_id,
            seq,
            conversation_database_identifier,
            event_database_identifier,
            version,
            object_identifier,
            message_index
    FROM    messages;

DROP TABLE messages;

-- Restore `messages` table from backup
CREATE TABLE messages (
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
  FOREIGN KEY(conversation_database_identifier) REFERENCES conversations(database_identifier) ON DELETE CASCADE,
  FOREIGN KEY(event_database_identifier) REFERENCES events(database_identifier) ON DELETE CASCADE
);

INSERT INTO messages
    SELECT  database_identifier,
            created_at,
            sent_at,
            received_at,
            deleted_at,
            user_id,
            seq,
            conversation_database_identifier,
            event_database_identifier,
            version,
            object_identifier,
            message_index
    FROM    messages_backup;

-- Dispose backup
DROP TABLE messages_backup;
