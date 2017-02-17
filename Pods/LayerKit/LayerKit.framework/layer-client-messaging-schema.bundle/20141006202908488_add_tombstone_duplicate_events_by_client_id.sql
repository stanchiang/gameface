CREATE TRIGGER tombstone_duplicate_events_by_client_id 
AFTER INSERT ON events
FOR EACH ROW WHEN NEW.client_id IS NOT NULL
BEGIN
	UPDATE events SET type = 10 
	WHERE database_identifier = NEW.database_identifier
	AND (SELECT count(*) FROM events WHERE client_id = NEW.client_id) > 1;
END;
