-- foreign key indices

CREATE INDEX conversation_participants_conversation_database_identifier_idx ON conversation_participants(conversation_database_identifier);

CREATE INDEX conversation_participants_event_database_identifier_idx ON conversation_participants(event_database_identifier);

CREATE INDEX event_content_parts_event_database_identifier_idx ON event_content_parts(event_database_identifier);

CREATE INDEX event_metadata_event_database_identifier_idx ON event_metadata(event_database_identifier);

CREATE INDEX events_stream_database_identifier_idx ON events(stream_database_identifier);

CREATE INDEX message_parts_message_database_identifier_idx ON message_parts(message_database_identifier);

CREATE INDEX message_recipient_status_message_database_identifier_idx ON message_recipient_status(message_database_identifier);

CREATE INDEX messages_conversation_database_identifier_idx ON messages(conversation_database_identifier);

CREATE INDEX messages_event_database_identifier_idx ON messages(event_database_identifier);

CREATE INDEX stream_members_stream_database_identifier_idx ON stream_members(stream_database_identifier);


-- foreign key-like indices

CREATE INDEX conversations_stream_database_identifier_idx ON conversations(stream_database_identifier);


-- other helpful indices

CREATE INDEX events_seq_idx ON events(seq);

CREATE INDEX messages_message_index_idx ON messages(message_index);

CREATE INDEX synced_changes_table_name_idx ON synced_changes(table_name);


-- deleted_at indices

CREATE INDEX conversation_participants_deleted_at_idx ON conversation_participants(deleted_at);

CREATE INDEX conversations_deleted_at_idx ON conversations(deleted_at);

CREATE INDEX messages_deleted_at_idx ON messages(deleted_at);

CREATE INDEX stream_members_deleted_at_idx ON stream_members(deleted_at);

CREATE INDEX streams_deleted_at_idx ON streams(deleted_at);


-- analyze

ANALYZE sqlite_master;

ANALYZE;
