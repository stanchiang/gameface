-- Switch to INSERT OR IGNORE (when the target event does not yet exist)

DROP TRIGGER track_inserts_of_events_delete;

CREATE TRIGGER track_inserts_of_events_delete AFTER INSERT ON events
WHEN NEW.seq IS NOT NULL AND NEW.type = 9
BEGIN
  INSERT OR IGNORE INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', (SELECT database_identifier FROM events WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq), 2);
  UPDATE events SET type = 10, subtype = NULL, external_content_id = NULL, member_id = NULL, target_seq = NULL, version = NULL WHERE database_identifier = (SELECT database_identifier FROM events WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq);
END;
