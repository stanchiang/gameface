-- Must retain creator_id in event for ordering

DROP TRIGGER IF EXISTS tombstone_deleted_events_on_delete;

CREATE TRIGGER tombstone_deleted_events_on_delete AFTER INSERT ON events
WHEN NEW.type = 9
BEGIN
  UPDATE events SET type = 10, subtype = NULL, external_content_id = NULL, member_id = NULL, target_seq = NULL, version = NULL
  WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq;
END;
