-------------------------------------------------------------------------------
-- The purpose of this migration is to drop the `fetched`, `requested` and
-- `uploaded` flags in favor of `transfer_status`.
-- 
-- Migration uses the existing data to form the correct `transfer_status`.
-------------------------------------------------------------------------------

-- Backup `message_parts` table first, before dropping it
CREATE TABLE message_parts_backup (
    database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    message_database_identifier INTEGER NOT NULL,
    mime_type TEXT NOT NULL,
    content BLOB,
    url TEXT,
    access_expiration INTEGER,
    fetched BOOLEAN,
    requested BOOLEAN,
    file_path TEXT,
    size INTEGER,
    uploaded BOOLEAN,
    access_time DATETIME,
    object_identifier TEXT,
    pruned BOOLEAN
);

INSERT INTO message_parts_backup
     SELECT database_identifier,
            message_database_identifier,
            mime_type,
            content,
            url,
            access_expiration,
            fetched,
            requested,
            file_path,
            size,
            uploaded,
            access_time,
            object_identifier,
            pruned
       FROM message_parts;

DROP TABLE message_parts;

-- Restore `message_parts` table from backup
CREATE TABLE message_parts (
    database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    message_database_identifier INTEGER NOT NULL,
    mime_type TEXT NOT NULL,
    content BLOB,
    url TEXT,
    access_expiration INTEGER,
    file_path TEXT,
    size INTEGER,
    access_time DATETIME,
    object_identifier TEXT,
    pruned BOOLEAN,
    transfer_status INTEGER,
    FOREIGN KEY(message_database_identifier) REFERENCES messages(database_identifier) ON DELETE CASCADE
);

INSERT INTO message_parts
     SELECT database_identifier,
            message_database_identifier,
            mime_type,
            content,
            url,
            access_expiration,
            file_path,
            size,
            access_time,
            object_identifier,
            pruned,
            CASE WHEN url IS NULL AND (uploaded = 0 OR uploaded IS NULL) THEN 0
                 WHEN url IS NOT NULL AND (uploaded = 0 OR uploaded IS NULL) THEN 1
                 WHEN uploaded = 1 AND fetched = 0 AND requested = 0 THEN 2
                 WHEN uploaded = 1 AND fetched = 0 AND requested = 1 THEN 3
                 WHEN uploaded = 1 AND fetched = 1 THEN 4
                 ELSE 2 -- default
                 END
       FROM message_parts_backup;

-- Mapping from flags to transfer status:
--      URL null,   uploaded = 0,                      -> LYRContentTransferAwaitingUpload     = 0
--      URL !null,  uploaded = 0                       -> LYRContentTransferUploading          = 1
--      uploaded = 1, fetched = 0, requested = 0       -> LYRContentTransferReadyForDownload   = 2
--      uploaded = 1, fetched = 0, requested = 1       -> LYRContentTransferDownloading        = 3
--      uploaded = 1, fetched = 1                      -> LYRContentTransferComplete           = 4

-- Dispose backup
DROP TABLE message_parts_backup;
