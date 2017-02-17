-------------------------------------------------------------------------------
-- Adding a required `version` field to the `message_parts` table, setting
-- the initial values to zero.
-------------------------------------------------------------------------------

ALTER TABLE message_parts ADD version INT NOT NULL DEFAULT 0;
