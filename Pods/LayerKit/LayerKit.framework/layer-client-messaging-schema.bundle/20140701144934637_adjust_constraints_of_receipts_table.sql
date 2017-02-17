DROP TABLE IF EXISTS message_recipient_status;

CREATE TABLE message_recipient_status (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  message_database_identifier INTEGER NOT NULL,
  user_id STRING,
  status INTEGER NOT NULL,
  seq INTEGER,
  FOREIGN KEY(message_database_identifier) REFERENCES messages(database_identifier) ON DELETE CASCADE
);

CREATE TRIGGER track_syncable_changes_for_message_receipts AFTER INSERT ON message_recipient_status
WHEN NEW.seq IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('message_recipient_status', NEW.database_identifier, 0);
END;
