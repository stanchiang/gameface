-------------------------------------------------------------------------------
-- Add fields that represent total number of messages in conversations.
-------------------------------------------------------------------------------

ALTER TABLE conversations ADD COLUMN total_message_count INTEGER NOT NULL DEFAULT 0;
ALTER TABLE conversations ADD COLUMN unread_message_count INTEGER NOT NULL DEFAULT 0;
