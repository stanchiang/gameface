--------------------------------------------------------------------------
-- Create a trigger that tracks updates to the 'distinct-ness' of a stream
--------------------------------------------------------------------------
CREATE TRIGGER track_stream_distinct_updates AFTER UPDATE OF is_distinct ON streams
WHEN NEW.is_distinct IS NOT NULL AND OLD.is_distinct IS NOT NULL AND NEW.is_distinct != OLD.is_distinct
BEGIN
INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', OLD.database_identifier, 1);
END;

-------------------------------------------------------------------------------------
-- Create a trigger that tracks updates to a conversation' stream database identifier
-------------------------------------------------------------------------------------
CREATE TRIGGER track_updates_of_stream_database_identifier_for_conversation AFTER UPDATE OF stream_database_identifier ON conversations
BEGIN
INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', NEW.stream_database_identifier, 1);
END;
