-------------------------------------------------------------------------------
-- Add fields that represent the partial sync hints received from the server
-- when the client performs the partial sync.
-------------------------------------------------------------------------------

ALTER TABLE streams ADD COLUMN total_message_event_count INTEGER NOT NULL DEFAULT 0;
ALTER TABLE streams ADD COLUMN unread_message_event_count INTEGER NOT NULL DEFAULT 0;
ALTER TABLE streams ADD COLUMN least_recent_unread_message_event_seq INTEGER;
ALTER TABLE streams ADD COLUMN last_message_event_received_at DATETIME;
ALTER TABLE streams ADD COLUMN last_message_event_seq INTEGER;

-------------------------------------------------------------------------------
-- Adding indexes for object identifiers.
-------------------------------------------------------------------------------

CREATE INDEX conversations_object_identifier_idx ON conversations(object_identifier);

CREATE INDEX messages_object_identifier_idx ON messages(object_identifier);
