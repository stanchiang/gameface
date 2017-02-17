-------------------------------------------------------------------------------
-- This migration adds support for data import.
--
-- JIRA ticket: APPS-2193
-- Contact: kevin@layer.com for more insight on this issue.
-------------------------------------------------------------------------------

ALTER TABLE streams ADD starting_seq INTEGER;

-- Streams can get new historical data after they have been created.
-- We need to track if the starting_seq changes.
CREATE TRIGGER track_updates_of_starting_seq AFTER UPDATE OF starting_seq ON streams
WHEN OLD.starting_seq IS NULL AND NEW.starting_seq IS NOT NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', NEW.database_identifier, 1);
END;


-- We don't publish updates to recipient_status for historic messages. We need to adjust the trigger to ensure
-- syncable changes are generated for only non-historic messages (i.e. seq > 0).
DROP TRIGGER IF EXISTS 'track_syncable_changes_for_message_receipts';

CREATE TRIGGER track_syncable_changes_for_message_receipts AFTER INSERT ON message_recipient_status
WHEN NEW.seq IS NULL AND ((SELECT seq FROM messages WHERE database_identifier = NEW.message_database_identifier) >= 0 OR (SELECT seq FROM messages WHERE database_identifier = NEW.message_database_identifier) IS NULL)
BEGIN
    INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('message_recipient_status', NEW.database_identifier, 0);
END;