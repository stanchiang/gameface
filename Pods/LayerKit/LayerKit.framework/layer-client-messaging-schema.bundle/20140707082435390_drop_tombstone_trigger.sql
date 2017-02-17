-- Drop tombstone_deleted_events_on_delete in favor of letting InboundRecon process the EVENT_DELETED to tombstone the event.

DROP TRIGGER IF EXISTS tombstone_deleted_events_on_delete;