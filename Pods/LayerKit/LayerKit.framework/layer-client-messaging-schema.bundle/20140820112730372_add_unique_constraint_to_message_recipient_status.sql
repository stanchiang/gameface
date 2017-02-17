-- Adding unique constraing to message_recipient_status.

-- Drop related triggers.
DROP TRIGGER track_syncable_changes_for_message_receipts;

-- Make a copy of the original table,
-- now featured with the UNIQUE constraint!
CREATE TABLE message_recipient_status_new (
    database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    message_database_identifier INTEGER NOT NULL,
    user_id STRING,
    status INTEGER NOT NULL,
    seq INTEGER,
    UNIQUE (message_database_identifier, user_id, status),
    FOREIGN KEY(message_database_identifier) REFERENCES messages(database_identifier) ON DELETE CASCADE
);

-- Flush everything from original table to the copy.
INSERT OR IGNORE INTO message_recipient_status_new
     SELECT database_identifier,
            message_database_identifier,
            user_id,
            status,
            seq
       FROM message_recipient_status;

-- Drop the original table.
DROP TABLE message_recipient_status;

-- Let's make the copy be the original table.
ALTER TABLE message_recipient_status_new RENAME to message_recipient_status;

-- Also bring back the accompanied trigger.
CREATE TRIGGER track_syncable_changes_for_message_receipts AFTER INSERT ON message_recipient_status
WHEN NEW.seq IS NULL
BEGIN
    INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('message_recipient_status', NEW.database_identifier, 0);
END;

-- et viola!
