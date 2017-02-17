-- Create or alter tables

CREATE TRIGGER track_updates_of_stream_id_for_events AFTER UPDATE OF stream_database_identifier ON events
WHEN NEW.stream_database_identifier IS NOT NULL AND OLD.stream_database_identifier IS NOT NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', NEW.database_identifier, 1);
END;