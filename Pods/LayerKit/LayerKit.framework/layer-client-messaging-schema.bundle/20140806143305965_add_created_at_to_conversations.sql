CREATE TABLE conversations_new (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  stream_database_identifier INTEGER UNIQUE,
  created_at DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME,
  object_identifier TEXT UNIQUE NOT NULL,
  FOREIGN KEY(stream_database_identifier) REFERENCES streams(database_identifier) ON DELETE CASCADE
);

INSERT INTO conversations_new
    SELECT  database_identifier,
            stream_database_identifier,
			CURRENT_TIMESTAMP,
            deleted_at,
            object_identifier			
    FROM    conversations;

DROP TABLE conversations;

ALTER TABLE conversations_new RENAME to conversations;

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
