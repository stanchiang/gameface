CREATE INDEX IF NOT EXISTS messages_is_unread_idx ON messages(is_unread);

CREATE INDEX IF NOT EXISTS conversations_has_unread_messages_idx ON conversations(has_unread_messages);
