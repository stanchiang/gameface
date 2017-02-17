-- The purpose of this migration is to add the support for external content.
-- Briefly: `message_parts` table gets a lot of BOOLEAN flags to keep track
-- of the external content states; `message_parts` also keeps a record of
-- where the external content file is located locally on the device, and
-- where the it's located on the network (along with an expiration date).
--
-- For questions: doug@layer.com

ALTER TABLE message_parts ADD access_expiration INTEGER;

ALTER TABLE message_parts ADD fetched BOOLEAN;

ALTER TABLE message_parts ADD requested BOOLEAN;

ALTER TABLE message_parts ADD file_path TEXT;

ALTER TABLE message_parts ADD size INTEGER;

ALTER TABLE message_parts ADD uploaded BOOLEAN;

ALTER TABLE message_parts ADD access_time DATETIME;

ALTER TABLE message_parts ADD object_identifier TEXT;

ALTER TABLE message_parts ADD pruned BOOLEAN;

ALTER TABLE event_content_parts ADD access_expiration INTEGER;

ALTER TABLE event_content_parts ADD url TEXT;

ALTER TABLE event_content_parts ADD size INTEGER;

-- The UPDATE below will fill out `message_parts` `object_identifier` fields
-- based on message's `object_identifier` and the index of the part.

UPDATE message_parts SET object_identifier = (SELECT messages.object_identifier FROM messages WHERE messages.database_identifier = message_parts.message_database_identifier) || '/parts/' || (SELECT COUNT(*)-1 FROM message_parts AS counted_message_parts WHERE counted_message_parts.message_database_identifier == message_parts.message_database_identifier AND counted_message_parts.database_identifier <= message_parts.database_identifier),
                         size = LENGTH(message_parts.content), 
                         uploaded = 1,
                         fetched = 1;

CREATE TABLE "deleted_message_parts" (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  file_path TEXT
);

CREATE TRIGGER track_deletes_of_message_parts AFTER DELETE ON message_parts
WHEN OLD.file_path NOT NULL
BEGIN
  INSERT INTO deleted_message_parts(file_path) VALUES (OLD.file_path);
END;

-- This migration also recognizes events that couldn't be received and
-- reconciled on older clients (<= 0.9.2). It basically looks for tombstone
-- events with eventType=EventType_TOMBSTONE (10) and
-- eventSubType=SUBTYPE_INCOMPATIBLE (255).
--
-- References:
-- JIRA Ticket - https://layerhq.atlassian.net/browse/APPS-839
-- Protocol changes - https://github.com/layerhq/lyr-thrift-common/commit/1ced112c63e46abbae8f42a75e088b030c3c106e
-- TMC changes https://github.com/layerhq/tmc/pull/216/files
--
-- Questions: klemen@layer.com

-- Delete any messages that shouldn't get reconciled previously.
DELETE FROM messages WHERE messages.database_identifier IN (
     SELECT messages.database_identifier
       FROM messages
  LEFT JOIN events ON messages.event_database_identifier = events.database_identifier
      WHERE events.type = 10 AND events.subtype = 255);

-- Delete the tombstoned events
DELETE FROM events WHERE events.type = 10 AND events.subtype = 255;

-- Clear out non-reconcilable synced changes.
DELETE FROM synced_changes WHERE synced_changes.change_identifier IN (
     SELECT synced_changes.change_identifier
       FROM synced_changes
  LEFT JOIN events ON synced_changes.row_identifier = events.database_identifier
      WHERE synced_changes.table_name = 'events' AND events.database_identifier IS NULL);
