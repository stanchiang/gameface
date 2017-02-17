-------------------------------------------------------------------------------
-- Adding external content management associated data to `event_content_parts`.
-------------------------------------------------------------------------------
CREATE TABLE new_event_content_parts (
    database_identifier INTEGER PRIMARY KEY AUTOINCREMENT,
    event_content_part_id INTEGER NOT NULL,
    event_database_identifier INTEGER NOT NULL,
    type TEXT NOT NULL,
    value BLOB,
    access_expiration INTEGER,
    url TEXT,
    size INTEGER,
    transfer_status INTEGER,
    file_path TEXT,
    last_accessed DATETIME,
    purged BOOLEAN,
    FOREIGN KEY(event_database_identifier) REFERENCES events(database_identifier) ON DELETE CASCADE,
    UNIQUE(event_content_part_id, event_database_identifier)
);

-------------------------------------------------------------------------------
-- Copy transfer and other statuses from message_parts to event_contetn_parts,
-- since that's where we're going to manage it now.
-------------------------------------------------------------------------------
INSERT INTO new_event_content_parts
     SELECT NULL,                           -- for `database_identifier`
            event_content_parts.event_content_part_id,
            event_content_parts.event_database_identifier,
            event_content_parts.type,                           
            event_content_parts.value,
            CASE WHEN (message_parts.access_expiration IS NULL) THEN event_content_parts.access_expiration ELSE message_parts.access_expiration END as new_access_expiration,
            CASE WHEN (message_parts.url IS NULL) THEN event_content_parts.URL ELSE message_parts.url END as new_url,
            CASE WHEN (message_parts.size IS NULL) THEN event_content_parts.size ELSE message_parts.size END as new_size,
            message_parts.transfer_status,  -- for 'transfer_status'
            message_parts.file_path,        -- for 'file_path'
            message_parts.access_time,      -- for 'last_accessed'
            message_parts.pruned            -- for 'purged'
       FROM event_content_parts
 INNER JOIN events ON (events.database_identifier = event_content_parts.event_database_identifier)
 INNER JOIN messages ON (messages.event_database_identifier = event_content_parts.event_database_identifier)
 INNER JOIN message_parts ON (message_parts.message_database_identifier = messages.database_identifier AND (SELECT COUNT(*)-1 FROM message_parts AS counted_message_parts WHERE counted_message_parts.message_database_identifier == message_parts.message_database_identifier AND counted_message_parts.database_identifier <= message_parts.database_identifier) = event_content_parts.event_content_part_id)
   ORDER BY event_content_parts.event_database_identifier ASC, event_content_parts.event_content_part_id ASC;
  
-- Drop the original table.
DROP TABLE event_content_parts;

-- Let's make the new table to be `event_content_parts`
ALTER TABLE new_event_content_parts RENAME to event_content_parts;

-------------------------------------------------------------------------------
-- Creating a trigger that writes a synced_change on transfer status change.
-- It should only add changes if the `purged` flag hasn't changed. This is
-- usually when it transitiones from one `transfer_status` value to another.
-------------------------------------------------------------------------------
CREATE TRIGGER track_event_content_part_transfer_status_changes AFTER UPDATE OF transfer_status ON event_content_parts
WHEN NEW.transfer_status <> OLD.transfer_status AND NEW.purged = 0
BEGIN
    INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('event_content_parts', OLD._ROWID_, 1);
END;

-------------------------------------------------------------------------------
-- Creating a trigger that writes a deleted synced_change whenever
-- `event_content_parts` has been marked for purging.
-- To recognize auto-purge's action, status should be changed along with
-- value `last_accessed` being null.
-------------------------------------------------------------------------------
CREATE TRIGGER track_event_content_part_purges AFTER UPDATE OF transfer_status ON event_content_parts
WHEN NEW.transfer_status = 2 AND NEW.purged <> OLD.purged AND NEW.purged = 1 AND NEW.last_accessed IS NULL
BEGIN
    INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('event_content_parts', OLD._ROWID_, 2);
END;
