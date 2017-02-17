-- The purpose of this migration is to add the `deleted_at` column to both
-- `streams` and `stream_members` table and also giving the `stream_members`
-- table the `seq` column.
--
-- `stream_members` also gets the `database_identifier`, since it's going
-- to be used to reference when query which stream member got deleted
-- when making mutations on objects in memory.
--
-- This way triggers can recognize if the mutation is coming from the
-- inbound or outbound reconciliation operation based on the values
-- of those two columns.
--
-- For questions: klemen@layer.com

--------------------------------------------------
-- Modifying `streams` table and delete trigger --
--------------------------------------------------

-- Add `deleted_at` column to `streams`
ALTER TABLE streams ADD COLUMN deleted_at DATETIME;

-- Track updates on `streams` when `deleted_at` transitions
-- from NULL to a defined value, and at the same time delete the stream
-- that the `deleted_at` update was performed on.
DROP TRIGGER track_deletes_of_streams;

CREATE TRIGGER track_deletes_of_streams AFTER UPDATE OF deleted_at ON streams
WHEN NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('streams', OLD.database_identifier, 2);
END;

---------------------------------------------------------
-- Modifying `stream_members` table and delete trigger --
---------------------------------------------------------

-- First, disable triggers that `track stream_members mutations`
DROP TRIGGER track_inserts_of_stream_members;

DROP TRIGGER track_deletes_of_stream_members;

-- Make a new copy of the `new_stream_members` table, now featuring the
-- `database_identifier`, `deleted_at` and `seq`.
CREATE TABLE new_stream_members (
  database_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  stream_database_identifier INTEGER NOT NULL,
  member_id STRING NOT NULL,
  deleted_at DATETIME,
  seq INTEGER,
  UNIQUE (stream_database_identifier, member_id),
  FOREIGN KEY(stream_database_identifier) REFERENCES streams(database_identifier) ON DELETE CASCADE
);

-- Copy records from `stream_members` to `new_stream_members`.
INSERT INTO new_stream_members
     SELECT NULL,                           -- for `database_identifier`
            stream_database_identifier,
            member_id,
            NULL,                           -- for `deleted_at`
            0                               -- for `seq`
       FROM stream_members;

-- Drop the original table.
DROP TABLE stream_members;

-- Let's make the new table to be `stream_members`
ALTER TABLE new_stream_members RENAME to stream_members;

-- Track inserts on `stream_members` where `seq` is defined, indicating that
-- the mutation came from the inbound reconciliation operation.
CREATE TRIGGER track_inserts_of_stream_members AFTER INSERT ON stream_members
WHEN NEW.seq IS NOT NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('stream_members', NEW._ROWID_, 0);
END;

-- Track updates on `stream_members` when `deleted_at` transitions
-- from NULL to a defined value, and at the same time delete the stream member
-- that the `deleted_at` update was performed on.
CREATE TRIGGER track_deletes_of_stream_members AFTER UPDATE OF deleted_at ON stream_members
WHEN NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL
BEGIN
  INSERT INTO synced_changes(table_name, row_identifier, change_type) VALUES ('stream_members', OLD._ROWID_, 2);
END;
