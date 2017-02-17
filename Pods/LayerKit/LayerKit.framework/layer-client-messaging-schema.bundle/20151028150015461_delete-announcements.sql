-------------------------------------------------------------------------------
-- This migration takes care of the corrupted data in the database potentially
-- caused by the announcements / distinc conversation bug in LayerKit
-- versions <=v0.17.0 && >=v0.15.0.
--
-- JIRA ticket: APPS-2164
-- Contact: klemen@layer.com for more insight on this issue.
-------------------------------------------------------------------------------

-- (1) Drop all triggers.
DROP TRIGGER IF EXISTS 'track_deletes_of_conversations';
DROP TRIGGER IF EXISTS 'track_inserts_of_conversations';
DROP TRIGGER IF EXISTS 'track_deletes_of_conversation_participants';
DROP TRIGGER IF EXISTS 'track_inserts_of_conversation_participants';
DROP TRIGGER IF EXISTS 'track_re_inserts_of_conversation_participants';
DROP TRIGGER IF EXISTS 'track_syncable_changes_for_message_receipts';
DROP TRIGGER IF EXISTS 'track_deletes_of_stream_members';
DROP TRIGGER IF EXISTS 'track_inserts_of_stream_members';
DROP TRIGGER IF EXISTS 'track_inserts_of_remote_keyed_values';
DROP TRIGGER IF EXISTS 'track_updates_of_remote_keyed_values';
DROP TRIGGER IF EXISTS 'track_deletes_of_remote_keyed_values';
DROP TRIGGER IF EXISTS 'track_re_inserts_of_remote_keyed_values';
DROP TRIGGER IF EXISTS 'track_inserts_of_local_keyed_values';
DROP TRIGGER IF EXISTS 'track_updates_of_local_keyed_values';
DROP TRIGGER IF EXISTS 'track_deletes_of_local_keyed_values';
DROP TRIGGER IF EXISTS 'track_re_inserts_of_local_keyed_values';
DROP TRIGGER IF EXISTS 'track_deletes_of_messages';
DROP TRIGGER IF EXISTS 'track_message_send_on_insert';
DROP TRIGGER IF EXISTS 'tombstone_duplicate_events_by_client_id';
DROP TRIGGER IF EXISTS 'track_inserts_of_events_delete';
DROP TRIGGER IF EXISTS 'track_inserts_of_events_non_delete';
DROP TRIGGER IF EXISTS 'track_updates_of_event_seqs';
DROP TRIGGER IF EXISTS 'track_updates_of_event_type_message_to_tombstone';
DROP TRIGGER IF EXISTS 'track_updates_of_stream_id_for_events';
DROP TRIGGER IF EXISTS 'track_deletes_of_streams';
DROP TRIGGER IF EXISTS 'track_inserts_of_streams';
DROP TRIGGER IF EXISTS 'track_updates_of_streams';
DROP TRIGGER IF EXISTS 'track_event_content_part_transfer_status_changes';
DROP TRIGGER IF EXISTS 'track_event_content_part_purges';
DROP TRIGGER IF EXISTS 'track_stream_distinct_updates';
DROP TRIGGER IF EXISTS 'track_updates_of_stream_database_identifier_for_conversation';

-- (2) Delete all conversations where it's corresponding stream constrains
--     only one participant. Messages / announcements should be taken care
--     of by the cascade delete.
-------------------------------------------------------------------------------
-- SELECT conversations.database_identifier,
--        conversations.object_identifier,
--        conversations.stream_database_identifier,
--        conversations.type,
--        (SELECT DISTINCT stream_members.stream_database_identifier FROM stream_members WHERE stream_members.stream_database_identifier = conversations.stream_database_identifier GROUP BY stream_members.stream_database_identifier HAVING COUNT(stream_members.stream_database_identifier) = 1) AS single_participant_stream_database_identifier
-- FROM conversations
-- WHERE conversations.database_identifier = single_participant_stream_database_identifier;
--
-- Keeping this sippet here -- useful for debugging ^^^ Querying for
-- conversations where it's associated stream has just one member.
-------------------------------------------------------------------------------
DELETE FROM conversations WHERE stream_database_identifier IN (
  SELECT DISTINCT stream_members.stream_database_identifier
  FROM stream_members
  GROUP BY stream_members.stream_database_identifier
  HAVING COUNT(stream_members.stream_database_identifier) = 1
);

