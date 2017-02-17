-------------------------------------------------------------------------------
-- Making the trigger below less excited every time the conversation's
-- `stream_database_identifier` gets updated. We'll only track these changes
-- if `stream_id` is left alone.
-------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS 'track_updates_of_stream_database_identifier_for_conversation';

CREATE TRIGGER track_updates_of_stream_database_identifier_for_conversation AFTER UPDATE OF stream_database_identifier ON conversations
WHEN (OLD.stream_id IS NULL AND NEW.stream_id IS NULL) OR OLD.stream_id = NEW.stream_id
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', NEW.stream_database_identifier, 1);
END;