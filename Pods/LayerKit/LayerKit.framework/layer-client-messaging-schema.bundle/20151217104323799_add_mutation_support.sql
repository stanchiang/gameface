---------------------------------------------------------------------------------------
-- Add `deletion_mode` property to conversations
---------------------------------------------------------------------------------------

ALTER TABLE conversations ADD COLUMN deletion_mode INTEGER DEFAULT 0;

---------------------------------------------------------------------------------------
-- Add `deletion_mode` property to messages
---------------------------------------------------------------------------------------

ALTER TABLE messages ADD COLUMN deletion_mode INTEGER DEFAULT 0;

---------------------------------------------------------------------------------------
-- Add `deletion_mode` property to streams
---------------------------------------------------------------------------------------

ALTER TABLE streams ADD COLUMN deletion_mode INTEGER DEFAULT 0;

---------------------------------------------------------------------------------------
-- Add `deletion_mode` property to events
---------------------------------------------------------------------------------------

ALTER TABLE events ADD COLUMN deletion_mode INTEGER DEFAULT 0;

----------------------------------
-- Create `remote_mutations` table
----------------------------------

CREATE TABLE "mutations" (
    database_identifier INTEGER PRIMARY KEY AUTOINCREMENT,
    seq INTEGER,
    type INTEGER NOT NULL,
    target INTEGER NOT NULL,
    stream_id BLOB NOT NULL,
    target_seq INTEGER NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    stream_database_identifier,
    event_database_identifier,
    is_synchronized BOOL,
    FOREIGN KEY(stream_database_identifier) REFERENCES streams(database_identifier) ON DELETE CASCADE
);

-------------------------------------------
-- Remove `deleted_at` triggers
-- Remove `deleted_at` indexes
-------------------------------------------

DROP TRIGGER IF EXISTS track_deletes_of_conversations;
DROP TRIGGER IF EXISTS track_deletes_of_messages;
DROP TRIGGER IF EXISTS track_deletes_of_streams;

-------------------------------------------
-- Add triggers for `deletion mode` updates
-- Add trigger for `mutation` insert
-- Add trigger for `mutation` update
-------------------------------------------

CREATE TRIGGER track_deletes_of_streams AFTER UPDATE OF deletion_mode ON streams
WHEN NEW.deletion_mode = 2
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', OLD.database_identifier, 2);
END;

CREATE TRIGGER track_deletions_of_conversations AFTER UPDATE OF deletion_mode ON conversations
WHEN NEW.deletion_mode != 0
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversations', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_global_deletions_of_messages AFTER UPDATE OF deletion_mode ON messages
WHEN NEW.deletion_mode == 2
AND (SELECT deletion_mode FROM conversations WHERE database_identifier = NEW.conversation_database_identifier) = 0
BEGIN
INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('messages', NEW.database_identifier, 2);
END;

---------------------------------------------------------------------------------------------
-- The following trigger only produces a syncable change under the below scenarios.
-- 1. The conversation has NOT already been deleted AND
-- 2a. There is no target_seq for a stream mutation OR
-- 2b. The messages seq is greater that the latest target_seq for a stream deletion mutation.
----------------------------------------------------------------------------------------------

CREATE TRIGGER track_sync_deletions_of_messages AFTER UPDATE OF deletion_mode ON messages
WHEN NEW.deletion_mode == 1
AND (SELECT deletion_mode FROM conversations WHERE database_identifier = NEW.conversation_database_identifier) = 0
AND (NOT EXISTS (SELECT target_seq FROM mutations WHERE target = 2 AND stream_id = (SELECT stream_id FROM conversations WHERE database_identifier = NEW.conversation_database_identifier))
OR (SELECT target_seq FROM mutations WHERE target = 2 AND stream_id = (SELECT stream_id FROM conversations WHERE database_identifier = NEW.conversation_database_identifier) ORDER BY seq DESC LIMIT 1) < NEW.seq)
BEGIN
INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('messages', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_inserts_of_mutations AFTER INSERT ON mutations
WHEN NEW.is_synchronized = 1
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('mutations', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_updates_of_mutations AFTER UPDATE OF is_synchronized ON mutations
WHEN NEW.is_synchronized = 1 AND OLD.is_synchronized = 0
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('mutations', NEW.database_identifier, 0);
END;

-------------------------------------------
-- Add IDX for `deletion_mode
-------------------------------------------

CREATE INDEX conversations_deletion_mode_idx ON conversations(deletion_mode);
CREATE INDEX messages_deletion_mode_idx ON messages(deletion_mode);
CREATE INDEX streams_deletion_mode_idx ON streams(deletion_mode);