-- (3) Delete all streams that have only one member in them. Events should be
--     taken care of by the cascade delete.
-------------------------------------------------------------------------------
-- SELECT streams.database_identifier,
--        streams.type,
--        HEX(streams.client_id),
--        (SELECT DISTINCT stream_members.stream_database_identifier FROM stream_members WHERE stream_members.stream_database_identifier = streams.database_identifier GROUP BY stream_members.stream_database_identifier HAVING COUNT(stream_members.stream_database_identifier) = 1) AS single_participant_stream_database_identifier
-- FROM streams
-- WHERE database_identifier = single_participant_stream_database_identifier;
--
-- Also keeping this sippet here -- useful for debugging ^^^ Querying for
-- streams with just one member in em.
-------------------------------------------------------------------------------
DELETE FROM streams WHERE database_identifier IN (
  SELECT DISTINCT stream_members.stream_database_identifier
  FROM stream_members
  GROUP BY stream_members.stream_database_identifier
  HAVING COUNT(stream_members.stream_database_identifier) = 1
);

-- (4) Rebuild all triggers.
CREATE TRIGGER tombstone_duplicate_events_by_client_id
AFTER INSERT ON events
FOR EACH ROW WHEN NEW.client_id IS NOT NULL
BEGIN
  UPDATE events SET type = 10
  WHERE database_identifier = NEW.database_identifier
  AND (SELECT count(*) FROM events WHERE client_id = NEW.client_id) > 1;
END;

