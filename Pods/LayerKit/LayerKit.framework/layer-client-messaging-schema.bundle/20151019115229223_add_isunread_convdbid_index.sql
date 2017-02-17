-------------------------------------------------------------------------------
-- Adds a compound index on `messages` table which should improve performance
-- of unread count of messages for a given conversation.
-------------------------------------------------------------------------------

CREATE INDEX messages_conversationdbid_and_isunread_idx ON messages(conversation_database_identifier, is_unread);