CREATE TRIGGER track_deletes_of_conversation_participants AFTER UPDATE OF deleted_at ON conversation_participants
WHEN NEW.seq IS OLD.seq AND (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversation_participants', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_deletes_of_conversations AFTER UPDATE OF deleted_at ON conversations
WHEN (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversations', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_deletes_of_local_keyed_values AFTER UPDATE OF deleted_at ON local_keyed_values
WHEN NEW.timestamp IS NULL AND (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('local_keyed_values', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_deletes_of_messages AFTER UPDATE OF deleted_at ON messages
WHEN (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('messages', NEW.database_identifier, 2);
END;

CREATE TRIGGER track_deletes_of_remote_keyed_values AFTER UPDATE OF deleted_at ON remote_keyed_values
WHEN NEW.timestamp NOT NULL AND (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('remote_keyed_values', OLD.database_identifier, 2);
END;

CREATE TRIGGER track_deletes_of_stream_members AFTER UPDATE OF deleted_at ON stream_members
WHEN NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('stream_members', OLD._ROWID_, 2);
END;

CREATE TRIGGER track_deletes_of_streams AFTER UPDATE OF deleted_at ON streams
WHEN NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', OLD.database_identifier, 2);
END;

CREATE TRIGGER track_event_content_part_purges AFTER UPDATE OF transfer_status ON event_content_parts
WHEN NEW.transfer_status = 2 AND NEW.purged <> OLD.purged AND NEW.purged = 1 AND NEW.last_accessed IS NULL
BEGIN
    INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('event_content_parts', OLD._ROWID_, 2);
END;

CREATE TRIGGER track_event_content_part_transfer_status_changes AFTER UPDATE OF transfer_status ON event_content_parts
WHEN NEW.transfer_status <> OLD.transfer_status AND NEW.purged = 0
BEGIN
    INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('event_content_parts', OLD._ROWID_, 1);
END;

CREATE TRIGGER track_inserts_of_conversation_participants AFTER INSERT ON conversation_participants
WHEN NEW.stream_member_database_identifier IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversation_participants', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_inserts_of_conversations AFTER INSERT ON conversations
WHEN NEW.stream_database_identifier IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversations', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_inserts_of_events_delete
AFTER INSERT ON events FOR EACH ROW
WHEN NEW.seq IS NOT NULL AND NEW.type = 9 AND NOT EXISTS (SELECT 1 FROM events WHERE client_id = NEW.client_id AND database_identifier != NEW.database_identifier)
BEGIN
  INSERT OR IGNORE INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', (SELECT database_identifier FROM events WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq), 2);
  UPDATE events SET type = 10, subtype = NULL, external_content_id = NULL, member_id = NULL, target_seq = NULL WHERE database_identifier = (SELECT database_identifier FROM events WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq);
END;

CREATE TRIGGER track_inserts_of_events_non_delete
AFTER INSERT ON events FOR EACH ROW
WHEN NEW.seq IS NOT NULL AND NEW.type != 9 AND NOT EXISTS (SELECT 1 FROM events WHERE client_id = NEW.client_id AND database_identifier != NEW.database_identifier)
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_inserts_of_local_keyed_values AFTER INSERT ON local_keyed_values
WHEN NEW.timestamp IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('local_keyed_values', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_inserts_of_remote_keyed_values AFTER INSERT ON remote_keyed_values
WHEN NEW.timestamp NOT NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('remote_keyed_values', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_inserts_of_stream_members AFTER INSERT ON stream_members
WHEN NEW.seq IS NOT NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('stream_members', NEW._ROWID_, 0);
END;

CREATE TRIGGER track_inserts_of_streams AFTER INSERT ON streams
WHEN NEW.stream_id IS NOT NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_message_send_on_insert AFTER INSERT ON messages
WHEN NEW.seq IS NULL
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('messages', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_re_inserts_of_conversation_participants AFTER UPDATE OF deleted_at ON conversation_participants
WHEN NEW.seq IS NOT NULL AND NEW.seq = OLD.seq AND (NEW.deleted_at IS NULL AND OLD.deleted_at NOT NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('conversation_participants', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_re_inserts_of_local_keyed_values AFTER UPDATE OF deleted_at ON local_keyed_values
WHEN NEW.timestamp IS NULL AND (NEW.deleted_at IS NULL AND OLD.deleted_at NOT NULL)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('local_keyed_values', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_re_inserts_of_remote_keyed_values AFTER UPDATE OF deleted_at ON remote_keyed_values
WHEN NEW.timestamp NOT NULL AND (NEW.deleted_at IS NULL AND OLD.deleted_at NOT NULL)
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('remote_keyed_values', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_stream_distinct_updates AFTER UPDATE OF is_distinct ON streams
WHEN NEW.is_distinct IS NOT NULL AND OLD.is_distinct IS NOT NULL AND NEW.is_distinct != OLD.is_distinct
BEGIN
INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', OLD.database_identifier, 1);
END;

CREATE TRIGGER track_syncable_changes_for_message_receipts AFTER INSERT ON message_recipient_status
WHEN NEW.seq IS NULL
BEGIN
    INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('message_recipient_status', NEW.database_identifier, 0);
END;

CREATE TRIGGER track_updates_of_event_seqs AFTER UPDATE OF seq ON events
WHEN NEW.seq IS NOT NULL AND OLD.seq IS NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', NEW.database_identifier, 1);
END;

CREATE TRIGGER track_updates_of_event_type_message_to_tombstone AFTER UPDATE OF type ON events
WHEN NEW.type = 10 AND OLD.type = 4
BEGIN
  DELETE FROM event_content_parts WHERE event_database_identifier = NEW.database_identifier;
  DELETE FROM remote_keyed_values WHERE object_type = 'event' AND object_id = NEW.database_identifier;
END;

CREATE TRIGGER track_updates_of_local_keyed_values AFTER UPDATE OF value ON local_keyed_values
WHEN OLD.deleted_at IS NULL AND NEW.timestamp IS NULL AND (NEW.value != OLD.value)
BEGIN
  INSERT INTO syncable_changes(table_name, row_identifier, change_type) VALUES ('local_keyed_values', NEW.database_identifier, 1);
END;

CREATE TRIGGER track_updates_of_remote_keyed_values AFTER UPDATE OF timestamp ON remote_keyed_values
WHEN NEW.timestamp NOT NULL AND OLD.deleted_at IS NULL AND (NEW.value != OLD.value)
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('remote_keyed_values', NEW.database_identifier, 1);
END;

CREATE TRIGGER track_updates_of_stream_database_identifier_for_conversation AFTER UPDATE OF stream_database_identifier ON conversations
BEGIN
INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', NEW.stream_database_identifier, 1);
END;

CREATE TRIGGER track_updates_of_stream_id_for_events AFTER UPDATE OF stream_database_identifier ON events
WHEN NEW.stream_database_identifier IS NOT NULL AND OLD.stream_database_identifier IS NOT NULL AND NEW.stream_database_identifier != OLD.stream_database_identifier
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('events', NEW.database_identifier, 1);
END;

CREATE TRIGGER track_updates_of_streams AFTER UPDATE OF stream_id ON streams
WHEN NEW.stream_id IS NOT NULL AND OLD.stream_id IS NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', NEW.database_identifier, 1);
END;
